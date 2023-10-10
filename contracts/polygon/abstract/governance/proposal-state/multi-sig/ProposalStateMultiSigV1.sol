// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/governance/proposal-state/multi-sig-settings/ProposalStateMultiSigSettingsV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/multi-sig-proposals/ProposalStateMultiSigProposalsV2.sol";

/**
 * @title ProposalStateMultiSigV1
 * @dev This abstract contract extends ProposalStateMultiSigSettingsV1 and ProposalStateMultiSigProposalsV2,
 * providing functionality for creating, signing, and executing multi-signature proposals.
 */
abstract contract ProposalStateMultiSigV1 is ProposalStateMultiSigSettingsV1, ProposalStateMultiSigProposalsV2 {

    /**
    * @dev Emits an event indicating the creation of a multi-signature proposal.
    * @param id The identifier of the created proposal.
    */
    event MultiSigProposalCreated(uint256 indexed id);

    /**
    * @dev Creates a multi-signature proposal with the given parameters.
    * @param caption The caption of the proposal.
    * @param message The message of the proposal.
    * @param creator The creator of the proposal.
    * @param target The target address for the proposal.
    * @param data The data for the proposal.
    */
    function _createMultiSigProposal(string memory caption, string memory message, address creator, address target, bytes memory data) internal virtual {
        uint256 id = _incrementMultiSigProposalsCount();
        for (uint256 i = 0; i < defaultMultiSigSignersLength(); i++) {
            _addSignerToMultiSigProposal(id, defaultMultiSigSigners(id));
        }
        _setMultiSigProposalCaption(id, caption);
        _setMultiSigProposalMessage(id, message);
        _setMultiSigProposalCreator(id, creator);
        _setMultiSigProposalTarget(id, target);
        _setMultiSigProposalData(id, data);
        _setMultiSigProposalRequiredQuorum(id, defaultMultiSigRequiredQuorum());
        _setMultiSigProposalDuration(id, defaultMultiSigDuration());
        _setMultiSigProposalStartTimestamp(id, block.timestamp);
        emit MultiSigProposalCreated(id);
    }

    /**
    * @dev Emits an event indicating the creation of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    */
    function _signMultiSigProposal(uint256 id) internal virtual override {
        /** ... @dev Sign logic ... */
        super._signMultiSigProposal(id);
    }

    /**
    * @dev Executes a multi-signature proposal with the given ID.
    * @param id The ID of the multi-signature proposal.
    */
    function _executeMultiSigProposal(uint256 id) internal virtual override {
        /** ... @dev Add execution logic ... */
        super._executeMultiSigProposal(id);
    }
}