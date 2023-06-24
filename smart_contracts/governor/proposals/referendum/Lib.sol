// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

import "deps/openzeppelin/utils/structs/EnumerableSet.sol";

library Lib {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Tracker { uint numberOfReferendums; }

    struct Settings {
        uint defaultThreshold;
        uint minTimeoutDays;
        uint maxTimeoutDays;
        uint defaultAverageActiveQuorumLookBackDays;
        uint minQuorumRequired;
        uint maxQuorumRequired;
        uint minThreshold;
        uint maxThreshold;
        address nativeToken;        
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

    struct Voter {
        address account;
        uint votes;
        /// choice 1: abstain.
        /// choice 2: for.
        /// choice 3: against.
        uint choice;
        bool hasVoted;
    }

    function mustNotBePassed(Referendum storage referendum) public view {
        require(
            !referendum.hasBeenPassed,
            "Referendum has been passed."
        );
    }

    function mustBePassed(Referendum storage referendum) public view {
        require(
            referendum.hasBeenPassed,
            "Referendum has not been passed."
        );
    }

    function mustNotBeCancelled(Referendum storage referendum) public view {
        require(
            !referendum.hasBeenCancelled,
            "Referendum has been cancelled."
        );
    }

    function mustBeCancelled(Referendum storage referendum) public view {
        require(
            referendum.hasBeenCancelled,
            "Referendum has not been cancelled."
        );
    }

    function mustNotBeExecuted(Referendum storage referendum) public view {
        require(
            !referendum.hasBeenExecuted,
            "Referendum has been executed."
        );
    }

    function mustBeExecuted(Referendum storage referendum) public view {
        require(
            referendum.hasBeenExecuted,
            "Referendum ahs not been executed."
        );
    }

    function mustNotBeExpired(Referendum storage referendum) public view {
        require(
            block.timestamp < referendum.endTimestamp,
            "Referendum has expired."
        );
    }

    function requiredQuorumHasBeenMet(Referendum storage referendum) public view returns (bool) {
        if (referendum.quorum >= referendum.quorumRequired) { return true; }
        else { return false; }
    }

    function requiredThresholdHasBeenMet(Referendum storage referendum) public view returns (bool) {
        if (((referendum.votesFor * 100) / (referendum.votesFor + referendum.votesAgainst)) >= referendum.threshold) { return true; }
        else { return false; }
    }
    
    function mustBePresent(
        Referendum storage referendum,
        Tracker storage tracker
    ) public view {
        require(
            referendum.identifier >= 1 &&
            referendum.identifier <= tracker.numberOfReferendums,
            "Identifier does not point to an existing referendum."
        );
    }
}