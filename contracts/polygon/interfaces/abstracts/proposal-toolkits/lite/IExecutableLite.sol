// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IExecutableLite {
    event Approved();

    event Executed();

    function approved() external view returns (bool);

    function executed() external view returns (bool);
}