// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

interface IState {
    event Stored(address indexed msgSender, bytes32 indexed location, bytes indexed data);

    event Updated(address indexed msgSender, string indexed module);

    event TimerSet(address indexed msgSender, uint64 indexed duration);

    event Upgraded(address indexed msgSender, address indexed newLogic);

    event Locked(address indexed msgSender);

    event Wiped(address indexed msgSender);

    function previous(uint index) external view returns (address);

    function latest() external view returns (address);

    function access(bytes32 location) external view returns (bytes memory);

    function module() external view returns (string memory);

    function version() external view returns (uint256);

    function empty(bytes32 location) external view returns (bool);

    function timestamp() external view returns (uint64);

    function locked() external view returns (bool);

    function core() external view returns (bool);

    function timerSet() external view returns (bool);

    function logic() external view returns (address);

    function terminal() external view returns (address);

    function state(bytes32) external view returns (bytes memory);

    function paused() external view returns (bool);

    function store(bytes32 location, bytes memory data) external;

    function update(string memory nameModule) external;

    function timer(uint64 duration) external;

    function lock() external;

    function wipe() external;

    function upgrade(address newLogic) external;

    function pause() external;

    function unpause() external;
}