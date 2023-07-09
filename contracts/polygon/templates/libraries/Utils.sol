// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

library Utils {
    function convertToWei(uint value)
        internal pure
        returns (uint) {
        return value * (10**18);
    }
}