// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title BytesArrayV1
 * @dev A library for managing an array of bytes, providing functions to find the first empty slot, check for an empty slot,
 * add data to the first empty slot or append it to the end, and remove data at a specified index.
 */
library BytesArrayV1 {

    /**
    * @dev Returns the index of the first empty slot in the array of bytes.
    * @param self The array of bytes to search.
    * @return uint256 representing the index of the first empty slot.
    */
    function firstEmptyIndex(bytes[] memory self) public pure returns (uint256) {
        uint256 firstEmptyIndex;
        bytes memory emptyBytes;
        for (uint256 i = 0; i < self.length; i++) {
            if (keccak256(self[i]) == keccak256(emptyBytes)) {
                firstEmptyIndex = i;
                break;
            }
        }
        return firstEmptyIndex;
    }

    /**
    * @dev Checks if there is an empty slot in the array of bytes.
    * @param self The array of bytes to check.
    * @return bool indicating whether there is an empty slot.
    */
    function hasEmptyIndex(bytes[] memory self) public pure returns (bool) {
        bool hasEmptyIndex;
        bytes memory emptyBytes;
        for (uint256 i = 0; i < self.length; i++) {
            if (keccak256(self[i]) == keccak256(emptyBytes)) {
                hasEmptyIndex = true;
                break;
            }
        }
        return hasEmptyIndex;
    }

    /**
    * @dev Adds the given bytes data to the first empty slot in the array.
    * If there is no empty slot, it appends the data to the end of the array.
    * @param self The storage reference to the array of bytes.
    * @param dat The bytes data to add.
    */
    function tryPushToEmptyFirst(bytes[] storage self, bytes memory dat) public {
        if (hasEmptyIndex(self)) {
            self[firstEmptyIndex(self)] = dat;
        }
        else {
            self.push(dat);
        }
    }

    /**
    * @dev Removes the bytes data at the specified index in the array.
    * It sets the data at the given index to an empty bytes value.
    * @param self The storage reference to the array of bytes.
    * @param id The index of the data to remove.
    */
    function remove(bytes[] storage self, uint256 id) public {
        bytes memory emptyBytes;
        self[id] = emptyBytes;
    }
}