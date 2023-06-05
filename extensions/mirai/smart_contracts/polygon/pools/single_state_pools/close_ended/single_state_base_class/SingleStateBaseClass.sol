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

    Fee internal fee;

    mapping(uint => Pool) internal pools;
    mapping(address => Account) internal accounts;

    address internal terminal;

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

    modifier onlyOnWhitelist(uint id) {
        Pool memory pool = pools[id];

        if (pool.settings.isWhitelisted) {
            Account memory caller = accounts[msg.sender];
            require(caller.isOnWhitelist[id], "caller is not on whitelist");
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

        _grantRole(DEFAULT_ADMIN_ROLE, terminal_);

        terminal = terminal_;

        lockUpDuration = 4 weeks;
    }

    // work in progress

    function _create(
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
        if (override_ == false) {
            require(value >= Utils.convertToWei(1), "insufficient value");
            require(supply >= Utils.convertToWei(1), "insufficient supply");
            require(block.timestamp <= startTimestamp_, "funding schedule begins in the past");
            require(admins.length >= 1, "no admins given");
            require(managers.length >= 1, "no managers given");
        }

        poolCount ++;
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
            account.isOnWhitelist[poolCount] = true;
            accounts[admins[i]] = account;
        }

        for (uint i = 0; i < managers.length; i++) {
            account = accounts[managers[i]];
            account.isManager[poolCount] = true;
            account.isOnWhitelist[poolCount] = true;
            accounts[managers[i]] = account;
        }
    }
}