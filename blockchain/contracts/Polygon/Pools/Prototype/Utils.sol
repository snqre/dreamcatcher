// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Utils {
    function convertToWei(uint256 value) internal pure returns (uint256) {
        return value * 10**18;
    }

    function valueToMint(uint256 value, uint256 supply, uint256 balance) public pure returns (uint256) {
        require(
            value >= convertToWei(1),
            "Utils::valueToMint(): value < convertToWei(1)"
        );

        require(
            supply >= convertToWei(1),
            "Utils::valueToMint(): supply < convertToWei(1)"
        );

        require(
            balance >= convertToWei(1),
            "Utils::valueToMint(): balance < convertToWei(1)"
        );

        return ((value * supply) / balance);
    }

    function burnToValue(uint256 value, uint256 supply, uint256 balance) public pure returns (uint256) {
        require(
            value >= convertToWei(1),
            "Utils::valueToMint(): value < convertToWei(1)"
        );

        require(
            supply >= convertToWei(1),
            "Utils::valueToMint(): supply < convertToWei(1)"
        );

        require(
            balance >= convertToWei(1),
            "Utils::valueToMint(): balance < convertToWei(1)"
        );
        
        return ((value * balance) / supply);
    }
}