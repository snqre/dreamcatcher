// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";
import "contracts/polygon/external/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

abstract contract SwapperLite is StorageLite {
    event Swap(address indexed router, address indexed tokenIn, address indexed tokenOut, uint amountIn, uint amountOutMin, address denominator);

    function _swapTokens(address router, address tokenIn, address tokenOut, uint amountIn, uint amountOutMin, address denominator) internal virtual {
        IERC20Metadata token = IERC20Metadata(tokenIn);
        amountIn *= 10**IERC20Metadata(tokenIn).decimals();
        amountIn /= 10**18;
        token.approve(router, amountIn);
        path = new address[](3);
        path[0] = tokenIn;
        path[1] = denominator;
        path[2] = tokenOut;
        IUniswapV2Router02 dex = IUniswapV2Router02(router);
        dex.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, address(this), block.timestamp);
        emit Swap(router, tokenIn, tokenOut, amountIn, amountOutMin, denominator);
    }
}