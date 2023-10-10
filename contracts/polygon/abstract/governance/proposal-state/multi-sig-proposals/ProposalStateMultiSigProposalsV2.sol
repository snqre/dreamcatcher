// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/governance/proposal-state/multi-sig-proposals/ProposalStateMultiSigProposalsV1.sol";

/**
 * @title ProposalStateMultiSigProposalsV2
 * @dev This abstract contract extends ProposalStateMultiSigProposalsV1 and provides functionality
 * for managing target addresses and data associated with multi-signature proposals.
 * It includes events, getters, and setters related to multi-signature proposal targets and data.
 */
abstract contract ProposalStateMultiSigProposalsV2 is 
    ProposalStateMultiSigProposalsV1 {
    
    /**
    * @dev Emitted when the target of a multi-signature proposal is set.
    * @param id The ID of the multi-signature proposal.
    * @param target The address of the target contract or account.
    */
    event MultiSigProposalTargetSetTo(uint256 indexed id, address indexed target);

    /**
    * @dev Emitted when the data of a multi-signature proposal is set.
    * @param id The ID of the multi-signature proposal.
    * @param data The data associated with the proposal.
    */
    event MultiSigProposalDataSetTo(uint256 indexed id, bytes indexed data);

    /**
    * @dev Returns the storage key for the target of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return bytes32 The storage key for the target.
    */
    function multiSigProposalTargetKey(uint256 id) public pure returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_TARGET", id));
    }

    /**
    * @dev Returns the storage key for the data of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return bytes32 The storage key for the data.
    */
    function multiSigProposalDataKey(uint256 id) public pure returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_DATA", id));
    }

    /**
    * @dev Returns the target address of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return address The target address.
    */
    function multiSigProposalTarget(uint256 id) public view returns (address) {
        return _address[multiSigProposalTargetKey(id)];
    }

    /**
    * @dev Returns the data of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return bytes32 The proposal data.
    */
    function multiSigProposalData(uint256 id) public view returns (bytes memory) {
        return _bytes[multiSigProposalDataKey(id)];
    }

    /**
    * @dev Sets the target address of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param target The address to set as the target.
    */
    function _setMultiSigProposalTarget(uint256 id, address target) internal virtual {
        _address[multiSigProposalTargetKey(id)] = target;
        emit MultiSigProposalTargetSetTo(id, target);
    }

    /**
    * @dev Sets the data of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param data The data to set for the proposal.
    */
    function _setMultiSigProposalData(uint256 id, bytes memory data) internal virtual {
        _bytes[multiSigProposalDataKey(id)] = data;
        emit MultiSigProposalDataSetTo(id, data);
    }
}