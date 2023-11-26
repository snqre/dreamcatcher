// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/libraries/OurMathLib.sol";
import "contracts/polygon/diamonds/facets/components/RoleComponent.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

library OracleComponent {
    using OurMathLib for uint;
    using RoleComponent for RoleComponent.Role;
    using EnumerableSet for EnumerableSet.bytes32Set;

    event OracleSourceMapped(bytes32 source, address oldFactory, address oldRouter, address newFactory, address newRouter);
    event OracleDenominatorAssigned(address oldDenominator, address newDenominator);

    struct Oracle {
        mapping(bytes32 => address) _factories;
        mapping(bytes32 => address) _routers;
        EnumerableSet.bytes32Set _sources;
        address _denominator;
    }

    function factories(Oracle storage oracle, bytes32 source) internal view returns (address) {
        return oracle._factories[source];
    }

    function routers(Oracle storage oracle, bytes32 source) internal view returns (address) {
        return oracle._routers[source];
    }

    function sources(Oracle storage oracle, uint i) internal view returns (bytes32) {
        return oracle._sources.at(i);
    }

    function sources(Oracle storage oracle) internal view returns (bytes32[] memory) {
        return oracle._sources.values();
    }

    function sourcesLength(Oracle storage oracle) internal view returns (uint) {
        return oracle._sources.length();
    }

    function sourcesContains(Oracle storage oracle, bytes32 source) internal view returns (bool) {
        return oracle._sources.contains(source);
    }

    function denominator(Oracle storage oracle) internal view returns (address) {
        return oracle._denominator;
    }

    function sumAverageValue(Oracle storage oracle, address[] memory tokens, uint[] memory amounts) internal view returns (uint) {
        uint sumAverageValue;
        for (uint i = 0; i < tokens.length; i++) {
            uint averageValue = averageValue(oracle, tokens[i], denominator(oracle), amounts[i]);
            if (averageValue != 0) {
                sumAverageValue += averageValue;
            }
        }
        return sumAverageValue;
    }

    function sumQuoteAverageValue(Oracle storage oracle, address[] memory tokens, uint[] memory amounts) internal view returns (uint) {
        uint sumQuoteAverageValue;
        for (uint i = 0; i < tokens.length; i++) {
            uint quoteAverageValue = quoteAverageValue(oracle, tokens[i], denominator(oracle), amounts[i]);
            if (quoteAverageValue != 0) {
                sumQuoteAverageValue += quoteAverageValue;
            }
        }
        return sumQuoteAverageValue;
    }

    function sumValue(Oracle storage oracle, uint sourceId, address[] memory tokens, uint[] memory amounts) internal view returns (uint) {
        uint sumValue;
        for (uint i = 0; i < tokens.length; i++) {
            uint value = value(oracle, sourceId, tokens[i], denominator(oracle), amounts[i]);
            if (value != 0) {
                sumValue += value;
            }
        }
        return sumValue;
    }

    function sumQuoteValue(Oracle storage oracle, uint sourceId, address[] memory tokens, uint[] memory amounts) internal view returns (uint) {
        uint sumQuoteValue;
        for (uint i = 0; i < tokens.length; i++) {
            uint quoteValue = quoteValue(oracle, sourceId, tokens[i], denominator(oracle), amounts[i]);
            if (quoteValue != 0) {
                sumQuoteValue += quoteValue;
            }
        }
        return sumQuoteValue;
    }

    function averageValue(Oracle storage oracle, address token0, address token1, uint amount) internal view returns (uint) {
        uint averageValue;
        uint success;
        for (uint i = 0; i < sourcesLength(oracle); i++) {
            uint value = value(oracle, i, token0, token1, amount);
            if (value != 0) {
                averageValue += value;
                success += 1;
            }
        }
        return averageValue / success;
    }

    function quoteAverageValue(Oracle storage oracle, address token0, address token1, uint amount) internal view returns (uint) {
        uint quoteAverageValue;
        uint success;
        for (uint i = 0; i < sourcesLength(oracle); i++) {
            uint quoteValue = quoteValue(oracle, i, token0, token1, amount);
            if (quoteValue != 0) {
                quoteAverageValue += quoteValue;
                success += 1;
            }
        }
        return quoteAverageValue / success;
    }

    function value(Oracle storage oracle, uint sourceId, address token0, address token1, uint amount) internal view returns (uint) {
        return (amount * amountOut(oracle, sourceId, token0, token1)) / 10**18;
    }

    function quoteValue(Oracle storage oracle, uint sourceId, address token0, address token1, uint amount) internal view returns (uint) {
        return (amount * quote(oracle, sourceId, token0, token1)) / 10**18;
    }

    function quote(Oracle storage oracle, uint sourceId, address token0, address token1) internal view returns (uint) {
        IToken tkn0 = IToken(token0);
        IToken tkn1 = IToken(token1);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        IUniswapV2Factory fctr = IUniswapV2Factory(factories(oracle, sources(oracle, sourceId)));
        address pair = fctr.getPair(token0, token1);
        if (pair == address(0)) {
            return 0; 
        }
        IUniswapV2Pair pr = IUniswapV2Pair(pair);
        (uint res0, uint res1,) = pr.getReserves();
        if (token0 == pr.token0()) {
            uint amount = 10**decimals0;
            IUniswapV2Router02 rtr = IUniswapV2Router02(routers(oracle, sources(oracle, sourceId)));
            uint quote = rtr.quote(amount, res0, res1);
            quote = quote.computeAsEtherValue(decimals1);
            return quote;
        } else {
            uint amount = 10**decimals1;
            IUniswapV2Router02 rtr = IUniswapV2Router02(routers(oracle, sources(oracle, sourceId)));
            uint quote = rtr.quote(amount, res0, res1);
            quote = quote.computeAsEtherValue(decimals1);
            return quote;
        }
    }

    function amountOut(Oracle storage oracle, uint sourceId, address token0, address token1) internal view returns (uint) {
        IToken tkn0 = IToken(token0);
        IToken tkn1 = IToken(token1);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        IUniswapV2Factory fctr = IUniswapV2Factory(factories(oracle, sources(oracle, sourceId)));
        address pair = fctr.getPair(token0, token1);
        if (pair == address(0)) {
            return 0;
        }
        IUniswapV2Pair pr = IUniswapV2Pair(pair);
        (uint res0, uint res1,) = pr.getReserves();
        if (token0 == pr.token0()) {
            uint amount = 10**decimals0;
            IUniswapV2Router02 rtr = IUniswapV2Router02(routers(oracle, sources(oracle, sourceId)));
            uint amountOut = rtr.getAmountOut(amount, res0, res1);
            amountOut = amountOut.computeAsEtherValue(decimals1);
            return amountOut;
        } else {
            uint amount = 10**decimals1;
            IUniswapV2Router02 rtr = IUniswapV2Router02(routers(oracle, sources(oracle, sourceId)));
            uint amountOut = rtr.getAmountOut(amount, res0, res1);
            amountOut = amountOut.computeAsEtherValue(decimals1);
            return amountOut;
        }
    }

    function amountsOut(Oracle storage oracle, uint sourceId, address[] memory path) internal view returns (uint) {
        IToken tkn0 = IToken(path[0]);
        IToken tkn1 = IToken(path[path.length - 1]);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        uint amount = 10**decimals0;
        IUniswapV2Router02 rtr = IUniswapV2Router02(routers(oracle, sources(oracle, sourceId)));
        uint[] memory amountsOut = rtr.getAmountsOut(amount, path);
        uint amountOut = amountsOut[amountsOut.length - 1];
        amountOut = amountOut.computeAsEtherValue(decimals1);
        return amountOut;
    }

    function assignDenominator(Oracle storage oracle, address denominator) internal returns (bool) {
        address oldDenominator = denominator(oracle);
        oracle._denominator = denominator;
        emit OracleDenominatorAssigned(oldDenominator, denominator);
        return true;
    }

    function addSource(Oracle storage oracle, bytes32 source, address factory, address router) internal returns (bool) {
        /// duplicate entries are ignored in enumerable sets
        oracle._sources.add(source);
        _mapSource(oracle, source, factory, router);
        return true;
    }

    function removeSource(Oracle storage oracle, bytes32 source) internal returns (bool) {
        oracle._sources.remove(source);
        _mapSource(oracle, source, address(0), address(0));
        return true;
    }

    function _mapSource(Oracle storage oracle, bytes32 source, address factory, address router) private returns (bool) {
        address oldFactory = factories(oracle, source);
        address oldRouter = routers(oracle, source);
        oracle._factories[source] = factory;
        oracle._routers[source] = router;
        emit OracleSourceMapped(source, oldFactory, oldRouter, factory, router);
        return true;
    }
}