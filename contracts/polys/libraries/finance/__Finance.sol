// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/interfaces/IUniswapV2Factory.sol";

import "contracts/polygon/interfaces/IUniswapV2Pair.sol";

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

import "contracts/polygon/interfaces/IUniswapV2Router02.sol";

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
    *
    * @dev We use this to determine how much of a pool's tokens to
    *      mint for the depositor when new tokens enter a vault.
     */
    function amountToMint(uint256 v, uint256 s, uint256 b) public pure returns (uint256) {

        require(
            v != 0 &&
            s != 0 &&
            b != 0,
            "__Finance: zero value"
        );
    
        return ((v * s) / b);
    }

    /**
    * @param a amount
    * @param s totalSupply
    * @param b balance
    *
    * @dev We use this to determine how much value to send to a
    *      depositor when they want to withdraw from a vault.
     */
    function amountToSend(uint256 a, uint256 s, uint256 b) public pure returns (uint256) {

        require(
            a != 0 &&
            s != 0 &&
            b != 0,
            "__Finance: zero value"
        );

        return ((a * b) / s);
    }

    /** Public View. */

    /**
    * @notice Calculates the price of a given amount in one token in terms of another token in a UniswapV2 pair.
    * @param factory The address of the UniswapV2 factory contract.
    * @param tokenA The address of the first token in the pair.
    * @param tokenB The address of the second token in the pair.
    * @param amount The amount of tokenA or tokenB for which to calculate the price.
    * @return uint256 Returns the calculated price, denominated in the other token, for the specified amount.
    *         If the pair does not exist, or if there is an issue with determining the order of tokens, returns 0.
    */
    function price(address factory, address tokenA, address tokenB, uint256 amount) public view returns (uint256) {

        uint256 side = _isSameOrder(factory, tokenA, tokenB);

        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);

        if (pair == address(0)) { return 0; }

        IUniswapV2Pair interface_ = IUniswapV2Pair(pair);

        IERC20Metadata tokenA_ = IERC20Metadata(interface_.token0());

        IERC20Metadata tokenB_ = IERC20Metadata(interface_.token1());

        (uint256 reserveA, uint256 reserveB,) = interface_.getReserves();

        if (side == 1) {

            uint256 price = (amount * (reserveA * (10**tokenB_.decimals()))) / reserveB;

            price *= 10**18;

            price /= 10**tokenA_.decimals();

            return price;
        }

        if (side == 0) {

            uint256 price = (amount * (reserveB * (10**tokenA_.decimals()))) / reserveA;

            price *= 10**18;

            price /= 10**tokenB_.decimals();

            return price;
        }

        else {

            return 0;
        }
    }

    /**
    * @notice Retrieves the timestamp of the last update for the reserves of a UniswapV2 pair.
    * @param factory The address of the UniswapV2 factory contract.
    * @param tokenA The address of the first token in the pair.
    * @param tokenB The address of the second token in the pair.
    * @return uint256 Returns the timestamp of the last update for the reserves of the specified UniswapV2 pair.
    *         If the pair does not exist, returns 0.
    */
    function lastTimestamp(address factory, address tokenA, address tokenB) public view returns (uint256) {

        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);

        if (pair == address(0)) { return 0; }

        IUniswapV2Pair interface_ = IUniswapV2Pair(pair);

        (, , uint256 lastTimestamp) = interface_.getReserves();

        return lastTimestamp;
    }

    /**
    * @notice Calculates the mean price of a given amount in one token in terms of another token across multiple UniswapV2 factories.
    * @param factories An array of addresses representing the UniswapV2 factory contracts to consider.
    * @param tokenA The address of the first token in the pair.
    * @param tokenB The address of the second token in the pair.
    * @param amount The amount of tokenA or tokenB for which to calculate the mean price.
    * @return uint256 Returns the mean price of the specified amount across the provided UniswapV2 factories.
    *         If no valid prices are obtained from any factory, returns 0.
    */
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

        if (meanPrice != 0 && validOutputs != 0) {

            meanPrice /= validOutputs;
        }

        else {

            return 0;
        }

        return meanPrice;
    }

    /**
    * @notice Calculates the mean timestamp of the last update for the reserves of a UniswapV2 pair across multiple factories.
    * @param factories An array of addresses representing the UniswapV2 factory contracts to consider.
    * @param tokenA The address of the first token in the pair.
    * @param tokenB The address of the second token in the pair.
    * @return uint256 Returns the mean timestamp of the last update for the reserves of the specified UniswapV2 pair across the provided factories.
    *         If no valid timestamps are obtained from any factory, returns 0.
    */
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

    /**
    * @return The total valuation of ie. a pool of assets.
    *
    * WARNING: This may return zero or fall short if one or all
    *          of the factories either do not have a pair or
    *          there was an issue getting the valuation. This
    *          is also applied to each token, it is important to
    *          make sure input is correct and that at least one or more
    *          factories have the pair and price that is being searched
    *          for.
     */
    function netAssetValue(address[] memory factories, address[] memory tokens, address denominator) public view returns (uint256) {

        uint256 netAssetValue;

        for (uint256 i = 0; i < tokens.length; i++) {

            uint256 balance = IERC20Metadata(tokens[i]).balanceOf(address(this));

            uint256 price = meanPrice(factories, tokens[i], denominator, balance);

            netAssetValue += price * balance;
        }

        return netAssetValue;
    }

    /**
    * @return The total valuation of ie. a pool of assets divided
    *         by its total supply of pool tokens. This can
    *         can get the "share price" of a pool in terms of
    *         the assets that its holding. This is used to calculate
    *         how much to mint or send through deposits or withdrawals.
    *
    * WARNING: This may return zero or fall short if one or all
    *          of the factories either do no not have a pair
    *          or there was an issue getting the valuation.
    *          This is also applied to each token, it is important
    *          to make sure input is correct and that at least 
    *          one or more factories have the pair and price 
    *          that is being searched for.
     */
    function netAssetValuePerToken(address[] memory factories, address token, address[] memory tokens, address denominator) public view returns (uint256) {

        return netAssetValue(factories, tokens, denominator) / IERC20Metadata(token).totalSupply();
    }

    /**
    * @return The factory with the best price. This is useful because
    *         using the factory we can set a mapping for the
    *         corresponding router contract and use that to
    *         swap using the better router. The price will return zero
    *         if the pair does not exist for that pair. Meaning
    *         that if all factories are giving the price of zero
    *         the best factory will be the first therefore further
    *         checks are required when using this function.
    *
    * WARNING: Best factory may return best amount out of zero.
     */
    function checkBestFactory(address[] memory factories, address tokenIn, address tokenOut, uint256 amountIn) public view returns (address) {

        uint256 bestAmountOut;

        address bestFactory;

        for (uint256 i = 0; i < factories.length; i++) {

            uint256 amountOut = price(factories[i], tokenIn, tokenOut, amountIn);

            if (amountOut >= bestAmountOut) {

                bestFactory = factories[i];

                bestAmountOut = amountOut;
            }
        }

        return bestFactory;
    }

    /**
    * @return The best amount of from the best factory. Just like the above function
    *         this is useful for various math. Again just like the above
    *         if the best factory returns zero then this will also return
    *         zero. This may happen because the pair was not found
    *         or because it is genuinly zero either way it is
    *         important to do further checks when using this function.
    *
    * WARNING: Best amount out may be zero.
     */
    function checkBestAmountOut(address[] memory factories, address tokenIn, address tokenOut, uint256 amountIn) public view returns (uint256) {

        uint256 bestAmountOut;

        for (uint256 i = 0; i < factories.length; i++) {

            uint256 amountOut = price(factories[i], tokenIn, tokenOut, amountIn);

            if (amountOut >= bestAmountOut) {

                bestAmountOut = amountOut;
            }
        }

        return bestAmountOut;
    }

    /** Public. */

    /**
    * @notice Executes a simple token swap on a UniswapV2 router with specified parameters.
    * @param router The address of the UniswapV2 router contract.
    * @param tokenIn The address of the input token to be swapped.
    * @param tokenOut The address of the output token to receive in the swap.
    * @param amountIn The amount of input token to be swapped.
    * @param amountOutMin The minimum acceptable amount of output tokens to receive in the swap.
    * @param denominator The address of an intermediary token used in the swap path.
    * @dev Transforms the amountIn to match token decimals, approves the router, constructs the swap path, and executes the swap using the UniswapV2 router with the specified parameters.
    */
    function swapTokens(address router, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin, address denominator) public {

        amountIn *= 10**IERC20Metadata(tokenIn).decimals();
        amountIn /= 10**18;

        IERC20Metadata(tokenIn).approve(router, amountIn);

        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        path[1] = denominator;
        path[2] = tokenOut;

        IUniswapV2Router02(router).swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), block.timestamp);
    }

    /**
    * @notice Executes a token swap with slippage tolerance on a UniswapV2 router using the mean price and mean last timestamp across multiple factories.
    * @param router The address of the UniswapV2 router contract.
    * @param factories An array of addresses representing the UniswapV2 factory contracts to consider.
    * @param tokenIn The address of the input token to be swapped.
    * @param tokenOut The address of the output token to receive in the swap.
    * @param amountIn The amount of input token to be swapped.
    * @param slippage The acceptable slippage percentage for the swap.
    * @param denominator The address of an intermediary token used in the swap path.
    * @dev Transforms the amountIn to match token decimals, approves the router, calculates minimum output amount considering slippage, constructs the swap path, and executes the swap using the UniswapV2 router.
    */
    function swapTokensSlippage(address router, address[] memory factories, address tokenIn, address tokenOut, uint256 amountIn, uint256 slippage, address denominator) public {
        
        amountIn *= 10**IERC20Metadata(tokenIn).decimals();
        amountIn /= 10**18;

        IERC20Metadata(tokenIn).approve(router, amountIn);

        uint256 amountOutMin = meanPrice(factories, tokenIn, tokenOut, amountIn);

        uint256 lastTimestamp = meanLastTimestamp(factories, tokenIn, tokenOut);

        amountOutMin = (amountOutMin * (10000 - slippage)) / 10000;

        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        path[1] = denominator;
        path[2] = tokenOut;

        IUniswapV2Router02(router).swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), block.timestamp);
    }

    /** Internal Pure. */

    function _isSameString(string memory stringA, string memory stringB) internal pure returns (bool) {

        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    /** Internal View. */

    /**
    * @notice Checks if two tokens have the same order in terms of their metadata on a given factory.
    * @param factory The address of the factory contract.
    * @param tokenA The address of the first token.
    * @param tokenB The address of the second token.
    * @return uint256 Returns:
    *         - 0 if tokens are in the same order as stored in metadata.
    *         - 1 if tokens are in the reverse order as stored in metadata.
    *         - 2 if tokens have different metadata.
    */
    function _isSameOrder(address factory, address tokenA, address tokenB) internal view returns (uint256) {

        Metadata memory metadata = _getMetadata(factory, tokenA, tokenB);

        IERC20Metadata tokenA_ = IERC20Metadata(tokenA);

        IERC20Metadata tokenB_ = IERC20Metadata(tokenB);

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

    /**
    * @notice Retrieves metadata for a token pair on a UniswapV2 factory.
    * @param factory The address of the UniswapV2 factory contract.
    * @param tokenA The address of the first token in the pair.
    * @param tokenB The address of the second token in the pair.
    * @return Metadata Returns a structure containing metadata for the specified token pair:
    *         - pair: The address of the UniswapV2 pair contract.
    *         - tokenA: The address of the first token in the pair.
    *         - tokenB: The address of the second token in the pair.
    *         - nameA: The name of the first token.
    *         - nameB: The name of the second token.
    *         - symbolA: The symbol of the first token.
    *         - symbolB: The symbol of the second token.
    *         - decimalsA: The number of decimals for the first token.
    *         - decimalsB: The number of decimals for the second token.
    */
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
}