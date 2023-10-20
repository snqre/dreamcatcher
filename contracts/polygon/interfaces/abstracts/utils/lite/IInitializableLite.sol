// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IInitializableLite {
    event Initialized(address indexed sender);

    function initialized() external view returns (bool);
}