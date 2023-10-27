// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/libraries/flags/uint256/Uint256FlagsV1.sol";
import "contracts/polygon/libraries/flags/address/AddressFlagsV1.sol";
import "contracts/polygon/libraries/errors/ErrorsV1.sol";

abstract contract ProposalStateMultiSigSettingsV1 is StateV1 {

    /**
    * @dev Importing the EnumerableSet library and applying it to the AddressSet data type.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @dev Importing the Uint256FlagsV1 library and applying it to the uint256 data type.
    */
    using Uint256FlagsV1 for uint256;

    /**
    * @dev Importing the AddressFlagsV1 library and applying it to the address data type.
    */
    using AddressFlagsV1 for address;

    /** Default Signers */

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
    * @dev Get the storage key for the set of default multi-signature signers.
    * @return The keccak256 hash of the string "DEFAULT_MULTI_SIG_SIGNERS".
    */
    function defaultMultiSigSignersKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_SIGNERS"));
    }

    /**
    * @dev Get the address of a default multi-signature signer at a specific index.
    * @param signerId The index of the signer in the set of default multi-signature signers.
    * @return The address of the signer at the specified index.
    */
    function defaultMultiSigSigners(uint256 signerId) public view virtual returns (address) {
        EnumerableSet.AddressSet storage signers = _addressSet[defaultMultiSigSignersKey()];
        return signers.at(signerId);
    }

    /**
    * @dev Get the number of default multi-signature signers.
    * @return The number of default multi-signature signers.
    */
    function defaultMultiSigSignersLength() public view virtual returns (uint256) {
        EnumerableSet.AddressSet storage signers = _addressSet[defaultMultiSigSignersKey()];
        return signers.length();
    }

    /**
    * @dev Check if an address is a default multi-signature signer.
    * @param account The address to check.
    * @return True if the address is a default multi-signature signer, false otherwise.
    */
    function isDefaultMultiSigSigner(address account) public view virtual returns (bool) {
        EnumerableSet.AddressSet storage signers = _addressSet[defaultMultiSigSignersKey()];
        return signers.contains(account);
    }

    /**
    * @dev Internal function to add an address as a default multi-signature signer.
    * @param account The address to be added as a signer.
    * @notice Emits a `DefaultMultiSigSignerAdded` event.
    * @notice Reverts if the address is already a default signer.
    * @param account The address to be added as a signer.
    */
    function _addDefaultMultiSigSigner(address account) internal virtual {
        EnumerableSet.AddressSet storage signers = _addressSet[defaultMultiSigSignersKey()];
        if (signers.contains(account)) { revert ErrorsV1.IsAlreadyInSet(account); }
        signers.add(account);
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
        EnumerableSet.AddressSet storage signers = _addressSet[defaultMultiSigSignersKey()];
        if (!signers.contains(account)) { revert ErrorsV1.IsNotInSet(account); }
        signers.remove(account);
        emit DefaultMultiSigSignerRemoved(account);
    }

    /** Default Required Quorum */

    /**
    * @dev Emitted when the required quorum percentage for the default multi-signature is set to a new value.
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    */
    event DefaultMultiSigRequiredQuorumSetTo(uint256 indexed bp);

    /**
    * @dev Get the storage key for the required quorum percentage of the default multi-signature.
    * @return The keccak256 hash of the string "DEFAULT_MULTI_SIG_REQUIRED_QUORUM".
    */
    function defaultMultiSigRequiredQuorumKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_REQUIRED_QUORUM"));
    }

    /**
    * @dev Get the required quorum percentage for the default multi-signature.
    * @return The basis points representing the required quorum percentage (0 to 10000).
    */
    function defaultMultiSigRequiredQuorum() public view virtual returns (uint256) {
        return _uint256[defaultMultiSigRequiredQuorumKey()].onlyBetween(0, 10000);
    }

    /**
    * @dev Internal function to set the required quorum percentage for the default multi-signature.
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    * @notice Emits a `DefaultMultiSigRequiredQuorumSetTo` event.
    * @notice Reverts if the provided basis points are out of bounds (0 to 10000).
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    */
    function _setDefaultMultiSigRequiredQuorum(uint256 bp) internal virtual {
        _uint256[defaultMultiSigRequiredQuorumKey()].onlynotMatchingValue(bp.onlyBetween(0, 10000));
        _uint256[defaultMultiSigRequiredQuorumKey()] = bp;
        emit DefaultMultiSigRequiredQuorumSetTo(bp);
    }

    /** Default Duration */

    /**
    * @dev Emitted when the duration for the default multi-signature is set to a new value.
    * @param seconds_ The new duration in seconds.
    */
    event DefaultMultiSigDurationSetTo(uint256 indexed seconds_);

    /**
    * @dev Get the storage key for the duration of the default multi-signature.
    * @return The keccak256 hash of the string "DEFAULT_MULTI_SIG_DURATION".
    */
    function defaultMultiSigDurationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_DURATION"));
    }

    /**
    * @dev Get the duration for the default multi-signature.
    * @return The duration in seconds.
    */
    function defaultMultiSigDuration() public view virtual returns (uint256) {
        return _uint256[defaultMultiSigDurationKey()];
    }

    /**
    * @dev Internal function to set the duration for the default multi-signature.
    * @param seconds_ The new duration in seconds.
    * @notice Emits a `DefaultMultiSigDurationSetTo` event.
    * @notice Reverts if the provided duration is the same as the current value.
    * @param seconds_ The new duration in seconds.
    */
    function _setDefaultMultiSigDuration(uint256 seconds_) internal virtual {
        _uint256[defaultMultiSigDurationKey()].onlynotMatchingValue(seconds_);
        _uint256[defaultMultiSigDurationKey()] = seconds_;
        emit DefaultMultiSigDurationSetTo(seconds_);
    }
}