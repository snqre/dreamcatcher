// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/libraries/OurMathLib.sol";
import "contracts/polygon/diamonds/facets/components/RoleComponent.sol";

library OracleComponent {
    using OurMathLib for uint;
    using RoleComponent for RoleComponent.Role;

    event Link(string exchange, address oldFactory, address newFactory, address oldRouter, address newRouter);

    struct Oracle {
        mapping(string => address) _factories;
        mapping(string => address) _routers;
        string[] _exchanges;
    }

    function factories(Oracle storage oracle, string memory exchange) internal view returns (address) {
        return oracle._factories[exchange];
    }

    function routers(Oracle storage oracle, string memory exchange) internal view returns (address) {
        return oracle._routers[exchange];
    }

    function sumAverageValue(Oracle storage oracle, string[] memory exchanges, address[] memory tokens, uint[] memory amounts, address denominator) internal view returns (uint) {
        uint sumAverageValue;
        for (uint i = 0; i < tokens.length; i++) {
            uint averageValue = averageValue(oracle, exchanges, tokens[i], denominator, amounts[i]);
            if (averageValue != 0) {
                sumAverageValue += averageValue;
            }
        }
        return sumAverageValue;
    }

    function sumQuoteAverageValue(Oracle storage oracle, string[] memory exchanges, address[] memory tokens, uint[] memory amounts, address denominator) internal view returns (uint) {
        uint sumQuoteAverageValue;
        for (uint i = 0; i < tokens.length; i++) {
            uint quoteAverageValue = quoteAverageValue(oracle, exchanges, tokens[i], denominator, amounts[i]);
            if (quoteAverageValue != 0) {
                sumQuoteAverageValue += quoteAverageValue;
            }
        }
        return sumQuoteAverageValue;
    }

    function sumValue(Oracle storage oracle, string memory exchange, address[] memory tokens, uint[] memory amounts, address denominator) internal view returns (uint) {
        uint sumValue;
        for (uint i = 0; i < tokens.length; i++) {
            uint value = value(oracle, exchange, tokens[i], denominator, amounts[i]);
            if (value != 0) {
                sumValue += value;
            }
        }
        return sumValue;
    }

    function sumQuoteValue(Oracle storage oracle, string memory exchange, address[] memory tokens, uint[] memory amounts, address denominator) internal view returns (uint) {
        uint sumQuoteValue;
        for (uint i = 0; i < tokens.length; i++) {
            uint quoteValue = quoteValue(oracle, exchange, tokens[i], denominator, amounts[i]);
            if (quoteValue != 0) {
                sumQuoteValue += quoteValue;
            }
        }
        return sumQuoteValue;
    }

    function averageValue(Oracle storage oracle, string[] memory exchanges, address token0, address token1, uint amount) internal view returns (uint) {
        uint averageValue;
        uint success;
        for (uint i = 0; i < exchanges.length; i++) {
            uint value = value(oracle, exchanges[i], token0, token1);
            if (value != 0) {
                averageValue += value;
                success += 1;
            }
        }
        return averageValue / success;
    }

    function quoteAverageValue(Oracle storage oracle, string[] memory exchanges, address token0, address token1, uint amount) internal view returns (uint) {
        uint quoteAverageValue;
        uint success;
        for (uint i = 0; i < exchanges.length; i++) {
            uint quoteValue = quoteValue(oracle, exchanges[i], token0, token1, amount);
            if (quoteValue != 0) {
                quoteAverageValue += quoteValue;
                success += 1;
            }
        }
        return quoteAverageValue / success;
    }

    function value(Oracle storage oracle, string memory exchange, address token0, address token1, uint amount) internal view returns (uint) {
        return (amount * amountOut(oracle, exchange, token0, token1)) / 10**18;
    }

    function quoteValue(Oracle storage oracle, string memory exchange, address token0, address token1, uint amount) internal view returns (uint) {
        return (amount * quote(oracle, exchange, token0, token1)) / 10**18;
    }

    function quote(Oracle storage oracle, string memory exchange, address token0, address token1) internal view returns (uint) {
        IToken tkn0 = IToken(token0);
        IToken tkn1 = IToken(token1);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        IUniswapV2Factory fctr = IUniswapV2Factory(oracle._factories[exchange]);
        address pair = fctr.getPair(token0, token1);
        if (pair == address(0)) { return 0; }
        IUniswapV2Pair pr = IUniswapV2Pair(pair);
        (uint res0, uint res1,) = pr.getReserves();
        if (token0 == pr.token0()) {
            uint amount = 10**decimals0;
            IUniswapV2Router02 rtr = IUniswapV2Router02(oracle._routers[exchange]);
            uint quote = rtr.quote(amount, res0, res1);
            quote = quote.computeAsEtherValue(decimals1);
            return quote;
        } else {
            uint amount = 10**decimals1;
            IUniswapV2Router02 rtr = IUniswapV2Router02(oracle._routers[exchange]);
            uint quote = rtr.quote(amount, res0, res1);
            quote = quote.computeAsEtherValue(decimals1);
            return quote;
        }
    }

    function amountOut(Oracle storage oracle, string memory exchange, address token0, address token1) internal view returns (uint) {
        IToken tkn0 = IToken(token0);
        IToken tkn1 = IToken(token1);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        IUniswapV2Factory fctr = IUniswapV2Factory(oracle._factories[exchange]);
        address pair = fctr.getPair(token0, token1);
        if (pair == address(0)) { return 0; }
        IUniswapV2Pair pr = IUniswapV2Pair(pair);
        (uint res0, uint res1,) = pr.getReserves();
        if (token0 == pr.token0()) {
            uint amount = 10**decimals0;
            IUniswapV2Router02 rtr = IUniswapV2Router02(oracle._routers[exchange]);
            uint amountOut = rtr.getAmountOut(amount, res0, res1);
            amountOut = amountOut.computeAsEtherValue(decimals1);
            return amountOut;
        } else {
            uint amount = 10**decimals1;
            IUniswapV2Router02 rtr = IUniswapV2Router02(oracle._routers[exchange]);
            uint amountOut = rtr.getAmountOut(amount, res0, res1);
            amountOut = amountOut.computeAsEtherValue(decimals1);
            return amountOut;
        }
    }

    function amountsOut(Oracle storage oracle, string memory exchange, address[] memory path) internal view returns (uint) {
        IToken tkn0 = IToken(path[0]);
        IToken tkn1 = IToken(path[path.length - 1]);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        uint amount = 10**decimals0;
        IUniswapV2Router02 rtr = IUniswapV2Router02(oracle._routers[exchange]);
        uint[] memory amountsOut = rtr.getAmountsOut(amount, path);
        uint amountOut = amountsOut[amountsOut.length - 1];
        amountOut = amountOut.computeAsEtherValue(decimals1);
        return amountOut;
    }

    function link(Oracle storage oracle, RoleComponent.Role storage role, string memory exchange, address factory, address router) internal {
        role.tryAuthenticate();
        address oldFactory = factories(oracle, exchange);
        address oldRouter = routers(oracle, exchange);
        oracle._factories[exchange] = factory;
        oracle._routers[exchange] = router;
        emit Link(exchange, oldFactory, factory, oldRouter, router);
    }
}