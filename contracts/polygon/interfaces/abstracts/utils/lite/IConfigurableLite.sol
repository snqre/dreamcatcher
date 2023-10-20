// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IConfigurableLite {
    event Configured(address indexed sender);

    function configured() external view returns (bool);
}