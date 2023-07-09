// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/Authenticator.sol";
import "contracts/polygon/templates/modular-upgradeable/Key.sol";

interface IMultiSigProposals {
    /// multi-sig-proposals-new_
    function new_(string memory reason, uint startTimestamp, address target, string memory signature, bytes memory args)
    external
    returns (uint);

    function sign(uint identifier)
    external
    returns (bool);

    function unsign(uint identifier)
    external
    returns (bool);

    /// multi-sig-proposals-cancel
    function cancel(uint identifier)
    external
    returns (bool);

    /// multi-sig-proposals-execute
    function execute(uint identifier)
    external
    returns (bool);

    /// multi-sig-proposals-set-default-required-quorum
    function setDefaultRequiredQuorum(uint newValueBasisPoints)
    external
    returns(bool);

    /// multi-sig-proposals-set-default-timeout
    function setDefaultTimeout(uint newValue)
    external
    returns (bool);

    event ProposalCreated(
        uint identifier,
        address creator,
        uint startTimestamp,
        uint endTimestamp,
        uint timeout,
        uint quorumRequired,
        address indexed target,
        string indexed signature,
        bytes indexed args,
        address[] signers
    );

    event Signed(uint indexed identifier, address indexed signer);
    event SignatureRevoked(uint indexed identifier, address indexed signer);
    event Approved(uint indexed identifier, address indexed lastSigner, uint indexed signaturesLength);
    event Cancelled(uint indexed identifier, address indexed caller);
    event Executed(uint indexed identifier, address indexed caller);

    error CallerIsNotAMemberOfTheCouncil(address caller);
    error CallerIsNotASigner(uint indentifier, address signer);
    error SignerHasNotSigned(uint identifier, address signer);
    error ProposalHasNotBeenApproved(uint identifier);
    error ProposalHasBeenApproved(uint identifier);
    error ProposalHasNotBeenExecuted(uint identifier);
    error ProposalHasBeenExecuted(uint identifier);
    error ProposalHasNotBeenCancelled(uint identifier);
    error ProposalHasBeenCancelled(uint identifier);
    error IdentifierNotFound(uint min, uint max, uint given);
    error ProposalHasExpired(uint endTimestamp, uint now_);
    error ProposalStartsInThePast(uint startTimestamp, uint now_);
    error DefaultRequiredQuorumIsOutOfBounds(uint min, uint max, uint given);
}

