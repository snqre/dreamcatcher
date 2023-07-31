// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/projects/mirai/solstice-v1.0.0/oracle/observer/UniswapV2Twap.sol";
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Pair.sol";

// quick-swap-factory 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32
contract Observer is UniswapV2Twap {
    constructor(address tokenA, address tokenB)
        UniswapV2Twap(_getPair(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32, tokenA, tokenB)) {
        
    }

    function _getPair(address factory, address tokenA, address tokenB)
        internal view
        returns (IUniswapV2Pair) {
        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        require(pair != address(0x0), "Observer: unable to find pair");
        return IUniswapV2Pair(pair);
    }

    function update()
        external override(UniswapV2Twap) {
        super.update();
    }

    function consult(address token, uint amountIn)
        external view override(UniswapV2Twap)
        returns (uint amountOut) {
        return super.consult(token, amountIn);
    }
}