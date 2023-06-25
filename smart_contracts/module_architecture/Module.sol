// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

/// all our contracts inherit a module wrapper

interface IModule {

    function setModuleManagerImplementation(address newImplementation) external;
    
}

contract Module {
    /// module copy of module manager Module struct.


    struct Implementation {
        uint moduleIdentifier;
        uint version;
        string moduleName;
        string moduleDescription;
        bool isActiveImplementation;
        address moduleManagerImplementation;
    }

    Implementation private implementation;

    constructor() {}

    function mustBeActiveImplementation() external view {
        require(
            implementation.isActiveImplementation,
            "Not an active implementation."
        );
    }

    function setModuleManagerImplementation(address newImplementation) external {
        implementation.moduleManagerImplementation = newImplementation;
    }

    function getModuleIdentifier() external view returns (uint) { return identifier; }
    function getImplementationVersion() external view returns (uint) { return version; }
    function getModuleName() external view returns (string memory) { return name; }
    function getModuleDescription() external view returns (string memory) { return description; }
}

contract DC88ModuleWrapper()