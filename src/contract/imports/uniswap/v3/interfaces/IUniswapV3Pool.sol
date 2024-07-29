// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;
import "./IUniswapV3Immutables.sol";
import "./IUniswapV3PoolState.sol";
import "./IUniswapV3PoolDerivedState.sol";
import "./IUniswapV3PoolActions.sol";
import "./IUniswapV3PoolOwnerActions.sol";
import "./IUniswapV3PoolEvents.sol";

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{}