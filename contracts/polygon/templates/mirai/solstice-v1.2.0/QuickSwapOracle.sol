// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

/// vs code solidity compiler does not like @ imports but i assure you this works
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/lib/contracts/libraries/FixedPoint.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";

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

* top notch spaghetti code
 */

contract UniswapV2Twap {
    using FixedPoint for *;

    uint public constant PERIOD = 10;

    IUniswapV2Pair public immutable pair;
    address public immutable token0;
    address public immutable token1;

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint32 public blockTimestampLast;

    // NOTE: binary fixed point numbers
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;

    // NOTE: public visibility
    // NOTE: IUniswapV2Pair
    constructor(IUniswapV2Pair _pair) public {
        pair = _pair;
        token0 = _pair.token0();
        token1 = _pair.token1();
        price0CumulativeLast = _pair.price0CumulativeLast();
        price1CumulativeLast = _pair.price1CumulativeLast();
        (, , blockTimestampLast) = _pair.getReserves();
    }

    /// according to my understanding this needs to be called to get the latest calculation
    /// but will only update after the given time frame
    /// for our contracts we will only allow trades to be executed with the precise data
    function update() external {
        (
            uint price0Cumulative,
            uint price1Cumulative,
            uint32 blockTimestamp
        ) = UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;

        require(timeElapsed >= PERIOD, "time elapsed < min period");

        // NOTE: overflow is desired
        /*
        |----b-------------------------a---------|
        0                                     2**256 - 1

        b - a is preserved even if b overflows
        */
        // NOTE: uint -> uint224 cuts off the bits above uint224
        // max uint
        // 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        // max uint244
        // 0x00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        price0Average = FixedPoint.uq112x112(
            uint224((price0Cumulative - price0CumulativeLast) / timeElapsed)
        );
        price1Average = FixedPoint.uq112x112(
            uint224((price1Cumulative - price1CumulativeLast) / timeElapsed)
        );

        price0CumulativeLast = price0Cumulative;
        price1CumulativeLast = price1Cumulative;
        blockTimestampLast = blockTimestamp;
    }

    function consult(address token, uint amountIn)
        external
        view
        returns (uint amountOut)
    {
        require(token == token0 || token == token1, "invalid token");

        if (token == token0) {
            // NOTE: using FixedPoint for *
            // NOTE: mul returns uq144x112
            // NOTE: decode144 decodes uq144x112 to uint144
            amountOut = price0Average.mul(amountIn).decode144();
        } else {
            amountOut = price1Average.mul(amountIn).decode144();
        }
    }
}

/// in our oracle we will deploy the twaps for each required pair
/// and search pair by token addresses
contract QuickSwapOracle {
    IUniswapV2Factory quickSwapFactory;

    UniswapV2Twap[] public observers;
    mapping(address => bool) public isDeployed;
    mapping(address => uint) public pairToObserverIdMapping;

    constructor() {
        quickSwapFactory = IUniswapV2Factory(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32);
    }

    /// return pair as an interface if found
    function _getPair(address tokenA, address tokenB)
        private view
        returns (address) {
        address pairAddress = quickSwapFactory.getPair(tokenA, tokenB);
        require(pairAddress != address(0x0), "QuickSwapOracle: unable to find pair");
        return IUniswapV2Pair(pairAddress);
    }

    /// deploys an "observer"
    function _deployObserver(address tokenA, address tokenB)
        private {
        require(!isDeployed[address(_getPair(tokenA, tokenB))], "QuickSwapOracle: observer is already deployed for this pair");
        observers.push();
        observers[observers.length - 1] = new UniswapV2Twap(getPair(tokenA, tokenB));
        pairToObserverIdMapping[address(_getPair(tokenA, tokenB))] = observers.length - 1;
    }

    
}