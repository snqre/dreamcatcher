// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/templates/mirai/solstice-v1.2.0/UniswapV2Twap.sol";
import "contracts/polygon/templates/mirai/solstice-v1.2.0/__QuickSwapOracle.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";

/**
* POLYGON MAINNET
* QUICK Token: 0x831753DD7087CaC61aB5644b308642cc1c33Dc13
* QuickSwapRouter: 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff
* QuickSwapFactory: 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32
* Pair Contract: 0xadbF1854e5883eB8aa7BAf50705338739e558E5b

* MUMBAI TESTNET
* QuickSwapRouter: 0x8954AfA98594b838bda56FE4C12a09D7739D179b
* QuickSwapFactory: 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32

* On paper this should get the twap of a pair
* The quickswap contracts are an exact fork of this
* So it should work exactly the same

* spaghetti code central
 */

/// in our oracle we will deploy the twaps for each required pair
/// and search pair by token addresses
contract QuickSwapOracle {
    IUniswapV2Factory quickSwapFactory;

    address hub;
    UniswapV2Twap[] public observers;
    mapping(address => bool) public isDeployed;
    mapping(address => uint) public pairToObserverIdMapping;

    constructor(address hub_) {
        hub = hub_;
    }

    function _deployObserver(address tokenA, address tokenB)
        public {
        uint id = __QuickSwapOracle.deployObserver(observers, isDeployed[address(getPair(tokenA, tokenB))], tokenA, tokenB);
        pairToObserverIdMapping[address(getPair(tokenA, tokenB))] = id;
    }

    function updateTwap(address tokenA, address tokenB)
        public {
        uint id = pairToObserverIdMapping[getPair(tokenA, tokenB)];
        observers[id].update();
    }

    function getTwap(address tokenA, address tokenB)
        public view
        returns (uint) {
        uint id = pairToObserverIdMapping[getPair(tokenA, tokenB)];
        observers[id].consult(tokenA);
    }

    function getPair(address tokenA, address tokenB)
        public view
        returns (IUniswapV2Pair) {
        return __QuickSwapOracle.getPair(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32, tokenA, tokenB);
    }
}