// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/governance/proposal-state/multi-sig-settings/ProposalStateMultiSigSettingsV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/multi-sig-proposals/ProposalStateMultiSigProposalsV1.sol";

/**
 * @title ProposalStateMultiSigV1
 * @dev This abstract contract extends ProposalStateMultiSigSettingsV1 and ProposalStateMultiSigProposalsV2,
 * providing functionality for creating, signing, and executing multi-signature proposals.
 */
abstract contract ProposalStateMultiSigV1 is ProposalStateMultiSigSettingsV1, ProposalStateMultiSigProposalsV1 {

    /**
    * @notice Emits when a new Multi-Signature Proposal is successfully created.
    * @param id The unique identifier of the Multi-Signature Proposal.
    * @param caption The caption or title of the Multi-Signature Proposal.
    * @param message The detailed message or description of the Multi-Signature Proposal.
    * @param creator The address of the creator initiating the Multi-Signature Proposal.
    * @param target The target address affected by the Multi-Signature Proposal.
    * @param data Additional data associated with the Multi-Signature Proposal.
    */
    event MultiSigProposalCreated(uint256 indexed id, string caption, string message, address creator, address indexed target, bytes indexed data);

    /**
    * @dev Internal function to create a new Multi-Signature Proposal.
    * @param caption The caption or title of the Multi-Signature Proposal.
    * @param message The detailed message or description of the Multi-Signature Proposal.
    * @param creator The address of the creator initiating the Multi-Signature Proposal.
    * @param target The target address affected by the Multi-Signature Proposal.
    * @param data Additional data associated with the Multi-Signature Proposal.
    * @return The unique identifier of the created Multi-Signature Proposal.
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
        _setMultiSigProposalRequiredQuorum(id, defaultMultiSigRequiredQuorum());
        _setMultiSigProposalStartTimestamp(id, block.timestamp);
        emit MultiSigProposalCreated(id);
        return id;
    }

    /**
    * @dev Internal function to handle the signing process for a Multi-Signature Proposal.
    * @param id The unique identifier of the Multi-Signature Proposal.
    */
    function _signMultiSigProposal(uint256 id) internal virtual override {
        /** ... @dev Add any additional signature logic */
        super._signMultiSigProposal(id);
    }

    /**
    * @dev Internal function to execute the actions specified in a passed Multi-Signature Proposal.
    * @param id The unique identifier of the Multi-Signature Proposal to be executed.
    */
    function _executeMultiSigProposal(uint256 id) internal virtual override {
        /** ... @dev Add any additional execution logic */
        super._executeMultiSigProposal(id);
    }
}