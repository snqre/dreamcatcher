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

// simple token: no snapshot, no voting
contract StandardToken {

}

// capped token
contract StandardTokenCapped {

}

// used for governance pools
contract GovernanceToken is ERC20, ERC20Burnable, ERC20Snapshot, AccessControl, ERC20Permit {
    using SafeMath for uint256;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERCPermit(name) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    // -.-.-.- private
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }
    // -.-.-.- owner commands
    function snapshot() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _snapshot();
    }

    function mint(address to, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, amount);
    }
    // -.-.-.- public
    function getVotes(address account) public view returns (uint256) {
        return balanceOfAt(account, _getCurrentSnapshotId());
    }

    function getPastVotes(address account, uint256 snapshotId) public view returns (uint256) {
        return balanceOfAt(account, snapshotId);
    }
}

contract GovernanceTokenCapped is GovernanceToken {
    uint256 internal mintable_;
    uint256 immutable maxSupply_;

    constructor(string memory name, string memory symbol, uint256 cap) GovernanceToken(name, symbol) {
        mintable_ = cap;
        maxSupply_ = cap;
    }
    // -.-.-.- private
    function _mint(address to, uint256 amount) internal override {
        require(mintable_ <= amount, "StandardToken::_mint(): mintable_ > amount");
        mintable_ = mintable_.sub(amount);
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override {
        super._burn(account, amount);
        mintable_.add(amount);
    }
}

contract SingleState is Initializable, PausableUpgradeable, OwnableUpgradeable, ReentrancyGuard, AccessControl {
    /**
    * D: dencentralized.
    * C: centralized.
    * H: hybrid.
     */
    uint256 internal priceToCreateNewPool;
    uint256 internal feeToContribute;
    uint256 internal feeToWithdraw;

    uint256 internal numberOfD;
    uint256 internal numberOfC;
    uint256 internal numberOfH;

    uint256 internal numberOfCappedD;
    uint256 internal numberOfCappedC;
    uint256 internal numberOfCappedH;

    struct Meta {
        uint256 no;
        string name;
        string description;
    }

    struct Funding {
        uint64 startTimestamp;
        uint64 duration;
        uint256 required;
        bool isWhitelisted;
        bool isVerified;
        bool success;
    }

    struct CollatTSchedule {
        uint256 startTimestamp;
        uint256 duration;
        uint256 guarantee;
        bool complete;
    }

    struct Holdings {
        address[] contracts;
        address[] amounts;
        uint256 balance;
    }

    struct PoolD {
        Meta meta;
        GovernanceToken governanceToken;
        Funding funding;
        Holdings holdings;
        CollatTSchedule[] collatTSchedules;
    }

    struct PoolC {
        Meta meta;
        StandardToken standardToken;
        Funding funding;
        Holdings holdings;
        CollatTSchedule[] collatTSchedules;
    }

    struct PoolH {
        Meta meta;
        GovernanceToken governanceToken;
        Funding funding;
        Holdings holdings;
        CollatTSchedule[] collatTSchedules;
    }

    mapping(uint256 => PoolD) internal poolsD;
    mapping(uint256 => PoolC) internal poolsC;
    mapping(uint256 => PoolH) internal poolsH;

    mapping(address => mapping(uint256 => bool)) internal isAdminOfD;
    mapping(address => mapping(uint256 => bool)) internal isCreatorOfD;
    mapping(address => mapping(uint256 => bool)) internal isManagerOfD;     // D: mainly the team behind
    mapping(address => mapping(uint256 => bool)) internal isOnWhitelistOfD; // D: does not have whitelist

    mapping(address => mapping(uint256 => bool)) internal isAdminOfC;
    mapping(address => mapping(uint256 => bool)) internal isCreatorOfC;
    mapping(address => mapping(uint256 => bool)) internal isManagerOfC;
    mapping(address => mapping(uint256 => bool)) internal isOnWhitelistOfC;

    mapping(address => mapping(uint256 => bool)) internal isAdminOfH;
    mapping(address => mapping(uint256 => bool)) internal isCreatorOfH;
    mapping(address => mapping(uint256 => bool)) internal isManagerOfH;
    mapping(address => mapping(uint256 => bool)) internal isOnWhitelistOfH;
    /**
    * createNewPool: int
    * contribute: points
    * withdraw: points
     */
    struct Fee {
        uint256 createNewPool;
        uint256 contribute;
        uint256 withdraw;
    } Fee private fee;

    // is the caller the admin of the pool [identifier] of x type
    modifier onlyAdminOf(uint class, uint256 no) {
        if (class == 0) { // D
            require(isAdminOfD[msg.sender][no], "onlyAdminOfD");
        }

        if (class == 1) { // C
            require(isAdminOfC[msg.sender][no], "onlyAdminOfC");
        }

        if (class == 2) { // H
            require(isAdminOfH[msg.sender][no], "onlyAdminOfH");
        }
    }

    // is the caller the creator of the pool [identifier] of x type
    modifier onlyCreatorOf(uint class, uint256 no) {
        if (class == 0) { // D
            require(isCreatorOfD[msg.sender][no], "onlyCreatorOfD");
        }

        if (class == 1) { // C
            require(isCreatorOfC[msg.sender][no], "onlyCreatorOfC");
        }

        if (class == 2) { // H
            require(isCreatorOfH[msg.sender][no], "onlyCreatorOfH");
        }
    }

    // is the caller the manager of the pool [identifier] of x type
    modifier onlyManagerOf(uint class, uint256 no) {
        if(class == 0) { // D
            require(isManagerOfD[msg.sender][no], "onlyManagerOfD");
        }

        if(class == 1) { // C
            require(isManagerOfC[msg.sender][no], "onlyManagerOfC");
        }

        if(class == 2) { // H
            require(isManagerOfH[msg.sender][no], "onlyManagerOfH");
        }
    }

    // whitelisted accounts can be set manually by admins but in future we will help do kyc and mml checks
    // is the caller on the whitelist of the pool [identifier] of x type
    modifier onlyOnWhitelistOf(uint class, uint256 no) {
        if (class == 0) { // D
            require(isOnWhitelistOfD[msg.sender][no], "onlyOnWhitelistOfD");
        }

        if (class == 1) { // C
            require(isOnWhitelistOfC[msg.sender][no], "onlyOnWhitelistOfC");
        }

        if (class == 2) { // H
            require(isOnWhitelistOfH[msg.sender][no], "onlyOnWhitelistOfH");
        }
    }

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address terminal) initializer public {
        __Pausable_init();
        __Ownable_init();
        // set authenticator
        if (msg.sender != terminal) {
            _grantRole(DEFAULT_ADMIN_ROLE, address(this));
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(DEFAULT_ADMIN_ROLE, terminal);
        } else {
            _grantRole(DEFAULT_ADMIN_ROLE, address(this));
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        }
    }
    // -.-.-.- private
    function _convertToWei(uint value) internal returns (uint256) {
        return value * 10**18;
    }

    function _newMeta(
        uint256 no,
        string memory name,
        string memory description
    ) internal returns (Meta) {
        Meta newMeta = Meta({
            no: no,
            name: name,
            description: description
        });

        return newMeta;
    }

    function _newFundingSchedule(
        uint64 startTimestamp,
        uint64 duration,
        uint256 required,
        bool isWhitelisted,
        bool isVerified,
        bool success
    ) internal returns (Funding) {
        Funding newFunding = Funding({
            startTimestamp: startTimestamp,
            duration: duration,
            required: required,
            isWhitelisted: isWhitelisted,
            isVerified: isVerified,
            success: success
        });

        return newFunding;
    }

    /**
        this is for collateralized transfers
     */
    function _newCollatTSchedule(
        uint256 startTimestamp,
        uint256 duration,
        uint256 guarantee,
        bool complete
    ) internal returns (CollatTSchedule) {
        CollatTSchedule newCollatTSchedule = CollatTSchedule({
            startTimestamp: startTimestamp,
            duration: duration,
            guarantee: guarantee,
            complete: complete
        });

        return newCollatTSchedule;
    }

    function _newHoldings(
        address[] contracts,
        address[] amounts,
        uint256 balance
    ) internal returns (Holdings) {
        Holdings newHoldings = Holdings({
            contracts: contracts,
            amounts: amounts,
            balance: balance
        });

        return newHoldings;
    }

    /**
        class: the base style of pool being generated
        name: the name of the pool
        description: a short description directly by the creator
        fundingStartTimestamp: when does the funding period start
        fundingDuration: how long does the funding period last
        fundingRequired: amount in matic required to pass the funding period
        isWhitelisted: are only kyc and mml entities allowed to use this
        isVerified: this pool is verified and is compliant
        admins: who are the admins who can edit key components of the pool
        managers: who can move capital
        tokenName: name of token
        tokenSymbol: symbol
        initialSupply: set the initialSupply for the amount of wei given
     */
    function _createNewPool(
        uint class,
        string memory name,
        string memory description,
        uint64 fundingStartTimestamp,
        uint64 fundingDuration,
        uint256 fundingRequired,
        bool isWhitelisted,
        bool isVerified,
        address[] admins,
        address[] managers,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 initialSupply
    ) internal nonReentrant payable {
        // required checks before the process
        require(msg.value >= 1, "SingleStage::_createNewPoolD(): msg.value < 1");

        /** PATH TO DECENTRALIZED POOL */
        // centralized pools are total controlled by managers
        // contributors within the pool dont have a say in what managers buy after contribution
        if (class == 0) { // D
            numberOfD += 1;
            Meta newMeta = _newMeta(numberOfD, name, description);
            Funding newFundingSchedule = _newFundingSchedule(
                fundingStartTimestamp,
                fundingDuration,
                fundingRequired,
                isWhitelisted,
                isVerified,
                false
            );

            // if the target is 0 then automatically pass the funding
            if (fundingRequired == 0) {
                newFundingSchedule.success = true;
            }

            GovernanceToken newGovernanceToken = new GovernanceToken(
                tokenName,
                tokenSymbol
            );

            // generate empty Holdings but factor in msg.value
            address[] contracts;
            address[] amounts;

            // initial investment from creator
            uint256 balance = msg.value;
            newHoldings = _newHoldings(contracts, amounts, balance);

            PoolD newPoolD = PoolD({
                meta: newMeta,
                governanceToken: newGovernanceToken,
                funding: newFundingSchedule,
                holdings: newHoldings,
                collatTSchedules: []
            });

            // mint initial supply for creator contribution
            newPoolD.governanceToken.mint(msg.sender, initialSupply);

            // add new pool to mapping
            poolsD[numberOfD] = newPoolD;

            // set creator
            isCreatorOfD[msg.sender][no] = true;

            // admins
            for (uint256 i = 0; i < admins.length; i++) {
                isAdminOfD[admins[i]][no] = true;
            }

            // set managers
            for (uint256 i = 0; i < managers.length; i++) {
                isManagerOfD[managers[i]][no] = true;
            }
        }

        // PATH TO CENTRALIZED POOL
        if (class == 1) { // C
            numberOfC += 1;
            Meta newMeta = _newMeta(numberOfC, name, description);
            Funding newFundingSchedule = _newFundingSchedule(
                fundingStartTimestamp,
                fundingDuration,
                fundingRequired,
                isWhitelisted,
                isVerified,
                false
            );

            // if the target is 0 then automatically pass the funding
            if (fundingRequired == 1) {
                newFundingSchedule.success = true;
            }

            // because centralized pools dont require voting theres not need for governance features
            StandardToken newStandardToken = new StandardToken(
                tokenName,
                tokenSymbol
            );

            // generate empty Holdings and adjust msg value
            address[] contracts;
            address[] amounts;

            // initial investment from creator
            uint256 balance = msg.value;
            newHoldings = _newHoldings(contracts, amounts, balance);

            PoolC newPoolC = PoolC({
                meta: newMeta,
                standardToken: newStandardToken,
                funding: newFundingSchedule,
                holdings: newHoldings,
                collatTSchedule: []
            });

            // mint initial supply for creator contribution
            newPoolC.standardToken.mint(msg.sender, initialSupply);

            // add new pool to mapping
            poolsC[numberOfC] = newPoolC;

            // set creator
            isCreatorOfC[msg.sender][no] = true;

            // admins
            for (uint256 i = 0; i < admins.length; i++) {
                isAdminOfC[admins[i]][no] = true;
            }

            // managers
            for (uint256 i = 0; i < managers.length; i++) {
                isManagerOfC[managers[i]][no] = true;
            }
        }
    }
        
}