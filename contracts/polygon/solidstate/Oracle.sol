// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/slots/oracles/OracleSlot.sol";
import "contracts/polygon/slots/.components/OracleComponent.sol";

contract Oracle is OracleSlot {
    using OracleComponent for OracleComponent.Oracle;

    constructor() {
        address USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;

        address QUICKSWAP_FACTORY = 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32;
        address QUICKSWAP_ROUTER = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

        address UNISWAP_V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

        /// for purpose of testing
        oracle().setDenominator(USDT);
        oracle().deployV2Adaptor(QUICKSWAP_FACTORY, QUICKSWAP_ROUTER, 5000);
        oracle().deployV3Adaptor(UNISWAP_V3_FACTORY, 60, 5000);
        oracle().requireWeightingIntegrity();
    }

    function sumQuoteValue(uint sourceId, address[] memory tokens, uint[] memory amounts) external view returns (uint) {
        return oracle().sumQuoteValue(sourceId, tokens, amounts);
    }

    function sumQuoteAverageValue(address[] memory tokens, uint[] memory amounts) external view returns (uint) {
        return oracle().sumQuoteAverageValue(tokens, amounts);
    }

    function sumQuoteWeightedValue(address[] memory tokens, uint[] memory amounts) external view returns (uint) {
        return oracle().sumQuoteWeightedValue(tokens, amounts);
    }

    function quoteWeightedValue(address token0, address token1, uint amount) external view returns (uint) {
        return oracle().quoteWeightedValue(token0, token1, amount);
    }

    function value(uint sourceId, address token0, address token1, uint amount) external view returns (uint) {
        return oracle().value(sourceId, token0, token1, amount);
    }

    function quote(uint sourceId, address token0, address token1) external view returns (uint) {
        return oracle().quote(sourceId, token0, token1);
    }
}