// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/governance/proposal-state/referendum-settings/ProposalStateReferendumSettingsV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/referendum-proposals/ProposalStateReferendumProposalsV1.sol";
import "contracts/polygon/interfaces/token/dream/IDream.sol";

/**
 * @title Proposal State Referendum Version 1
 * @dev This contract combines functionality related to Referendum Proposals, including creation, voting, and execution.
 *      It inherits from ProposalStateReferendumSettingsV1 and ProposalStateReferendumProposalsV1 for modular functionality.
 */
abstract contract ProposalStateReferendumV1 is 
    ProposalStateReferendumSettingsV1, 
    ProposalStateReferendumProposalsV1 {

    /**
    * @notice Emits when a new Referendum Proposal is successfully created.
    * @param id The unique identifier of the created Referendum Proposal.
    */
    event ReferendumProposalCreated(uint256 indexed id);

    /**
    * @dev Internal function to create a new Referendum Proposal.
    * @param caption The caption or title of the Referendum Proposal.
    * @param message The detailed message or description of the Referendum Proposal.
    * @param creator The address of the creator initiating the Referendum Proposal.
    * @param target The target address affected by the Referendum Proposal.
    * @param data Additional data associated with the Referendum Proposal.
    */
    function _createReferendumProposal(string memory caption, string memory message, address creator, address target, bytes memory data) internal virtual {
        uint256 id = _incrementReferendumProposalsCount();
        _setReferendumProposalCaption(id, caption);
        _setReferendumProposalMessage(id, message);
        _setReferendumProposalCreator(id, creator);
        _setReferendumProposalTarget(id, target);
        _setReferendumProposalData(id, data);
        _setReferendumProposalRequiredQuorum(id, defaultReferendumProposalRequiredQuorum());
        _setReferendumProposalRequiredThreshold(id, defaultReferendumProposalRequiredThreshold());
        _setReferendumProposalDuration(id, defaultReferendumProposalDuration());
        _setReferendumProposalMinBalanceToVote(id, defaultReferendumProposalMinBalanceToVote());
        _setReferendumProposalVotingERC20(id, defaultReferendumProposalVotingERC20());
        _setReferendumProposalSnapshotId(id, IDream(referendumProposalVotingERC20(id)).snapshot());
        _setReferendumProposalStartTimestamp(id, block.timestamp);
        emit ReferendumProposalCreated(id);
    }

    /**
    * @dev Internal function to handle the voting process for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    */
    function _voteOnReferendumProposal(uint256 id) internal virtual override {
        /** ... @dev Vote logic ... */
        super._voteOnReferendumProposal(id);
    }

    /**
    * @dev Internal function to execute the actions specified in a passed Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal to be executed.
    */
    function _executeReferendumProposal(uint256 id) internal virtual override {
        /** ... @dev Add execution logic ... */
        super._executeReferendumProposal(id);
    }
}