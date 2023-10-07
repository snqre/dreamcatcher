// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title MatchString Library
 * @dev A library providing string comparison functionality using keccak256 hashing.
 */
library MatchStringV1 {

    /**
    * @dev External pure function to compare two strings for equality.
    * @param stringA The first string for comparison.
    * @param stringB The second string for comparison.
    * @return bool indicating whether the two strings are equal.
    * @dev This function uses keccak256 hashing to compare the equality of the provided strings.
    */
    function same(string memory stringA, string memory stringB) public pure returns (bool) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }
}