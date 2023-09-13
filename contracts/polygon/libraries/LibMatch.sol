// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

library LibMatch
{
    function isMatchString
    (
        string memory stringA,
        string memory stringB
    )
    external pure
    returns (bool)
    {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }
}