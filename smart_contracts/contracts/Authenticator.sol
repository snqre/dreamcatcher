// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "smart_contracts/libraries/Terminal.sol";

// key 
contract Authenticator {
    address sndr = Terminal.sender();
    mapping(address => bool) internal isAdmin;
    mapping(address => bool) internal isDev;    // we will maintain some control of the contract for period after deployment to improve and fine tuine it
    mapping(address => bool) internal isSyndicate;
    mapping(address => bool) internal isOperator; // elected official
    // ====== RESERVED FOR EXTERNAL CONTRACTS NOT TO INTENDED FOR USE OF USER ADDRESSES
    mapping(address => bool) internal isValidator; // validators can stake and hold
    mapping(address => bool) internal isProposer; // can propose -- reserved for external contracts not for users in case we want to outsource the propose function
    mapping(address => bool) internal isExtension; // extension contract must be given permission

    modifier onlyAdmin() {require(isAdmin[sndr] == true, "Authenticator: admin permission required");_;}
    modifier onlyDev() {require(isDev[sndr] == true, "Authenticator: dev permission required");_;}
    modifier onlySyndicate() {require(isSyndicate[sndr] == true, "Authenticator: syndicate permission required");_;}
    modifier onlyOperator() {require(isOperator[sndr] == true, "Authenticator: operator permission required");_;}
    modifier onlyExtension() {require(isExtension[sndr] == true, "Authenticator: extension permission required");_;}
    modifier onlyValidator() {require(isValidator[sndr] == true, "validator permission required");_;}

    // mutex anti reentrancy lock
    // 1 mutex leaves the contract vulnerable to DDOS and denial of service attacks so its import to use this only where required
    // if we need more mutex, then we can have a second lock but the maximum is 1 per function
    bool private locked;
    modifier antiReentrancy() {
        require(!locked, "MUTEXT: is locked");
        locked = true;
        _;
        locked = false;
    }

    constructor() {}

    

}
