// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/interfaces/IConOwnable.sol";

interface IConState is IConOwnable
{
    event Update
    (
        bytes32 indexed location,
        bytes indexed data
    );

    event Upgrade(address indexed newImplementation);

    function access(bytes32 location) external view returns (bytes memory);

    function store
    (
        bytes32 location,
        bytes memory data
    )
    external;

    function upgrade(address newImplementation)
    external;
}