// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ILowLevelCaller {
    event LowLevelCallExecuted(address indexed target, bytes indexed response);
}