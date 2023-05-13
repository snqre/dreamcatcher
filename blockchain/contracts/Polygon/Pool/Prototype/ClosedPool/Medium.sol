// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IMedium {
    function getPrice(address _contract) public returns (uint256);
}

contract Medium {
    function getPrice(address _contract) public returns (uint256) {
        uint256 _priceInMatic =200;
        return _priceInMatic;   
    }

}