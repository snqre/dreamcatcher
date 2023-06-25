// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/utils/structs/EnumerableSet.sol";

import "smart_contracts/module_architecture/ModuleStateLib.sol";
import "smart_contracts/module_architecture/Module.sol";

interface IModuleManager {
    
}

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

    /// update module manager.
    /// very computationally intensive so not designed to be used often.
    function _update(
        address newImplementation
    ) private {
        /// let all modules know the location of the new implementation.
        for (
            uint i = 1;
            i < numberOfModules;
            i ++
        ) { /// we let the most recent implementation know but already versions will not change.
            ModuleStateLib.Module storage module = modules[i];
            uint length = module.implementations.length();
            address latestImplementation = module.implementations.at(length);
            IModule(latestImplementation).setModuleManagerImplementation(newImplementation);

            /// for each module we need to transfer existing data to the new one.
            /// so we rebuild each module for each existing on at the new implementation.
            IModuleManager(newImplementation).create(
                module.implementations.at(1),
                module.name,
                module.description
            );

            /// and for each existing implementation we load them in.
            for (
                uint x = 2;
                x < length;
                x ++
            ) { /// for each implementation after the original.
                IModuleManager(newImplementation).updateImplementation(
                    module.name,
                    module.implementations.at(x)
                );
            }
        }
    }
}