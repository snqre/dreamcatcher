// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

interface ITerminal {
    event Deploy(string indexed module, address indexed state);

    event Upgrade(string indexed module, address indexed newLogic, address indexed state);

    event Rename(string indexed module, string indexed newModule, address indexed state);

    event Terminate(string indexed module, address indexed state);

    function name() external view returns (string memory);

    function access(string memory module, bytes32 location) external view returns (bytes memory);

    function version(string memory module) external view returns (uint256);

    function latest(string memory module) external view returns (address);

    function previous(string memory module, uint index) external view returns (address);

    function empty(string memory module, bytes32 location) external view returns (bool);

    function modules(string memory module) external view 
    returns (
        string memory module_,
        address state,
        address logic,
        uint256 version,
        bool terminated
    );

    function modulesIndexed(uint index) external view
    returns (
        string memory module_,
        address state,
        address logic,
        uint256 version,
        bool terminated
    );

    function active() external view returns (string[] memory);

    function terminated() external view returns (string[] memory);

    function deploy(string memory module) external;

    function upgrade(string memory module, address newLogic) external;

    function rename(string memory module, string memory newModule) external;

    function terminate(string memory module) external;
}