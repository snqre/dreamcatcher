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
contract PublicVotedProposals is Context, Ownable, ReentrancyGuard {
    uint count;
    address dreamToken;

    struct PublicVotedProposal {
        uint reference_;
        uint snapshotId;
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
        bool hasBeenWithdrawn;
        bool hasBeenImplemented;
        bool hasBeenCleared;
        bool delegate;
        address target;
        string signature;
        bytes args;
    }

    mapping(uint => PublicVotedProposal) private publicVotedProposals;

    constructor(address owner) Ownable(owner) {}

    function _mustNotBeMember(
        uint snapshotId
    ) internal view virtual {
        require(
            IDreamToken(dreamToken).getVotesAt(
                msg.sender,
                snapshotId
            ) <= 0,
            "PublicVotedProposals: caller is a member of referenced member"
        );
    }

    function _mustBeMember(
        uint snapshotId
    ) internal view virtual {
        require(
            IDreamToken(dreamToken).getVotesAt(
                msg.sender,
                snapshotId
            ) >= 1,
            "PublicVotedProposals: caller is not a member"
        );
    }

    function _mustNotBeCleared(uint reference_) internal view virtual {
        require(!publicVotedProposals[reference_].hasBeenCleared, "PublicVotedProposals: referenced proposal has been cleared");
    }

    function _mustBeCleared(uint reference_) internal view virtual {
        require(publicVotedProposals[reference_].hasBeenCleared, "PublicVotedProposals: referenced proposal has not been cleared");
    }

    function _mustNotBeWithdrawn(uint reference_) internal view virtual {
        require(!publicVotedProposals[reference_].hasBeenWithdrawn, "PublicVotedProposals: referenced proposal has been withdrawn");
    }

    function _mustBeWithdrawn(uint reference_) internal view virtual {
        require(publicVotedProposals[reference_].hasBeenWithdrawn, "PublicVotedProposals: referened proposal has not been withdrawn");
    }

    function _mustNotBeImplemented(uint reference_) internal view virtual {
        require(!publicVotedProposals[reference_].hasBeenImplemented, "PublicVotedProposals: referenced proposal has been implemented");
    }

    function _mustBeImplemented(uint reference_) internal view virtual {
        require(publicVotedProposals[reference_].hasBeenImplemented, "PublicVotedProposals: referenced proposal has not been implemented");
    }
    //required quorum wip
    function _requiredQuorumHasBeenMet(uint reference_) internal view virtual {
        uint currentQuorum = (publicVotedProposals[reference_])
    }

    function _getAverageActiveQuorum(
        uint rangeBeginTimestamp,
        uint rangeEndTimestamp
    ) internal virtual returns (
        uint //average active quorum
    ) {
        uint activeProposals;
        uint totalQuorum;
        for (
            uint i = 1; 
            i < count; 
            i++
        ) {//too many proposals may increase gas costs too much
            PublicVotedProposal storage proposal = publicVotedProposals[i];
            if (//conditions to be an active proposal
                rangeBeginTimestamp          >= proposal.startTimestamp &&
                rangeEndTimestamp            <= proposal.endTimestamp &&
                proposal.hasBeenWithdrawn    == false &&
                proposal.hasBeenImplemented  == false &&
                proposal.hasBeenCleared      == false
            ) {
                activeProposals ++;
                totalQuorum += proposal.quorum;
            }
        }

        uint averageActiveQuorum = totalQuorum / activeProposals;
        return averageActiveQuorum;
    }

    function _pushNewPublicVotedProposal(
        string memory reason,
        uint startTimestamp,
        uint timeout,
        uint quorumRequired,
        uint threshold,
        bool delegate,
        address target,
        string memory signature,
        bytes memory args
    ) internal virtual nonReentrant returns (
        uint,
        uint
    ) {
        count ++;
        PublicVotedProposal storage newProposal = publicVotedProposals[count];
        newProposal.reference_ = count;
        newProposal.snapshotId = IDreamToken(dreamToken).snapshot();
        newProposal.creator = _msgSender();
        newProposal.reason = reason;
        //check for default startTimestamp
        uint defaultStartTimestamp = block.timestamp;
        if (startTimestamp == 0) {
            newProposal.startTimestamp = defaultStartTimestamp;
        }

        else {
            newProposal.startTimestamp = startTimestamp;
        }
        //check for default timeout
        uint defaultTimeout = 4 weeks;
        if (timeout == 0) {
            newProposal.timeout = defaultTimeout;
        }

        else {
            newProposal.timeout = timeout;
        }
        //check for default quorumRequired
        uint now_ = block.timestamp;
        uint range = now_ - 4 weeks;
        uint defaultQuorumRequired = _getAverageActiveQuorum(
            range,
            now_
        );
        if (quorumRequired == 0) {
            newProposal.quorumRequired = defaultQuorumRequired;
        }

        else {
            newProposal.quorumRequired = quorumRequired;
        }
        //check for default threshold
        uint defaultThreshold = 80;
        if (threshold == 0) {
            newProposal.threshold = defaultThreshold;
        }

        else {
            newProposal.threshold = threshold;
        }
        //copy commands
        newProposal.delegate = delegate;
        newProposal.target = target;
        newProposal.signature = signature;
        newProposal.args = args;

        return (//return reference and snapshot id
            newProposal.reference_,
            newProposal.snapshotId
        );
    }

    function pushNewPublicVotedProposal(
        string memory reason,
        uint startTimestamp,
        uint timeout,
        uint quorumRequired,
        uint threshold,
        bool delegate,
        address target,
        string memory signature,
        bytes memory args
    ) internal virtual nonReentrant returns (
        uint,
        uint
    ) {//generate new proposal using internal function
        return _pushNewPublicVotedProposal(
            reason,
            startTimestamp,
            timeout,
            quorumRequired,
            threshold,
            delegate,
            target,
            signature,
            args
        );
    }
}