// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Pair.sol";

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
contract QuickSwapOracle {
    address quickSwapFactory;

    constructor() {
        quickSwapFactory = 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32;
    }

    function getPair(
        address tokenA, 
        address tokenB
        ) public view
        returns (
            address,
            uint,
            address,
            address,
            address,
            uint112,
            uint112,
            uint32,
            uint,
            uint,
            uint
            ) {
        address pairAddress = IUniswapV2Factory(
            quickSwapFactory
            ).getPair(
                tokenA, 
                tokenB
            );

        require(
            pairAddress != address(0), 
            "QuickSwapOracle: match not found"
        );

        IUniswapV2Pair pair = IUniswapV2Pair(
            pairAddress
        );

        (
            uint112 reserveA,
            uint112 reserveB,
            uint32 blockTimestampLast
        ) = pair.getReserves();
        
        return (
            pairAddress,
            pair.MINIMUM_LIQUIDITY,
            pair.factory(),
            pair.token0(),
            pair.token1(),
            reserveA,
            reserveB,
            blockTimestampLast,
            pair.price0CumulativeLast,
            pair.price1CumulativeLast,
            pair.kLast
        );
    }

    function getPrice(
        address tokenA, 
        address tokenB
        ) public view
        returns (uint) {
        (
            ,
            ,
            ,
            ,
            ,
            uint112 reserveA,
            uint112 reserveB,
            ,
            ,
            ,
        ) = getPair(
            tokenA,
            tokenB
        );

        return reserveB / reserveA;
    }
}