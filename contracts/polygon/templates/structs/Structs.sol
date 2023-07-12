// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

struct Key {
    bool isOwned;
    bool isTimed;
    bool isStandard;
    bool isConsumable;
    uint startTimestamp;
    uint endTimestamp;
    uint numUses;
}

struct Module {
    string[] keys;
    EnumerableSet.AddressSet implementations;
    Module[] dependencies;
    uint[] dependenciesVersions;
}

struct TimedKey {
    string key;
    uint startTimestamp;
    uint endTimestamp;
    uint duration;
}

struct Account {
    string[] keys;
    string[] consumableKeys;
    TimedKey[] timedKeys;
}