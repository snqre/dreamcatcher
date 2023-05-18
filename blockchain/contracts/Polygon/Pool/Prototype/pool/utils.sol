// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library Utils {
    function howMuchToMint(uint256 _value, uint256 _supply, uint256 _balance) public pure returns (uint256) {
        return ((_value * _supply) / _balance);
    }

    function howMuchToSend(uint256 _value, uint256 _supply, uint256 _balance) public pure returns (uint256) {
        return ((_value * _balance) / _supply);
    }

    function convertToWei(uint256 _value) public pure returns (uint256) {
        return (_value * 10**18);
    }

    function convertToInt(uint256 _value) public pure returns (uint256) {
        return (_value / 10**18);
    }
}