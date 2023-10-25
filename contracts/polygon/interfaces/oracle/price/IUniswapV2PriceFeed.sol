// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IUniswapVPriceFeed {
    function price(address tokenA, address tokenB) external view returns (uint);
}