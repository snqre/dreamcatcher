// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/interfaces/IProxyStateOwnable.sol";

interface ITerminalV1 is IProxyStateOwnable {
    
    event ProxyDeployed(string indexed name, address indexed proxy);

    event ProxyUpgraded(string indexed name, address indexed proxy, address indexed implementation);

    event ProxyPaused(string indexed name, address indexed proxy);

    event ProxyUnpaused(string indexed name, address indexed proxy);

    event ProxyReleased(string indexed name, address indexed proxy);

    function getDeployed(uint256 index) external view returns (address);

    function getSupported(uint256 index) external view returns (address);

    function getLatestImplementation(string calldata name) external view returns (address);

    function getImplementation(string calldata name, uint256 index) external view returns (address);

    function getVersion(string calldata name) external view returns (uint256 index);

    function getNames(uint256 index) external view returns (string memory);

    function deploy(string calldata name) external returns (address);

    function upgradeTo(string calldata name, address implementation) external;

    function pause_(string calldata name) external;

    function unpause_(string calldata name) external;

    function release(string calldata name) external;
}