// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error IsZero(string variable);
error Infinite();

library OurMath {

    ////////////////////////////////////////////////////////////////////

    /// 100% => 10000
    function computePercentageChange(int valueBefore, int valueAfter) internal pure returns (int percentage) {
        if (valueBefore == 0) { revert Infinite(); }
        return (valueAfter - valueBefore) / (valueBefore / 10000);
    }

    /// 100% => 10000
    function computePercentageOfAInB(uint valueA, uint valueB) internal pure returns (uint percentage) {
        if (valueA == 0) { revert IsZero("valueA"); }
        if (valueB == 0) { revert IsZero("valueB"); }
        return (valueA * 10000) / valueB;
    }

    /// 100% => 10000
    function computeValueOfBWithPercentage(uint percentage, uint value) internal pure returns (uint) {
        if (percentage == 0) { revert IsZero("percentage"); }
        if (value == 0) { revert IsZero("value"); }
        return (percentage * value) / 10000;
    }

    ////////////////////////////////////////////////////////////////////

    /// decimals 18 => ?
    function computeAsNativeValue(uint value, uint8 decimals) internal pure returns (uint) {
        return ((value * (10**18) / (10**18)) * (10**decimals)) / (10**18);
    }

    /// decimals ? => 18
    function computeAsEtherValue(uint value, uint8 decimals) internal pure returns (uint) {
        return ((value * (10**18) / (10**decimals)) * (10**18)) / (10**18);
    }

    ////////////////////////////////////////////////////////////////////

    /// assuming price is as 10**18
    function computeValue(uint amount, uint price) internal pure returns (uint value) {
        amount *= 10**18;
        return (amount * price) / 10**18;
    }

    ////////////////////////////////////////////////////////////////////

    function computeAmountOut(uint amountIn, uint priceIn, uint priceOut) internal pure returns (uint amountOut) {
        if (amountIn == 0) { revert IsZero("amountIn"); }
        if (priceIn == 0) { revert IsZero("priceIn"); }
        if (priceOut == 0) { revert IsZero("priceOut"); }
        return (amountIn * priceIn) / priceOut;
    }

    function computeAmountIn(uint amountOut, uint priceIn, uint priceOut) internal pure returns (uint amountIn) {
        if (amountOut == 0) { revert IsZero("amountOut"); }
        if (priceIn == 0) { revert IsZero("priceIn"); }
        if (priceOut == 0) { revert IsZero("priceOut"); }
        return (amountOut * priceOut) / priceIn;
    }

    ////////////////////////////////////////////////////////////////////

    function computeSharesToMint(uint valueIn, uint balance, uint sumShares) internal pure returns (uint sharesToMint) {
        if (valueIn == 0) { revert IsZero("valueIn"); }
        if (balance == 0) { revert IsZero("balance"); }
        if (sumShares == 0) { revert IsZero("totalSupply"); }
        return (valueIn * sumShares) / balance;
    }

    function computeValueToSend(uint sharesIn, uint balance, uint sumShares) internal pure returns (uint valueToSend) {
        if (sharesIn == 0) { revert IsZero("valueIn"); }
        if (balance == 0) { revert IsZero("balance"); }
        if (sumShares == 0) { revert IsZero("totalSupply"); }
    }

    /// compute amount of value to send based on shares burnt : ie amount 1250 balance 1300 supply 3250 return 500
    function computeValueToSend(uint a, uint b, uint s) internal pure returns (uint) {
        /// amount balance and supply must be same decimals : no value should be zero
        if (a == 0 || s == 0 || b == 0) { return 0; }
        return (a * b) / s;
    }
}