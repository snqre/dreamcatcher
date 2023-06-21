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
contract FullSetElectionProposals is Context, Ownable, ReentrancyGuard {
    uint count;
    address dreamToken;

    struct FullSetElectionProposal {
        uint reference_;
        uint snapshotId;
        address creator;
        string reason;
        uint startTimestamp;
        uint endTimestamp;
        uint timeout;
        uint quorum;
        uint quorumRequired;
        uint[] votesFor;                //array to see how many votes for each participant
        uint votesToAbstain;            //amount of participants who are not voting for any participants
        EnumerableSet.
            AddressSet participants;    //participants who are participating in the election
        bool hasBeenWithdrawn;
        bool hasBeenImplemented;
        bool hasBeenCleared;
        EnumerableSet.
            AddressSet voters;          //voters who are electing
    }

    mapping(uint => FullSetElectionProposal) private fullSetElectionProposals;

    constructor(address owner) Ownable(owner) {}

    function _pushNewFullSetElectionProposal(
        string memory reason,
        uint startTimestamp
    ) internal virtual nonReentrant returns (
        uint,
        uint
    ) {
        count++;
        FullSetElectionProposal storage newProposal = fullSetElectionProposals[count];
        newProposal.reference_ = count;
        newProposal.snapshotId = IDreamToken(dreamToken).snapshot();
        newProposal.creator = _msgSender();
        newProposal.reason = reason;
        //check for default startTimestamp
        uint defaultStartTimestamp = block.timestamp;
        if (startTimestamp == 0) { newProposal.startTimestamp = defaultStartTimestamp; }
        else { newProposal.startTimestamp = startTimestamp; }
        //check for default quorumRequired
        uint now_ block.timestamp;

    }
}