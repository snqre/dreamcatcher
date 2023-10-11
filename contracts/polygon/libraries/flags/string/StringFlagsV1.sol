// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library StringFlagsV1 {

    error IsMatchingValue();

    function onlynotMatchingValue(string memory self, string memory value) public pure returns (string memory) {
        if (keccak256(abi.encode(self)) == keccak256(abi.encode(value))) { revert IsMatchingValue(); }
        return self;
    }
}