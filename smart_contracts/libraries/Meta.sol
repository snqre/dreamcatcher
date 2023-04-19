// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// **deprecated
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

    struct Database {
        mapping(address => uint256) balance;
        mapping(address => uint256) vested;
        mapping(address => uint256) staked;
        mapping(address => uint256) vote;
        mapping(address => mapping(address => uint256)) allowed;
        // votes can be delegated to other accounts
        mapping(address => mapping(address => uint256)) delegatedVote;
    }

    struct Quorum {
        uint256 proposalCount;
        uint256 requiredQuorum;
    }
}
