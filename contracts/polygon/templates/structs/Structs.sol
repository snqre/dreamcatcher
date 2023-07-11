// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

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