// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
* @title Authenticator
* @todo 
*
*
*
*
*
 */
contract Authenticator {
    bool locked;
    modifier mutex() {
        require(!locked, "Mutex: Reentrant call");
        assembly {sstore(locked_slot, 1)}
        locked = true;
        _;
        locked = false;
    }
}
