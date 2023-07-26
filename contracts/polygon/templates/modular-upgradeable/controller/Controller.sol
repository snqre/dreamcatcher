// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/controller/Proposals.sol";
import "contracts/polygon/templates/modular-upgradeable/controller/__MultiSigProposals.sol";
import "contracts/polygon/templates/modular-upgradeable/controller/__Proposals.sol";
import "contracts/polygon/templates/modular-upgradeable/controller/__MultiSigProposals.sol";

/// multi sig > proposal > controller (inheritance flow)
interface IControler {
    function queueMultiSigProposal(string memory message, address target, string memory signature, bytes memory args) external returns (uint);
    function signMultiSigProposal(uint id) external;
    function unsignMultiSigProposal(uint id) external;
    function executeMultiSigProposal(uint id) external;
    function getMultiSigProposal(uint id) external view returns (uint, address, string memory, uint, uint, uint, uint, __MultiSigProposals.State, address, string memory, bytes memory, address[] memory, address[] memory);
    function queueProposal(address creator, string memory reason, address target, string memory signature, bytes memory args) external returns (uint);
    function vote(uint id, __Proposals.Side side) external;
    function execute(uint id) external;
    function getProposal(uint id) external view returns (uint, uint, address, string memory, uint, uint, uint, uint, uint, __Proposals.Votes, uint, __Proposals.State, address, string memory, bytes memory, address[] memory);
}

/// requires hub to grant it access to its function queueProposal and queueBatchProposal
contract Controller is Proposals {
    
    /// address of hub given in multi sig proposals
    /// address token given in proposals
    constructor(address hub_, address token_) 
        MultiSigProposals(hub_)
        Proposals(token_) {
        /// please check the constructors of the inherited contracts to see contract settings
    }

    /// its a dirty way to do this but it beats the alternative
    function executeMultiSigProposal(uint id)
        public override {
        super.executeMultiSigProposal(id);
        /// although _proposals is declared in both proposals and msp
        /// this is okay because only msp's _proposals is internal the other is private
        /// so this should only be refereing to msp's _proposals array
        __MultiSigProposals.Proposal storage proposal = _proposals[id];
        /// once a msp proposal is passed it is then sent to the public
        if (proposal.class == __MultiSigProposals.Class.DEFAULT) {
            queueProposal(
                proposal.creator, 
                proposal.message, 
                proposal.payloadA.target, 
                proposal.payloadA.signature, 
                proposal.payloadA.args
            );
        }
        else if (proposal.class == _MultiSigProposals.Class.BATCH) {
            queueBatchProposal(
                proposal.creator,
                proposal.message,
                proposal.payloadB.targets,
                proposal.payloadB.signatures,
                proposal.payloadB.args
            );
        }
    }
}