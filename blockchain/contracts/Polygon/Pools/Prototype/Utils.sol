// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Utils {
    function valueToMint(uint256 value, uint256 supply, uint256 balance) public pure returns (uint256) {
        return ((value * supply) / balance);
    }

    function burnToValue(uint256 value, uint256 supply, uint256 balance) public pure returns (uint256) {
        return ((value * balance) / supply);
    }
}