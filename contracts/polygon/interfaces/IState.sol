// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

interface IState {
    event Store(bytes32 indexed location, bytes indexed data);
    
    event Update(string indexed module);

    event Upgrade(address indexed newLogic);

    event Lock();

    event Wupe();

    function module() external view returns (string memory);

    function access(bytes32 location) external view returns (bytes memory);

    function version() external view returns (uint256);

    function latest() external view returns (address);

    function previous(uint index) external view returns (address);

    function empty(bytes32 location) external view returns (bool);

    function store(bytes32 location, bytes memory data) external;

    function wipe() external;

    function upgrade(address newLogic) external;

    function update(string memory module) external;

    function lock() external;
}