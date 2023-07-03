// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/templates/modular_upgradeable/Key.sol";
import "contracts/projects/dreamcatcher/tokens/DreamToken.sol";

contract Dreamcatcher is Key {
    DreamToken public dreamToken;

    constructor() Key("Dreamcatcher") {
        dreamToken = new DreamToken(/** vault */);
    }
}