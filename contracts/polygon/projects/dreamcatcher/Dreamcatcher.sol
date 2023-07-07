// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/Key.sol";
import "contracts/polygon/projects/dreamcatcher/tokens/DreamToken.sol";

contract Dreamcatcher is Key {
    DreamToken public dreamToken;
    Authenticator public authenticator;

    constructor() Key("Dreamcatcher") {
        dreamToken = new DreamToken(/** vault */);
        authenticator = new Authenticator();
    }
}