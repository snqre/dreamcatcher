// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;

interface IErc173 {
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    function owner() external view returns (address);
    function transferOwnership(address account) external;
}