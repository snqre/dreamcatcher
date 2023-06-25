// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

interface IModule {
    function setModuleManagerImplementation(address newImplementation) external;
}

contract Module {
    uint identifier;
    uint version;
    string name;
    string description;
    bool isActiveImplementation;
    address moduleManagerImplementation;

    constructor() {}

    function mustBeActiveImplementation() external view {
        require(
            isActiveImplementation,
            "Not an active implementation."
        );
    }

    function setModuleManagerImplementation(address newImplementation) external {
        moduleManagerImplementation = newImplementation;
    }

    function getModuleIdentifier() external view returns (uint) { return identifier; }
    function getImplementationVersion() external view returns (uint) { return version; }
    function getModuleName() external view returns (string memory) { return name; }
    function getModuleDescription() external view returns (string memory) { return description; }
}