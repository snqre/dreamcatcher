// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract LowLevelCaller {

    event LowLevelCallExecuted(address indexed target, bytes indexed data, bytes indexed response);

    function _lowLevelCall(address target, bytes memory data) internal virtual returns (bytes memory) {
        (bool success, bytes memory response) = target.call(data);
        require(success, "LowLevelCaller: failed low level call");
        emit LowLevelCallExecuted(target, data, response);
        return response;
    }
}