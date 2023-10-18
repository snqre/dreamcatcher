// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/interfaces/IUniswapV2PriceFeedV1.sol";

import "contracts/polygon/interfaces/IUniswapV2Factory.sol";

import "contracts/polygon/interfaces/IUniswapV2Pair.sol";

import "contracts/polygon/ProxyStateOwnableContract.sol";

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

import "contracts/polygon/interfaces/IUniswapV2Router02.sol";

contract MarketV1 is ProxyStateOwnableContract {

    /** Events. */

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

    /** Public. */

    /**
    * @param tokenIn Is the token contract that is being sold.
    *
    * @param tokenOut Is the token contract that is being purchased.
    *
    * @param amountIn Is the amount of the token being sold.
    *
    * @param amountOutMin Is the minimum amount that should be received
    *        from the sale of the token.
    *
    * @param denominator Is the address of the token that is going to be used
    *        as denominator. ie. USDT or ETH typically have the
    *        liquidity to carry most trades on most exchanges.
    *
    * WARNING: Do not try to use this function to buy or sell the
    *          token that has been used as the denominator.
    *
    * @param from Is the address that is sending the tokens that are
    *        being sold.
    *
    * @param to Is the recipient of the tokens that have been purchased.
    *
    * NOTE A router address must be given and this can be done
    *      on any IUniswapV2Router02 compatible DEX.
     */
    function swapTokens(
        address router,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address denominator,
        address from,
        address to
    ) public onlyOwner() whenNotPaused() {

        /**
        * @dev The contract is standardizing the decimal places to 
        *      ensure they are all a 10**18.
         */
        amountIn *= 10**IERC20Metadata(tokenIn).decimals();
        amountIn /= 10**18;

        /**
        * @dev The contract pulls the tokens that should be sold
        *      as a deposit.
         */
        IERC20Metadata(tokenIn).transferFrom(from, address(this), amountIn);

        /**
        * @dev We have to approve the router and allow it to spend these
        *      tokens.
         */
        IERC20Metadata(tokenIn).approve(router, amountIn);

        address[] memory path;

        path = new address[](3);
        path[0] = tokenIn;
        path[1] = denominator;
        path[2] = tokenOut;

        IUniswapV2Router02(router).swapExactTokensForTokens(
            amountIn, 
            amountOutMin, 
            path, 
            to, 
            block.timestamp
        );

        emit Swap(router, tokenIn, tokenOut, amountIn, amountOutMin, denominator, from, to);
    }

    /**
    * @dev Just like the previous this one swaps tokens but takes
    *      @param slippage to determine the amountOutMin.
     */
    function swapTokensSlippage(
        address router,
        address factory,
        address priceFeed,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 slippage, /** @dev  NOTE 10000 => 100% */
        address denominator,
        address from,
        address to
    ) public onlyOwner() whenNotPaused() {

        /**
        * @dev The contract is standardizing the decimal places to 
        *      ensure they are all a 10**18.
         */
        amountIn *= 10**IERC20Metadata(tokenIn).decimals();
        amountIn /= 10**18;

        /**
        * @dev The contract pulls the tokens that should be sold
        *      as a deposit.
         */
        IERC20Metadata(tokenIn).transferFrom(from, address(this), amountIn);

        /**
        * @dev We have to approve the router and allow it to spend these
        *      tokens.
         */
        IERC20Metadata(tokenIn).approve(router, amountIn);

        (uint256 amountOutMin, uint256 lastTimestamp) = IUniswapV2PriceFeedV1(priceFeed).getPrice(factory, tokenIn, tokenOut, amountIn);

        require(amountOutMin != 0 && lastTimestamp != 0, "MarketV1: abnormal price read");

        require(lastTimestamp <= block.timestamp - 1 days, "MarketV1: outdated price read");

        amountOutMin = (amountOutMin * (10000 - slippage)) / 10000;

        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        path[1] = denominator;
        path[2] = tokenOut;
        
        IUniswapV2Router02(router).swapExactTokensForTokens(
            amountIn, 
            amountOutMin, 
            path, 
            to, 
            block.timestamp
        );

        emit Swap(router, tokenIn, tokenOut, amountIn, amountOutMin, denominator, from, to);
    }
}