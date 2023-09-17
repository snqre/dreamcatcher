// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IProxyState {
    function writeToStorage(uint256 amount) external;
}

contract Caller {
    address addressToCall;

    constructor(address addressToCall_) {
        addressToCall = addressToCall_;
    }

    function call(uint256 amount) external {
        IProxyState(addressToCall).writeToStorage(amount);
    }
}