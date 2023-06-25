// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "smart_contracts/module_architecture/ModuleStateLib.sol";

contract ModuleManager {
    using ModuleStateLib for ModuleStateLib.Module;

    mapping(uint => Module) private modules;
    

    function updateModuleMetadata(bytes32 )
}