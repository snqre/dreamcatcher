// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";
import "contracts/polygon/projects/dreamcatcher/tokens/DreamToken.sol";

library __Proposals {
    using EnumerableSet for EnumerableSet.AddressSet;

    enum Side {
        ABSTAIN,
        AGAINST,
        FOR
    }

    enum State {
        DEFAULT,
        APPROVED,
        EXECUTED
    }

    enum Class {
        DEFAULT,
        BATCH
    }

    struct Settings {
        uint threshold;
        uint timeout;
        uint averageQuorumLookBack;
        uint minRequiredQuorum;
        uint maxRequiredQuorum;
    }

    struct Votes {
        uint abstain;
        uint against;
        uint for_;
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
        uint snapshot;
        address creator;
        string reason;
        uint startTimestamp;
        uint endTimestamp;
        uint timeout;
        uint quorum;
        uint requiredQuorum;
        Votes votes;
        uint threshold;
        State state;
        address target;
        string signature;
        bytes args;
        EnumerableSet.AddressSet voters;
    }

    /// look for the average quorum within a period of time
    function getAverageQuorum(Proposal[] storage proposals, uint averageQuorumLookBack)
        public view
        returns (uint) {
        uint sumQuorum;
        uint checkedProposals;
        /// start iteration from end of the array
        for (uint i = proposals.length - 1; i >= 0; i--) {
            Proposal storage proposal = proposals[i];
            /// if within applicable range
            if (proposal.startTimestamp >= (block.timestamp - averageQuorumLookBack)) {
                sumQuorum += proposal.quorum;
                checkedProposals++;
            }
            /// if is not within applicable range then break
            else { break; }
        }
        return sumQuorum / checkedProposals;
    }

    function onlyApproved(Proposal[] storage proposals, uint id)
        public view {
        Proposal storage proposal = proposals[id];
        require(
            proposal.state == State.APPROVED,
            "__Proposal: proposal has not been approved"
        );
    }

    function onlyNotApproved(Proposal[] storage proposals, uint id)
        public view {
        Proposal storage proposal = proposals[id];
        require(
            proposal.state != State.APPROVED,
            "__Proposal: proposal has been approved"
        );
    }

    function onlyExecuted(Proposal[] storage proposals, uint id)
        public view {
        Proposal storage proposal = proposals[id];
        require(
            proposal.state == State.EXECUTED,
            "__Proposal: proposal has not been executed"
        );
    }
    
    function onlyNotExecuted(Proposal[] storage proposals, uint id)
        public view {
        Proposal storage proposal = proposals[id];
        require(
            proposal.state != State.EXECUTED,
            "__Proposal: proposal has been executed"
        );
    }

    function onlyNotVoted(Proposal[] storage proposals, uint id, address account)
        public view {
        Proposal storage proposal = proposals[id];
        require(
            !proposal.voters.contains(account),
            "__Proposals: caller has voted"
        );
    }

    function requiredQuorumHasBeenMet(uint id)
        public view
        returns (bool) {
        Proposal storage proposal = proposals[id];
        if (proposal.quorum >= proposal.requiredQuorum) { return true;}
        else { return false; }
    }

    function requiredThresholdHasBeenMet(uint id)
        public view
        returns (bool) {
        Proposal storage proposal = proposals[id];
        uint current = (proposal.votes.for_ / (proposal.votes.for_ + proposal.votes.against)) * 10000;
        if (current >= proposal.threshold) { return true; }
        else { return false; }
    }

    function queue(Proposal[] storage proposals, Settings storage settings, address token, address creator, string memory reason, address target, string memory signature, bytes memory args)
        public 
        returns (uint) {
        proposals.push();
        Proposal storage proposal = proposals[proposals.length - 1];
        proposal.id = proposals.length - 1;
        /// take a snapshot of the token and assign it to proposal
        proposal.snapshot = IDreamToken(token).snapshot();
        proposal.creator = creator;
        proposal.reason = reason;
        proposal.startTimestamp = block.timestamp;
        proposal.endTimestamp = proposal.startTimestamp + settings.timeout;
        proposal.timeout = settings.timeout;
        /// use average to get required quorum but only if it within range
        uint averageQuorum = getAverageQuorum(proposals, settings.averageQuorumLookBack);
        if (averageQuorum < settings.minRequiredQuorum) { averageQuorum = settings.minRequiredQuorum; }
        else if (averageQuorum > settings.maxRequiredQuorum) { averageQuorum = settings.maxRequiredQuorum; }
        proposal.requiredQuorum = averageQuorum;
        proposal.threshold = settings.threshold;
        proposal.payloadA.target = target;
        proposal.payloadA.signature = signature;
        proposal.payloadA.args = args;
        proposal.class = Class.DEFAULT;
        return proposal.id;
    }

    function queueBatch(Proposal[] storage proposals, Settings storage settings, address token, address creator, string memory reason, address[] memory targets, string[] memory signatures, bytes[] memory args)
        public
        returns (uint) {
        proposals.push();
        Proposal storage proposal = proposals[proposals.length - 1];
        proposal.id = proposals.length - 1;
        /// take a snapshot of the token and assign it to proposal
        proposal.snapshot = IDreamToken(token).snapshot();
        proposal.creator = creator;
        proposal.reason = reason;
        proposal.startTimestamp = block.timestamp;
        proposal.endTimestamp = proposal.startTimestamp + settings.timeout;
        proposal.timeout = settings.timeout;
        /// use average to get required quorum but only if it within range
        uint averageQuorum = getAverageQuorum(proposals, settings.averageQuorumLookBack);
        if (averageQuorum < settings.minRequiredQuorum) { averageQuorum = settings.minRequiredQuorum; }
        else if (averageQuorum > settings.maxRequiredQuorum) { averageQuorum = settings.maxRequiredQuorum; }
        proposal.requiredQuorum = averageQuorum;
        proposal.threshold = settings.threshold;
        proposal.payloadB.targets = targets;
        proposal.payloadB.signatures = signatures;
        proposal.payloadB.args = args;
        proposal.class = Class.BATCH;
        return proposal.id;
    }

    /// accounts can only vote once
    /// so its important that everyone thinks carefully about their choice
    /// a long enough period of time is given
    function vote(Proposal[] storage proposals, address token, uint id, Side side)
        public {
        onlyNotApproved(proposals, id);
        onlyNotExecuted(proposals, id);
        onlyNotVoted(proposals, id, msg.sender);
        Proposal storage proposal = proposals[id];
        uint votes = IDreamToken(token).balanceOfAt(msg.sender, proposal.snapshot);
        require(votes >= 1, "__Proposals: zero votes");
        proposal.voters.add(msg.sender);
        if (side == Side.ABSTAIN) {
            proposal.votes.abstain += votes;
        }
        else if (side == Side.AGAINST) {
            proposal.votes.against += votes;
        }
        else if (side == Side.FOR) {
            proposal.votes.for_ += votes;
        }
        proposal.quorum += votes;
        /// only require metrics are met but also ONLY AFTER TIMEOUT
        if (requiredQuorumHasBeenMet(id) && requiredThresholdHasBeenMet(id) && block.timestamp > proposal.endTimestamp) {
            proposal.state = State.APPROVED;
        }
    }

    /// this does nothing on its own but should send the proposal to timelock within the main contract
    /// anyone can execute this but council members are expected to keep on top of this
    function execute(Proposal[] storage proposals, uint id)
        public {
        /// only require metrics are met but also ONLY AFTER TIMEOUT
        if (requiredQuorumHasBeenMet(id) && requiredThresholdHasBeenMet(id) && block.timestamp > proposal.endTimestamp) {
            proposal.state = State.APPROVED;
        }
        onlyApproved(proposals, id);
        onlyNotExecuted(proposals, id);
        Proposal storage proposal = proposals[id];
        proposal.state = State.EXECUTED;
    }

    function getProposal(Proposal[] storage proposals, uint id)
        public view
        returns (uint, uint, address, string memory, uint, uint, uint, uint, uint, Votes, uint, State, address, string memory, bytes memory, address[] memory) {
        Proposal storage proposal = proposals[id];
        require(proposal.class == Class.DEFAULT, "__Proposals: proposal class cannot be DEFAULT");
        return (
            proposal.id,
            proposal.snapshot,
            proposal.creator,
            proposal.reason,
            proposal.startTimestamp,
            proposal.endTimestamp,
            proposal.timeout,
            proposal.quorum,
            proposal.requiredQuorum,
            proposal.votes,
            proposal.threshold,
            proposal.state,
            proposal.payloadA.target,
            proposal.payloadA.signature,
            proposal.payloadA.args,
            proposal.voters.values()
        );
    }

    function getBatchProposal(Proposal[] storage proposals, uint id)
        public view
        returns (uint, uint, address, string memory, uint, uint, uint, uint, uint, Votes, uint, State, address[] memory, string[] memory, bytes[] memory, address[] memory) {
        Proposal storage proposal = proposals[id];
        require(proposal.class == Class.BATCH, "__Proposals: proposal class cannot be BATCH");
        return (
            proposal.id,
            proposal.snapshot,
            proposal.creator,
            proposal.reason,
            proposal.startTimestamp,
            proposal.endTimestamp,
            proposal.timeout,
            proposal.quorum,
            proposal.requiredQuorum,
            proposal.votes,
            proposal.threshold,
            proposal.state,
            proposal.payloadB.targets,
            proposal.payloadB.signatures,
            proposal.payloadB.args,
            proposal.voters.values()
        );
    }
}