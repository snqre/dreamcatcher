// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/security/ReentrancyGuard.sol";

import "smart_contracts/module_architecture/ModuleManager.sol";

contract Terminal is ReentrancyGuard {
    ModuleManager private moduleManager;

    constructor() {
        /// using module manager we keep track of any static upgrades.
        moduleManager = new ModuleManager();
        moduleManager.create("Terminal");
        moduleManager.upgrade(
            "Terminal",
            address(this)
        );
    }
}