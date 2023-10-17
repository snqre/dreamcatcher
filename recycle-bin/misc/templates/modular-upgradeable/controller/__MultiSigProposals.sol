// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";

library __MultiSigProposals {
    using EnumerableSet for EnumerableSet.AddressSet;

    enum State {
        DEFAULT,
        REJECTED,
        APPROVED,
        EXECUTED
    }

    enum Class {
        DEFAULT,
        BATCH
    }

    struct Settings {
        uint timeout;
        uint requiredQuorum;
    }

    struct PayloadA {
        address target;
        string signature;
        bytes args;
    }

    struct PayloadB {
        address[] targets;
        string[] signatures;
        bytes[] args;
    }

    struct Proposal {
        PayloadA payloadA;
        PayloadB payloadB;
        Class class;
        uint id;
        address creator;
        string message;
        uint startTimestamp;
        uint endTimestamp;
        uint timeout;
        uint requiredQuorum;
        State state;
        EnumerableSet.AddressSet signers;
        EnumerableSet.AddressSet signatures;
    }

    function onlySigner(Proposal[] storage proposals, uint id, address account)
        public view {
        Proposal storage proposal = proposals[id];
        require(
            proposal.signers.contains(account),
            "__MultiSigProposals: caller is not expected to sign"
        );
    }

    function onlySigned(Proposal[] storage proposals, uint id, address account)
        public view {
        onlySigner(proposals, id, account);
        Proposal storage proposal = proposals[id];
        require(
            proposal.signatures.contains(account),
            "__MultiSigProposals: signer has not signed"
        );
    }

    function onlyNotSigned(Proposal[] storage proposals, uint id, address account)
        public view {
        onlySigner(proposals, id, account);
        Proposal storage proposal = proposals[id];
        require(
            !proposal.signatures.contains(account),
            "__MultiSigProposals: signer has signed"
        );
    }

    function onlyApproved(Proposal[] storage proposals, uint id)
        public view {
        Proposal storage proposal = proposals[id];
        require(
            proposal.state == State.APPROVED,
            "__MultiSigProposals: proposal has not been approved"
        );
    }

    function onlyNotApproved(Proposal[] storage proposals, uint id)
        public view {
        Proposal storage proposal = proposals[id];
        require(
            proposal.state != State.APPROVED,
            "__MultiSigProposals: proposal has been approved"
        );
    }

    function onlyExecuted(Proposal[] storage proposals, uint id)
        public view {
        Proposal storage proposal = proposals[id];
        require(
            proposal.state == State.EXECUTED,
            "__MultiSigProposals: proposal has not been executed"
        );
    }

    function onlyNotExecuted(Proposal[] storage proposals, uint id)
        public view {
        Proposal storage proposal = proposals[id];
        require(
            proposal.state != State.EXECUTED,
            "__MultiSigProposals: proposal has been executed"
        );
    }

    function onlyNotExpired(Proposal[] storage proposals, uint id)
        public view {
        Proposal storage proposal = proposals[id];
        require(
            block.timestamp < proposal.endTimestamp,
            "__MultiSigProposals: proposal has expired"
        );
    }
    
    function requiredQuorumHasBeenMet(Proposal[] storage proposals, uint id)
        public view 
        returns (bool) {
        Proposal storage proposal = proposals[id];
        uint currentQuorum = (proposal.signers.length() / proposal.signatures.length()) * 10000;
        if (currentQuorum >= proposal.requiredQuorum) { return true; }
        else { return false; }
    }

    function queue(Proposal[] storage proposals, Settings storage settings, address hub, string memory message, address target, string memory signature, bytes memory args)
        public 
        returns (uint) {
        /// only the members of the council can call this function
        address[] memory members = IHub(hub).getRoleMembers("council");
        bool isAMember;
        for (uint i = 0; i < members.length; i++) {
            if (msg.sender == members[i]) { isAMember = true; }
        }
        require(isAMember, "__MultiSigProposals: caller is not part of the council");
        proposals.push();
        Proposal storage proposal = proposals[proposals.length - 1];
        proposal.class = Class.DEFAULT;
        proposal.id = proposals.length - 1;
        proposal.message = message;
        proposal.startTimestamp = block.timestamp;
        proposal.endTimestamp = proposal.startTimestamp + settings.timeout;
        proposal.requiredQuorum = settings.requiredQuorum;
        proposal.payloadA.target = target;
        proposal.payloadA.signature = signature;
        proposal.payloadA.args = args;
        for (uint i = 0; i < members.length; i++) {
            proposal.signers.add(members[i]);
        }
        return (proposal.id);
    }

    function queueBatch(Proposal[] storage proposals, Settings storage settings, address hub, string memory message, address[] memory targets, string[] memory signatures, bytes[] memory args)
        public
        returns (uint) {
        /// only the members of the council can call this function
        address[] memory members = IHub(hub).getRoleMembers("council");
        bool isAMember;
        for (uint i = 0; i < members.length; i++) {
            if (msg.sender == members[i]) { isAMember = true; }
        }
        require(isAMember, "__MultiSigProposals: caller is not part of the council");
        proposals.push();
        Proposal storage proposal = proposals[proposals.length - 1];
        proposal.class = Class.BATCH;
        proposal.id = proposals.length - 1;
        proposal.message = message;
        proposal.startTimestamp = block.timestamp;
        proposal.endTimestamp = proposal.startTimestamp + settings.timeout;
        proposal.requiredQuorum = settings.requiredQuorum;
        proposal.payloadB.targets = targets;
        proposal.payloadB.signatures = signatures;
        proposal.payloadB.args = args;
        for (uint i = 0; i < members.length; i++) {
            proposal.signers.add(members[i]);
        }
        return (proposal.id);
    }

    function sign(Proposal[] storage proposals, uint id, address account)
        public {
        onlyNotSigned(proposals, id, account);
        onlyNotApproved(proposals, id);
        onlyNotExecuted(proposals, id);
        onlyNotExpired(proposals, id);
        Proposal storage proposal = proposals[id];
        proposal.signatures.add(account);
        if (requiredQuorumHasBeenMet(proposals, id)) {
            proposal.state = State.APPROVED;
        }
    }

    function unsign(Proposal[] storage proposals, uint id, address account)
        public {
        onlySigned(proposals, id, account);
        onlyNotApproved(proposals, id);
        onlyNotExecuted(proposals, id);
        onlyNotExpired(proposals, id);
        Proposal storage proposal = proposals[id];
        proposal.signatures.remove(account);
        if (!requiredQuorumHasBeenMet(proposals, id)) {
            proposal.state = State.DEFAULT;
        }
    }

    /// this executes nothing as is
    function execute(Proposal[] storage proposals, uint id)
        public {
        onlyApproved(proposals, id);
        onlyNotExecuted(proposals, id);
        onlyNotExpired(proposals, id);
        Proposal storage proposal = proposals[id];
        proposal.state = State.EXECUTED;
    }
    
    function getProposal(Proposal[] storage proposals, uint id)
        public view
        returns (uint, address, string memory, uint, uint, uint, uint, State, address, string memory, bytes memory, address[] memory, address[] memory) {
        Proposal storage proposal = proposals[id];
        require(proposal.class == Class.DEFAULT, "__MultiSigProposals: proposal cannot be BATCH class");
        return (
            proposal.id,
            proposal.creator,
            proposal.message,
            proposal.startTimestamp,
            proposal.endTimestamp,
            proposal.timeout,
            proposal.requiredQuorum,
            proposal.state,
            proposal.payloadA.target,
            proposal.payloadA.signature,
            proposal.payloadA.args,
            proposal.signers.values(),
            proposal.signatures.values()
        );
    }

    function getBatchProposal(Proposal[] storage proposals, uint id)
        public view
        returns (uint, address, string memory, uint, uint, uint, uint, State, address[] memory, string[] memory, bytes[] memory, address[] memory, address[] memory) {
        Proposal storage proposal = proposals[id];
        require(proposal.class == Class.BATCH, "__MultiSigProposals: proposal cannot be DEFAULT class");
        return (
            proposal.id,
            proposal.creator,
            proposal.message,
            proposal.startTimestamp,
            proposal.endTimestamp,
            proposal.timeout,
            proposal.requiredQuorum,
            proposal.state,
            proposal.payloadB.targets,
            proposal.payloadB.signatures,
            proposal.payloadB.args,
            proposal.signers.values(),
            proposal.signatures.values()
        );
    }
}
