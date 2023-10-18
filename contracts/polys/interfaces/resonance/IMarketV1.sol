// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/ProxyStateOwnableContract.sol";

interface IMarketV1 is IProxyStateOwnable {

    event Swap(
        address indexed router,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address denominator,
        address from,
        address to
    );

    function swapTokens(
        address router,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address denominator,
        address from,
        address to
    ) external;

    function swapTokensSlippage(
        address router,
        address factory,
        address priceFeed,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 slippage,
        address denominator,
        address from,
        address to
    ) external;
}