// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";

interface IModuleManager {
    function create(string memory name) external returns (uint);
    function upgrade(
        string memory name,
        address newImplementation
    ) external;

    function downgrade(
        string memory name,
        uint version
    ) external;

    function getLatestVersion(string memory name) external view returns (uint);
    function getLatestImplementation(string memory name) external view returns (address);
    function getImplementation(
        string memory name,
        uint version
    ) external view returns (address);
}

contract ModuleManager is Context, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    uint count;

    /// @dev a Module is an abstraction for a group of contract addresses that do the same thing.
    struct Module {
        uint identifier;
        string name;
        EnumerableSet.
            AddressSet implementations;
    }

    /// storage.
    mapping(uint => Module) private modules;
    mapping(string => uint) private nameToIdentifier;

    constructor() {}

    function _mustNotBeExistingModule(string memory name) private view {
        /// check if module exists by name.
        require(
            nameToIdentifier[name] == 0,
            "Module name is already in use."
        );
    }

    function _mustBeExistingModule(string memory name) private view {
        /// check if module exists by name.
        require(
            nameToIdentifier[name] != 0,
            "Module does not exist."
        );
    }

    function _mustBeExistingVersion(
        string memory name,
        uint version
    ) private view {
        Module storage module = modules[nameToIdentifier[name]];
        require(
            version >= 1 &&
            version <= module.implementations.length(),
            "Version does not point to an existing implementation."
        );
    }

    function create(string memory name) public nonReentrant returns (uint) {
        /// create a module.
        _mustNotBeExistingModule(name);

        count ++;
        Module storage module = modules[count];

        /// map name to module.
        nameToIdentifier[name] = count;

        module.identifier = count;
        module.name = name;

        return module.identifier;
    }

    function upgrade(
        string memory name,
        address newImplementation
    ) public nonReentrant {
        /// upgrade latest implementation to.
        _mustBeExistingModule(name);
        Module storage module = modules[nameToIdentifier[name]];
        module.implementations.add(newImplementation);
    }

    function downgrade(
        string memory name,
        uint version
    ) public nonReentrant {
        _mustBeExistingModule(name);

        Module storage module = modules[nameToIdentifier[name]];
        upgrade( /// push this version as latest version.
            name,
            module.implementations.at(version)
        );
    }

    function getLatestVersion(string memory name) public view returns (uint) {
        Module storage module = modules[nameToIdentifier[name]];
        return module.implementations.length();
    }

    function getLatestImplementation(string memory name) public view returns (address) {
        Module storage module = modules[nameToIdentifier[name]];
        return module.implementations.at(module.implementations.length());
    }

    function getImplementation(
        string memory name,
        uint version
    ) public view returns (address) {
        _mustBeExistingVersion(
            name,
            version
        );

        Module storage module = modules[nameToIdentifier[name]];
        return module.implementations.at(version);
    }
}