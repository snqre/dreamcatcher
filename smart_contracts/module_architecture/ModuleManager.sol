// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";

import "smart_contracts/module_architecture/ModuleStateLib.sol";
import "smart_contracts/module_architecture/Module.sol";

interface IModuleManager {
    
}

contract ModuleManager is Context, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    uint numberOfModules;

    struct Implementation {
        uint version;
        address implementation;
        uint launchTimestamp;
        uint expirationTimestamp;
        bool hasBeenPaused;
        bool hasExpiration;
    }
    
    struct Module {
        uint identifier;
        uint latestVersion;
        address latestImplementation;
        string name;
        uint launchTimestamp;
        uint expirationTimestamp;
        bool hasBeenPaused;
        bool hasExpiration;
    }

    mapping(uint => Module) private modules;
    mapping(uint => mapping(uint => Implementation)) private implementations;
    mapping(string => uint) private nameToIdentifier;

    event ModuleCreated(
        string indexed name,
        uint indexed launchTimestamp,
        uint indexed expirationTimestamp,
        bool hasBeenPaused,
        bool hasExpiration
    );

    event NewImplementation(
        string indexed name,
        address newImplementation,
        uint launchTimestamp,
        uint expirationTimestamp,
        bool hasBeenPaused,
        bool hasExpiration
    );

    constructor() {}

    function _createNewModule(
        string memory name,
        uint launchTimestamp,
        uint expirationTimestamp,
        bool startFromPaused
    ) private returns (uint) {
        numberOfModules ++;
        uint identifier = numberOfModules;
        Module storage module = modules[identifier];

        /// map name to module identifier.
        uint searchResult = nameToIdentifier[name];
        require(searchResult == 0, "Module name is already in use.");
        nameToIdentifier[name] = identifier;

        if (launchTimestamp != 0) {
            require(
                launchTimestamp >= block.timestamp,
                "Module is being launched in the past."
            );
        }

        if (expirationTimestamp != 0) {
            require(
                expirationTimestamp >= block.timestamp,
                "Module is expired in the past."
            );
        }

        if (
            launchTimestamp != 0 &&
            expirationTimestamp != 0
        ) {
            require(
                expirationTimestamp > launchTimestamp,
                "Module expires before it is launched."
            );
        }

        /// basic meta data.
        module.identifier = identifier;
        module.name = name;
        
        /// launch timestamp.
        if (launchTimestamp != 0) { module.launchTimestamp = launchTimestamp; }
        else { module.launchTimestamp = block.timestamp; }

        /// expiration timestamp.
        if (expirationTimestamp != 0) {
            module.hasExpiration = true;
            module.expirationTimestamp = expirationTimestamp;
        }
        
        /// does the module start in a paused state.
        if (startFromPaused) { module.hasBeenPaused = true; }

        emit ModuleCreated(
            module.name, 
            module.launchTimestamp, 
            module.expirationTimestamp, 
            module.hasBeenPaused, 
            module.hasExpiration
        );

        return module.identifier;
    }

    function _pushNewImplementation(
        string memory name,
        address newImplementation,
        uint launchTimestamp,
        uint expirationTimestamp,
        bool startFromPaused
    ) private returns (uint) {
        Module storage module = modules[nameToIdentifier[name]];
        uint version = module.latestVersion ++;
        Implementation storage implementation = implementations[nameToIdentifier[name]][version];

        if (launchTimestamp != 0) {
            require(
                launchTimestamp >= block.timestamp,
                "Implementation is being launched in the past."
            );
        }

        if (expirationTimestamp != 0) {
            require(
                expirationTimestamp >= block.timestamp,
                "Implementation is expired in the past."
            );
        }

        if (
            launchTimestamp != 0 &&
            expirationTimestamp != 0
        ) {
            require(
                expirationTimestamp > launchTimestamp,
                "Implementation expires before it is launched."
            );
        }

        implementation.version = version;
        implementation.implementation = newImplementation;
        module.latestImplementation = newImplementation;
        
        if (launchTimestamp != 0) { implementation.launchTimestamp = launchTimestamp; }
        else { implementation.launchTimestamp = block.timestamp; }

        if (expirationTimestamp != 0) {
            implementation.hasExpiration = true;
            implementation.expirationTimestamp = expirationTimestamp;
        }

        if (startFromPaused) { implementation.hasBeenPaused; }

        emit NewImplementation(
            module.name, 
            implementation.implementation, 
            implementation.launchTimestamp, 
            implementation.expirationTimestamp, 
            implementation.hasBeenPaused, 
            implementation.hasExpiration
        );

        return implementation.version;
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

    function _getLatestVersion(string memory name) private view returns (uint) {
        uint searchResult = nameToIdentifier[name];
        Module storage module = modules[searchResult];
        return module.latestVersion;
    }

    function _getLatestImplementation(string memory name) private view returns (uint) {
        uint searchResult = nameToIdentifier[name];
        Module storage module = modules[searchResult];
        return module.latestImplementation;
    }

    function _getImplementation(
        string memory name,
        uint version
    ) private view returns (address) {
        uint searchResult = nameToIdentifier[name];
        Module storage module = modules[searchResult];
        uint length = module.latestVersion;
        
        require(
            version >= 1 &&
            version <= length,
            "Version does not point to an existing implementation."
        );

        return implementations[searchResult][version];
    }
}