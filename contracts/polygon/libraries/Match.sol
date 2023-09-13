// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

library Match {
    function isSameString(string memory stringA, string memory stringB) public pure returns (bool) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }
}