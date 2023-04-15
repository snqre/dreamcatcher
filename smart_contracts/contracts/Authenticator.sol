// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// key 
contract Authenticator {
    bool private locked;
    modifier reentrancyLock() {
        require(!locked, "Anti-Reentrancy Lock");
        locked = true;
        _;
        locked = false;
    }

    // PERMISSIONS
    mapping(address => bool) internal isAdmin;        // highest level
    mapping(address => bool) internal isOwner;        // temp role
    mapping(address => bool) internal isValidator;    // exchanges native tokens for votes or has permission to do so
    mapping(address => bool) internal isExtension;

    modifier admin() {require(isAdmin[msg.sender] == true, "only an admin can call this function");_;}
    modifier owner() {require(isOwner[msg.sender] == true, "only an owner can call this function");_;}
    modifier validator() {require(isValidator[msg.sender] == true, "only a validator can call this function");_;}
    modifier extension() {require(isExtension[msg.sender] == true, "only approved contracts can call this function");_;}

    function grantRoleAdmin(address account) public admin returns (bool) {isAdmin[account] = true; return true;}             // admin can grant admin
    function revokeRoleAdmin(address account) public admin returns (bool) {isAdmin[account] = false; return true;}           // admin can revoke admin
    function grantRoleOwner(address account) public admin returns (bool) {isOwner[account] = true; return true;}             // admin can grant owner
    function revokeRoleOwner(address account) public admin returns (bool) {isOwner[account] = false; return true;}           // admin can revoke owner
    function revokeMyRoleOwner() public owner returns (bool) {isOwner[msg.sender] = false; return true;}                     // owner can revoke self owner
    function grantRoleValidator(address account) public admin returns (bool) {isValidator[account] = true; return true;}     // admin can grant validator
    function revokeRoleValidator(address account) public admin returns (bool) {isValidator[account] = false; return true;}   // admin can revoke validator
    function revokeMyRoleValidator() public validator returns (bool) {isValidator[msg.sender] = false; return true;}         // validator can revoke self validator
    function grantRoleExtension(address account) public admin  returns (bool) {isExtension[account] = true; return true;}    // admin can grant extension
    function revokeRoleExtension(address account) public admin returns (bool) {isExtension[account] = false; return true;}   // admin can revoke extension
    function revokeMyRoleExtension() public extension returns (bool) {isExtension[msg.sender] = false; return true;}         // extension can revoke self extension
}
