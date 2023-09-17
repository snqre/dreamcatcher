// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/abstract/ProxyState.sol";

contract ProxyState is ProxyState {
    function readFromStorage() external view returns (uint256) {
        bytes32 location = keccak256(abi.encode("storage"));
        return _uint256[location];
    }

    function initialize(address implementation) external {
        _upgrade(implementation);
    }
}