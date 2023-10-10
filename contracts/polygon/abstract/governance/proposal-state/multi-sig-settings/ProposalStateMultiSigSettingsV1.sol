// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

/**
 * @title ProposalStateMultiSigSettingsV1
 * @dev This abstract contract extends StateV1 and provides functionality for managing default multi-signature settings.
 * It includes events, errors, storage keys, getters, and setters related to default multi-signature settings.
 */
abstract contract ProposalStateMultiSigSettingsV1 is StateV1 {

    /**
    * @dev Use the `EnumerableSet` library to provide additional functionality for handling sets of addresses.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @dev Emitted when a default multi-signature signer is added.
    * @param account The address of the added default signer.
    */
    event DefaultMultiSigSignerAdded(address indexed account);

    /**
    * @dev Emitted when a default multi-signature signer is removed.
    * @param account The address of the removed default signer.
    */
    event DefaultMultiSigSignerRemoved(address indexed account);

    /**
    * @dev Emitted when the required quorum percentage for the default multi-signature is set to a new value.
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    */
    event DefaultMultiSigRequiredQuorumSetTo(uint256 indexed bp);

    /**
    * @dev Emitted when the duration for the default multi-signature is set to a new value.
    * @param seconds_ The new duration in seconds.
    */
    event DefaultMultiSigDurationSetTo(uint256 indexed seconds_);

    /**
    * @dev Throws an error indicating that the address is already a default multi-signature signer.
    * @param account The address that is already a default signer.
    */
    error AlreadyDefaultMultiSigSigner(address account);

    /**
    * @dev Throws an error indicating that the address is not a default multi-signature signer.
    * @param account The address that is not a default signer.
    */
    error NotDefaultMultiSigSigner(address account);

    /**
    * @dev Throws an error indicating that a value is out of bounds.
    * @param min The minimum allowed value.
    * @param max The maximum allowed value.
    * @param value The value that is out of bounds.
    */
    error OutOfBounds(uint256 min, uint256 max, uint256 value);

    /** Keys. */

    /**
    * @dev Get the storage key for the set of default multi-signature signers.
    * @return The keccak256 hash of the string "DEFAULT_MULTI_SIG_SIGNERS".
    */
    function defaultMultiSigSignersKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_SIGNERS"));
    }

    /**
    * @dev Get the storage key for the required quorum percentage of the default multi-signature.
    * @return The keccak256 hash of the string "DEFAULT_MULTI_SIG_REQUIRED_QUORUM".
    */
    function defaultMultiSigRequiredQuorumKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_REQUIRED_QUORUM"));
    }

    /**
    * @dev Get the storage key for the duration of the default multi-signature.
    * @return The keccak256 hash of the string "DEFAULT_MULTI_SIG_DURATION".
    */
    function defaultMultiSigDurationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_DURATION"));
    }

    /** Getters. */

    /**
    * @dev Get the address of a default multi-signature signer at a specific index.
    * @param id The index of the signer in the set of default multi-signature signers.
    * @return The address of the signer at the specified index.
    */
    function defaultMultiSigSigners(uint256 id) public view virtual returns (address) {
        return _addressSet[defaultMultiSigSignersKey()].at(id);
    }

    /**
    * @dev Get the number of default multi-signature signers.
    * @return The number of default multi-signature signers.
    */
    function defaultMultiSigSignersLength() public view virtual returns (uint256) {
        return _addressSet[defaultMultiSigSignersKey()].length();
    }

    /**
    * @dev Check if an address is a default multi-signature signer.
    * @param account The address to check.
    * @return True if the address is a default multi-signature signer, false otherwise.
    */
    function isDefaultMultiSigSigner(address account) public view virtual returns (bool) {
        return _addressSet[defaultMultiSigSignersKey()].contains(account);
    }

    /**
    * @dev Get the required quorum percentage for the default multi-signature.
    * @return The basis points representing the required quorum percentage (0 to 10000).
    */
    function defaultMultiSigRequiredQuorum() public view virtual returns (uint256) {
        return _uint256[defaultMultiSigRequiredQuorumKey()];
    }

    /**
    * @dev Get the duration for the default multi-signature.
    * @return The duration in seconds.
    */
    function defaultMultiSigDuration() public view virtual returns (uint256) {
        return _uint256[defaultMultiSigDurationKey()];
    }

    /** Setters. */

    /**
    * @dev Internal function to add an address as a default multi-signature signer.
    * @param account The address to be added as a signer.
    * @notice Emits a `DefaultMultiSigSignerAdded` event.
    * @notice Reverts if the address is already a default signer.
    * @param account The address to be added as a signer.
    */
    function _addDefaultMultiSigSigner(address account) internal virtual {
        if (isDefaultMultiSigSigner(account)) { revert AlreadyDefaultMultiSigSigner(account); }
        _addressSet[defaultMultiSigSignersKey()].add(account);
        emit DefaultMultiSigSignerAdded(account);
    }

    /**
    * @dev Internal function to remove an address from the default multi-signature signers.
    * @param account The address to be removed from signers.
    * @notice Emits a `DefaultMultiSigSignerRemoved` event.
    * @notice Reverts if the address is not a default signer.
    * @param account The address to be removed from signers.
    */
    function _removeDefaultMultiSigSigner(address account) internal virtual {
        if (!isDefaultMultiSigSigner(account)) { revert NotDefaultMultiSigSigner(account); }
        _addressSet[defaultMultiSigSignersKey()].remove(account);
        emit DefaultMultiSigSignerRemoved(account);
    }

    /**
    * @dev Internal function to set the required quorum percentage for the default multi-signature.
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    * @notice Emits a `DefaultMultiSigRequiredQuorumSetTo` event.
    * @notice Reverts if the provided basis points are out of bounds (0 to 10000).
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    */
    function _setDefaultMultiSigRequiredQuorum(uint256 bp) internal virtual {
        if (bp > 10000) { revert OutOfBounds(0, 10000, bp); }
        _uint256[defaultMultiSigRequiredQuorumKey()] = bp;
        emit DefaultMultiSigRequiredQuorumSetTo(bp);
    }

    /**
    * @dev Internal function to set the duration for the default multi-signature.
    * @param seconds_ The new duration in seconds.
    * @notice Emits a `DefaultMultiSigDurationSetTo` event.
    * @param seconds_ The new duration in seconds.
    */
    function _setDefaultMultiSigDuration(uint256 seconds_) internal virtual {
        _uint256[defaultMultiSigDurationKey()] = seconds_;
        emit DefaultMultiSigDurationSetTo(seconds_);
    }
}