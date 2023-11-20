// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Finance {

    /// compute the % change of to int values as basis points
    function computeChangeInBasisPoints(int value0, int value1) internal pure returns (int) {
        require(value0 != 0, 'Value is zero');
        return (value1 - value0) / (value0 / 10000);
    }

    /// compute total assets by adding an asset and price **must be as 10**18
    function computeTotalAssets(uint[] memory amounts, uint[] memory prices) internal pure returns (uint) {
        require(amounts.length == prices.length, 'Arrays are unequal in length');
        uint totalAssets;
        for (uint i = 0; i < amounts.length; i++) {
            /// all values must be converted to 18 decimals values
            totalAssets += (amounts[i] * prices[i]) / (10**18);
        }
        /// divide by 10**18 to get real values
        return totalAssets;
    }

    /// compute amount returned by swapping an asset for another asset
    function computeAmountOut(uint amountIn, uint price0, uint price1) internal pure returns (uint) {
        require(amountIn != 0, 'Value is zero');
        require(price0 != 0, 'Value is zero');
        require(price1 != 0, 'Value is zero');
        return (amountIn * price0) / price1;
    }

    /// compute amount required when swapping as asset to return an amount out
    function computeAmountIn(uint amountOut, uint price1, uint price0) internal pure returns (uint) {
        require(amountOut != 0, 'Value is zero');
        require(price0 != 0, 'Value is zero');
        require(price1 != 0, 'Value is zero');
        return (amountOut * price1) / price0;
    }

    /// compute amount of shares to mint based on balance and supply
    function computeSharesToMint(uint v, uint b, uint s) internal pure returns (uint) {
        /// must be a sufficient number to produce an accurate result
        require(b >= 1 ether / 20, 'Insufficient size for an accurate result');
        require(s >= 1 ether / 20, 'Insufficient size for an accurate result');
        return (v * s) / b;
    }

    /// compute amount of assets to return based on balance and supply
    function computeAssetsToSend(uint a, uint b, uint s) internal pure returns (uint) {
        /// must be a sufficient number to produce an accurate result
        require(b >= 1 ether / 20, 'Insufficient size for an accurate result');
        require(s >= 1 ether / 20, 'Insufficient size for an accurate result');
        return (a * b) / s;
    }

    /// decimals 18 => ?
    function computeAsNativeValue(uint num, uint8 decimals) internal pure returns (uint) {
        /// reduce risk of unexpected behaviour
        require(decimals >= 2, 'Decimals are too small');
        require(decimals <= 18, 'Decimals are too large');
        return ((num * (10**18) / (10**18)) * (10**decimals)) / (10**18);
    }

    /// decimals ? => 18
    function computeAsStandardValue(uint num, uint8 decimals) internal pure returns (uint) {
        /// reduce risk of unexpected behaviour
        require(decimals >= 2, 'Decimals are too small');
        require(decimals <= 18, 'Decimals are too large');
        return ((num * (10**18) / (10**decimals)) * (10**18)) / (10**18);
    }
}