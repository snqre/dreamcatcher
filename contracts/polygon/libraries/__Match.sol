// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library __Match {

    function isSameString(string memory stringA, string memory stringB) public pure returns (bool) {
        
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }
}