contract MultiSigProposals is IMultiSigProposals {
    using EnumerableSet for EnumerableSet.AddressSet;
    IAuthenticator public authenticator;

    struct Proposal {
        uint identifier;
        address creator;
        string reason;
        uint startTimestamp;
        uint endTimestamp;
        uint threshold;
        uint timeout;
        uint requiredQuorum;
        bool hasBeenCancelled;
        bool hasBeenExecuted;
        bool hasBeenApproved;
        address target;
        string signature;
        bytes args;
        EnumerableSet.AddressSet signers;
        EnumerableSet.AddressSet signatures;
    }

    uint public numberOfProposals;

    struct Settings {
        uint defaultRequiredQuorum;
        uint defaultThreshold;
        uint defaultTimeout;
    }

    IKey dreamcatcher;

    Settings public settings;
    mapping(uint => Proposal) private proposals;

    constructor(address dreamcatcher_, address authenticator_) {
        authenticator = IAuthenticator(authenticator_);
        settings.defaultTimeout = 30 days;
        settings.defaultRequiredQuorum = 7500;
        dreamcatcher = IKey(dreamcatcher_);
    }

    /// -----------------------------------------
    /// using private view functions as modifiers.
    /// -----------------------------------------

    function _mustBeASigner(Proposal storage proposal)
        private view {
        address caller = msg.sender;
        if (!proposal.signers.contains(caller)) {
            revert CallerIsNotASigner(proposal.identifier, caller);
        }
    }

    function _mustHaveBeenSigned(Proposal storage proposal)
        private view {
        address caller = msg.sender;
        if (!proposal.signatures.contains(caller)) {
            revert SignerHasNotSigned(proposal.identifier, caller);
        }
    }

    function _mustNotHaveBeenApproved(Proposal storage proposal)
        private view {
        if (proposal.hasBeenApproved) {
            revert ProposalHasBeenApproved(proposal.identifier);
        }
    }

    function _mustHaveBeenApproved(Proposal storage proposal)
        private view {
        if (!proposal.hasBeenApproved) {
            revert ProposalHasNotBeenApproved(proposal.identifier);
        }
    }

    function _mustNotHaveBeenCancelled(Proposal storage proposal)
        private view {
        if (proposal.hasBeenCancelled) {
            revert ProposalHasBeenCancelled(proposal.identifier);
        }
    }

    function _mustHaveBeenCancelled(Proposal storage proposal)
        private view {
        if (!proposal.hasBeenCancelled) {
            revert ProposalHasNotBeenCancelled(proposal.identifier);
        }
    }

    function _mustNotHaveBeenExecuted(Proposal storage proposal)
        private view {
        if (proposal.hasBeenExecuted) {
            revert ProposalHasBeenExecuted(proposal.identifier);
        }
    }

    function _mustHaveBeenExecuted(Proposal storage proposal)
        private view {
        if (!proposal.hasBeenExecuted) {
            revert ProposalHasNotBeenExecuted(proposal.identifier);
        }
    }

    function _mustNotBeExpired(Proposal storage proposal)
        private view {
        uint currentTimestamp = block.timestamp;
        if (currentTimestamp >= proposal.endTimestamp) {
            revert ProposalHasExpired(proposal.endTimestamp, currentTimestamp);
        }
    }

    function _mustBeAnExistingIdentifier(uint identifier)
        private view {
        if (identifier < 1 && identifier > numberOfProposals) { 
            revert IdentifierNotFound(1, numberOfProposals, identifier); 
        }
    }

    function _hookEnd(Proposal storage proposal, address caller)
        private {
        /// hook at the end of every state changing function - except new().
        if (_requiredQuorumHasBeenMet(proposal)) {
            proposal.hasBeenApproved = true;
            
            emit Approved(proposal.identifier, caller, proposal.signatures.length());
        }
    }

    function _requiredQuorumHasBeenMet(Proposal storage proposal)
        private view
        returns (bool) {
        uint currentQuorum = (proposal.signers.length() * 10000) / proposal.signatures.length();
        if (currentQuorum >= proposal.requiredQuorum) { return true; }
        else {return false; }
    }

    function new_(string memory reason, uint startTimestamp, address target, string memory signature, bytes memory args) 
        external
        returns (uint) {
        authenticator.authenticate(msg.sender, "multi-sig-proposals-new_", true, true);

        uint now_ = block.timestamp;
        numberOfProposals ++;
        Proposal storage proposal = proposals[numberOfProposals];

        /// meta data.
        proposal.identifier = numberOfProposals;
        proposal.creator = msg.sender;
        proposal.reason = reason;

        /// proposals cannot start in the past.
        if (startTimestamp < now_) {
            revert ProposalStartsInThePast(startTimestamp, now_);
        }

        /// schedule.
        proposal.startTimestamp = startTimestamp;
        proposal.timeout = settings.defaultTimeout;
        proposal.endTimestamp = proposal.startTimestamp + proposal.timeout;
        proposal.requiredQuorum = settings.defaultRequiredQuorum;
        proposal.threshold = settings.defaultThreshold;

        /// payload.
        proposal.target = target;
        proposal.signature = signature;
        proposal.args = args;

        /// signers :: anyone who is on the council.
        address[] memory signers;

        emit ProposalCreated(proposal.identifier, proposal.creator, proposal.startTimestamp, proposal.endTimestamp, proposal.timeout, proposal.requiredQuorum, proposal.target, proposal.signature, proposal.args, signers);

        return proposal.identifier;
    }

    function sign(uint identifier)
        external 
        returns (bool) {
        Proposal storage proposal = proposals[identifier];

        _mustBeAnExistingIdentifier(identifier);
        _mustBeASigner(proposal);
        _mustNotHaveBeenApproved(proposal);
        _mustNotHaveBeenCancelled(proposal);
        _mustNotHaveBeenExecuted(proposal);
        _mustNotBeExpired(proposal);

        /// signature.
        address signer = msg.sender;
        proposal.signatures.add(signer);

        emit Signed(identifier, signer);

        _hookEnd(proposal, signer);
        return true;
    }

    function unsign(uint identifier)
        external 
        returns (bool) {
        Proposal storage proposal = proposals[identifier];

        _mustBeAnExistingIdentifier(identifier);
        _mustBeASigner(proposal);
        _mustHaveBeenSigned(proposal);
        _mustNotHaveBeenApproved(proposal);
        _mustNotHaveBeenCancelled(proposal);
        _mustNotHaveBeenExecuted(proposal);
        _mustNotBeExpired(proposal);

        /// remove signature.
        address signer = msg.sender;
        proposal.signatures.remove(signer);

        emit SignatureRevoked(identifier, signer);

        _hookEnd(proposal, signer);
        return true;
    }

    /// updated - now locked using authenticator.
    function cancel(uint identifier)
        external
        returns (bool) {
        authenticator.authenticate(msg.sender, "multi-sig-proposals-cancel", true, true);
        Proposal storage proposal = proposals[identifier];

        _mustBeAnExistingIdentifier(identifier);
        _mustNotHaveBeenApproved(proposal);
        _mustNotHaveBeenCancelled(proposal);
        _mustNotHaveBeenExecuted(proposal);
        _mustNotBeExpired(proposal);

        /// cancel.
        proposal.hasBeenCancelled = true;

        emit Cancelled(identifier, msg.sender);

        _hookEnd(proposal, msg.sender);
        return true;
    }

    /// updated - now locked using authenticator.
    function execute(uint identifier)
        external 
        returns (bool) {
        authenticator.authenticate(msg.sender, "multi-sig-proposals-execute", true, true);
        Proposal storage proposal = proposals[identifier];

        _mustBeAnExistingIdentifier(identifier);
        _mustNotBeExpired(proposal);
        _mustNotHaveBeenExecuted(proposal);
        _mustNotHaveBeenCancelled(proposal);
        _mustHaveBeenApproved(proposal);

        /// make call.
        proposal.hasBeenExecuted = true;
        dreamcatcher.connect(proposal.target, proposal.signature, proposal.args);

        _hookEnd(proposal, msg.sender);
        return true;
    }
    
    /// updated - now locked using authenticator.
    function setDefaultRequiredQuorum(uint newValueBasisPoints)
        external
        returns (bool) {
        authenticator.authenticate(msg.sender, "multi-sig-proposals-set-default-required-quorum", true, true);
        if (newValueBasisPoints < 5000 || newValueBasisPoints > 10000) {
            revert DefaultRequiredQuorumIsOutOfBounds(5000, 10000, newValueBasisPoints);
        }

        settings.defaultRequiredQuorum = newValueBasisPoints;
        return true;
    }

    /// updated - now locked using authenticator.
    function setDefaultTimeout(uint newValue)
        external
        returns (bool) {
        authenticator.authenticate(msg.sender, "multi-sig-proposals-set-default-timeout", true, true);
        settings.defaultTimeout = newValue;
        return true;
    }
}