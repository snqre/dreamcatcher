// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/templates/modular-upgradeable/controller/__MultiSigProposals.sol";

interface IMultiSigProposals {
    event MultiSigProposalQueued(string message, address target, string signature, bytes args);
    event MultiSigBatchProposalQueued(string message, address[] targets, string[] signatures, bytes[] args);
    event MultiSigProposalSigned(uint id);
    event MultiSigProposalUnsigned(uint id);
    event MultiSigProposalExecuted(uint id);
}

contract MultiSigProposals is IMultiSigProposals {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public hub;
    __MultiSigProposals.Settings public settings;
    __MultiSigProposals.Proposal[] internal _proposals;

    /// all % math is done in basis points (out of 10000)
    constructor(address hub_) {
        hub = hub_;
        settings.timeout = 604800 seconds; /// 1 week
        settings.requiredQuorum = (IHub(hub).getRoleLength("council") / 10000) * 7500; /// 75% required to sign   
    }

    /// only members of the council can queue multi sig proposals
    function queueMultiSigProposal(string memory message, address target, string memory signature, bytes memory args)
        public
        returns (uint) {
        uint id = __MultiSigProposals.queue(_proposals, settings, hub, message, target, signature, args);
        emit MultiSigProposalQueued(message, target, signature, args);
        return id;
    }

    function queueMultiSigBatchProposal(string memory message, address[] memory targets, string[] memory signatures, bytes[] memory args)
        public
        returns (uint) {
        uint id = __MultiSigProposals.queueBatch(_proposals, settings, hub, message, targets, signatures, args);
        emit MultiSigBatchProposalQueued(message, targets, signatures, args);
        return id;
    }
    
    /// only members of the council at the time it was queued are expected to sign
    function signMultiSigProposal(uint id)
        public {
        __MultiSigProposals.sign(_proposals, id, msg.sender);
        emit MultiSigProposalSigned(id);
    }

    function unsignMultiSigProposal(uint id)
        public {
        __MultiSigProposals.unsign(_proposals, id, msg.sender);
        emit MultiSigProposalUnsigned(id);
    }

    function executeMultiSigProposal(uint id)
        public {
        __MultiSigProposals.execute(_proposals, id);
        /// ... pass multi sig into public queue
        emit MultiSigProposalExecuted(id);
    }

    function getMultiSigProposal(uint id)
        public view
        returns (uint, address, string memory, uint, uint, uint, uint, __MultiSigProposals.State, address, string memory, bytes memory, address[] memory, address[] memory) {
        return __MultiSigProposals.getProposal(_proposals, id);
    }

    function getMultiSigBatchProposal(uint id)
        public view
        returns (uint, address, string memory, uint, uint, uint, uint, __MultiSigProposals.State, address[] memory, string[] memory, bytes[] memory, address[] memory, address[] memory) {
        return __MultiSigProposals.getBatchProposal(_proposals, id);
    }
}
