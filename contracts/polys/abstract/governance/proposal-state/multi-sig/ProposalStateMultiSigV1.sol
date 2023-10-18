// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/governance/proposal-state/multi-sig/multi-sig-proposals/ProposalStateMultiSigProposalsV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/multi-sig/multi-sig-settings/ProposalStateMultiSigSettingsV1.sol";

/**
 * @title ProposalStateMultiSigV1
 * @dev This abstract contract extends ProposalStateMultiSigSettingsV1 and ProposalStateMultiSigProposalsV2,
 * providing functionality for creating, signing, and executing multi-signature proposals.
 */
abstract contract ProposalStateMultiSigV1 is ProposalStateMultiSigSettingsV1, ProposalStateMultiSigProposalsV1 {

    /**
    * @notice Emitted when a MultiSig Proposal is created.
    * @param id The ID of the MultiSig Proposal.
    * @param caption The caption of the proposal.
    * @param message The message associated with the proposal.
    * @param creator The address of the creator of the proposal.
    * @param target The target address of the proposal.
    * @param data The data associated with the proposal.
    */
    event MultiSigProposalCreated(uint256 indexed id, string caption, string message, address creator, address indexed target, bytes indexed data);

    /**
    * @notice Creates a MultiSig Proposal.
    * @param caption The caption of the proposal.
    * @param message The message associated with the proposal.
    * @param creator The address of the creator of the proposal.
    * @param target The target address of the proposal.
    * @param data The data associated with the proposal.
    * @return id The ID of the created MultiSig Proposal.
    */
    function _createMultiSigProposal(string memory caption, string memory message, address creator, address target, bytes memory data) internal virtual returns (uint256) {
        uint256 id = _incrementMultiSigProposalsCount();
        for (uint256 i = 0; i < defaultMultiSigSignersLength(); i++) {
            _addMultiSigProposalSigner(id, defaultMultiSigSigners(i));
        }
        _setMultiSigProposalCaption(id, caption);
        _setMultiSigProposalMessage(id, message);
        _setMultiSigProposalCreator(id, creator);
        _setMultiSigProposalTarget(id, target);
        _setMultiSigProposalData(id, data);
        _setMultiSigProposalDuration(id, defaultMultiSigDuration());
        _setMultiSigProposalRequiredQuorum(id, defaultMultiSigDuration());
        _setMultiSigProposalStartTimestamp(id, block.timestamp);
        emit MultiSigProposalCreated(id, caption, message, creator, target, data);
        return id;
    }

    /**
    * @notice Adds additional signature logic for signing a MultiSig Proposal.
    * @param id The ID of the MultiSig Proposal to be signed.
    */
    function _signMultiSigProposal(uint256 id) internal virtual override {
        /** ... @dev Additional signature logic */
        super._signMultiSigProposal(id);
    }

    /**
    * @notice Adds additional execution logic for executing a MultiSig Proposal.
    * @param id The ID of the MultiSig Proposal to be executed.
    */
    function _executeMultiSigProposal(uint256 id) internal virtual override {
        /** ... @dev Additional execution logic */
        super._executeMultiSigProposal(id);
    }
}