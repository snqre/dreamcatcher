// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

library Utils {
    function convertToWei(uint value)
    internal pure
    returns (uint256) {
        return value * (10**18);
    }
}