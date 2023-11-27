// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library OurUintLib {
    function isZero(uint value) internal pure returns (bool) {
        return value == 0;
    }

    function compare(uint value0, uint value1) internal pure returns (bool) {
        return value0 == value1;
    }
}