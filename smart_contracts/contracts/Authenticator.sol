// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// how to interact with the autenticator module externally from other contracts
interface IAuthenticator {
    // externally check permissions
    function hasAdminPermission(address _owner) public returns (bool) {return isAdmin[_owner];}
    function hasDevPermission(address _owner) public returns (bool) {return isDev[_owner];}
    function hasSyndicatePermission(address _owner) public returns (bool) {return isSyndicate[_owner];}
    function hasOperatorPermission(address _owner) public returns (bool) {return isOperator[_owner];}
    function hasExtensionPermission(address _owner) public returns (bool) {return isExtension[_owner];}
    function hasValidatorPermission(address _ownerr) public returns (bool) {return isValidator[_owner];}
    // events
    event AdminPermissionGranted(address indexed _owner);
    event AdminPermissionRevoked(address indexed _owner);
    event DevPermissionGranted(address indexed _owner);
    event DevPermissionRevoked(address indexed _owner);
    event SyndicatePermissionGranted(address indexed _owner);
    event SyndicatePermissionRevoked(address indexed _owner);
    event OperatorPermissionGranted(address indexed _owner);
    event OperatorPermissionRevoked(address indexed _owner);
    // general extension permissions
    event ExtensionPermissionGranted(address indexed _owner);
    event ExtensionPermissionRovoked(address indexed _owner);
    // validator permissions

}

library LibAuthenticator {
    function sender() internal view returns (address) {return msg.sender;}
}

// key 
contract Authenticator is IAuthenticator, LibAuthenticator {
    mapping(address => bool) internal isAdmin;
    mapping(address => bool) internal isDev;    // we will maintain some control of the contract for period after deployment to improve and fine tuine it
    mapping(address => bool) internal isSyndicate;
    mapping(address => bool) internal isOperator; // elected official
    // ====== RESERVED FOR EXTERNAL CONTRACTS NOT TO INTENDED FOR USE OF USER ADDRESSES
    mapping(address => bool) internal isValidator; // validators can stake and hold
    mapping(address => bool) internal isProposer; // can propose -- reserved for external contracts not for users in case we want to outsource the propose function
    mapping(address => bool) internal isExtension; // extension contract must be given permission

    modifier onlyAdmin() {require(isAdmin[sender()] == true, "Authenticator: admin permission required");_;}
    modifier onlyDev() {require(isDev[sender()] == true, "Authenticator: dev permission required");_;}
    modifier onlySyndicate() {require(isSyndicate[sender()] == true, "Authenticator: syndicate permission required");_;}
    modifier onlyOperator() {require(isOperator[sender()] == true, "Authenticator: operator permission required");_;}
    modifier onlyExtension() {require(isExtension[sender()] == true, "Authenticator: extension permission required");_;}
    modifier onlyValidator() {require(isValidator[sender()] == true, "validator permission required");}

    // Here i'm trying to see if i can make it so we can assign certain things to created role during runtime
    mapping(string => mapping(address => bool)) private isRole;
    function checkRole(string _roleCaption, address _owner) public view returns (bool) {
        isRole[_roleCaption][_owner];
    }
    modifier onlyRole(string _roleCaption) {
        require(isRole[_roleCaption][sender()] == true);
        _;
    }

    // mutex anti reentrancy lock
    // 1 mutex leaves the contract vulnerable to DDOS and denial of service attacks so its import to use this only where required
    // if we need more mutex, then we can have a second lock but the maximum is 1 per function
    bool private locked;
    modifier mutex() {
        require(!locked, "MUTEXT: is locked");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        // inbuilt
        isRole["GeneratedRole"][sender()] = true;
        result = checkRole("GeneratedRole", sender());
    }

    function example() public onlyRole("GeneratedRole") {
        // do something
    }

    

}
