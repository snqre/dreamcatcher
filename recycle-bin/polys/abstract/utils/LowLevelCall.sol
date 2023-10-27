// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract LowLevelCall {

    /**
    * @dev Emitted when a low-level call is executed.
    * @param target The target address of the call.
    * @param data The data passed to the call.
    * @param response The response received from the call.
    */
    event LowLevelCall(address indexed target, bytes indexed data, bytes indexed response);

    /**
    * @dev Executes a low-level call to the target address with the given data.
    * @param target The target address of the call.
    * @param data The data to be passed to the call.
    * @return response The response received from the call.
    * Emits a {LowLevelCall} event.
    */
    function _lowLevelCall(address target, bytes memory data) internal virtual returns (bytes memory) {
        (bool success, bytes memory response) = target.call(data);
        require(success, "LowLevelCall: failed low level call");
        emit LowLevelCall(target, data, response);
        return response;
    }
}