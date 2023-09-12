// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

interface IQuickSwapPlugIn {
    /**
        @return
        pair address
        tokenA address
        tokenB address
        tokenA name
        tokenB name
        tokenA symbol
        tokenB symbol
        tokenA decimals
        tokenB decimals
    */
    function getContext
    (
        address tokenA,
        address tokenB
    )
    external view
    returns
    (
        address,
        address,
        address,
        string memory,
        string memory,
        string memory,
        string memory,
        uint256,
        uint256
    );

    function isSameOrder
    (
        address tokenA,
        address tokenB
    )
    external view
    returns (uint8);

    /**
        @return
        price
        timestamp
    */
    function getPrice
    (
        address tokenA,
        address tokenB,
        uint256 amount
    )
    external view
    returns
    (
        uint256,
        uint64
    );

    function swapTokens
    (
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address gate,
        address form,
        address to
    )
    external
    returns (uint256[] memory);

    function swapTokensSlippage
    (
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 slippage,
        address gate,
        address from,
        address to
    )
    external
    returns (uint256[] memory);
}