// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Authenticator {
    modifier onlyFoundingTeam() {
        //only for the first timeframe after deployment to make sure we can fix any likely problems will revoke before funding rounds
        require(isFoundingTeam[msg.sender]);
        _;
    }

    modifier onlySyndicate() {
        require(condition);
        _;
    }

    modifier onlyCustodian() {
        require(condition);
        _;
    }
}
