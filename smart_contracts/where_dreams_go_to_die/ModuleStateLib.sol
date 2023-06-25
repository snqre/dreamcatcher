// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/utils/structs/EnumerableSet.sol";

/// each of our modules will have this basic template.
library ModuleStateLib {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Module {
        uint identifier;
        uint version;
        EnumerableSet
            .AddressSet implementations;
        string name;
        string description;
        bool isActive;
    }
}