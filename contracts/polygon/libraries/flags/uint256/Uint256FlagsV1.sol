// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/libraries/errors/ErrorsV1.sol";

library Uint256FlagsV1 {

    /**
    * @dev Throws an error indicating that a value is out of bounds.
    * @param min The minimum allowed value.
    * @param max The maximum allowed value.
    * @param value The value that is out of bounds.
    */
    error OutOfBounds(uint256 min, uint256 max, uint256 value);

    function onlyBetween(uint256 self, uint256 min, uint256 max) public pure returns (uint256) {
        if (self < min || self > max) { revert OutOfBounds(min, max, self); }
        return self;
    }

    function onlynotMatchingValue(uint256 self, uint256 value) public pure returns (uint256) {
        if (self == value) { revert ErrorsV1.IsMatchingValue(); }
        return self;
    }
}