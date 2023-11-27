// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Factory.sol";

library UniswapV2RouterShortcut {
    function feeTo(address factory) internal view returns (address) {
        return IUniswapV2Factory(factory).feeTo();
    }

    function feeToSetter(address factory) internal view returns (address) {
        return IUniswapV2Factory(factory).feeToSetter();
    }

    function getPair(address factory, address tokenA, address tokenB) internal view returns (address) {
        return IUniswapV2Factory(factory).getPair(tokenA, tokenB);
    }

    function allPairs(address factory, uint i) internal view returns (address) {
        return IUniswapV2Factory(factory).allPairs(i);
    }

    function allPairsLength(address factory) internal view returns (uint) {
        return IUniswapV2Factory(factory).allPairsLength();
    }
}