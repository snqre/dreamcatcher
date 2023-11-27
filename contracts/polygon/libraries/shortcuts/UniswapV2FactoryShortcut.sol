// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router01.sol";

library UniswapV2RouterShortcut {
    function factory(address router) internal view returns (address) {
        return IUniswapV2Router01(router).factory();
    }

    function WETH(address router) internal view returns (address) {
        return IUniswapV2Router01(router).WETH();
    }

    function quote(address router, uint amountA, uint reserveA, uint reserveB) internal view returns (uint) {
        return IUniswapV2Router01(router).quote(amountA, uint reserveA, reserveB);
    }

    function getAmountOut(address router, uint amountIn, uint reserveIn, uint reserveOut) internal view returns (uint) {
        return IUniswapV2Router01(router).getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(address router, uint amountOut, uint reserveIn, uint reserveOut) internal view returns (uint) {
        return IUniswapV2Router01(router).getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(address router, uint amountIn, address[] memory path) internal view returns (uint[] memory) {
        return IUniswapV2Router01(router).getAmountsOut(amountIn, path);
    }

    function getAmountsIn(address router, uint amountOut, address[] memory path) internal view returns (uint[] memory) {
        return IUniswapV2Router01(router).getAmountsIn(amountOut, path);
    }
}