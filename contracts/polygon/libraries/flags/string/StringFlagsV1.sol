// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/libraries/errors/ErrorsV1.sol";

library StringFlagsV1 {

    function onlynotMatchingValue(string memory self, string memory value) public pure returns (string memory) {
        if (keccak256(abi.encode(self)) == keccak256(abi.encode(value))) { revert ErrorsV1.IsMatchingValue(); }
        return self;
    }
}