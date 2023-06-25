// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Implementation {
    string moduleName;
    uint public version;

    constructor(
        string memory moduleName_,
        uint version_
    ) {
        moduleName = moduleName_;
        version = version_;
    }
    
    function getParent() external view returns (string memory) {
        return moduleName;
    }

    function getVersion() external view returns (uint) {
        return version;
    }
}