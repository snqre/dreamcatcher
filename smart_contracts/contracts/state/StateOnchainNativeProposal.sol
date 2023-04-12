// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StateProposalOnchainNative {
    uint256 minProposalDuration;
    uint256 maxProposalDuration;
    pcount = 0;


    modifier pcount() {
        _;
        pcount++;
    }
    
    mapping(uint256 => Proposal) internal proposals;
    struct Class {
        // the class will determine the way the contract will read proposals and how they act on the instructions
        string default = "default";
        string protocolUpgrade = "protocolUpgrade";
        string funding;
        string governance;
        string parameter;
        string consensus;
        string budget;
        string membership;
        string election;
        string bugFix;
        string bounty;
    }

    struct Status {
        uint256 open     = 0;
        uint256 closed   = 1;
        uint256 approved = 2;
        uint256 rejected = 3;
        uint256 pending  = 4;
    }

    struct Condition {
        quorum;
        threshold;
        duration;
        eligibility;
    }

    mapping(uint256 => mapping(address => uint256)) addressVotes;
    struct Proposal {
        uint256 id;
        string caption;
        string description;
        address creator;
        Status status;
        timestamp = block.timestamp;
        Condition condition;
    }
}