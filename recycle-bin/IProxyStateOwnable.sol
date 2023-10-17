// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/interfaces/IProxyState.sol";

interface IProxyStateOwnable is IProxyState {
    event Initialized(address indexed account);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event Paused(address indexed account);

    event Unpaused(address indexed account);

    function owner() external view returns (address);

    function paused() external view returns (bool);

    function initialize() external;

    function upgrade(address implementation) external;

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;

    function pause() external;
    
    function unpause() external;
}