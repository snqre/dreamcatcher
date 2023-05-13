// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

contract Proposal {
    struct My {
        string caption;
        string description;
        uint256 duration;
    } My private my;

    constructor(
        address _contract
    ) {

    }
}