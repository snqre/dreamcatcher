// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library StringFlagsV1 {

    error IsMatchingValue();

    function onlynotMatchingValue(bytes memory self, bytes memory value) public pure returns (bytes memory) {
        if (keccak256(self) == keccak256(value)) { revert IsMatchingValue(); }
        return self;
    }
}