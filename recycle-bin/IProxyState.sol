// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IProxyState {
    event Upgraded(address indexed implementation);

    function implementation() external view returns (address);
}