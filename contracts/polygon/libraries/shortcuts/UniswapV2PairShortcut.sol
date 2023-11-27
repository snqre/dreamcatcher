// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Pair.sol";

library UniswapV2PairShortcut {
    function MINIMUM_LIQUIDITY(address pair) internal view returns (uint) {
        return IUniswapV2Pair(pair).MINIMUM_LIQUIDITY();
    }

    function token0(address pair) internal view returns (address) {
        return IUniswapV2Pair(pair).token0();
    }

    function token1(address pair) internal view returns (address) {
        return IUniswapV2Pair(pair).token1();
    }

    function getReserves(address pair) internal view returns (uint112, uint112, uint32) {
        return IUniswapV2Pair(pair).getReserves();
    }

    function price0CumulativeLast(address pair) internal view returns (uint) {
        return IUniswapV2Pair(pair).price0CumulativeLast();
    }

    function price1CumulativeLast(address pair) internal view returns (uint) {
        return IUniswapV2Pair(pair).price1CumulativeLast();
    }

    function kLast(address pair) internal view returns (uint) {
        return IUniswapV2Pair(pair).kLast();
    }
}