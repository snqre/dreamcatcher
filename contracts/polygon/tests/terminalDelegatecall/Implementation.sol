// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/abstract/ProxyState.sol";

contract Implementation is ProxyState {
    function writeToStorage(uint256 amount) external {
        bytes32 location = keccak256(abi.encode("storage"));
        _uint256[location] = amount;
    }
}