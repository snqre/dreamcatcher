// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

interface ITerminal {
    event RouterDeployed(address indexed msgSender, string indexed module);

    event RouterUpgraded(address indexed msgSender, string indexed module, address indexed newLogic);

    event RouterRenamed(address indexed msgSender, string indexed module, string indexed newModule);

    event RouterLocked(address indexed msgSender, string indexed module);

    event RouterTimerSet(address indexed msgSender, string indexed module, uint64 indexed duration);

    event RouterPaused(address indexed msgSender, string indexed module);

    event RouterUnpaused(address indexed msgSender, string indexed module);

    event OwnershipTransferred(address indexed msgSender, address indexed newOwner);

    event Updated(address indexed msgSender, string indexed newName);

    function name() external view returns (string memory);

    function access(string memory module, bytes32 location) external view returns (bytes memory);

    function version(string memory module) external view returns (uint256);

    function latest(string memory module) external view returns (address);

    function previous(string memory module, uint256 index) external view returns (address);

    function empty(string memory module, bytes32 location) external view returns (bool);

    function timestamp(string memory module) external view returns (uint64);

    function locked(string memory module) external view returns (bool);

    function core(string memory module) external view returns (bool);

    function timerSet(string memory module) external view returns (bool);

    function logic(string memory module) external view returns (address);

    function terminal(string memory module) external view returns (address);

    function searchByName(string memory module) external view
    returns (
        string memory module,
        address terminal,
        address state,
        address logic,
        uint256 version,
        uint64 timestamp,
        bool core,
        bool locked,
        bool paused,
        bool timerSet
    );
}