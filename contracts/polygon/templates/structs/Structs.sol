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

struct ConnectionRequestSchedule {
    uint startTimestamp;    // queued timestamp.
    uint timelockDuration;  // amount of time it is locked for.
    uint timeoutDuration;   // window of time when it can be executed.
}

struct Payload {
    address target;
    string signature;
    bytes args;
}

// single request.
struct ConnectionRequest {
    Payload payload;
    ConnectionRequestSchedule connectionRequestSchedule;
    uint identifier;
    address origin;
    string message;
    bool rejected;
    bool approved;
    bool executed;
    bool pending;
}

struct Batch {
    address[] targets;
    string[] signatures;
    bytes[] args;
}

// multi request can be complex.
struct BatchConnectionRequest {
    Batch batch;
    ConnectionRequestSchedule connectionRequestSchedule;
    uint identifier;
    address origin;
    string message;
    bool rejected;
    bool approved;
    bool executed;
    bool pending;
}

struct TimelockSettings {
    uint timelockDuration;
    uint timeoutDuration;
}
