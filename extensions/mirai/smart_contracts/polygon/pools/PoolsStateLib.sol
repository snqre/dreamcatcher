// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";

/// what happens if an owned asset does not have liquidity anymore where do we fetch the price from?
/// back up oracle?

library PoolsStateLib { /// we found a way to get the price of assets using quickSwap.
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
    }

    struct Tracker { uint numberOfPools; }
}