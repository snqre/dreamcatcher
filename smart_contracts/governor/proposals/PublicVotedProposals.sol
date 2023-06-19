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
    uint countActivitySnapshots;
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

    struct ActivitySnapshot {
        uint timestamp;
        uint reference_;
        uint activeProposals;
        uint countInteractions;
    }

    mapping(uint => PublicVotedProposal) private publicVotedProposals;
    mapping(uint => ActivitySnapshot) private activitySnapshots;

    constructor(address owner) Ownable(owner) {}

    function _mustBeMember(uint reference_, address account) internal view virtual {
        // get snapshotId
        uint sId = publicVotedProposals[reference_].snapshotId;

        // get balance at the time of the proposal
        uint balance = IDreamToken(dreamToken).getVotesAt(account, sId);

        // caller must have at least 1 wei of $DREAM to be a member
        require(balance >= 1, "PublicVotedProposal: caller is not a member");
    }

    function _getVotes(address account) internal view virtual returns (uint) {
        return IDreamToken(dreamToken).getVotes(account);
    }

    /**
     * @dev Activity snapshots are used to measure the quorum
     * If there is less activity, less quorum is needed
     * Vice versa more activity will require more quorum
     * This can also incentive more proposals
     * During less active moments, its easier to pass a proposal which results in more proposals
     */

    function _calculateAverageActiveQuorum() internal virtual returns (
        uint
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
                block.timestamp >= proposal.startTimestamp &&
                block.timestamp <= proposal.endTimestamp &&
                proposal.hasBeenWithdrawn == false &&
                proposal.hasBeenImplemented == false &&
                proposal.hasBeenCleared == false
            ) {
                activeProposals ++;
                totalQuorum += proposal.quorum;
            }
        }

        uint averageActiveQuorum = totalQuorum / activeProposals;
        return averageActiveQuorum;
    }

    function _activitySnapshot() internal virtual returns (uint, uint) {
        countActivitySnapshots ++;
        uint reference_ = countActivitySnapshots;
        ActivitySnapshot storage snapshot = activitySnapshots[reference_];
        snapshot.timestamp = block.timestamp;
        snapshot.reference_ = reference_;

        uint activeProposals;
        uint countInteractions;
        for (uint i = 1; i < count; i++) {//too many proposals may increase the cost of this calculation
            PublicVotedProposal storage proposal = publicVotedProposals[reference_];
            if (//conditions to be an active proposal
                proposal.startTimestamp <= snapshot.timestamp && 
                proposal.endTimestamp >= snapshot.timestamp && 
                proposal.hasBeenWithdrawn == false &&
                proposal.hasBeenImplemented == false &&
                proposal.hasBeenCleared == false
            ) {
                activeProposals ++;
                countInteractions += proposal.quorum;
            }
        }

        snapshot.activeProposals = activeProposals;
        snapshot.countInteractions = countInteractions;
        //return reference and timestamp
        return (snapshot.reference_, snapshot.timestamp);
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
    ) internal virtual {
        count ++;
        PublicVotedProposal storage newPublicVotedProposal = publicVotedProposals[count];
        newPublicVotedProposal.reference_ = count;
        newPublicVotedProposal.snapshotId = IDreamToken(dreamToken).snapshot();
        newPublicVotedProposal.creator = _msgSender();
        newPublicVotedProposal.reason = reason;

        /** @dev setting startTimeframe and checking for default value */
        uint defaultStartTimestamp = block.timestamp;
        if (startTimestamp == 0) {
            newPublicVotedProposal.startTimestamp = defaultStartTimestamp;
        }

        else {
            newPublicVotedProposal.startTimestamp = startTimestamp;
        }

        /** @dev setting timeout and checking for default value */
        uint defaultTimeout = 1 weeks;
        if (timeout == 0) {
            newPublicVotedProposal.timeout = defaultTimeout;
        }

        else {
            newPublicVotedProposal.timeout = timeout;
        }

        /** @dev default check */
        uint defaultQuorumRequired = 50;

        // calculate based on algo
        
        
    }

}