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
    EnumerableSet.AddressSet implementations;
    bool isUpgradeable;
    bool isInUse;
}

struct SettingsTimelock {
    uint duration;
    uint executionWindowDuration;
}

struct Payload {
    address target;
    string signature;
    bytes args;
}

struct ConnectionRequest {
    Payload payload;
    bool isApproved;
    bool isExecuted;
    bool isPending;
}

