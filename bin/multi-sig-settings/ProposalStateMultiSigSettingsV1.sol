// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

/**
 * @title ProposalStateMultiSigSettingsV1
 * @dev Abstract contract defining the state and settings for multi-signature proposals.
 */
abstract contract ProposalStateMultiSigSettingsV1 is StateV1 {

    /**
    * @dev Add a signer to the default list for multi-signature proposals.
    * @param account The address of the signer to be added.
    * @notice Reverts if the signer is already in the default list.
    * @notice Emits a `DefaultMultiSigProposalsSignerAdded` event.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @dev Emitted when the default duration for multi-signature proposals is set to a new value.
    * @param seconds_ The new duration in seconds.
    */
    event DefaultMultiSigProposalsDurationSetTo(uint256 indexed seconds_);

    /**
    * @dev Emitted when the default required quorum percentage for multi-signature proposals is set to a new value.
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    */
    event DefaultMultiSigProposalsRequiredQuorumSetTo(uint256 indexed bp);

    /**
    * @dev Emitted when a signer is added to the default list of signers for multi-signature proposals.
    * @param account The address of the added signer.
    */
    event DefaultMultiSigProposalsSignerAdded(address indexed account);

    /**
    * @dev Emitted when a signer is removed from the default list of signers for multi-signature proposals.
    * @param account The address of the removed signer.
    */
    event DefaultMultiSigProposalsSignerRemoved(address indexed account);

    /**
    * @dev Error indicating that a value is out of bounds.
    */
    error OutOfBounds(uint256 min, uint256 max, uint256 value);

    /**
    * @dev Error indicating that an account is already a default signer for multi-signature proposals.
    */
    error IsAlreadyADefaultSigner(address account);

    /**
    * @dev Error indicating that an account is not a default signer for multi-signature proposals.
    */
    error IsNotADefaultSigner(address account);

    /** @dev Keys. */

    /**
    * @dev Get the storage key for the default duration of multi-signature proposals.
    * @return The keccak256 hash of the string "DEFAULT_MULTI_SIG_PROPOSALS_DURATION".
    */
    function defaultMultiSigProposalsDurationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_PROPOSALS_DURATION"));
    }

    /**
    * @dev Get the storage key for the default required quorum of multi-signature proposals.
    * @return The keccak256 hash of the string "DEFAULT_MULTI_SIG_PROPOSALS_REQUIRED_QUORUM".
    */
    function defaultMultiSigProposalsRequiredQuorumKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_PROPOSALS_REQUIRED_QUORUM"));
    }

    /**
    * @dev Get the storage key for the default signers of multi-signature proposals.
    * @return The keccak256 hash of the string "DEFAULT_MULTI_SIG_PROPOSALS_SIGNERS".
    */
    function defaultMultiSigProposalsSignersKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_PROPOSALS_SIGNERS"));
    }

    /** @dev Getters. */

    /**
    * @dev Get the default duration for multi-signature proposals.
    * @return The default duration in seconds.
    */
    function defaultMultiSigProposalsDuration() public view virtual returns (uint256) {
        return _uint256[defaultMultiSigProposalsDurationKey()];
    }

    /**
    * @dev Get the default required quorum percentage for multi-signature proposals.
    * @return The default required quorum percentage (basis points).
    */
    function defaultMultiSigProposalsRequiredQuorum() public view virtual returns (uint256) {
        return _uint256[defaultMultiSigProposalsRequiredQuorumKey()];
    }

    /**
    * @dev Get the address of a signer in the default list for multi-signature proposals.
    * @param id The index of the signer in the list.
    * @return The address of the signer at the specified index.
    */
    function defaultMultiSigProposalsSigners(uint256 id) public view virtual returns (address) {
        return _addressSet[defaultMultiSigProposalsSignersKey()].at(id);
    }

    /**
    * @dev Get the number of signers in the default list for multi-signature proposals.
    * @return The number of signers in the default list.
    */
    function defaultMultiSigProposalsSignersLength() public view virtual returns (uint256) {
        return _addressSet[defaultMultiSigProposalsSignersKey()].length();
    }

    /**
    * @dev Check if an account is a default signer for multi-signature proposals.
    * @param account The address to check.
    * @return True if the account is a default signer, false otherwise.
    */
    function isDefaultMultiSigProposalsSigner(address account) public view virtual returns (bool) {
        bool isDefaultSigner;
        for (uint256 i = 0; i < defaultMultiSigProposalsSignersLength(); i++) {
            if (defaultMultiSigProposalsSigners(i) == account) {
                isDefaultSigner = true;
                break;
            }
        }
        return isDefaultSigner;
    }

    /** @dev Flags. */

    /**
    * @dev Modifier to ensure that a value is within a specified range.
    * @param min The minimum allowed value (inclusive).
    * @param max The maximum allowed value (inclusive).
    * @param value The value to check.
    * @notice Reverts if the value is outside the specified range.
    */
    function _onlyBetween(uint256 min, uint256 max, uint256 value) internal view virtual {
        if (value < min || value > max) { revert OutOfBounds(min, max, value); }
    }

    /** @dev Setters. */

    /**
    * @dev Set the default duration for multi-signature proposals.
    * @param seconds_ The new default duration in seconds.
    * @notice Emits an `DefaultMultiSigProposalsDurationSetTo` event.
    */
    function _setDefaultMultiSigProposalsDuration(uint256 seconds_) internal virtual {
        _uint256[defaultMultiSigProposalsDurationKey()] = seconds_;
        emit DefaultMultiSigProposalsDurationSetTo(seconds_);
    }

    /**
    * @dev Set the default required quorum percentage for multi-signature proposals.
    * @param bp The new default basis points representing the required quorum percentage (0 to 10000).
    * @notice Emits a `DefaultMultiSigProposalsRequiredQuorumSetTo` event.
    */
    function _setDefaultMultiSigProposalsRequiredQuorum(uint256 bp) internal virtual {
        _onlyBetween(0, 10000, bp);
        _uint256[defaultMultiSigProposalsRequiredQuorumKey()] = bp;
        emit DefaultMultiSigProposalsRequiredQuorumSetTo(bp);
    }

    /**
    * @dev Add a signer to the default list for multi-signature proposals.
    * @param account The address of the signer to be added.
    * @notice Reverts if the signer is already in the default list.
    * @notice Emits a `DefaultMultiSigProposalsSignerAdded` event.
    */
    function _addDefaultMultiSigProposalsSigner(address account) internal virtual {
        if (isDefaultMultiSigProposalsSigner(account)) {
            revert IsAlreadyADefaultSigner(account);
        }
        _addressSet[defaultMultiSigProposalsSignersKey()].add(account);
        emit DefaultMultiSigProposalsSignerAdded(account);
    }

    /**
    * @dev Remove a signer from the default list for multi-signature proposals.
    * @param account The address of the signer to be removed.
    * @notice Reverts if the signer is not in the default list.
    * @notice Emits a `DefaultMultiSigProposalsSignerRemoved` event.
    */
    function _removeDefaultMultiSigProposalsSigner(address account) internal virtual {
        if (!isDefaultMultiSigProposalsSigner(account)) {
            revert IsNotADefaultSigner(account);
        }
        _addressSet[defaultMultiSigProposalsSignersKey()].remove(account);
        emit DefaultMultiSigProposalsSignerRemoved(account);
    }
}