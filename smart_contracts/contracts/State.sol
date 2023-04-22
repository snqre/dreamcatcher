// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract State {
    uint256 immutable INFINITE = type(uint256).max;

    // =.=.=.=.= ROLES =.=.=.=.=
    struct Admin {
        uint256 cur;
        uint256 min;
        uint256 max;
    }

    struct Operator {
        uint256 cur;
        uint256 min;
        uint256 max;
    }

    struct Syndicate {
        uint256 cur;
        uint256 min;
        uint256 max;
    }

    struct Validator {
        uint256 cur;
        uint256 min;
        uint256 max;
    }

    struct Extension {
        uint256 cur;
        uint256 min;
        uint256 max;
    }

    struct Roles {
        Admin admin;
        Operator operator;
        Syndicate syndicate;
        Validator validator;
        Extension extension;
    }

    // =.=.=.=.= VOTING MECHANICS =.=.=.=.=
    struct VotingMechanic {
        uint256 voteWeightPerToken;
    }

    struct Settings {
        Roles roles;
        uint256 bpTransferBurnMax;
        uint256 bpTransferBankMax;
        uint256 bpTransferBurn;
        uint256 bpTransferBank;
        VotingMechanic votingMechanic;
    }

    mapping(address => bool) internal isAdmin;      // address > bool | -human -contract
    mapping(address => bool) internal isOperator;   // address > bool | -human *cancel *
    mapping(address => bool) internal isSyndicate;  // address > bool | -human
    mapping(address => bool) internal isValidator;  // address > bool | -contract
    mapping(address => bool) internal isExtension;  // address > bool | -contract

    mapping(address => uint256) internal durationAdmin;
    mapping(address => uint256) internal durationOperator;
    mapping(address => uint256) internal durationSyndicate;
    mapping(address => uint256) internal durationValidator;
    mapping(address => uint256) internal durationExtension;

    mapping(address => uint256) internal startAdmin;
    mapping(address => uint256) internal startOperator;
    mapping(address => uint256) internal startSyndicate;
    mapping(address => uint256) internal startValidator;
    mapping(address => uint256) internal startExtension;

    mapping(address => uint256) internal expiryAdmin;
    mapping(address => uint256) internal expiryOperator;
    mapping(address => uint256) internal expirySyndicate;
    mapping(address => uint256) internal expiryValidator;
    mapping(address => uint256) internal expiryExtension;

    struct Meta {
        string name;            // name
        string symbol;          // symbol
        uint8 decimals;         // decimals
        uint256 mintable;       // total mintable
        uint256 totalSupply;    // supply
        uint256 totalStaked;    // staked in vault
        uint256 totalVested;    // vested in vault
        uint256 totalVotes;     // votes
        uint256 totalBurnt;     // all time burnt
        uint256 maxSupply;      // hard cap
        address bank;           // **deprecated
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

    mapping(address => mapping(string => VestingSchedule)) internal schedules;      // schedules
    mapping(address => uint256) internal balance;                                   // balance
    mapping(address => uint256) internal staked;                                    // staked
    mapping(address => uint256) internal votes;                                     // votes
    mapping(address => mapping(address => uint256)) internal allowed;     
}
