// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

// change these to human imports stuff
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

// if this format is ok then we are fine
import "blockchain/contracts/Polygon/Pools/Prototype/Utils.sol";
import "blockchain/contracts/Polygon/ERC20Standards/Tokens/SimpleToken.sol" as SimpleTokenContract;
import "blockchain/contracts/Polygon/Finance/Medium.sol";

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
            address[] memory contract__;
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

contract StandardToken is ERC2O, ERC20Burnable, ERC20Permit, AccessControl {
    using SafeMath for uint256;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        super._beforeTokenTransfer(from, to, amount);
    }

    function mint(address to, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(to, amount);
    }
}

contract GovernanceToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, AccessControl {
    using SafeMath for uint256;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERCPermit(name) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function snapshot() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _snapshot();
    }

    function mint(address to, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, amount);
    }

    function getVotes(address account) public view returns (uint256) {
        return balanceOfAt(account, _getCurrentSnapshotId());
    }

    function getPastVotes(address account, uint256 snapshotId) public view returns (uint256) {
        return balanceOfAt(account, snapshotId);
    }
}

/**
no: is the unique number generated for each pool in the contract
this is used to select which pool is being refered to in functions
 */
contract SingleState is Initializable, PausableUpgradeable, OwnableUpgradeable, ReentrancyGuard, AccessControl {
    struct Fee {
        uint256 createNewPool;
        uint256 contribute;
        uint256 withdraw;
        uint256 update;
    }

    struct FundingSchedule {
        uint64 startTime;
        uint64 duration;
        uint256 target;
        uint256 required;
        bool hasWhitelist;
        bool isVerified;
        bool success;
    }

    struct CollatTSchedule {
        uint256 startTime;
        uint256 duration;
        uint256 collateral;
        bool complete;
    }

    struct Reserve {
        address[] contracts;
        address[] amounts;
        uint256 balance;
    }

    struct Pool {
        uint256 no;
        bytes32 class;
        string name;
        string description;
        StandardToken standardToken;
        GovernanceToken governanceToken;
        FundingSchedule fundingSchedule;
        Reserve reserve;
        CollatTSchedule collatTSchedules;
    }

    struct Account {
        bool[] isAdminOf;
        bool[] isCreatorOf;
        bool[] isManagerOf;
        bool[] isOnWhitelistOf;
        bool[] isParticipantOf;
        bool hasCompletedKYC;
        bool isVerified;
        uint256 reputationScore;
    }

    uint256 poolCount;

    Fee public fee;

    mapping(uint256 => Pool) public pools;
    mapping(address => Account) public accounts;

    bytes32 decentralized = keccak256(abi.encodePacked("decentralized"));
    bytes32 centralized = keccak256(abi.encodePacked("centralized"));
    bytes32 hybrid = keccak256(abi.encodePacked("hybrid"));

    address terminal;

    // this is the amount of time after the start of a funding schedule
    // that contributors can withdraw
    // assuming the funding schedule has not succeeded yet
    lockUpPeriod;

    modifier onlyAdminOf(uint no) {
        Account memory caller = accounts[msg.sender];
        require(
            caller.isAdminOf[no],
            "SingleState::onlyAdminOf(): caller is not admin of selected pool"
        );
        _;
    }

    modifier onlyCreatorOf(uint no) {
        Account memory caller = accounts[msg.sender];
        require(
            caller.isAdminOf[no],
            "SingleState::onlyAdminOf(): caller is not admin of selected pool"
        );
        _;
    }

    modifier onlyManagerOf(uint no) {
        Account memory caller = accounts[msg.sender];
        require(
            caller.isAdminOf[no],
            "SingleState::onlyAdminOf(): caller is not admin of selected pool"
        );
        _;
    }

    modifier onlyOnWhitelistOf(uint no) {
        Pool memory pool = pools[no];
        if (pool.fundingSchedule.hasWhitelist) {
            Account memory caller = accounts[msg.sender];
            require(
                caller.isAdminOf[no],
                "SingleState::onlyAdminOf(): caller is not admin of selected pool"
            );
        }
        _;
    }

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address terminal_) initializer public {
        __Pausable_init();
        __Ownable_init();
        
        if (msg.sender != terminal_) {
            _grantRole(DEFAULT_ADMIN_ROLE, address(this));
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(DEFAULT_ADMIN_ROLE, terminal_);
        } else {
            _grantRole(DEFAULT_ADMIN_ROLE, address(this));
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        }

        terminal = terminal_;

        lockUpPeriod = 4 weeks;
    }
    
    function _pushNewPoolToStorage(
        string memory style,
        uint256 no,
        string memory name,
        string memory description,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 initialSupply,
        uint64 startTime,
        uint64 duration,
        uint256 target,
        uint256 required,
        bool hasWhitelist,
        bool isVerified,
        address[] memory admins,
        address[] memory managers,
        bool override_
    ) internal payable nonReentrant {

        if (override_ == false) {
            require(
                no >= 0,
                "SingleState::_pushNewPoolToStorage(): no < 0"
            );

            require(
                no <= type(uint256).max,
                "SingleState::_pushNewPoolToStorage(): no > type(uint256).max"
            );

            require(
                initialSupply >= Utils.convertToWei(1),
                "SingleState::_pushNewPoolToStorage(): initialSupply < 1 wei"
            );

            require(
                admins.length >= 0,
                "SingleState::_pushNewPoolToStorage(): admins.length < 0"
            );

            require(
                admins.length <= 9,
                "SingleState::_pushNewPoolToStorage(): admins.length > 9"
            );

            require(
                managers.length >= 0,
                "SingleState::_pushNewPoolToStorage(): managers.length < 0"
            );

            require(
                managers.length <= 9,
                "SingleState::_pushNewPoolToStorage(): managers.length > 9"
            );
        } 

        bytes32 style_ = keccak256(abi.encodePacked(style));

        if (style_ == decentralized || style_ == hybrid) {
            Pool pool = Pool({
                no: no,
                class: style_,
                name: name,
                description: description,
                standardToken: address(0),
                governanceToken: new GovernanceToken(
                    tokenName,
                    tokenSymbol
                ),
                fundingSchedule: FundingSchedule({
                    startTime: startTime,
                    duration: duration,
                    target: target,
                    required: required,
                    hasWhitelist: hasWhitelist,
                    isVerified: isVerified,
                    success: false
                }),
                reserve: Reserve({
                    contracts: new address[](0),
                    amounts: new address[](0),
                    balance: msg.value
                }),
                collatTSchedules: new CollatTSchedule[](0)
            });

            Account memory account;
            account = accounts[msg.sender];
            account.isCreatorOf[no] = true;

            for (uint256 i = 0; i < admins.length; i++) {
                account = accounts[admins[i]];
                account.isAdminOf[no] = true;
            }

            for (uint256 i = 0; i < managers.length; i++) {
                account = accounts[managers[i]];
                account.isManagerOf[no] = true;
            }

            pools[no] = pool;
        }

        else if (style_ == centralized) {
            Pool pool = Pool({
                no: no,
                class: style_,
                name: name,
                description: description,
                standardToken: new StandardToken(
                    tokenName,
                    tokenSymbol
                ),
                governanceToken: address(0),
                fundingSchedule: FundingSchedule({
                    startTime: startTime,
                    duration: duration,
                    target: target,
                    required: required,
                    hasWhitelist: hasWhitelist,
                    isVerified: isVerified,
                    success: false
                }),
                reserve: Reserve({
                    contracts: [],
                    amounts: [],
                    balance: msg.value
                }),
                collatTSchedules: []
            });

            Account account;
            account = accounts[msg.sender];
            account.isCreatorOf[no] = true;

            if (admins.length != 0) {
                for (uint256 i = 0; i < admins.length; i++) {
                    account = accounts[admins[i]];
                    account.isAdminOf[no] = true;
                }
            }

            if (managers.length != 0) {
                for (uint256 i = 0; i < managers.length; i++) {
                    account = accounts[managers[i]];
                    account.isManagerOf[no] = true;
                }
            }

            pools[no] = pool;
        }

        else {
            revert("SingleState::_pushNewPoolToStorage(): invalid style");
        }
    }

    // onlyOnWhitelistOf will not revert if there is no whitelist for the selected pool
    function _contribute(uint no, bool override_) internal payable onlyOnWhitelistOf(no) nonReentrant {
        // in this context value is the amount in matic being sent to the pool
        uint value = msg.value;

        if (override_ == false) {
            require(
                value >= 1,
                "SingleState::_contribute(): value < 1 wei"
            );
        }
        
        Account memory caller = accounts[msg.sender];
        Pool memory pool = pools[no];

        /** replaced by onlyOnWhitelistOf modifier
        if (pool.fundingSchedule.hasWhitelist) {
            require(
                caller.isOnWhitelistOf[no],
                "SingleState::_contribute: caller is not on whitelist of the selected pool"
            );
        }
        */

        if (pool.class == decentralized || pool.class == hybrid) {
            uint supply = pool.governanceToken.totalSupply();

        } else if (pool.class == centralized) {
            uint supply = pool.standardToken.totalSupply();
        } else {
            revert("SingleState::_contribute: unidentified class");
        }

        uint balance = pool.reserve.balance;
        
        // this will revert if parameters are insufficient as the math cannot be done with low values
        uint amountToMint = Utils.valueToMint(value, supply, balance);
        
        // cannot contribute to a pool after funding period in prototype
        if (override_ == false) {
            require(
                block.timestamp <= pool.fundingSchedule.startTime + pool.fundingSchedule.duration,
                "SingleState::_contribute(): funding period for selected pool is over"
            );
        }

        if (override_ == false) {
            if (fee.contribute >= 1) {
                uint fee = amountToMint.mul(fee.contribute).div(10_000);
                amountToMint = amountToMint.sub(fee);
                
                if (pool.class == decentralized || pool.class == hybrid) {
                    pool.governanceToken.mint(terminal, fee);

                } else if (pool.class = centralized) {
                    pool.standardToken.mint(terminal, fee);

                } else {
                    // if it got here and hasnt reverted already this is troubling
                    revert("SingleState::_contribute: unidentified class");
                }
            }
        }
        
        pool.reserve.balance += value;
        
        if (pool.class == decentralized || pool.class == hybrid) {
            pool.governanceToken.mint(msg.sender, amountToMint);
        } 

        else if (pool.class = centralized) {
            pool.standardToken.mint(msg.sender, amountToMint);
        } 
        
        else {
            // better safe than sorry i guess ...
            revert("SingleState::_contribute: unidentified class");
        }

        // note storage update
        pools[no] = pool;
        accounts[msg.sender] = caller;
    }

    function _withdraw(uint no, uint amount, bool override_) internal payable nonReentrant {
        // in this context amount is the amount of the corresponding token being burnt
        require(
            amount >= 1,
            "SingleState::_withdraw(): amount < 1"
        );

        Pool memory pool = pools[no];



        // if past lock up period then can withdraw even if fundingSchedule is stil active
        // so setting funding schedule ending to 100 years doesnt cause a disaster
        bool isPastLockUpPeriod = block.timestamp >= pool.fundingSchedule.startTime.add(lockUpPeriod);

        if (!isPastLockUpPeriod) {
            bool isWithdrawalAllowed = !pool.fundingSchedule.success && (block.timestamp >= pool.fundingSchedule.startTime + pool.fundingSchedule.duration);

            require(
                isWithdrawalAllowed,
                "SingleState::_withdraw(): withdrawal is not allowed at this time"
            );
        }
        
        
        if (pool.class == decentralized || pool.class == hybrid) {
            uint supply = pool.governanceToken.totalSupply();
        } 

        else if (pool.class == centralized) {
            uint supply = pool.standardToken.totalSupply();
        }

        else {
            // first check. if this happens its likely because of a pool creation error
            revert("SingleState::_contribute: unidentified class");
        }

        uint balance = pool.reserve.balance;

        // this will revert if there is insufficient values to make the calculation
        uint amountToSend = Utils.burnToValue(amount, supply, balance);

        // this must never happen. but if it does revert and return their tokens to them
        require(
            pool.reserve.balance >= valueToSend,
            "SingleState::_withdraw(): insufficient balance on contract to make withdrawal"
        );

        if (override_ == false) {
            if (fee.withdraw >= 1) {
                uint fee = amount.mul(fee.withdraw).div(10_000);
                valueToSend = valueToSend.sub(fee);
                Address.sendValue(payable(terminal), fee);
            }
        }

        if (pool.class == decentralized || pool.class == hybrid) {
            uint supply = pool.governanceToken.burnFrom(msg.sender, amount);
        } 

        else if (pool.class == centralized) {
            uint supply = pool.standardToken.burnFrom(msg.sender, amount);
        }

        else {
            // again ... better safe than sorry ...
            revert("SingleState::_contribute: unidentified class");
        }

        // note storage update
        Address.sendValue(payable(msg.sender), valueToSend);
        pool.reserve.balance = pool.reserve.balance.sub(valueToSend);
    }
}