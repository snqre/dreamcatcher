// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ILowLevelCall {

    /**
    * @dev Emitted when a low-level call is executed.
    * @param target The target address of the call.
    * @param data The data passed to the call.
    * @param response The response received from the call.
    */
    event LowLevelCall(address indexed target, bytes indexed data, bytes indexed response);
}