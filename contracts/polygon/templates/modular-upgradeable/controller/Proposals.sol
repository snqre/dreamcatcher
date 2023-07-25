// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";
import "contracts/polygon/templates/modular-upgradeable/controller/__Proposals.sol";
import "contracts/polygon/templates/modular-upgradeable/controller/MultiSigProposals.sol";

interface IProposals {
    event ProposalQueued(address creator, string reason, address target, string signature, bytes args);
    event BatchProposalQueued(address creator, string reason, address[] targets, string[] signatures, bytes[] args);
}

contract Proposals is IProposals, MultiSigProposals {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public token;
    __Proposals.Settings public settings;
    __Proposals.Proposal[] private _proposals;

    constructor(address token_) {
        token = token_;
        settings.averageQuorumLookBack = 2419200 seconds; /// 30 days
        settings.maxRequiredQuorum = IERC20(token).totalSupply();
        settings.minRequiredQuorum = (IERC20(token).totalSupply() / 10000) * 1000; /// 10% of supply
        settings.threshold = 5000;
        settings.timeout = 2419200 seconds; /// 30 days
    }
    
    function queueProposal(address creator, string memory reason, address target, string memory signature, bytes memory args)
        public
        returns (uint) {
        IHub(hub).validate(msg.sender, address(this), "queueProposal");
        uint id = __Proposals.queue(_proposals, settings, token, creator, reason, target, signature, args);
        emit ProposalQueued(creator, reason, target, signature, args);
        return id;
    }

    function queueBatchProposal(address creator, string memory reason, address[] memory targets, string[] memory signatures, bytes[] memory args)
        public
        returns (uint) {
        IHub(hub).validate(msg.sender, address(this), "queueBatchProposal");
        uint id = __Proposals.queueBatch(_proposals, settings, token, creator, reason, targets, signatures, args);
        emit BatchProposalQueued(creator, reason, targets, signatures, args);
        return id;
    }

    /// 0(abstain), 1(against), 2(for)
    /// only accounts with at least 1 wei of our native token can vote
    function vote(uint id, __Proposals.Side side)
        public {
        __Proposals.vote(_proposals, token, id, side);
    }

    /// pass public proposal to hub's timelock to be queued for execution
    function execute(uint id)
        public {
        __Proposals.execute(_proposals, id);
        /// writing this code at contract level
        /// this is not too much in byte size and it should be okay
        __Proposal.Proposal storage proposal = _proposals[id];
        if (proposal.class == __Proposal.Class.DEFAULT) {
            /// **we can pass the creator of the proposal from here to hub if required for further development
            IHub(hub).queue(
                proposal.payloadA.target, 
                proposal.payloadA.signature, 
                proposal.payloadA.args
            );
        }
        else if (proposal.class == _Proposal.Class.BATCH) {
            IHub(hub).queueBatch(
                proposal.payloadB.targets, 
                proposal.payloadB.signatures, 
                proposal.payloadB.args
            );
        }
    }

    function getProposal(uint id)
        public view
        returns (uint, uint, address, string memory, uint, uint, uint, uint, uint, __Proposals.Votes, uint, __Proposals.State, address, string memory, bytes memory, address[] memory) {
        return __Proposals.getProposal(_proposals, id);
    }

    function getBatchProposal(uint id)
        public view
        returns (uint, uint, address, string memory, uint, uint, uint, uint, uint, Votes, uint, State, address[] memory, string[] memory, bytes[] memory, address[] memory) {
        return __Proposals.getBatchProposal(_proposals, id);
    }
}