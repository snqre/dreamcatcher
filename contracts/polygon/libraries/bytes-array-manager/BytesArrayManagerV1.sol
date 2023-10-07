// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/libraries/shared/Shared.sol";

/**
 * @title BytesArrayManagerV1 Library
 * @dev A library providing functionality for managing arrays of byte arrays, including checking for empty indices, finding empty indices,
 * storing byte arrays in the array, and comparing byte arrays for equality.
 */
library BytesArrayManagerV1 {    

    /**
    * @dev Public view function to check if a byte array storage contains an empty index.
    * @param array The storage array of byte arrays to check.
    * @return bool indicating whether the storage array contains an empty index.
    * @dev The function iterates through the storage array and checks if any index is equal to an empty byte array.
    */
    function hasEmptyIndex(bytes[] storage array) public view returns (bool) {
        bytes memory emptyBytes;
        for (uint256 i = 0; i < array.length; i++) {
            if (_isSame(array[i], emptyBytes)) {
                return true;
            }
        }
    }

    /**
    * @dev Public view function to find the index of the first empty byte array in a storage array.
    * @param array The storage array of byte arrays to search.
    * @return uint256 representing the index of the first empty byte array.
    * @dev If no empty index is found, the function reverts with the HasNoEmptyIndex error.
    * @dev The function iterates through the storage array and returns the index of the first empty byte array encountered.
    */
    function emptyIndex(bytes[] storage array) public view returns (uint256) {
        if (!hasEmptyIndex(array)) { revert HasNoEmptyIndex(); }
        bytes memory emptyBytes;
        for (uint256 i = 0; i < array.length; i++) {
            if (_isSame(array[i], emptyBytes)) {
                return i;
            }
        }
    }

    /**
    * @dev Public function to store a byte array in a storage array, either by filling an empty slot or appending to the array.
    * @param array The storage array of byte arrays to modify.
    * @param dat The byte array to be stored.
    * @dev If the storage array has an empty index, the function replaces the empty slot with the provided byte array.
    * @dev Otherwise, the function appends the byte array to the end of the storage array.
    */
    function slot(bytes[] storage array, bytes memory dat) public {
        if (hasEmptyIndex(array)) {
            array[emptyIndex(array)] = dat;
        }
        else {
            array.push(dat);
        }
    }

    /**
    * @dev Internal pure function to compare two byte arrays for equality.
    * @param bytesA The first byte array for comparison.
    * @param bytesB The second byte array for comparison.
    * @return bool indicating whether the two byte arrays are equal.
    * @dev This function uses keccak256 hashing to compare the equality of the provided byte arrays.
    */
    function _isSame(bytes memory bytesA, bytes memory bytesB) internal pure returns (bool) {
        return keccak256(bytesA) == keccak256(bytesB);
    }

}