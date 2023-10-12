// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/governance/proposal-state/referendum/referendum-settings/ProposalStateReferendumSettingsV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/referendum/referendum-proposals/ProposalStateReferendumProposalsV1.sol";
import "contracts/polygon/interfaces/token/dream/IDream.sol";

/**
 * @title Proposal State Referendum Version 1
 * @dev This contract combines functionality related to Referendum Proposals, including creation, voting, and execution.
 *      It inherits from ProposalStateReferendumSettingsV1 and ProposalStateReferendumProposalsV1 for modular functionality.
 */
abstract contract ProposalStateReferendumV1 is ProposalStateReferendumSettingsV1, ProposalStateReferendumProposalsV1 {

    /**
    * @notice Emitted when a new Referendum Proposal is created.
    * @dev This event provides information about the newly created proposal.
    * @param id The unique identifier assigned to the referendum proposal.
    * @param caption The caption or title of the proposal.
    * @param message The detailed message or description of the proposal.
    * @param creator The address of the creator or proposer of the referendum proposal.
    * @param target The address of the target contract or entity affected by the proposal.
    * @param data The data associated with the proposal, usually containing encoded instructions.
    */
    event ReferendumProposalCreated(uint256 indexed id, string caption, string message, address creator, address indexed target, bytes indexed data);

    /**
    * @dev Creates a new referendum proposal.
    * @param caption The caption or title of the proposal.
    * @param message The detailed message or description of the proposal.
    * @param creator The address of the creator/initiator of the proposal.
    * @param target The address representing the target of the proposal.
    * @param data Additional data attached to the proposal.
    * @return The unique identifier (ID) assigned to the newly created proposal.
    */
    function _createReferendumProposal(string memory caption, string memory message, address creator, address target, bytes memory data) internal virtual returns (uint256) {
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
        emit ReferendumProposalCreated(id, caption, message, creator, target, data);
        return id;
    }

    /**
    * @dev Handles the voting process for a user on a referendum proposal.
    * @param id The unique identifier of the referendum proposal.
    * @param side The chosen side to vote on (0 for abstain, 1 for against, 2 for support).
    */
    function _voteOnReferendumProposal(uint256 id, uint256 side) internal virtual override {
        /** ... @dev Additional vote logic */
        super._voteOnReferendumProposal(id, side);
    }

    /**
    * @dev Executes the actions specified in a successful referendum proposal.
    * @param id The unique identifier of the successful referendum proposal.
    */
    function _executeReferendumProposal(uint256 id) internal virtual override {
        /** ... @dev Additional execution logic */
        super._executeReferendumProposal(id);
    }
}