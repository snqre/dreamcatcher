// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IOwnableLite {
    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;
}