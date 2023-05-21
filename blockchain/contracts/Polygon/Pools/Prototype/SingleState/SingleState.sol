// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "blockchain/contracts/Polygon/Pools/Prototype/Utils.sol";
import "blockchain/contracts/Polygon/ERC20Standards/Tokens/SimpleToken.sol" as SimpleTokenContract;
import "blockchain/contracts/Polygon/Finance/Oracle.sol";

interface ISingleState {
    /** proxy compatible . anyone can still call without proxy */
    function createNewPool(bytes memory args) external payable returns (bool);
    function contribute(bytes memory args) external payable returns (bool);
    function withdraw(bytes memory args) external returns (bool);

    event NewPoolCreated(
        address indexed creator,
        string name,
        address[] managers,
        string nameToken,
        string symbolToken,
        uint256 durationSeconds,
        uint256 requiredInMatic,
        bool isWhitelisted
    );

    event Contribution(
        address indexed contributor,
        string name,
        uint256 contribution,
        uint256 amountMinted
    );

    event Withdrawal(
        address indexed withdrawer,
        string name,
        uint256 amountBurnt,
        uint256 withdraw
    );
}

contract SingleState is ISingleState, Ownable, ReentrancyGuard {
    struct Tracker {uint256 numberOfPools;} Tracker public tracker;
    struct InitialFundingSchedule {
        uint256 startTimestamp;
        uint256 durationSeconds;
        uint256 requiredInMatic;
        bool isWhitelisted;
        bool success;
    }
    /** can only do this for assets we can get the price of */
    struct CollatTSchedule {
        uint256 startTimestamp;
        uint256 remainingTime;
        uint256 collateralInMatic;
        bool complete;
    }

    struct Asset {
        address contractToken;
        uint256 balanceOf;
    }
    
    struct Pool {
        uint256 id;
        string name;
        InitialFundingSchedule initialFundingSchedule;
        SimpleTokenContract.SimpleToken simpleToken;
        uint256 numberOfCollatTSchedules;
        uint256 nav;
        /** assets */
        uint256 balanceInMatic;
        address[] contracts;
        uint256[] amounts;
    }

    mapping(uint256 => Pool) public pools;
    mapping(uint256 => mapping(uint256 => CollatTSchedule)) public poolsCollatTSchedules;
    /** roles */
    struct Account {
        bool[] isAdmin;
        bool[] isCreator;
        bool[] isManager;
        bool[] isOnWhitelist;
    }

    mapping(address => Account) internal accounts;

    struct Settings {
        uint256 priceToCreateNewPool;
        uint256 feeToContribute;
        uint256 feeToWithdraw;
        address dreamToken;
        address safe;
    }
    
    Settings public settings;

    constructor() Ownable() {}

    /*---------------------------------------------------------------- PRIVATE **/
    function _connect(address obj, string memory signature, bytes memory args) internal {}

    function _checkIsManagerOf(uint256 id) internal returns (bool) {
        Account memory caller = accounts[msg.sender];
        if (caller.isManager[id]) {
            return true;
        } 
        
        return false;
    }
    /** key issues what happens if a contracts is not found */
    function _getNetAssetValueOf(bytes memory args) internal returns (uint256) {
        (address oracle, uint256 id) = abi.decode(args, (address, uint256));
        Pool memory pool = pools[id];
        uint256 sum;
        /** for each asset in the pool */
        for (uint256 i = 0; i < pool.contracts.length; i++) {
            address contract_ = pool.contracts[i];
            address[] contract__;
            contract__[0] = contract_;
            uint256 amount = pool.amounts[i];
            args = abi.encode(contract_);
            bool isVerified = IOracle(oracle).isVerifiedInUSD(args);
            if (isVerified) {
                uint256[] memory price = IOracle(oracle).getContractsToValuesUSD(
                    abi.encode(
                        contract__
                    )
                );

                sum += amount * price[0];
            } else {
                /** do something if not verified */
            }
        }
        /** will return zero if nothing was found */
        return sum;
    }

    /*---------------------------------------------------------------- PUBLIC **/
    /** proxy compatible */
    function createNewPool(bytes memory args) public payable nonReentrant returns (bool) {
        (
            string memory name,
            address[] memory managers,
            string memory nameToken,
            string memory symbolToken,
            uint256 durationSeconds,
            uint256 requiredInMatic,
            bool isWhitelisted
        ) = abi.decode(
            args,
            (
                string,
                address[],
                string,
                string,
                uint256,
                uint256,
                bool
            )
        );

        require(
            durationSeconds >= 604800 seconds,
            "SingleState::createNewPool: durationSeconds < 604800 seconds"
        );

        require(
            requiredInMatic >= 0,
            "SingleState::createNewPool: requiredInMatic < 0"
        );
        /** if there is a cost then execute */
        if (settings.priceToCreateNewPool > 0) {
            IERC20(settings.dreamToken).transferFrom(
                msg.sender,
                settings.safe,
                settings.priceToCreateNewPool
            );
        }
        /** generate new id and deploy new token contract */
        require(
            tracker.numberOfPools < type(uint256).max,
            "SingleState::createNewPool: tracker.numberOfPools >= type(uint256).max"
        );

        tracker.numberOfPools ++;

        uint256 id = tracker.numberOfPools;
        SimpleTokenContract.SimpleToken simpleToken = new SimpleTokenContract.SimpleToken(nameToken, symbolToken);
        uint256 now_ = block.timestamp;
        /** generate initial funding schedule */
        InitialFundingSchedule memory newInitialFundingSchedule;
        newInitialFundingSchedule.startTimestamp = now_;
        newInitialFundingSchedule.durationSeconds = durationSeconds;
        newInitialFundingSchedule.requiredInMatic = requiredInMatic;
        newInitialFundingSchedule.isWhitelisted = isWhitelisted;
        newInitialFundingSchedule.success = false;
        /** generate new pool */
        Pool memory newPool;
        newPool.id = id;
        newPool.name = name;
        newPool.balanceInMatic = msg.value;
        newPool.initialFundingSchedule = newInitialFundingSchedule;
        newPool.simpleToken = simpleToken;
        newPool.nav = 0;

        pools[id] = newPool;

        /** set managers and give whitelist permission */
        for (uint256 i = 0; i < managers.length; i++) {
            Account memory manager = accounts[managers[i]];
            manager.isManager[id] = true;
            manager.isOnWhitelist[id] = true;
            accounts[managers[i]] = manager;
        }

        emit NewPoolCreated(
            msg.sender,
            name,
            managers,
            nameToken,
            symbolToken,
            durationSeconds,
            requiredInMatic,
            isWhitelisted
        );

        return true;
    }
    /** proxy compatible */
    function contribute(bytes memory args) public payable nonReentrant returns (bool) {
        uint256 id = abi.decode(args, (uint256));
        uint256 value = msg.value;
        require(value > 0, "SingleState::contribute: value <= 0");
        /** get pool and caller meta data */
        Account memory caller = accounts[msg.sender];
        Pool memory pool = pools[id];
        /** check if pool is whitelisted and if caller is whitelisted */
        if (pool.initialFundingSchedule.isWhitelisted) {
            require(caller.isOnWhitelist[id], "SingleState::contribute: caller is not on whitelist for this pool");
        }

        uint256 supply = pool.simpleToken.totalSupply();
        uint256 balance = pool.balanceInMatic;

        require(supply > 0, "SingleState::contribute: supply <= 0");
        require(balance > 0, "SingleState::contribute: balance <= 0");

        uint256 amountToMint = Utils.valueToMint(
            value,
            supply,
            balance
        );

        require(
            block.timestamp
            <= pool.initialFundingSchedule.startTimestamp
            + pool.initialFundingSchedule.durationSeconds,
            "SingleState::contribute: initial funding period for this pool has expired"
        );

        if (settings.feeToContribute > 0) {
            uint256 fee = (amountToMint * settings.feeToContribute) / 10000;
            amountToMint -= fee;
            /** mint fee of tokens to safe */
            pool.simpleToken.mint(settings.safe, fee);
        }

        /** update */
        pool.balanceInMatic += value;
        pool.simpleToken.mint(msg.sender, amountToMint);
        pools[id] = pool;
        accounts[msg.sender] = caller;

        emit Contribution(
            msg.sender,
            pool.name,
            value,
            amountToMint
        );

        return true;
    }
    /** proxy compatible */
    function withdraw(bytes memory args) public nonReentrant returns (bool) {
        (
            uint256 id,
            uint256 amount
        ) = abi.decode(
            args,
            (
                uint256,
                uint256
            )
        );

        require(amount > 0, "SingleState::withdraw: value <= 0");
        Pool memory pool = pools[id];

        uint256 supply = pool.simpleToken.totalSupply();
        uint256 balance = pool.balanceInMatic;
        
        require(supply > 0, "SingleState::withdraw: supply <= 0");
        require(balance > 0, "SingleState::withdraw: balance <= 0");
        
        uint256 valueToSend = Utils.burnToValue(
            amount,
            supply,
            balance
        );
        /** note this should never happen but if it does we return the tokens back and we can identify who we need to payout */
        require(
            pool.balanceInMatic >= valueToSend,
            "SingleState::withdraw: insufficient balance on contract to make withdrawal"
        );
        /** fees */
        if (settings.feeToWithdraw > 0) {
            uint256 fee = (amount * settings.feeToWithdraw) / 10000;
            valueToSend -= fee;
            Address.sendValue(payable(settings.safe), fee);
        }
        /** burn, send value, and update */
        pool.simpleToken.burnFrom(msg.sender, amount);
        Address.sendValue(payable(msg.sender), valueToSend);
        pool.balanceInMatic -= valueToSend;
        
        emit Withdrawal(
            msg.sender,
            pool.name,
            amount,
            valueToSend
        );

        return true;
    }
    /** use money from the pool to purchase an asset not listed */
    function newCollatTAgreement(bytes memory args) public payable returns (bool) {
        (
            uint256 id,
            address asset,
            uint256 amount
        ) = abi.decode(
            args,
            (
                uint256,
                address,
                uint256
            )
        );

        require(_checkIsManagerOf(id), "SingleState::newCollatTAgreement: caller is not manager of this pool");



    }

}