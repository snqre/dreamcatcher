// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/abstract/ImplementationAccessControl.sol";

/**
* Stack[0] Terminal
 */
contract TerminalStack0 is ImplementationAccessControl {
    constructor() ImplementationAccessControl(3600 seconds, msg.sender) {}
}