// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/** once files are loaded into project file then connect to local
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
 */

import "extensions/mirai/smart_contracts/polygon/finance/oracles/price/Price.sol";
import "extensions/mirai/smart_contracts/polygon/tokens/governance_token/GovernanceToken.sol";
import "extensions/mirai/smart_contracts/polygon/tokens/standard_token/StandardToken.sol";
import "smart_contracts/utils/Utils.sol";

interface ISingleStateBaseClass {
    event NewPoolCreated(
        string name,
        string description,
        address poolTokenContract,
        uint supply,
        uint64 startTimestamp,
        uint64 duration,
        uint required,
        bool isWhitelisted,
        bool isVerified,
        bool useNonVerified,
        address[] admins,
        address[] managers
    );
}

contract SingleStateBaseClass is ISingleStateBaseClass, Initializable, PausableUpgradeable, OwnableUpgradeable, AccessControl, ReentrancyGuard {
    struct Fee {
        uint create;
        uint contribute;
        uint withdraw;
        uint update;
    }

    struct FundingSchedule {
        uint64 startTimestamp;
        uint64 duration;
        uint required;
        bool isVerified;
        bool success;
    }

    struct CollatTSchedule {
        uint startTimestamp;
        uint duration;
        uint collateral;
        bool complete;
    }

    struct Reserve {
        address[] tokenContracts;
        address[] tokenAmounts;
        uint balance;
    }

    struct Settings {
        bool useNonVerified;
        bool isWhitelisted;
    }

    struct Pool {
        uint id;
        string name;
        string description;
        Reserve reserve;
        Settings settings;
        StandardToken standardToken;
        FundingSchedule fundingSchedule;
        CollatTSchedule[] collatTSchedules;  
    }

    // less gas eff. but will improve organization
    struct Account {
        bool[] isAdmin;
        bool[] isCreator;
        bool[] isManager;
        bool[] isOnWhitelist;
        bool[] isParticipant;
        
        bool isVerified;
    }

    uint poolCount;
    uint collatTScheduleCount;

    Fee internal fee;

    mapping(uint => Pool) internal pools;
    mapping(address => Account) internal accounts;

    address internal terminal;
    address internal dreamToken;

    // amnt time after strt of fnding to allw withdrawals
    uint64 internal lockUpDuration;

    modifier onlyAdmin(uint id) {
        Account memory caller = accounts[msg.sender];
        require(caller.isAdmin[id], "caller is not admin");
        _;
    }

    modifier onlyCreator(uint id) {
        Account memory caller = accounts[msg.sender];
        require(caller.isCreator[id], "caller is not creator");
        _;
    }

    modifier onlyManager(uint id) {
        Account memory caller = accounts[msg.sender];
        require(caller.isManager[id], "caller is not manager");
        _;
    }

    // checks the amount of tokens of the corresponding pool so only someone with a specific amount can access a particular function
    modifier onlyAmount(uint id, uint amount) {
        Pool selectedPool = pools[id];
        uint callerBalance = selectedPool.standardToken.balanceOf(msg.sender);
        require(callerBalance >= amount, "insufficient amount of tokens");
        _;
    }

    modifier onlyOnWhitelist(uint id) {
        Pool memory pool = pools[id];

        if (pool.settings.isWhitelisted) {
            Account memory caller = accounts[msg.sender];
            require(caller.isOnWhitelist[id], "caller is not on whitelist");
        }
        _;
    }

    modifier onlyDuringSchedule(uint id) {
        Pool memory pool = pools[id];
        uint64 now_ = block.timestamp;
        uint64 start = pool.fundingSchedule.startTimestamp;
        uint64 duration = pool.fundingSchedule.duration;
        uint64 end = start + duration;
        bool scheduleBegun = now_ >= start;
        bool scheduleEnded = now_ >= end;
        require(scheduleBegun, "schedule not begun");
        require(!scheduleEnded, "schedule has ended");
        _;
    }

    // after funding period duration unlock funds and after lockUpAmount even if funding period is not over still allow withdrawal
    modifier onlyAfterLockUpDuration(uint id) {
        Pool memory pool = pools[id];
        uint64 now_ = block.timestamp;
        uint64 start = pool.fundingSchedule.startTimestamp;
        uint64 duration = pool.fundingSchedule.duration;
        uint64 end = start + duration;
        uint64 lockUpEnd = start + lockUpDuration;
        bool lockUpHasEnded = now_ >= lockUpEnd;
        bool scheduleEnded = now_ >= end;

        // either the lock up period is over or the schedule has ended
        require(lockUpHasEnded || scheduleEnded);
        _;
    }

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address terminal_, address dreamToken_) initializer public {
        __Pausable_init();
        __Ownable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, terminal_);

        terminal = terminal_;
        dreamToken = dreamToken_;

        lockUpDuration = 4 weeks;

        fee.create = 100000;
        fee.contribute = 10;
        fee.withdraw = 10;
        fee.update = 10;
    }

    function _createNewPool(
        uint value,
        string memory name_,
        string memory description_,
        bool useNonVerified_,
        bool isWhitelisted_,
        string memory tokenName,
        string memory tokenSymbol,
        uint supply,
        uint64 startTimestamp_,
        uint64 duration_,
        uint required_,
        bool isVerified_,
        address[] memory admins,
        address[] memory managers,
        bool override_
    ) internal {
        poolCount ++;
        if (override_ == false) {
            require(poolCount        <= type(uint256).max, "maximum amount of pools created");
            require(value            >= 1, "insufficient value");
            require(supply           >= 1, "insufficient supply");
            require(block.timestamp  <= startTimestamp_, "funding schedule begins in the past");
            require(admins.length    >= 1, "no admins given");
            require(admins.length    <= 9, "too many admins given");
            require(managers.length  >= 1, "no managers given");
            require(managers.length  <= 9, "too many managers given");
        }

        Pool memory newPool = Pool({
            id:                  poolCount,
            name:                name_,
            description:         description_,
            reserve: Reserve({
                tokenContracts:  [],
                tokenAmounts:    [],
                balance:         value
            }),
            settings: Settings({
                useNonVerified:  useNonVerified_,
                isWhitelisted:   isWhitelisted_ 
            }),
            standardToken: new StandardToken(
                tokenName,
                tokenSymbol
            ),
            fundingSchedule: FundingSchedule({
                startTimestamp:  startTimestamp_,
                duration:        duration_,
                required:        required_,
                isVerified:      isVerified_,
                success:         false
            }),
            collatTSchedules:    []
        });

        newPool.standardToken.mint(msg.sender, supply);

        pools[poolCount] = newPool;

        Account account;
        account = accounts[msg.sender];
        account.isCreator[poolCount] = true;
        accounts[msg.sender] = account;

        for (uint i = 0; i < admins.length; i++) {
            account = accounts[admins[i]];
            account.isAdmin[poolCount] = true;
            accounts[admins[i]] = account;
        }

        for (uint i = 0; i < managers.length; i++) {
            account = accounts[managers[i]];
            account.isManager[poolCount] = true;
            accounts[managers[i]] = account;
        }
    }

    function _contribute(uint id, uint value) internal onlyOnWhitelist(id) onlyDuringSchedule(id) {
        require(value >= 1, "insufficient value");

        Pool memory selectedPool = pools[id];

        uint supply = selectedPool.standardToken.totalSupply();
        uint balance = selectedPool.reserve.balance;
        uint amountToMint = Utils.amountToMint(value, supply, balance);

        selectedPool.reserve.balance += value;
        selectedPool.standardToken.mint(msg.sender, amountToMint);
        
        pools[id] = selectedPool;
    }

    function _withdraw(uint id, uint amount) internal onlyAfterLockUpDuration(id) {
        require(amount >= 1, "insufficient amount");

        Pool memory selectedPool = pools[id];

        uint supply = selectedPool.standardToken.totalSupply();
        uint balance = selectedPool.reserve.balance;
        uint valueToSend = Utils.valueToMint(amount, supply, balance);

        // this should never happen. but if it does we return tokens back to owners so we have something to go of
        require(selectedPool.reserve.balance >= valueToSend, "insufficient balance on contract to make withdrawal");

        Address.sendValue(payable(msg.sender), valueToSend);
        selectedPool.reserve.balance -= valueToSend;
        pools[id] = selectedPool;
    }

    function createNewPool(
        string memory name,
        string memory description,
        bool useNonVerified,
        bool isWhitelisted,
        string memory tokenName,
        string memory tokenSymbol,
        uint supply,
        uint64 duration,
        uint required,
        address[] memory admins,
        address[] memory managers
    ) public payable returns (bool) {
        uint value = msg.value;
        uint64 now_ = block.timestamp;

        // logic to check if the pool is pre verified
        bool isVerified;

        _createNewPool(
            value,
            name,
            description,
            useNonVerified,
            isWhitelisted,
            tokenName,
            tokenSymbol,
            supply,
            now_,
            duration,
            required,
            isVerified,
            admins,
            managers,
            false
        );

        return true;
    }

    function contribute(uint id) public payable returns (bool) {
        _contribute(id, msg.value);
        return true;
    }

    function withdraw(uint id, uint amount) public returns (bool) {
        _withdraw(id, amount);
        return true;
    }

    // collateralized transfers
    function newCollatTSchedule(uint id, uint64 duration_, uint amount) public onlyManager(id) onlyAmount(id, amount) returns (bool) {
        collatTScheduleCount ++;
        Pool selectedPool = pools[id];

        uint64 now_ = block.timestamp;

        CollatTSchedule collatTSchedule = CollatTSchedule({
            startTimestamp: now_,
            duration: duration_,
            
        });


        selectedPool.collatTSchedules[collatTScheduleCount] = 
    }
}