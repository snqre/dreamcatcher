// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/libraries/OurMathLib.sol";
import "contracts/polygon/diamonds/facets/components/RoleComponent.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV3Factory.sol";
import "contracts/polygon/deps/uniswap/v3-periphery/libraries/OracleLibrary.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV3Pool.sol";
import "contracts/polygon/libraries/OurAddressLib.sol";

library OldOracleComponent {
    using OurMathLib for uint;
    using RoleComponent for RoleComponent.Role;
    using EnumerableSet for EnumerableSet.bytes32Set;

    event OracleSourceMapped(bytes32 source, address oldFactory, address oldRouter, address newFactory, address newRouter);
    event OracleDenominatorSet(address oldDenominator, address newDenominator);

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

    function setDenominator(Oracle storage oracle, address denominator) internal returns (bool) {
        address oldDenominator = denominator(oracle);
        _setDenominator(oracle, denominator);
        emit OracleDenominatorSet(oldDenominator, denominator);
        return true;
    }

    function addSource(Oracle storage oracle, bytes32 source, address factory, address router) internal returns (bool) {
        address oldFactory = factories(oracle, source);
        address oldRouter = routers(oracle, source);
        _addSource(oracle, source, factory, router);
        emit OracleSourceMapped(source, oldFactory, oldRouter, factory, router);
        return true;
    }

    function removeSource(Oracle storage oracle, bytes32 source) internal returns (bool) {
        address oldFactory = factories(oracle, source);
        address oldRouter = routers(oracle, source);
        _removeSource(oracle, source);
        emit OracleSourceMapped(source, oldFactory, oldRouter, address(0), address(0));
        return true;
    }

    function _setDenominator(Oracle storage oracle, address denominator) private returns (bool) {
        oracle._denominator = denominator;
        return true;
    }

    function _addSource(Oracle storage oracle, bytes32 source, address factory, address router) private returns (bool) {
        /// duplicate is ignored
        oracle._sources.add(source);
        _mapSource(oracle, source, factory, router);
        return true;
    }

    function _removeSource(Oracle storage oracle, bytes32 source) private returns (bool) {
        oracle._sources.remove(source);
        _mapSource(oracle, source, address(0), address(0));
        return true;
    }

    /// not built to be called directly use addSource and removeSource
    function _mapSource(Oracle storage oracle, bytes32 source, address factory, address router) private returns (bool) {
        oracle._factories[source] = factory;
        oracle._routers[source] = router;
        return true;
    }
}

/// improvement
///
/// . uniswap v3 support
/// . source weighting
/// . refactoring
/// . liquidity checks
///
/// note in 0.7.6 overflow is not checked
library OracleComponent {
    using OurMathLib for uint;
    using OurAddressLib for address;
    using RoleComponent for RoleComponent.Role;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    error InvalidPool();
    error InvalidPair();

    enum Version {
        NONE,
        V2,
        V3
    }

    struct Oracle {
        mapping(bytes32 => address) _factories;
        mapping(bytes32 => address) _routers;
        mapping(bytes32 => uint16) _weight;
        mapping(bytes32 => Version) _version;
        EnumerableSet.Bytes32Set _sources;
        address _denominator;
        uint _twapSeconds;
    }

    function factories(Oracle storage oracle, bytes32 source) internal view returns (address) {
        return oracle._factories[source];
    }

    function routers(Oracle storage oracle, bytes32 source) internal view returns (address) {
        return oracle._routers[source];
    }

    function weight(Oracle storage oracle, bytes32 source) internal view returns (uint16) {
        return oracle._weight[source];
    }

    /// version of uniswap being use
    function version(Oracle storage oracle, bytes32 source) internal view returns (Version) {
        return oracle._version[source];
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

    /// ie. USD a common asset to use as a base unit of value
    function denominator(Oracle storage oracle) internal view returns (address) {
        return oracle._denominator;
    }

    function twapSeconds(Oracle storage oracle) internal view returns (uint) {
        return oracle._twapSeconds;
    }

    function amountOut(Oracle storage oracle, uint sourceId, address token0, address token1) internal view returns (uint) {
        Version version = version(oracle, sources(oracle, sourceId));
        if (version == Version.NONE) { return 0; }
        if (version == Version.V2) {

        } else {
            IUniswapV3Factory fctr = IUniswapV3Factory(factories(oracle, sources(oracle, sourceId)));
            uint[] fees = new uint[](2);
            fees[0] = 0100;
            fees[1] = 0500;
            fees[2] = 1000;
            uint sum;
            uint success;
            for (uint i = 0; i < fees.length; i++) {
                address pool = fctr.getPool(token0, token1, fees[i]);
                if (pool != address(0)) {
                    IUniswapV3Pool pl = IUniswapV3Pool(pool);
                    (int24 tick,) = OracleLibrary.consult(pool, twapSeconds(oracle));
                    uint amountIn = 10**token0.decimals();
                    uint amountOut = OracleLibrary.getQuoteAtTick(tick, amountIn, token0, token1);
                    amountOut = amountOut.computeAsEtherValue(token1.decimals());
                    sum += amountOut;
                    success += 1;
                }
            }
            if (success == 0) { return 0; }
            return sum / success;
        }
    }

    function _addSource(Oracle storage oracle, bytes32 source, address factory, address router, uint16 weigth, Version version) private returns (bool) {
        /// duplicate is ignored
        oracle._sources.add(source);
        _mapSource(oracle, source, factory, router, weigth, version);
        return true;
    }

    function _removeSource(Oracle storage oracle, bytes32 source) private returns (bool) {
        oracle._sources.remove(source);
        _mapSource(oracle, source, address(0), address(0), 0, Version.NONE);
        return true;
    }

    function _mapSource(Oracle storage oracle, bytes32 source, address factory, address router, uint16 weigth, Version version) private returns (bool) {
        oracle._factories[source] = factory;
        oracle._routers[source] = router;
        oracle._weight[source] = weight;
        oracle._version[source] = version;
        return true;
    }
}

contract Test {
    bytes32 internal constant _ORACLE = keccak256("slot.oracle");

    function oracle() internal pure returns (OracleComponent.Oracle storage s) {
        bytes32 location = _ORACLE;
        assembly {
            s.slot := location
        }
    }

    function test(address token0, address token1) external returns (uint) {
        bytes32 someRandomExchange = keccak256(abi.encode("helloWorld"));
        oracle()._addSource(someRandomExchange, 0x1F98431c8aD98523631AE4a59f267346ea31F984, address(0), 0, Version.V3);
        return oracle().amountOut(0, token0, token1);
    }
}