// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/templates/mirai/soltice-v0.2.5/UniswapV2Twap.sol";

library __Oracle {
    function getPair(address factory, address tokenA, address tokenB)
        public view
        returns (IUniswapV2Pair) {
        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        require(pair != address(0x0), "QuickSwapOracle: unable to find pair");
        return IUniswapV2Pair(pair);
    }
}