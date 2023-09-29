// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/interfaces/IUniswapV2Factory.sol";

import "contracts/polygon/interfaces/IUniswapV2Pair.sol";

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

/**
* @dev Finance libary has the functionality of UniswapV2PriceFeedV1
*      and MarketV1. It also has some more functionality that can be
*      used for the purposes of financial math. This is mainly built
*      for non proxy contracts such as the closed beta solstice
*      vault.
 */
library __Finance {

    struct Metadata {
        address pair;
        address tokenA;
        address tokenB;
        string nameA;
        string nameB;
        string symbolA;
        string symbolB;
        uint8 decimalsA;
        uint8 decimalsB;
    }

    /** Public Pure. */

    /**
    * @param v value
    * @param s totalSupply
    * @param b balance
     */
    function amountToMint(uint256 v, uint256 s, uint256 b) public pure returns (uint256) {

        require(
            v != 0 &&
            s != 0 &&
            b != 0,
            "Finance: zero value"
        );
    
        return ((v * s) / b);
    }

    /**
    * @param a amount
    * @param s totalSupply
    * @param b balance
     */
    function amountToSend(uint256 a, uint256 s, uint256 b) public pure returns (uint256) {

        require(
            a != 0 &&
            s != 0 &&
            b != 0,
            "Finance: zero value"
        );

        return ((a * b) / s);
    }

    /** Public View. */

    function price(address factory, address tokenA, address tokenB, uint256 amount) public view returns (uint256) {

        uint256 side = _isSameOrder(factory, tokenA, tokenB);

        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);

        if (pair == address(0)) { return 0; }

        IUniswapV2Pair interface_ = IUniswapV2Pair(pair);

        IERC20Metadata tokenA_ = IERC20Metadata(interface_.token0());

        IERC20Metadata tokenB_ = IERC20Metadata(interface_.token1());

        (uint256 reserveA, uint256 reserveB,) = interface_.getReserves();

        if (side == 1) {

            uint256 rA = reserveA * (10**tokenB_.decimals());

            uint256 price = (amount * rA) / reserveB;

            price *= 10**18;

            price /= 10**tokenA_.decimals();

            return price;
        }

        if (side == 0) {

            uint256 rB = reserveB * (10**tokenA_.decimals());

            uint256 price = (amount * rB) / reserveB;

            price *= 10**18;

            price /= 10**tokenB_.decimals();

            return price;
        }

        else {

            return 0;
        }
    }

    function lastTimestamp(address factory, address tokenA, address tokenB) public view returns (uint256) {

        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);

        if (pair == address(0)) { return 0; }

        IUniswapV2Pair interface_ = IUniswapV2Pair(pair);

        (, , uint256 lastTimestamp) = interface_.getReserves();

        return lastTimestamp;
    }

    function meanPrice(address[] memory factories, address tokenA, address tokenB, uint256 amount) public view returns (uint256) {

        uint256 validOutputs;

        uint256 meanPrice;

        for (uint256 i = 0; i < factories.length; i++) {

            uint256 price = price(factories[i], tokenA, tokenB, amount);

            if (price != 0) { 

                meanPrice += price;

                validOutputs += 1;
            }
        }

        meanPrice /= validOutputs;

        return meanPrice;
    }

    function meanLastTimestamp(address[] memory factories, address tokenA, address tokenB) public view returns (uint256) {

        uint256 validOutputs;

        uint256 meanLastTimestamp;

        for (uint256 i = 0; i < factories.length; i++) {

            uint256 lastTimestamp = lastTimestamp(factories[i], tokenA, tokenB);

            if (lastTimestamp != 0) {

                meanLastTimestamp += lastTimestamp;

                validOutputs += 1;
            }
        }

        meanLastTimestamp /= validOutputs;

        return meanLastTimestamp;
    }

    function netAssetValue(address[] memory factories, address[] memory tokens, address denominator) public view returns (uint256) {

        uint256 netAssetValue;

        for (uint256 i = 0; i < tokens.length; i++) {

            uint256 balance = IERC20Metadata(tokens[i]).balanceOf(address(this));

            uint256 price = meanPrice(factories, tokens[i], denominator, balance);

            netAssetValue += price * balance;
        }

        return netAssetValue;
    }

    function netAssetValuePerToken(address[] memory factories, address token, address[] memory tokens, address denominator) public view returns (uint256) {

        return netAssetValue(factories, tokens, denominator) /= IERC20Metadata(token).totalSupply();
    }

    /** Internal Pure. */

    function _isSameString(string memory stringA, string memory stringB) internal pure returns (bool) {

        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    /** Internal View. */

    function _isSameOrder(address factory, address tokenA, address tokenB) internal view returns (uint256) {

        Metadata memory metadata = _getMetadata(factory, tokenA, tokenB);

        IERC20Metadata(tokenA_) = IERC20Metadata(tokenA);

        IERC20Metadata(tokenB_) = IERC20Metadata(tokenB);

        if (
            tokenA == metadata.tokenA &&
            tokenB == metadata.tokenB &&
            _isSameString(tokenA_.name(), metadata.nameA) &&
            _isSameString(tokenB_.name(), metadata.nameB) &&
            _isSameString(tokenA_.symbol(), metadata.symbolA) &&
            _isSameString(tokenB_.symbol(), metadata.symbolB) &&
            tokenA_.decimals() == metadata.decimalsA &&
            tokenB_.decimals() == metadata.decimalsB
        ) {

            return 0;
        }

        else if (
            tokenA == metadata.tokenB &&
            tokenB == metadata.tokenA &&
            _isSameString(tokenA_.name(), metadata.nameB) &&
            _isSameString(tokenB_.name(), metadata.nameA) &&
            _isSameString(tokenA_.symbol(), metadata.symbolB) &&
            _isSameString(tokenB_.symbol(), metadata.symbolA) &&
            tokenA_.decimals() == metadata.decimalsB &&
            tokenB_.decimals() == metadata.decimalsA
        ) {

            return 1;
        }

        else {

            return 2;
        }
    }

    function _getMetadata(address factory, address tokenA, address tokenB) internal view returns (Metadata memory) {

        Metadata memory metadata;

        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);

        if (pair == address(0)) {

            string memory emptyString;

            metadata = Metadata({
                pair: address(0),
                tokenA: address(0),
                tokenB: address(0),
                nameA: emptyString,
                nameB: emptyString,
                symbolA: emptyString,
                symbolB: emptyString,
                decimalsA: 0,
                decimalsB: 0
            });
        }

        else {

            IUniswapV2Pair interface_ = IUniswapV2Pair(pair);

            IERC20Metadata tokenA_ = IERC20Metadata(interface_.token0());

            IERC20Metadata tokenB_ = IERC20Metadata(interface_.token1());

            metadata = Metadata({
                pair: pair,
                tokenA: interface_.token0(),
                tokenB: interface_.token1(),
                nameA: tokenA_.name(),
                nameB: tokenB_.name(),
                symbolA: tokenA_.symbol(),
                symbolB: tokenB_.symbol(),
                decimalsA: tokenA_.decimals(),
                decimalsB: tokenB_.decimals()
            });
        }

        return metadata;
    }

    /**
    * @return The factory with the best price.
     */
    function _checkBestRoute(address[] memory factories, address tokenIn, address tokenOut, uint256 amountIn) internal view returns (address) {

        uint256 amountOutBest;

        address factoryBest;

        uint256[] memory amountsOut = new uint256[](factories.length);

        for (uint256 i = 0; i < factories.length; i++) {

            amountsOut[i] = price(factories[i], tokenIn, tokenOut, amountIn);

            if (amountsOut[i] > amountOutBest) {

                amountOutBest = amountsOut[i];

                factoryBest = factories[i];
            }
        }

        return factoryBest;
    }
}