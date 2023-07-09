// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/Key.sol";
import "contracts/polygon/projects/dreamcatcher/tokens/DreamToken.sol";

contract Dreamcatcher is Key {
    DreamToken public dreamToken;

    constructor() Key() {
        dreamToken = new DreamToken(/** vault */);
        authenticator = new Authenticator();
        
        createNewModule("dream-token", address(dreamToken), true, []);
    }
}