// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IPausable {
    event Paused();

    event Unpaused();

    function paused() external view returns (bool);
}