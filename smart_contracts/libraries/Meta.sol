// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Meta {
    struct Properties {
        string name;
        string symbol;
        uint256 decimals;
        uint256 maxSupply;
        uint256 totalSupply;
        uint256 totalVested;
        uint256 totalStaked;
    }
}
