// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title MatchBytes Library
 * @dev A library providing byte array comparison functionality using keccak256 hashing.
 */
library MatchBytesV1 {

    /**
    * @dev External pure function to compare two byte arrays for equality.
    * @param bytesA The first byte array for comparison.
    * @param bytesB The second byte array for comparison.
    * @return bool indicating whether the two byte arrays are equal.
    * @dev This function uses keccak256 hashing to compare the equality of the provided byte arrays.
    */
    function same(bytes memory bytesA, bytes memory bytesB) public pure returns (bool) {
        return keccak256(abi.encode(bytesA)) == keccak256(abi.encode(bytesB));
    }
}