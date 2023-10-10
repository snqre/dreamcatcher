// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/governance/proposal-state/multi-sig-proposals/ProposalStateMultiSigProposalsV1.sol";

/**
 * @title ProposalStateMultiSigProposalV2
 * @dev An abstract contract extending ProposalStateMultiSigProposalsV1, adding functionality
 * to manage the creator of a multi-signature proposal.
 * Provides events and functions to set, get, and handle the creator of a specific multi-signature proposal.
 * => FORGOT TO ADD CREATOR AS PROPERTIES SO THIS IS THE WAY OUT.
 */
abstract contract ProposalStateMultiSigProposalV2 is ProposalStateMultiSigProposalsV1 {

    /**
    * @dev Emitted when the creator of a multi-signature proposal is set to a new account.
    * @param account The address of the new creator.
    */
    event MultiSigProposalCreatorSetTo(address indexed account);

    /**
    * @dev Get the storage key for the creator of a specific multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_CREATOR" concatenated with the proposal ID.
    */
    function multiSigProposalCreatorKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_CREATOR", id));
    }

    /**
    * @dev Get the count of multi-signature proposals.
    * @return The number of multi-signature proposals.
    */
    function multiSigProposalsCount() public view returns (uint256) {
        return _bytesArray[multiSigProposalsKey()].length;
    }

    /**
    * @dev Get the creator of a specific multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The address of the proposal creator.
    */
    function multiSigProposalCreator(uint256 id) public view virtual returns (address) {
        return _address[multiSigProposalCreatorKey(id)];
    }

    /**
    * @dev Set the creator of a specific multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param account The address of the new creator.
    */
    function _setMultiSigProposalCreator(uint256 id, address account) internal virtual {
        _address[multiSigProposalCreatorKey(id)] = account;
        emit MultiSigProposalCreatorSetTo(account);
    }
}