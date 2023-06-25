// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

interface IModule {
    function setModuleManagerImplementation(address newImplementation) external;
}