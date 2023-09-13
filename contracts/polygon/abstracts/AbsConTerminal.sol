// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/interfaces/IConState.sol";

abstract contract AbsConTerminal
{
    bytes32 constant ROUTERS = keccak256("ROUTERS");

    IConState public state;

    event DEPLOY
    (
        string name,
        string module,
        address router
    );
}