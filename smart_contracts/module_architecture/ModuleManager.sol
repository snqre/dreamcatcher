// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
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
    
    function getImplementations(string memory name) external view returns (address[] memory);
    function getModules() external view returns (string[] memory);
}

contract ModuleManager is IModuleManager, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    uint public count; /// number of modules.

    /// @dev a Module is an abstraction for a group of contract addresses that do the same thing.
    struct Module {
        uint identifier;
        string name;
        EnumerableSet.
            AddressSet implementations;
    }

    /// main storage.
    mapping(uint => Module) private modules;
    mapping(string => uint) public nameToIdentifier;

    event ModuleCreated(
        string indexed name,
        uint indexed identifer
    );

    event ModuleUpgraded(
        string indexed name,
        uint indexed identifier,
        address indexed newImplementation
    );

    event ModuleDowngraded(
        string indexed name,
        uint indexed identifier,
        address indexed newImplementation
    );

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

    function _mustNotBeDuplicateImplementation(
        string memory name,
        address newImplementation
    ) private view {
        /// @dev it is still possible to have duplicates using downgrade.
        Module storage module = modules[nameToIdentifier[name]];
        require(
            !module.implementations.contains(newImplementation),
            "Module already has this implementation."
        );
    }

    function _upgrade(
        string memory name,
        address newImplementation
    ) private {
        /// upgrade latest implementation to.
        _mustBeExistingModule(name);
        Module storage module = modules[nameToIdentifier[name]];
        module.implementations.add(newImplementation);
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

        emit ModuleCreated(
            module.name,
            module.identifier
        );

        return module.identifier;
    }

    function upgrade(
        string memory name,
        address newImplementation
    ) public nonReentrant {
        /// check for duplicate implementation for module.
        _mustNotBeDuplicateImplementation(
            name,
            newImplementation
        );

        _upgrade(
            name,
            newImplementation
        );

        emit ModuleUpgraded(
            name,
            nameToIdentifier[name],
            newImplementation
        );
    }

    function downgrade(
        string memory name,
        uint version
    ) public nonReentrant {
        _mustBeExistingModule(name);

        Module storage module = modules[nameToIdentifier[name]];
        _upgrade( /// push this version as latest version.
            name,
            module.implementations.at(version)
        );

        emit ModuleDowngraded(
            module.name,
            module.identifier,
            module.implementations.at(version)
        );
    }

    function getLatestVersion(string memory name) public view returns (uint) {
        /// return the active version for this module.
        Module storage module = modules[nameToIdentifier[name]];
        return module.implementations.length();
    }
    /// for some reason this doesnt work.
    function getLatestImplementation(string memory name) public view returns (address) {
        /// return the address to the active implementation for this module.
        Module storage module = modules[nameToIdentifier[name]];
        return module.implementations.at(module.implementations.length());
    }

    function getImplementation(
        string memory name,
        uint version
    ) public view returns (address) {
        /// search the address of an existing version.
        _mustBeExistingVersion(
            name,
            version
        );

        Module storage module = modules[nameToIdentifier[name]];
        return module.implementations.at(version);
    }
    /// and this is return a zero address even when a module has been upgraded.
    function getImplementations(string memory name) public view returns (address[] memory) {
        /// @dev return an array with all the implementations for a module.
        Module storage module = modules[nameToIdentifier[name]];
        address[] memory implementations = new address[](module.implementations.length());
        for (
            uint i = 0; 
            i <= module.implementations.length(); 
            i ++
        ) {
            implementations[i] = module.implementations.at(i);
        }

        return implementations;
    }

    function getModules() public view returns (string[] memory) {
        /// @dev return an array with all the names of existing modules.
        string[] memory names = new string[](count);
        for (
            uint i = 0;
            i <= count;
            i++
        ) {
            Module storage module = modules[i];
            names[i] = module.name;
        }
        /// return the array with all the names of existing modules.
        return names;
    }
}