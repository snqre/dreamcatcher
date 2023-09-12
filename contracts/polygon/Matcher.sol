// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

library Matcher 
{
    function isSameString
    (
        string memory stringA,
        string memory stringB
    )
        public pure returns (bool)
    {
        bytes32 a = keccak256(abi.encode(stringA));
        bytes32 b = keccak256(abi.encode(stringB));
        return a == b;
    }
}