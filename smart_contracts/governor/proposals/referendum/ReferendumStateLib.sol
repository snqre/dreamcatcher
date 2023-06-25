// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/utils/structs/EnumerableSet.sol";

import "smart_contracts/governor/proposals/ProposalsStateLib.sol";

library ReferendumStateLib {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Settings {
        uint defaultThreshold;
        uint minThreshold;
        uint maxThreshold;

        uint defaultTimeout;
        uint minTimeout;
        uint maxTimeout;

        uint defaultRequiredQuorum;
        uint minRequiredQuorum;
        uint maxRequiredQuorum;
    }

    struct Voter {
        address account;
        uint votes;
        /// choice 1: abstain.
        /// choice 2: for.
        /// choice 3: against.
        uint choice;
        bool hasVoted;
        uint timestampOfLastVote;
    }

    struct Referendum {
        uint identifier;
        uint snapshot;
        address creator;
        string reason;
        uint startTimestamp;
        uint endTimestamp;
        uint timeout;
        uint quorum;
        uint quorumRequired;
        uint votesFor;
        uint votesAgainst;
        uint votesToAbstain;
        uint threshold;
        bool hasBeenCancelled;
        bool hasBeenExecuted;
        bool hasBeenPassed;
        bool delegatecall;
        address target;
        string signature;
        bytes args;
        EnumerableSet.
            AddressSet voters;
    }
}