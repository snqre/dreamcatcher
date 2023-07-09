// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/Authenticator.sol";

contract Vault {
    IAuthenticator public authenticator;

    constructor(address authenticator_) {
        authenticator = IAuthenticator(authenticator_);
    }

    
}