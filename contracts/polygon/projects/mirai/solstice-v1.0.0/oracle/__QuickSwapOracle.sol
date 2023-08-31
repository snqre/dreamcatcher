// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/projects/mirai/solstice-v1.0.0/oracle/UniswapV2Twap.sol";

library __QuickSwapOracle {
    function getPair(address factory, address tokenA, address tokenB)
        public view
        returns (IUniswapV2Pair) {
        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        require(pair != address(0x0), "QuickSwapOracle: unable to find pair");
        return IUniswapV2Pair(pair);
    }

    
    
}