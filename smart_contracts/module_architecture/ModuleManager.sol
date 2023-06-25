// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/utils/structs/EnumerableSet.sol";

import "smart_contracts/module_architecture/ModuleStateLib.sol";

contract ModuleManager {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint numberOfModules;

    mapping(string => uint) private modulesSearch;
    mapping(uint => ModuleStateLib.Module) private modules;

    constructor() {}

    function _updateImplementation(
        string memory name,
        address newImplementation
    ) private {
        uint searchResult = modulesSearch[name];
        ModuleStateLib.Module storage module = modules[searchResult];
        module.version ++;
        module.implementations.add(newImplementation);
    }

    function _create(
        address implementation,
        string memory name,
        string memory description
    ) private {
        numberOfModules ++;
        ModuleStateLib.Module storage module = modules[numberOfModules];
        module.identifier = numberOfModules;

        /// push first implementation
        module.version ++;
        module.implementations.add(implementation);

        module.name = name;
        module.description = description;
        module.isActive;

        /// map name to module identifier.
        uint searchResult = modulesSearch[module.name];
        require(searchResult == 0, "Module name is already in use.");
        modulesSearch[module.name] = module.identifier;
    }

    function _getLatestVersion(string memory name) private view returns (uint) {
        uint searchResult = modulesSearch[name];
        ModuleStateLib.Module storage module = modules[searchResult];
        return module.version;
    }

    function _getLatestImplementation(string memory name) private view returns (address) {
        uint searchResult = modulesSearch[name];
        ModuleStateLib.Module storage module = modules[searchResult];
        uint length = module.implementations.length();
        return module.implementations.at(length);
    }

    function _getImplementation(
        string memory name,
        uint version
    ) private view returns (address) {
        uint searchResult = modulesSearch[name];
        ModuleStateLib.Module storage module = modules[searchResult];
        uint length = module.implementations.length();

        require(
            version >= 1 &&
            version <= length,
            "Version does not point to an existing implementation."
        );

        return module.implementations.at(version);
    }
}