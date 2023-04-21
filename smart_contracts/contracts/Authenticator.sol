// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuthenticatorState {

    mapping(address => bool) internal isAdmin;      // address > bool | -human -contract
    mapping(address => bool) internal isDev;        // address > bool | -human **temp
    mapping(address => bool) internal isSyndicate;  // address > bool | -human
    mapping(address => bool) internal isOperator;   // address > bool | -human
    mapping(address => bool) internal isValidator;  // address > bool | -contract
    mapping(address => bool) internal isExtension;  // address > bool | -contract
}

contract Authenticator is AuthenticatorState {

    modifier onlyAdmin() {
        require(
            isAdmin[msg.sender] == true,        // check admin permission
            "onlyAdmin"                         // revert message
        );
        _;                                      // execute function
    }

    modifier onlyDev() {
        require(
            isDev[msg.sender] == true,          // check dev permission
            "onlyDev"                           // revert message
        );
        _;                                      // execute function
    }

    modifier onlyOperator() {
        require(
            isOperator[msg.sender] == true,     // check operator permission
            "onlyOperator"                      // revert message
        );
        _;                                      // execute function
    }

    modifier onlySyndicate() {
        require(
            isSyndicate[msg.sender] == true,    // check syndicate permission
            "onlySyndicate"                     // revert message
        );
        _;                                      // execute function
    }
    
    modifier onlyExtension() {
        require(
            isExtension[msg.sender] == true,    // check extension permission
            "onlyExtension"                     // revert message
        );
        _;                                      // execute function
    }

    modifier onlyValidator() {
        require(
            isValidator[msg.sender] == true,    // check validator permission
            "onlyValidator"                     // revert message
        );
        _;                                      // execute function
    }

    bool private locked;                        // state
    modifier antiReentrancy() {
        require(
            !locked                             // cannot be locked
        );
        locked = true;                          // set as locked before executing function
        _;                                      // execute function
        locked = false;                         // unlock after function execution
    }
}
