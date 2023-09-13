// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

interface IConOwnable
{
    event OwnershipTransferred
    (
        address indexed previousOwner,
        address indexed newOwner
    );

    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;
}