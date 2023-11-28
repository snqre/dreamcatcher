// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/solidstate/UniswapV2OracleAdaptor.sol";
import "contracts/polygon/solidstate/UniswapV3OracleAdaptor.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

/// this has to be declared here because UniswapV3OracleAdaptor uses an outdated solidity version
interface IUniswapV3OracleAdaptor {
    function factory() external view returns (address);
    function secondsAgo() external view returns (uint);
    function quote(address token0, address token1) external view returns (uint);
}

/// improvement
///
/// . uniswap v3 support
/// . source weighting
/// . refactoring
/// . liquidity checks
///
/// note in 0.7.6 overflow is not checked
///
/// when modifying weight or adding new sources ensure the oracle is paused
///
/// if the oracle cannt find a value for an asset it will always assume the asset is worthless
/// the deposit mechanic returns asset as a portion of ownership of the pool token
/// therefore the unique attack vector is when minting the shares to the account
/// in this case its best to not mint anything and consider the amount in as worthless if forced
/// and allow the vault or safe to remain solvent
///
/// initially the idea was to deploy the adaptors directly from the component but
/// because v3 and our core contracts are based on different compiler versions
/// the v3 adaptor is not compatible with our contracts so v3 must be deployed
/// alone.
library OracleComponent {
    using EnumerableSet for EnumerableSet.AddressSet;

    event OracleV2AdaptorDeployed(address source, address factory, address router, uint16 weight);
    event OracleV3AdaptorDeployed(address source, address factory, uint32 secondsAgo, uint16 weight);
    event OracleAdaptorWeightSet(address source, uint16 oldWeight, uint16 newWeight);
    event OracleDenominatorSet(address oldDenominator, address newDenominator);

    /// weightings must always sum up to 10000
    /// use set weighting before deploying a new source to make space for a new source
    /// use require weithint integrity to check that weighting is equal to 10000 after changes
    error OracleWeightingIntegrityIsBroken();

    struct Oracle {
        EnumerableSet.AddressSet _sources;
        mapping(address => uint8) _version;
        mapping(address => uint16) _weight;
        address _denominator;
    }

    function sources(Oracle storage oracle, uint i) internal view returns (address) {
        return oracle._sources.at(i);
    }

    function sources(Oracle storage oracle) internal view returns (address[] memory) {
        return oracle._sources.values();
    }

    function sourcesLength(Oracle storage oracle) internal view returns (uint) {
        return oracle._sources.length();
    }

    function sourcesContains(Oracle storage oracle, address source) internal view returns (bool) {
        return oracle._sources.contains(source);
    }

    function version(Oracle storage oracle, address source) internal view returns (uint) {
        return oracle._version[source];
    }

    function weight(Oracle storage oracle, address source) internal view returns (uint) {
        return oracle._weight[source];
    }

    function denominator(Oracle storage oracle) internal view returns (address) {
        return oracle._denominator;
    }

    /// always check weighting integrity after changing or deploying any sources!
    function requireWeightingIntegrity(Oracle storage oracle) internal view returns (bool) {
        uint sumWeight;
        for (uint i = 0; i < sourcesLength(oracle); i++) {
            sumWeight += weight(oracle, sources(oracle, i));
        }
        if (sumWeight != 10000) {
            revert OracleWeightingIntegrityIsBroken();
        }
        return true;
    }

    /// will use denominator as default base currency
    /// use a single source to determine sum of value against base currency
    function sumQuoteValue(Oracle storage oracle, uint sourceId, address[] memory tokens, uint[] memory amounts) internal view returns (uint) {
        uint sumQuoteValue;
        uint success;
        for (uint i = 0; i < tokens.length; i++) {
            uint value = value(oracle, sourceId, tokens[i], denominator(oracle), amounts[i]);
            if (value != 0) {
                sumQuoteValue += value;
                success += 1;
            }
        }
        if (success == 0) { return 0; }
        return sumQuoteValue / success;
    }

    /// will use denominator as default base currency
    /// use a all sources to determine sum of value against base currency
    /// non weighted just average
    function sumQuoteAverageValue(Oracle storage oracle, address[] memory tokens, uint[] memory amounts) internal view returns (uint) {
        uint sumQuoteAverageValue;
        uint success;
        for (uint i = 0; i < tokens.length; i++) {
            uint sumValue;
            uint successValue;
            for (uint x = 0; x < sourcesLength(oracle); x++) {
                uint value = value(oracle, x, tokens[i], denominator(oracle), amounts[i]);
                if (value != 0) {
                    sumValue += value;
                    successValue += 1;
                }
            }
            if (successValue != 0) {
                /// average of each exchange for this one asset
                sumQuoteAverageValue += sumValue / successValue;
                success += 1;
            }
        }
        if (success == 0) { return 0; }
        return sumQuoteAverageValue / success;
    }

    /// will use denominator as default base currency
    /// use weighted sources to determine sum of value against base currency
    function sumQuoteWeightedValue(Oracle storage oracle, address[] memory tokens, uint[] memory amounts) internal view returns (uint) {
        uint sumQuoteWeightedValue;
        uint success;
        for (uint i = 0; i < tokens.length; i++) {
            uint value = quoteWeightedValue(oracle, tokens[i], denominator(oracle), amounts[i]);
            if (value != 0) {
                sumQuoteWeightedValue += value;
                success += 1;
            }
        }
        if (success == 0) { return 0; }
        return sumQuoteAverageValue / success;
    }

    /// this is where weighting gets involved and this should be the most used function
    function quoteWeightedValue(Oracle storage oracle, address token0, address token1, uint amount) internal view returns (uint) {
        uint quoteWeightedValue;
        uint success;
        uint[] memory values = new uint[](sourcesLength(oracle));
        uint16[] memory weighting = new uint16[](sourcesLength(oracle));
        for (uint i = 0; i < sourcesLength(oracle); i++) {
            uint value = value(oracle, i, token0, token1, amount);
            /// weighting will be zero if value is zero and therefore zero values will not be included in the final value
            if (value != 0) {
                values[i] = value;
                weighting[i] = weight(oracle, sources(oracle, i));
            }
        }
        uint quoteWeightedValue = values.computeValueWithWeighting(weighting);
        return quoteWeightedValue;
    }

    function value(Oracle storage oracle, uint sourceId, address token0, address token1, uint amount) internal view returns (uint) {
        return (amount * quote(oracle, sourceId, token0, token1)) / 10**18;
    }

    function quote(Oracle storage oracle, uint sourceId, address token0, address token1) internal view returns (uint) {
        address source = sources(oracle, sourceId);
        uint8 version = version(oracle, source);
        if (version == 2) {
            IUniswapV2OracleAdaptor adaptor = IUniswapV2OracleAdaptor(source);
            return adaptor.quote(token0, token1);
        } else if (version == 3) {
            IUniswapV3OracleAdaptor adaptor = IUniswapV3OracleAdaptor(source);
            return adaptor.quote(token0, token1);
        } else {
            return 0;
        }
    }

    function setDenominator(Oracle storage oracle, address denominator_) internal returns (bool) {
        address oldDenominator = denominator(oracle);
        oracle._denominator = denominator_;
        emit OracleDenominatorSet(oldDenominator, denominator_);
        return true;
    }

    function setWeight(Oracle storage oracle, address source, uint16 weight) internal returns (bool) {
        uint16 oldWeight = weight(oracle, source);
        oracle._weight[source] = weight;
        emit OracleAdaptorWeightSet(source, oldWeight, weight);
        return true;
    }

    function deployV2Adaptor(Oracle storage oracle, address factory, address router, uint16 weight) internal returns (address) {
        address adaptor = _deployV2Adaptor(oracle, factory, router, weight);
        emit OracleV2AdaptorDeployed(adaptor, factory, router, weight);
        return adaptor;
    }

    function deployV3Adaptor(Oracle storage oracle, address factory, uint32 secondsAgo, uint16 weight) internal returns (address) {
        address adaptor = _deployV3Adaptor(oracle, factory, secondsAgo, weight);
        emit OracleV3AdaptorDeployed(adaptor, factory, secondsAgo, weight);
        return adaptor;
    }

    function _setDenominator(Oracle storage oracle, address denominator) private returns (bool) {
        oracle._denominator = denominator;
        return true;
    }

    function _setWeight(Oracle storage oracle, address source, uint16 weight) private returns (bool) {
        oracle._weight[source] = weight;
        return true;
    }

    function _deployV2Adaptor(Oracle storage oracle, address factory, address router, uint16 weight) private returns (address) {
        address adaptor = address(new UniswapV2OracleAdaptor(factory, router));
        oracle._sources.add(adaptor);
        oracle._version[adaptor] = 2;
        oracle._weight[adaptor] = weight;
        return adaptor;
    }

    function _deployV3Adaptor(Oracle storage oracle, address factory, uint32 secondsAgo, uint16 weight) private returns (address) {
        address adaptor = address(new UniswapV3OracleAdaptor(factory, secondsAgo));
        oracle._sources.add(adaptor);
        oracle._version[adaptor] = 3;
        oracle._weight[adaptor] = weight;
        return adaptor;
    }
}