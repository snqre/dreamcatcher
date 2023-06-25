// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "smart_contracts/governor/proposals/referendum/ReferendumStateLib.sol";

import "smart_contracts/tokens/dream_token/DreamToken.sol";

library ReferendumLogicLib {
    function mustNotBePassed(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            !referendum.hasBeenPassed,
            "Referendum has been passed."
        );
    }

    function mustBePassed(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            referendum.hasBeenPassed,
            "Referendum has not been passed."
        );
    }

    function mustNotBeCancelled(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            !referendum.hasBeenCancelled,
            "Referendum has been cancelled."
        );
    }

    function mustBeCancelled(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            referendum.hasBeenCancelled,
            "Referendum has not been cancelled."
        );
    }

    function mustNotBeExecuted(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            !referendum.hasBeenExecuted,
            "Referendum has been executed."
        );
    }

    function mustBeExecuted(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            referendum.hasBeenExecuted,
            "Referendum ahs not been executed."
        );
    }

    function mustNotBeExpired(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            block.timestamp < referendum.endTimestamp,
            "Referendum has expired."
        );
    }

    function requiredQuorumHasBeenMet(ReferendumStateLib.Referendum storage referendum) public view returns (bool) {
        if (referendum.quorum >= referendum.quorumRequired) { return true; }
        else { return false; }
    }

    function requiredThresholdHasBeenMet(ReferendumStateLib.Referendum storage referendum) public view returns (bool) {
        if (((referendum.votesFor * 100) / (referendum.votesFor + referendum.votesAgainst)) >= referendum.threshold) { return true; }
        else { return false; }
    }
    
    function mustBePresent(
        ReferendumStateLib.Referendum storage referendum,
        ProposalsStateLib.Tracker storage tracker
    ) public view {
        require(
            referendum.identifier >= 1 &&
            referendum.identifier <= tracker.numberOfReferendums,
            "Identifier does not point to an existing referendum."
        );
    }

    function mustNotHaveVoted(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            !referendum.voters.contain(msg.sender),
            "Caller has voted."
        );
    }

    function getAverageActiveQuorum(
        ReferendumStateLib.Referendum[] storage referendums,
        ProposalsStateLib.Tracker storage tracker,
        uint start,
        uint end
    ) public returns (
        uint,
        uint
    ) {
        uint numberOfActiveReferendums;
        uint totalQuorum;

        for (
            uint i = 1;
            i < tracker.numberOfReferendums;
            i++
        ) {
            ReferendumStateLib.Referendum storage referendum = referendums[i];

            /// conditions for an active referendum.
            if (
                start >= referendum.startTimestamp &&
                end <= referendum.endTimestamp &&
                !referendum.hasBeenCancelled &&
                !referendum.hasBeenExecuted &&
                !referendum.hasBeenPassed
            ) {
                numberOfActiveReferendums ++;
                totalQuorum += referendum.quorum;
            }
        }

        uint averageActiveQuorum = totalQuorum / numberOfActiveReferendums;
        return (numberOfActiveReferendums, averageActiveQuorum);
    }

    function create(
        ReferendumStateLib.Referendum[] storage referendums,
        ReferendumStateLib.Settings storage settings,
        ProposalsStateLib.Settings storage proposalsSettings,
        ProposalsStateLib.Tracker storage tracker,
        string memory reason,
        uint startTimestamp,
        uint timeout,
        uint requiredQuorum,
        uint threshold,
        bool delegatecall,
        address target,
        string memory signature,
        bytes memory args
    ) public returns (
        uint,
        uint
    ) {
        require(
            address(0) != msg.sender,
            "Caller is zero address."
        );

        require(
            address(0) != target,
            "Target contract is zero address."
        );

        if (startTimestamp != 0) {
            require(
                block.timestamp >= startTimestamp,
                "Referendum is starting in the past."
            );
        }

        if (timeout != 0) {
            require(
                timeout >= settings.minTimeout &&
                timeout <= settings.maxTimeout,
                "Timeout is out of bounds."
            );
        }

        if (threshold != 0) {
            require(
                threshold >= settings.minThreshold &&
                threshold <= settings.maxThreshold
            );
        }

        tracker.numberOfReferendums ++;
        ReferendumStateLib.Referendum storage referendum = referendums[tracker.numberOfReferendums];
        referendum.identifier = tracker.numberOfReferendums;

        /// create a snapshot and return the snapshot identifier.
        referendum.snapshot = IDreamToken(proposalsSettings.dreamToken).snapshot();
        referendum.creator = msg.sender;
        referendum.reason = reason;

        if (startTimestamp != 0) { referendum.startTimestamp = startTimestamp; }
        else { referendum.startTimestamp = block.timestamp; }

        if (timeout != 0) { referendum.timeout = settings.defaultTimeout; }
        else { timeout = settings.minTimeout; }

        referendum.endTimestamp = referendum.startTimestamp + referendum.timeout;

        if (requiredQuorum != 0) { referendum.requiredQuorum = requiredQuorum; }
        else {
            (, uint averageActiveQuorum) = getAverageActiveQuorum(
                referendums, 
                tracker, 
                block.timestamp - settings.defaultAverageActiveQuorumLookBackTime, 
                block.timestamp
            );

            if (averageActiveQuorum < settings.minRequiredQuorum) { averageActiveQuorum = settings.minRequiredQuorum; }
            else if (averageActiveQuorum > settings.maxRequiredQuorum) { averageActiveQuorum = settings.maxRequiredQuorum; }

            referendum.requiredQuorum = averageActiveQuorum;
        }

        if (threshold != 0) { referendum.threshold = threshold; }
        else { referendum.threshold = settings.defaultThreshold; }

        /// store payload.
        referendum.delegatecall = delegatecall;
        referendum.signature = signature;
        referendum.args = args;

        /// store new referendum
        referendums.push(referendum);

        return (
            referendum.identifer,
            referendum.snapshot
        );
    }

    function vote( /// can only vote once.
        ReferendumStateLib.Referendum[] storage referendums,
        ProposalsStateLib.Tracker storage tracker,
        uint identifier,
        uint choice
    ) public {
        ReferendumStateLib.Referendum storage referendum = referendums[identifer];

        mustBePresent(referendum, tracker);
        mustNotBePassed(referendum);
        mustNotBeCancelled(referendum);
        mustNotBeExpired(referendum);

        require(
            choice >= 0 &&
            choice <= 2,
            "Choice is out of bounds."
        );

        mustNotHaveVoted(referendum);

        uint votes = IDreamToken(settings.nativeToken).getVotesAt(
            msg.sender,
            referendum.snapshot
        );

        if (choice == 0) { referendum.votesToAbstain += votes; }
        else if (choice == 1) { referendum.votesFor += votes; }
        else if (choice == 2) { referendum.votesAgainst += votes; }

        referendum.quorum += votes;
        referendum.voters.add(msg.sender);

        referendums[identifier] = referendum;
    }

    function cancel(
        ReferendumStateLib.Referendum[] storage referendums,
        ProposalsStateLib.Tracker storage tracker,
        uint identifier
    ) public {
        ReferendumStateLib.Referendum storage referendum = referendums[identifer];

        mustBePresent(referendum, tracker);
        mustNotBePassed(referendum);
        mustNotBeCancelled(referendum);
        mustNotBeExecuted(referendum);
        mustNotBeExpired(referendum);

        referendum.hasBeenCancelled = true;

        referendums[identifier] = referendum;
    }

    function execute(
        ReferendumStateLib.Referendum[] storage referendums,
        ProposalsStateLib.Tracker storage tracker,
        uint identifier
    ) public {
        ReferendumStateLib.Referendum storage referendum = referendums[identifer];

        mustBePresent(referendum, tracker);
        mustNotBeExpired(referendum);
        mustNotBeExecuted(referendum);
        mustBePassed(referendum);
        mustNotBeCancelled(referendum);

        referendum.hasBeenExecuted = true;

        referendums[identifier] = referendum;
    }

    function setDefaultThreshold(
        ReferendumStateLib.Settings storage settings,
        uint value
    ) public {
        require(
            value >= settings.minThreshold &&
            value <= settings.maxThreshold,
            "Value is out of bounds." 
        );

        settings.defaultThreshold = value;
        return true;
    }
}