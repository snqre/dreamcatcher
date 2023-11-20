// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Utils {
    function onlySelf() internal view {
        require(caller() == self(), "Unable to proceed because you are not the contract");
    }

    function self() internal view returns (address) {
        return address(this);
    }

    function caller() internal view returns (address) {
        return msg.sender;
    }

    function timestamp() internal view returns (uint) {
        return block.timestamp;
    }
}