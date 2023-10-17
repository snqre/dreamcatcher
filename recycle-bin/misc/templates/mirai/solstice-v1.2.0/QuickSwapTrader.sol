// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/templates/mirai/solstice-v1.2.0/Token.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";

/**
* POLYGON MAINNET
* QUICK Token: 0x831753DD7087CaC61aB5644b308642cc1c33Dc13
* QuickSwapRouter: 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff
* QuickSwapFactory: 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32
* Pair Contract: 0xadbF1854e5883eB8aa7BAf50705338739e558E5b

* MUMBAI TESTNET
* QuickSwapRouter: 0x8954AfA98594b838bda56FE4C12a09D7739D179b
* QuickSwapFactory: 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32
 */
contract QuickSwapTrader {
    address quickSwapFactory;
    address tokenA;
    address tokenB;
    constructor() {
        quickSwapFactory = 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32;
        tokenA = address(new Token("DreamToken", "DREAM"));
        tokenB = address(new Token("Stablecoin", "USDTX"));
        IUniswapV2Factory(quickSwapFactory).createPair(tokenA, tokenB);
        address pair = IUniswapV2Factory(quickSwapFactory).getPair(tokenA, tokenB);
    }

    function _getPair(address factory, address tokenA, address tokenB)
        private view
        returns (address) {
        return IUniswapV2Factory(factory).getPair(tokenA, tokenB);
    }

    function _requirePairMatch(address pair_, address factory_, address tokenA, address tokenB)
        private view 
        returns (uint, address, address, address, uint112, uint112, uint32, uint, uint, uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(pair_);
        require(tokenA == pair.token0() && tokenB == pair.token1() && factory_ == pair.factory(), "QuickSwapOracle: pair does not match");
        (uint112 reserveA, uint112 reserveB, uint32 blockTimestampLast) = pair.getReserves();
        return (pair.MINIMUM_LIQUIDITY(), pair.factory(), pair.token0(), pair.token1(), reserveA, reserveB, blockTimestampLast, pair.price0CumulativeLast(), pair.price1CumulativeLast(), pair.kLast());
    }

    function getPrice(address tokenA, address tokenB)
        public view
        returns (uint) {
        address pair = _getPair(quickSwapFactory, tokenA, tokenB);
        (, , , , uint112 reserveA, uint112 reserveB, , , , ) = _requirePairMatch(pair, quickSwapFactory, tokenA, tokenB);
        return reserveB / reserveA;
    }

    function swap(address tokenA, address tokenB)
        public {
        
    }
}