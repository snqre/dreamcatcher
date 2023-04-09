// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Math {
    // is the value positive or negative
    function checkSkew(uint256 _value) internal returns (bool) {
        if (_value > 0) {
            return true;
        }
        else if (_value < 0) {
            return false;
        }
    }
}
