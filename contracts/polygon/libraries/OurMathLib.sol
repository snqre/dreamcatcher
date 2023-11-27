// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error IsZero(string variable);
error Infinite();

library OurMathLib {

    /// 100% => 10000
    function computePercentageChange(int valueBefore, int valueAfter) internal pure returns (int percentage) {
        return (valueAfter - valueBefore) / (valueBefore / 10000);
    }

    /// 100% => 10000
    function computePercentageOfAInB(uint valueA, uint valueB) internal pure returns (uint percentage) {
        return (valueA * 10000) / valueB;
    }

    /// 100% => 10000
    function computeValueOfBWithPercentage(uint percentage, uint value) internal pure returns (uint) {
        return (percentage * value) / 10000;
    }

    /// decimals 18 => ?
    function computeAsNativeValue(uint value, uint8 decimals) internal pure returns (uint) {
        return ((value * (10**18) / (10**18)) * (10**decimals)) / (10**18);
    }

    /// decimals ? => 18
    function computeAsEtherValue(uint value, uint8 decimals) internal pure returns (uint) {
        return ((value * (10**18) / (10**decimals)) * (10**18)) / (10**18);
    }

    function computeSharesToMint(uint valueIn, uint balance, uint sumShares) internal pure returns (uint sharesToMint) {
        return (valueIn * sumShares) / balance;
    }

    function computeValueToSend(uint sharesIn, uint balance, uint sumShares) internal pure returns (uint valueToSend) {
        return (sharesIn * balance) / sumShares;
    }

    /// ensure 100% => 10000 for accurate compute
    function computeValueWithWeighting(uint[] memory values, uint[] memory weighting) internal pure returns (uint) {
        uint value;
        uint length = values.length;
        for (uint i = 0; i < length; i++) {
            value += (values[i] * weighting[i]) / 10000;
        }
        return value;
    }
}