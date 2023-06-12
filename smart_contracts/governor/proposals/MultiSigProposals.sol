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
        uint endTimestamp;          // start timestamp + timeout
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

    event MultiSigProposalCreated(
        uint indexed reference_,
        address indexed creator,
        uint indexed startTimestamp,
        uint endTimestamp,
        uint timeout,
        uint quorumRequired,
        bool delegate,
        address target,
        string signature,
        bytes args,
        uint gasLimit,
        address[] signers
    );

    event Signed(
        uint indexed reference_,
        address indexed signer,
        uint indexed timestamp
    );

    event SignatureRevoked(
        uint indexed reference_,
        address indexed signer,
        uint indexed timestamp
    );

    event Cleared(
        uint indexed reference_,
        address indexed lastSigner,
        uint indexed timestamp,
        uint numberOfSignatures
    );

    event Withdrawn(
        uint indexed reference_,
        address indexed caller,
        uint indexed timestamp
    );

    event Implemented(
        uint indexed reference_,
        address indexed caller,
        uint indexed timestamp
    );

    constructor(address owner) Ownable(owner) {}

    // will revert if the caller is not a signer
    function _mustBeSigner(uint reference_, address account) internal virtual {
        require(multiSigProposals[reference_].signers.contains(account), "caller is not an expected signer");
    }

    function _mustHaveSigned(uint reference_, address account) internal virtual {
        require(multiSigProposals[reference_].signatures.contains(account), "caller has not signed");
    }

    // will revert if the referenced proposal has been cleared
    function _mustNotBeCleared(uint reference_) internal virtual {
        require(!multiSigProposals[reference_].hasBeenCleared, "referenced proposal has been cleared");
    }

    // will revert if the referenced proposal has been cleared
    function _mustBeCleared(uint reference_) internal virtual {
        require(multiSigProposals[reference_].hasBeenCleared, "referenced proposal has been cleared");
    }

    // will revert if the referenced proposal has been withdraw
    function _mustNotBeWithdrawn(uint reference_) internal virtual {
        require(!multiSigProposals[reference_].hasBeenWithdrawn, "referenced proposal has been withdraw");
    }

    // will revert if the referenced proposal has been implemented
    function _mustNotBeImplemented(uint reference_) internal virtual {
        require(!multiSigProposals[reference_].hasBeenImplemented, "referenced proposal has been implemented");
    }

    // will revert if the referenced proposal has expired
    function _mustNotBeExpired(uint reference_) internal virtual {
        require(block.timestamp < multiSigProposals[reference_].endTimestamp, "referenced proposal has expired");
    }

    function _requiredQuorumHasBeenMet(uint reference_) internal virtual returns (bool) {
        uint currentQuorum = (multiSigProposals[reference_].signers.length() * 100) / multiSigProposals[reference_].signatures.length();
        if (currentQuorum >= multiSigProposals[reference_].quorumRequired) {
            return true;
        }

        else {
            return false;
        }
    }

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

        // we finally emit an event for proposal creation on the contract
        emit MultiSigProposalCreated(
            newMultiSigProposal.reference_,
            newMultiSigProposal.creator,
            newMultiSigProposal.startTimestamp,
            newMultiSigProposal.endTimestamp,
            newMultiSigProposal.timeout,
            newMultiSigProposal.quorumRequired,
            newMultiSigProposal.delegate,
            newMultiSigProposal.target,
            newMultiSigProposal.signature,
            newMultiSigProposal.args,
            newMultiSigProposal.gasLimit,
            signers
        );
    }

    function _sign(uint reference_) internal virtual {
        _mustBeSigner(reference_, _msgSender());
        _mustNotBeCleared(reference_);
        _mustNotBeWithdrawn(reference_);
        _mustNotBeImplemented(reference_);
        _mustNotBeExpired(reference_);

        // we add the callers address to the array of signatures
        multiSigProposals[reference_].signatures.add(_msgSender());

        uint now_ = block.timestamp;
        emit Signed(reference_, _msgSender(), now_);

        // here we check if the threshold has been met
        if (_requiredQuorumHasBeenMet(reference_)) {
            multiSigProposals[reference_].hasBeenCleared;
            emit Cleared(reference_, _msgSender(), now_, multiSigProposals[reference_].signatures.length());
        }
    }

    function _unsign(uint reference_) internal virtual {
        _mustBeSigner(reference_, _msgSender());
        _mustHaveSigned(reference_, _msgSender());
        _mustNotBeCleared(reference_);
        _mustNotBeWithdrawn(reference_);
        _mustNotBeImplemented(reference_);
        _mustNotBeExpired(reference_);

        // we remove the callers signature
        multiSigProposals[reference_].signatures.remove(_msgSender());

        emit SignatureRevoked(reference_, _msgSender(), block.timestamp);
    }

    // in this context this is cancel
    function _withdraw(uint reference_) internal virtual {
        _mustNotBeCleared(reference_);
        _mustNotBeWithdrawn(reference_);
        _mustNotBeImplemented(reference_);

        multiSigProposals[reference_].hasBeenWithdrawn = true;

        emit Withdrawn(reference_, _msgSender(), block.timestamp);
    }

    // this alone does nothing, can only set once
    function _implement(uint reference_) internal virtual {
        _mustNotBeExpired(reference_);
        _mustNotBeImplemented(reference_);
        _mustBeCleared(reference_);
        
        multiSigProposals[reference_].hasBeenImplemented = true;

        emit Implemented(reference_, _msgSender(), block.timestamp);
    }
}