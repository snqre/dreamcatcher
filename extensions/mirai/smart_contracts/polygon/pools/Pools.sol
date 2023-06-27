// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/Pausable.sol";
import "smart_contracts/module_architecture/ModuleManager.sol";
import "extensions/mirai/smart_contracts/polygon/tokens/standard_token/StandardToken.sol";

library QuickSwapLogicLib {
    function getLiquidity() public view returns (uint) {
        /// returns the amount of liquidity in a pair.
    }

    function getPrice() public view returns (uint) {
        /// checks the exchange rate on quickswap.
    }
}

library PoolsStateLib {
    /// outsource to library to reduce contract size.
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct FundingSchedule {
        uint startTimestamp;
        uint endTimestamp;
        uint duration;
        uint maticRequired;
        bool isWhitelisted;
        bool hasBeenPassed;
        bool hasBeenCancelled;
        bool hasBeenCompleted;
        bool canStartWithoutRequiredMatic;
    }

    struct CollatTSchedule {
        uint startTimestamp;
        uint endTimestamp;
        uint duration;
        uint maticGuarantee;
        bool hasBeenCancelled;
        bool hasBeenCompleted;
    }

    struct Vault {
        EnumerableSet.AddressSet contracts;
        EnumerableSet.UintSet amounts;
        uint maticBalance;
    }

    struct Settings {
        bool isWhitelisted;
    }

    struct Account {
        uint ownershipBasisPoints;
        bool isAdmin;
        bool isCreator;
        bool isManager;
        bool isOnWhitelist;
    }

    struct Pool {
        uint identifier;
        string name;
        address creator;
        FundingSchedule fundingSchedule;
        CollatTSchedule[] collatTSchedules;
        Vault vault;
        Settings settings;
        bool hasBeenLaunched;
        bool hasBeenPaused;
        address[] accountsAddress;
        Account[] accounts;
        uint numberOfAccounts;
    }

    struct Tracker { uint numberOfPools; }
}

library PoolsLogicLib {
    /// outsource to library to reduce contract size.
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    function createNewAccount(
        PoolsStateLib.Pool storage pool,
        address account
    ) public returns (uint) {
        /// create a new account within a pool.
        pool.numberOfAccounts ++;
        uint newIdentifier = pool.numberOfAccounts;

        /// map address to new identifier
        pool.accountsAddress[newIdentifier] = account;

        return newIdentifier;
    }

    function create(
        PoolsStateLib.Tracker storage tracker,
        PoolsStateLib.Pool[] storage pools,
        string memory name,
        address creator,
        address[] memory managers
    ) public returns (uint) {
        tracker.numberOfPools ++;
        uint newIdentifier = tracker.numberOfPools;
        PoolsStateLib.Pool storage newPool = pools[newIdentifier];
        newPool.name = name;
        newPool.creator = creator;

        /// log creator account
        uint identifier = createNewAccount(
            newPool, 
            newPool.creator
        );

        newPool.accounts[identifier].isCreator = true;

        /// for each manager assign an account.
        for (uint i = 0; i < managers.length; i++) {
            identifier = createNewAccount(
                newPool, 
                managers[i]
            );

            /// set each account to be manager.
            newPool.accounts[identifier].isManager = true;
        }

        return newIdentifier;
    }
}

contract Pools is Context {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// quickswaps uniswap v2 router fork as specified on https://github.com/QuickSwap/quickswap-core/tree/master.
    address public constant QUICKSWAP_V2_ROUTER = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address public constant MATIC = 0x0000000000000000000000000000000000001010;
    address public constant DREAM = ;
    address public constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address public constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address public constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;

    PoolsStateLib.Tracker public tracker;
    PoolsStateLib.Pool[] public pools;
    mapping(string => uint) public poolsNameToIdentifier;

    constructor(address moduleManager) {
        IModuleManager(moduleManager).create("mirai-pools");
        IModuleManager(moduleManager).upgrade(
            "mirai-pools",
            address(this)
        );
    }

    function create( /// create a new closed ended pool.
        string memory name,
        address[] memory managers
    ) public { /// using libraries to reduce contract size.
        uint newIdentifier = PoolsLogicLib.create(
            tracker, 
            pools, 
            name,
            _msgSender(),
            managers
        );

        /// map pool name to identifier.
        poolsNameToIdentifier[name] = newIdentifier;
    }
}