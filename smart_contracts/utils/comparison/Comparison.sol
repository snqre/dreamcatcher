// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

/// public comparison functions

library Comparison {
    function mustBeWithinRange(
        uint value,
        uint min,
        uint max
    ) public pure {
        require(
            value >= min &&
            value <= max,
            "Value is not within range."
        );
    }
    
    function mustBeGreaterThan(
        uint value,
        uint min
    ) public pure {
        require(
            value >= min,
            "Value is not greater than min."
        );
    }

    function mustBeLessThan(
        uint value,
        uint max
    ) public pure {
        require(
            value <= max,
            "Value is not less than max."
        );
    }

    function mustNotBeZeroAddress(address account) public pure {
        require(
            account != address(0),
            "Account is zero address."
        );
    }

    function mustNotBeBeforePresent(uint timestamp) public view {
        require(
            block.timestamp >= timestamp,
            "Timestamp is in the past."
        );
    }
}