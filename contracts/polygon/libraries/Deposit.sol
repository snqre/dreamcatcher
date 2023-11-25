// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

library Gate {
    struct Deposit {
        bool enabled;
        bool hasWhitelist;
        uint sharesMinted;
        EnumerableSet.AddressSet allowed;
    }

    ////////////////////////////////////////////////////////////////////

    function enabled(Deposit storage deposit) internal view returns (bool) {
        return deposit.enabled;
    }

    function hasWhitelist(Deposit storage deposit) internal view returns (bool) {
        return deposit.hasWhitelist;
    }

    ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////

    struct Withdraw {
        bool enabled;
        uint valueReturned;
        EnumerableSet.AddressSet allowed;
    }

    ////////////////////////////////////////////////////////////////////

    function enabled(Withdraw storage withdraw) internal view returns (bool) {
        return withdraw.enabled;
    }

    ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////

    struct Trade {
        bool enabled;
        EnumerableSet.AddressSet allowed;
        uint slippageThreshold;
    }
}