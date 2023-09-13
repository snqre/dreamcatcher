// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/interfaces/IConOwnable.sol";

import "contracts/polygon/abstracts/AbsConRouter.sol";

interface IConRouter is IConOwnable
{
    event Upgrade(address indexed newImplementation);

    function access() external view returns (AbsConRouter.Self memory);

    function latestVersion() external view returns (uint256);

    function implementation(uint index) external view returns
    (
        string memory name,
        address logic,
        uint256 version
    );

    function latestImplementation() external view returns
    (
        string memory name,
        address logic,
        uint256 version
    );

    function upgrade
    (
        string memory name,
        address newImplementation
    )
    external;
}