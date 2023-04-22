// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract State {
    uint256 immutable INFINITE = type(uint256).max;

    struct Settings {

        uint256 bpTransferBurnMin;
        uint256 bpTransferBankMin;
        uint256 bpTransferBurnMax;
        uint256 bpTransferBankMax;
        uint256 bpTransferBurn;
        uint256 bpTransferBank;
    }

    mapping(address => bool) internal admin;

    struct Meta {
        string name;            // name
        string symbol;          // symbol
        uint8 decimals;         // decimals
        uint256 mintable;       // total mintable
        uint256 totalSupply;    // supply
        uint256 totalStaked;    // staked in vault
        uint256 totalVested;    // vested in vault
        uint256 totalVotes;     // votes
        uint256 maxSupply;      // hard cap
        address vault;          // address of contract vault
    }

    struct VestingSchedule {
        string caption;         // id
        uint256 duration;       // duration
        uint256 start;          // block.timestamp
        uint256 end;            // unlock
        uint256 value;          // amount
        bool used;              // already in use
    }

    Settings internal settings;
    Meta internal meta;

    mapping(address => uint256) internal balance;
    mapping(address => uint256) internal staked;
    mapping(address => uint256) internal votes;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => mapping(string => VestingSchedule)) internal schedules;
}
