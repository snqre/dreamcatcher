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

    event DefaultMultiSigSignerAdded(uint256 indexed account);

    event DefaultMultiSigSignerRemoved(uint256 indexed account);

    function defaultMultiSigSignersKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_SIGNERS"));
    }

    function defaultMultiSigSigners(uint256 signerId) public view virtual returns (address) {
        EnumerableSet.AddressSet storage signers = _addressSet[defaultMultiSigSignersKey()];
        return signers.at(signerId);
    }

    function defaultMultiSigSignersLength() public view virtual returns (uint256) {
        EnumerableSet.AddressSet storage signers = _addressSet[defaultMultiSigSignersKey()];
        return signers.length();
    }

    function isDefaultMultiSigSigner(address account) public view virtual returns (bool) {
        EnumerableSet.AddressSet storage signers = _addressSet[defaultMultiSigSignersKey()];
        return signers.contains(account);
    }

    function _addDefaultMultiSigSigner(address account) internal virtual {
        EnumerableSet.AddressSet storage signers = _addressSet[defaultMultiSigSignersKey()];
        if (signers.contains(account)) { revert ErrorsV1.IsAlreadyInSet(account); }
        signers.add(account);
        emit DefaultMultiSigSignerAdded(account);
    }

    function _removeDefaultMultiSigSigner(address account) internal virtual {
        EnumerableSet.AddressSet storage signers = _addressSet[defaultMultiSigSignersKey()];
        if (!signers.contains(account)) { revert ErrorsV1.IsNotInSet(account); }
        signers.remove(account);
        emit DefaultMultiSigSignerRemoved(account);
    }

    /** Default Required Quorum */

    event DefaultMultiSigRequiredQuorumSetTo(uint256 indexed bp);

    function defaultMultiSigRequiredQuorumKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_REQUIRED_QUORUM"));
    }

    function defaultMultiSigRequiredQuorum() public view virtual returns (uint256) {
        uint256 storage requiredQuorum = _uint256[defaultMultiSigRequiredQuorumKey()];
        return requiredQuorum.onlyBetween(0, 10000);
    }

    function _setDefaultMultiSigRequiredQuorum(uint256 bp) internal virtual {
        bp.onlyBetween(0, 10000);
        uint256 storage requiredQuorum = _uint256[defaultMultiSigRequiredQuorumKey()];
        requiredQuorum.onlynotMatchingValue(bp);
        requiredQuorum = bp;
        emit DefaultMultiSigRequiredQuorumSetTo(bp);
    }

    /** Default Duration */

    event DefaultMultiSigDurationSetTo(uint256 indexed seconds_);

    function defaultMultiSigDurationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_MULTI_SIG_DURATION"));
    }

    function defaultMultiSigDuration() public view virtual returns (uint256) {
        uint256 storage duration = _uint256[defaultMultiSigDurationKey()];
        return duration;
    }

    function _setDefaultMultiSigDuration(uint256 seconds_) internal virtual {
        uint256 storage duration = _uint256[defaultMultiSigDurationKey()];
        duration.onlynotMatchingValue(seconds_);
        duration = seconds_;
        emit DefaultMultiSigDurationSetTo(seconds_);
    }
}