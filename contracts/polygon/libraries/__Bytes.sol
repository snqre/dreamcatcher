// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library __Bytes {

    /** Public. */

    /**
    * @dev Will try to push to an index in the array which contains
    *      an empty bytes entry. If there is no empty entry it will
    *      push the dat to a new index.
     */
    function pushBytesArray(bytes[] storage array, bytes calldata dat) public returns (uint256 index) {

        (bool success, uint256 emptyIndex) = _getEmptyIndex(array);

        if (success) {

            array[emptyIndex] = dat;

            return emptyIndex;
        }

        else {

            array.push(dat);

            return array.length - 1;
        }

    }

    /** Internal Pure. */

    function _isSameBytes(bytes memory bytesA, bytes memory bytesB) internal pure returns (bool isMatch) {

        return keccak256(bytesA) == keccak256(bytesB);
    }

    /** Internal View. */

    /**
    * @dev Returns the index of the first empty entry in a bytes array.
     */
    function _getEmptyIndex(bytes[] storage array) internal view returns (bool success, uint256 index) {

        bytes memory emptyBytes;

        for (uint256 i = 0; i < array.length; i++) {

            if (_isSameBytes(array[i], emptyBytes)) {

                success = true;
                index = i;
                break;
            }
        }

        return (success, index);
    }
}