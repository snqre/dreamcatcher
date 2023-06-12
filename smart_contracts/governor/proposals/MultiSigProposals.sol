// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";

using EnumerableSet for EnumerableSet.AddressSet;
contract MultiSigProposals is Context, Ownable {
    uint count;

    struct MultiSigProposal {
        uint reference_;            // the unique identifier of this proposal on this contract
        address creator;            // the address that created this proposal
        uint startTimestamp;        // start timestamp
        uint endTimestamp;          // start timestamp - timeout
        uint timeout;               // amount of time after start timestamp proposal will expire
        uint quorumRequired;        // minimum % of signatures required to clear the proposal
        bool hasBeenWithdrawn;      // proposal has been withdrawn
        bool hasBeenImplemented;    // proposal has been cleared and has been implemented
        bool hasBeenCleared;        // proposal has been cleared and can be implemented
        bool delegate;              // you are requesting that the following call is made as the owner contract
        address target;             // you are requesting to target this contract  
        string signature;           // you are requesting to call this function
        bytes args;                 // you are requesting to use these parameters
        uint gasLimit;              // you are requesting this gas limit
        EnumerableSet
            .AddressSet signers;    // an array of signers who are authorized to sign
        EnumerableSet
            .AddressSet signatures; // an array of current signatures
    }

    mapping(uint => MultiSigProposal) private multiSigProposals;

    constructor(address admin) Ownable(admin) {}

    function _pushNewMultiSigProposal(
        uint startTimestamp,
        uint timeout,
        uint quorumRequired,
        bool delegate,
        address target,
        string memory signature,
        bytes memory args,
        uint gasLimit,
        address[] memory signers
    ) internal virtual {
        count ++;
        MultiSigProposal storage newMultiSigProposal = multiSigProposals[count];
        newMultiSigProposal.reference_ = count;
        newMultiSigProposal.creator = _msgSender();

        // here we check for default timestamp
        uint now_ = block.timestamp;
        if (startTimestamp == 0) {
            newMultiSigProposal.startTimestamp = now_;
        }

        else {
            require(startTimestamp >= now_, "startTimestamp is in the past");
            newMultiSigProposal.startTimestamp = startTimestamp;
        }

        // here we check for default timeout
        uint defaultTimeout = 24 hours;
        if (timeout == 0) {
            newMultiSigProposal.timeout = defaultTimeout;
        }

        else {
            newMultiSigProposal.timeout = timeout;
        }

        // set endTimestamp
        newMultiSigProposal.endTimestamp = newMultiSigProposal.startTimestamp + newMultiSigProposal.timeout;
        
        // note this is in percentage out of 100 and here we check for default quorum required
        uint defaultQuorumRequired = 100;
        if (quorumRequired == 0) {
            newMultiSigProposal.quorumRequired = defaultQuorumRequired;
        }

        else {
            require(quorumRequired <= 100, "quorumRequired is greater than 100%");
            newMultiSigProposal.quorumRequired = quorumRequired;
        }

        newMultiSigProposal.delegate = delegate;
        newMultiSigProposal.target = target;
        newMultiSigProposal.signature = signature;
        newMultiSigProposal.args = args;
        newMultiSigProposal.gasLimit = gasLimit;

        // here we are adding the expected signers to the proposal
        for (uint i = 0; i < signers.length; i++) {
            // for each signer add to proposal expected signers
            newMultiSigProposal.signers.add(signers[i]);
        }

        // ... we dont touch signatures because this remains empty ...
    }
}