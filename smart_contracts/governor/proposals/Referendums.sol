// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";

import "smart_contracts/utils/Utils.sol";
import "smart_contracts/tokens/dream_token/DreamToken.sol";

using EnumerableSet for EnumerableSet.AddressSet;
contract Referendums is Context, Ownable, ReentrancyGuard {
    enum Side { ABSTAIN, FOR, AGAINST }

    struct Tracker {
        uint numberOfReferendums;
    }
    
    struct Settings {
        uint threshold;
        uint minTimeoutDays;
        uint maxTimeoutDays;
        uint averageActiveQuorumLookBackDays;
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

    Tracker internal tracker;
    Settings internal settings;
    mapping(uint => Referendum) internal referendums;
    mapping(address => mapping(uint => Side)) internal sideVotedFor;
    mapping(address => mapping(uint => bool)) internal hasVoted;
    mapping(address => bool) internal whitelist;//remember check this from terminal

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
        Side side
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
        settings.threshold = 75;
        settings.minTimeoutDays = 7 days;
        settings.maxTimeoutDays = 365 days;
        settings.averageActiveQuorumLookBackDays = 30 days;
        settings.minQuorumRequired = Utils.convertToWei(40000000);
        settings.maxQuorumRequired = Utils.convertToWei(200000000);
        settings.minThreshold = 0;
        settings.maxThreshold = 100;
    }

    function _mustNotBePassed(uint identifier) internal view virtual {
        require(
            !referendums[identifier].hasBeenPassed,
            "Referendums: referendum has been passed"
        );
    }

    function _mustBePassed(uint identifier) internal view virtual {
        require(
            referendums[identifier].hasBeenPassed,
            "Referendums: referendum has not been passed"
        );
    }

    function _mustNotBeCancelled(uint identifier) internal view virtual {
        require(
            !referendums[identifier].hasBeenCancelled,
            "Referendums: referendum has been cancelled"
        );
    }

    function _mustBeCancelled(uint identifier) internal view virtual {
        require(
            referendums[identifier].hasBeenCancelled,
            "Referendums: referendum has not been cancelled"
        );
    }

    function _mustNotBeExecuted(uint identifier) internal view virtual {
        require(
            !referendums[identifier].hasBeenExecuted,
            "Referendums: referendum has been executed"
        );
    }

    function _mustBeExecuted(uint identifier) internal view virtual {
        require(
            referendums[identifier].hasBeenExecuted,
            "Referendums: referendum has not been executed"
        );
    }

    function _mustNotBeExpired(uint identifier) internal view virtual {
        require(
            block.timestamp < referendums[identifier].endTimestamp,
            "Referendums: referendum has expired"
        );
    }

    function _requiredQuorumHasBeenMet(uint identifier) internal view virtual returns (bool) {
        Referendum storage referendum = referendums[identifier];
        if (referendum.quorum >= referendum.quorumRequired) { return true; }
        else { return false; }
    }

    function _requiredThresholdHasBeenMet(uint identifier) internal view virtual returns (bool) {
        Referendum storage referendum = referendums[identifier];
        uint current = (referendum.votesFor * 100) / (referendum.votesFor + referendum.votesAgainst);
        if (current >= referendum.threshold) { return true; }
        else { return false; }
    }

    function _mustBePresent(uint identifier) internal view virtual {
        require(
            identifier >= 1 &&
            identifier <= tracker.numberOfReferendums,
            "Referendums: identifier does not point to an existing referendum"
        );
    }

    function _getAverageActiveQuorum(
        uint rangeStart,
        uint rangeEnd
    ) internal virtual returns (
        uint averageActiveQuorum,
        uint numberOfActiveReferendums
    ) {
        uint activeProposals;
        uint totalQuorum;

        for (
            uint i = 1;//this starts at one because of the way we start counting proposals
            i < tracker.numberOfReferendums;
            i++
        ) {
            Referendum storage referendum = referendums[i];
            if (//conditions to be an active proposal
                rangeStart >= referendum.startTimestamp &&
                rangeEnd <= referendum.endTimestamp &&
                referendum.hasBeenCancelled == false &&
                referendum.hasBeenExecuted == false &&
                referendum.hasBeenPassed == false
            ) {
                activeProposals ++;
                totalQuorum += referendum.quorum;
            }
        }

        //average active quorum
        return (totalQuorum / activeProposals, activeProposals);
    }

    function _new(
        string memory reason,
        uint startTimestamp,
        uint timeout,
        uint quorumRequired,
        uint threshold,
        bool delegatecall,
        address target,
        string memory signature,
        bytes memory args
    ) internal virtual returns (
        uint identifier_,
        uint snapshot
    ) {
        uint now_ = block.timestamp;
        require(_msgSender() != address(0), "Referendums: _msgSender() == address(0)");
        require(now_ >= startTimestamp, "Referendums: startTimestamp is in the past");
        require(
            timeout >= settings.minTimeoutDays &&
            timeout <= settings.maxTimeoutDays,
            "Referendums: timeout value out of bounds"
        );
        require(target != address(0), "Referendum: target == address(0)");
        require(whitelist[target], "Referendum: target is not whitelisted");
        require(
            threshold >= settings.minThreshold &&
            threshold <= settings.maxThreshold
        );

        tracker.numberOfReferendums ++;
        uint identifier = tracker.numberOfReferendums;
        Referendum storage referendum = referendums[identifier];
        referendum.identifier = identifier;

        //create snapshot and return snapshot identifier
        referendum.snapshot = IDreamToken(settings.nativeToken).snapshot();
        referendum.creator = _msgSender();
        referendum.reason = reason;

        if (startTimestamp == 0) { startTimestamp = now_; }
        else { referendum.startTimestamp = startTimestamp; }

        if (timeout == 0) { timeout = settings.minTimeoutDays; }
        else { referendum.timeout = timeout; }

        referendum.endTimestamp = referendum.startTimestamp + referendum.timeout;

        if (quorumRequired == 0) {
            uint averageActiveQuorum = _getAverageActiveQuorum(
                now_ - settings.averageActiveQuorumLookBackDays,
                now_
            );

            if (averageActiveQuorum < settings.minQuorumRequired) { averageActiveQuorum = settings.minQuorumRequired; }
            else if (averageActiveQuorum > settings.maxQuorumRequired) { averageActiveQuorum = settings.maxQuorumRequired; }

            referendum.quorumRequired = averageActiveQuorum;
        }

        else { referendum.quorumRequired = quorumRequired; }

        if (threshold == 0) { referendum.threshold = settings.threshold; }
        else { referendum.threshold = threshold; }

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

    function _vote(
        uint identifier, 
        uint side
    ) internal virtual {
        _mustBePresent(identifier);
        _mustNotBePassed(identifier);
        _mustNotBeCancelled(identifier);
        _mustNotBeExpired(identifier);

        Referendum storage referendum = referendums[identifier];
        Side selectedSide = Side(side);
        uint votes = IDreamToken(settings.nativeToken).getVotesAt(
            _msgSender(),
            referendum.snapshot
        );
        uint now_ = block.timestamp;
        if (hasVoted[_msgSender()][identifier]) {//if caller has voted
            //delete previous votes
            if (sideVotedFor[_msgSender()][identifier] == Side.ABSTAIN) {
                referendum.votesToAbstain -= votes;
            }

            else if (sideVotedFor[_msgSender()][identifier] == Side.FOR) {
                referendum.votesFor -= votes;
            }

            else if (sideVotedFor[_msgSender()][identifier] == Side.AGAINST) {
                referendum.votesAgainst -= votes;
            }
            
            //add new votes
            if (selectedSide == Side.ABSTAIN) {
                sideVotedFor[_msgSender()][identifier] = Side.ABSTAIN;
                referendum.votesToAbstain += votes;
            }

            else if (selectedSide == Side.FOR) {
                sideVotedFor[_msgSender()][identifier] = Side.FOR;
                referendum.votesFor += votes;
            }

            else if (selectedSide == Side.AGAINST) {
                sideVotedFor[_msgSender()][identifier] = Side.AGAINST;
                referendum.votesAgainst += votes;
            }
        }

        else {
            // add new votes
            hasVoted[_msgSender()][identifier] = true;
            referendum.quorum += votes;
            if (selectedSide == Side.ABSTAIN) {
                sideVotedFor[_msgSender()][identifier] = Side.ABSTAIN;
                referendum.votesToAbstain += votes;
            }

            else if (selectedSide == Side.FOR) {
                sideVotedFor[_msgSender()][identifier] = Side.FOR;
                referendum.votesFor += votes;
            }

            else if (selectedSide == Side.AGAINST) {
                sideVotedFor[_msgSender()][identifier] = Side.AGAINST;
                referendum.votesAgainst += votes;
            }
        }

        emit Voted(
            referendum.identifier,
            _msgSender(),
            votes,
            now_,
            sideVotedFor[_msgSender()][identifier]
        );

        if (
            _requiredQuorumHasBeenMet(identifier) &&
            _requiredThresholdHasBeenMet(identifier)
        ) {
            referendum.hasBeenPassed = true;

            emit Passed(
                referendum.identifier,
                _msgSender(),
                now_,
                referendum.quorum
            );
        }
    }

    function _cancel(uint identifier) internal virtual {
        _mustBePresent(identifier);
        _mustNotBePassed(identifier);
        _mustNotBeCancelled(identifier);
        _mustNotBeExecuted(identifier);
        _mustNotBeExpired(identifier);

        Referendum storage referendum = referendums[identifier];
        referendum.hasBeenCancelled = true;

        emit Cancelled(
            identifier,
            _msgSender(),
            block.timestamp
        );
    }

    function _execute(uint identifier) internal virtual {
        _mustBePresent(identifier);
        _mustNotBeExpired(identifier);
        _mustNotBeExecuted(identifier);
        _mustBePassed(identifier);
        _mustNotBeCancelled(identifier);

        Referendum storage referendum = referendums[identifier];
        referendum.hasBeenExecuted = true;

        emit Executed(
            identifier,
            _msgSender(),
            block.timestamp
        );
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
    ) public virtual onlyOwner nonReentrant returns (
        bool success,
        uint identifier,
        uint snapshot
    ) {
        (
            uint identifier,
            uint snapshot
        ) = _new(
            reason,
            startTimestamp,
            timeout,
            quorumRequired,
            threshold,
            delegatecall,
            target,
            signature,
            args
        );

        return (
            true,
            identifier,
            snapshot
        );
    }

    function vote(
        uint identifier,
        uint side
    ) public virtual onlyOwner nonReentrant returns (bool success) {
        _vote(
            identifier,
            side
        );

        return true;
    }

    function cancel(uint identifier) public virtual onlyOwner nonReentrant returns (bool success) {
        _cancel(identifier);

        return true;
    }

    function execute(uint identifier) public virtual onlyOwner nonReentrant returns (bool success) {
        _execute(identifier);

        return true;
    }

    function numberOfReferendums() public view virtual returns (uint) {
        return tracker.numberOfReferendums;
    }

    function numberOfActiveReferendums() public view virtual returns (uint) {
        (, uint activeReferendums) = _getAverageActiveQuorum(
            0, type(uint256).max
        );

        return activeReferendums;
    }

}