// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";

import "smart_contracts/utils/Utils.sol";
import "smart_contracts/tokens/dream_token/DreamToken.sol";
import "smart_contracts/governor/proposals/referendum/Lib.sol";
import "smart_contracts/utils/comparison/Comparison.sol";
import "smart_contracts/governor/proposals/coordinator/Coordinator.sol";

contract Referendum is Context, Ownable, ReentrancyGuard {
    Lib.Tracker private tracker;
    Lib.Settings private settings;
    
    mapping(uint => Lib.Referendum) private referendums;
    mapping(uint => mapping(address => Lib.Voter)) private voters;

    event ReferendumCreated(
        uint indexed identifier,
        uint snapshot,
        address indexed creator,
        string indexed reason,
        uint startTimestamp,
        uint endTimestamp,
        uint timeout,
        uint quorumRequired,
        uint threshold,
        bool delegatecall,
        address target,
        string signature,
        bytes args
    );

    event Voted(
        uint indexed identifier,
        address indexed voter,
        uint indexed votes,
        uint timestamp,
        uint choice
    );

    event Passed(
        uint indexed identifier,
        address indexed lastVoter,
        uint indexed timestamp,
        uint quorum
    );

    event Cancelled(
        uint indexed identifier,
        address indexed caller,
        uint indexed timestamp
    );

    event Executed(
        uint indexed identifier,
        address indexed caller,
        uint indexed timestamp
    );

    constructor(address owner) Ownable(owner) {
        settings.defaultThreshold = 75;
        settings.minTimeoutDays = 7 days;
        settings.maxTimeoutDays = 365 days;
        settings.defaultAverageActiveQuorumLookBackDays = 30 days;
        settings.minQuorumRequired = Utils.convertToWei(40000000);
        settings.maxQuorumRequired = Utils.convertToWei(200000000);
        settings.minThreshold = 50;
        settings.maxThreshold = 100;
    }

    function _getAverageActiveQuorum(
        uint start,
        uint end
    ) private view returns (
        uint,
        uint
    ) {
        uint numberOfActiveReferendums;
        uint totalQuorum;

        for (uint i = 1; i < tracker.numberOfReferendums; i++) {
            Lib.Referendum storage referendum = referendums[i];

            // conditions to be an active referendum
            if (
                start >= referendum.startTimestamp &&
                end <= referendum.endTimestamp &&
                !referendum.hasBeenCancelled &&
                !referendum.hasBeenExecuted &&
                !Referendum.hasBeenPassed
            ) {
                numberOfActiveReferendums ++;
                totalQuorum += referendum.quorum;
            }
        }

        uint averageActiveQuorum = totalQuorum / numberOfActiveReferendums;
        return (numberOfActiveReferendums, averageActiveQuorum);
    }

    function new_(
        string memory reason,
        uint startTimestamp,
        uint timeout,
        uint quorumRequired,
        uint threshold,
        bool delegatecall,
        address target,
        string memory signature,
        bytes memory args
    ) external onlyOwner nonReentrant returns (
        uint,
        uint
    ) {
        /// outsource require function to reduce contract size.
        Comparison.mustNotBeZeroAddress(_msgSender());
        Comparison.mustNotBeZeroAddress(target);

        if (startTimestamp != 0) { Comparison.mustNotBeBeforePresent(startTimestamp); }

        if (timeout != 0) {
            Comparison.mustBeWithinRange(
                timeout, 
                settings.minTimeoutDays,
                settings.maxTimeoutDays
            );
        }

        if (threshold != 0) {
            Comparison.mustBeWithinRange(
                threshold, 
                settings.minThreshold,
                settings.maxThreshold
            );
        }

        /// ask coordinator.
        Coordinator.mustBeOnWhitelist(target);
        
        tracker.numberOfReferendums ++;
        Lib.Referendum storage referendum = referendums[tracker.numberOfReferendums];
        referendum.identifier = tracker.numberOfReferendums;

        /// create a snapshot and return the snapshot identifier.
        referendum.snapshot = IDreamToken(settings.nativeToken).snapshot();
        referendum.creator = _msgSender();
        referendum.reason = reason;

        if (startTimestamp != 0) { referendum.startTimestamp = startTimestamp; }
        else { referendum.startTimestamp = block.timestamp; }

        if (timeout != 0) { referendum.timeout = timeout; }
        else { timeout = settings.minTimeoutDays; }

        referendum.endTimestamp = referendum.startTimestamp + referendum.timeout;

        if (quorumRequired != 0) { referendum.quorumRequired = quorumRequired; }
        else {
            (, uint averageActiveQuorum) = _getAverageActiveQuorum(
                block.timestamp - settings.defaultAverageActiveQuorumLookBackDays, 
                block.timestamp
            );

            if (averageActiveQuorum < settings.minQuorumRequired) { averageActiveQuorum = settings.minQuorumRequired; }
            else if (averageActiveQuorum > settings.maxQuorumRequired) { averageActiveQuorum = settings.maxQuorumRequired; }

            referendum.quorumRequired = averageActiveQuorum;
        }

        if (threshold != 0) { referendum.threshold = threshold; }
        else { referendum.threshold = settings.defaultThreshold; }

        /// store payload.
        referendum.delegatecall = delegatecall;
        referendum.signature = signature;
        referendum.args = args;

        emit ReferendumCreated(
            referendum.identifier,
            referendum.snapshot,
            referendum.creator,
            referendum.reason,
            referendum.startTimestamp,
            referendum.endTimestamp,
            referendum.timeout,
            referendum.quorumRequired,
            referendum.threshold,
            referendum.delegatecall,
            referendum.target,
            referendum.signature,
            referendum.args
        );

        return (
            referendum.identifier,
            referendum.snapshot
        );
    }

    function vote(
        uint identifier,
        uint choice
    ) external nonReentrant returns (bool) {
        Lib.Referendum storage referendum = referendums[identifier];

        /// outsource require function to reduce contract size.
        Lib.mustBePresent(
            referendum,
            tracker
        );

        Lib.mustNotBePassed(referendum);
        Lib.mustNotBeCancelled(referendum);
        Lib.mustNotBeExpired(referendum);

        Comparison.mustBeWithinRange(
            choice,
            0, 
            2
        );

        Lib.Voter storage voter = voters[identifier][_msgSender()];
        voter.account = _msgSender();
        voter.votes = IDreamToken(settings.nativeToken).getVotesAt(
            _msgSender(),
            referendum.snapshot
        );

        /// voter must have at least 1 vote.
        Comparison.mustBeGreaterThan(
            voter.votes,
            1
        );

        if (voter.hasVoted) {
            /// delete previous choice and response.
            if (voter.choice = 0) { referendum.votesToAbstain -= voter.votes; }
            else if (voter.choice = 1) { referendum.votesFor -= voter.votes; }
            else if (voter.choice = 2) { referendum.votesAgainst -= voter.votes; }
            
            referendum.quorum -= voter.votes;
            referendum.voters.add(_msgSender());
        }

        /// log new vote or overwrite previous.
        voter.choice = choice;
        voter.hasVoted = true;

        if (choice = 0) { referendum.votesToAbstain += voter.votes; }
            else if (choice = 1) { referendum.votesFor += voter.votes; }
            else if (choice = 2) { referendum.votesAgainst += voter.votes; }

        referendum.quorum += voter.votes;

        emit Voted(
            referendum.identifer,
            _msgSender(),
            voter.votes,
            block.timestamp,
            choice
        );

        return true;
    }

    function cancel(uint identifier) external onlyOwner nonReentrant returns (bool) {
        Lib.Referendum storage referendum = referendums[identifer];

        /// outsource require function to reduce contract size.
        Lib.mustBePresent(referendum);
        Lib.mustNotBePassed(referendum);
        Lib.mustNotBeCancelled(referendum);
        Lib.mustNotBeExecuted(referendum);
        Lib.mustNotBeExpired(referendum);

        referendum.hasBeenCancelled = true;

        emit Cancelled(
            identifier,
            _msgSender(),
            block.timestamp
        );
    }

    function execute(uint identifier) external onlyOwner nonReentrant returns (bool) {
        Lib.Referendum storage referendum = referendums[identifer];

        /// outsource require function to reduce contract size.
        Lib.mustBePresent(referendum);
        Lib.mustNotBeExpired(referendum);
        Lib.mustNotBeExecuted(referendum);
        Lib.mustBePassed(referendum);
        Lib.mustNotBeCancelled(referendum);

        referendum.hasBeenExecuted = true;

        emit Executed(
            identifier,
            _msgSender(),
            block.timestamp
        );
    }

    function setDefaultThreshold(uint value) external onlyOwner returns (bool) {
        Comparison.mustBeWithinRange(
            value,
            settings.minThreshold, 
            settings.maxThreshold
        );

        settings.defaultThreshold = value;
        return true;
    }

    function setMinThreshold(uint value) external onlyOwner returns (bool) {
        Comparison.mustBeWithinRange(
            value, 
            50, 
            settings.maxThreshold
        );
        
        settings.minThreshold = value;
        return true;
    }

    function setMaxThreshold(uint value) external onlyOwner returns (bool) {
        Comparison.mustBeWithinRange(
            value, 
            settings.minThreshold, 
            100
        );

        settings.maxThreshold = value;
        return true;
    }

    function setMinTimeoutDays(uint value) external onlyOwner returns (bool) {
        Comparison.mustBeGreaterThan(
            value,
            7 days
            );

            settings.minTimeoutDays = value;
            return true;
    }

    function setMaxTimeoutDays(uint value) external onlyOwner returns (bool) {
        settings.maxTimeoutDays = value;
        return true;
    }

    function setAverageActiveQuorumLookBackDays(uint value) external onlyOwner returns (bool) {
        settings.defaultAverageActiveQuorumLookBackDays = value;
        return true;
    }

    function setMinQuorumRequired (uint value) external onlyOwner returns (bool) {
        settings.minQuorumRequired = value;
        return true;
    }

    function setMaxQuorumRequired (uint value) external onlyOwner returns (bool) {
        Comparison.mustBeGreaterThan(
            value,
            200000000
        );

        settings.maxQuorumRequired = value;
        return true;
    }

    function setNativeToken(address contract_) external onlyOwner returns (bool) {
        settings.nativeToken = contract_;
        return true;
    }

    function getNumberOfActiveReferendums() external view returns (uint) {
        (uint numberOfActiveReferendums, ) = _getAverageActiveQuorum(
            0,
            type(uint256).max
        );

        return numberOfActiveReferendums;
    }

    function getReferendum(uint identifier) external view returns (Lib.Referendum) {
        Lib.Referendum storage referendum = referendums[identifer];
        return referendum;
    }

    function getVoter(uint identifier, address account) external view returns (Lib.Voter) {
        Lib.Voter storage voter = voter[identifer];
        return voter;
    }

    function getVoters(uint identifier) external view returns (address[] memory) {
        Lib.Referendum storage referendum = referendums[identifer];
        return Utils.convertEnumerableSetAddressSetToArray(referendum.voters);
    }
}