// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/libraries/flags/uint256/Uint256FlagsV1.sol";
import "contracts/polygon/libraries/flags/address/AddressFlagsV1.sol";
import "contracts/polygon/libraries/flags/string/StringFlagsV1.sol";
import "contracts/polygon/libraries/flags/bytes/BytesFlagsV1.sol";
import "contracts/polygon/libraries/errors/ErrorsV1.sol";

/**
 * @title ProposalStateMultiSigProposalsV1
 * @dev A Solidity smart contract for managing multi-signature proposals.
 * 
 * This contract provides functionality to create, manage, and execute multi-signature proposals.
 * It includes features such as adding signers, setting quorum, managing proposal duration, and more.
 */
abstract contract ProposalStateMultiSigProposalsV1 is StateV1 {

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

    /**
    * @dev Provides additional functionality for string operations through the StringFlagsV1 library.
    */
    using StringFlagsV1 for string;

    /**
    * @dev Using statement to enable flag-based error handling for bytes data.
    */
    using BytesFlagsV1 for bytes;

    /** Count */

    /**
    * @dev Emitted when the count of multi-signature proposals is incremented.
    * @param id The unique identifier of the multi-signature proposal.
    */
    event MultiSigProposalsCountIncremented(uint256 indexed id);

    /**
    * @dev Get the storage key for the count of multi-signature proposals.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSALS_COUNT".
    */
    function multiSigProposalsCountKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSALS_COUNT"));
    }

    /**
    * @dev Get the count of multi-signature proposals.
    * @return The current count of multi-signature proposals.
    */
    function multiSigProposalsCount() public view virtual returns (uint256) {
        return _uint256[multiSigProposalsCountKey()];
    }

    /**
    * @dev Internal function to increment the count of multi-signature proposals.
    * @return The updated count of multi-signature proposals.
    * @notice Emits a `MultiSigProposalsCountIncremented` event.
    */
    function _incrementMultiSigProposalsCount() internal virtual returns (uint256) {
        _uint256[multiSigProposalsCountKey()] += 1;
        emit MultiSigProposalsCountIncremented(_uint256[multiSigProposalsCountKey()]);
        return _uint256[multiSigProposalsCountKey()];
    }

    /** Conditions */

    /**
    * @dev Get the number of required signatures for a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The calculated number of required signatures based on signers length and required quorum.
    */
    function multiSigProposalRequiredSignaturesLength(uint256 id) public view virtual returns (uint256) {
        return (multiSigProposalSignersLength(id) * multiSigProposalRequiredQuorum(id)) / 10000;
    }

    /**
    * @dev Check if a multi-signature proposal has sufficient signatures.
    * @param id The unique identifier of the multi-signature proposal.
    * @return True if the proposal has enough signatures, false otherwise.
    */
    function multiSigProposalHasSufficientSignatures(uint256 id) public view virtual returns (bool) {
        return multiSigProposalSignaturesLength(id) >= multiSigProposalRequiredSignaturesLength(id);
    }

    /** Caption */

    /**
    * @dev Emitted when the caption of a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the multi-signature proposal.
    * @param caption The new caption for the multi-signature proposal.
    */
    event MultiSigProposalCaptionSetTo(uint256 indexed id, string indexed caption);

    function multiSigProposalCaptionKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_CAPTION", id));
    }

    /**
    * @dev Get the storage key for the caption of a specific multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_CAPTION" concatenated with the proposal ID.
    */
    function multiSigProposalCaption(uint256 id) public view virtual returns (string memory) {
        return _string[multiSigProposalCaptionKey(id)];
    }

    /**
    * @dev Internal function to set the caption of a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param caption The new caption for the multi-signature proposal.
    * @notice Reverts if the provided caption is the same as the current value or an empty string.
    * @notice Emits a `MultiSigProposalCaptionSetTo` event.
    */
    function _setMultiSigProposalCaption(uint256 id, string memory caption) internal virtual {
        string memory emptyString;
        caption.onlynotMatchingValue(emptyString);
        _string[multiSigProposalCaptionKey(id)].onlynotMatchingValue(caption);
        _string[multiSigProposalCaptionKey(id)] = caption;
        emit MultiSigProposalCaptionSetTo(id, caption);
    } 

    /** Message */

    /**
    * @dev Emitted when the message of a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the multi-signature proposal.
    * @param message The new message for the multi-signature proposal.
    */
    event MultiSigProposalMessageSetTo(uint256 indexed id, string indexed message);

    /**
    * @dev Get the storage key for the message of a specific multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_MESSAGE" concatenated with the proposal ID.
    */
    function multiSigProposalMessageKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_MESSAGE", id));
    }

    /**
    * @dev Get the message of a specific multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The current message for the multi-signature proposal.
    */
    function multiSigProposalMessage(uint256 id) public view virtual returns (string memory) {
        return _string[multiSigProposalMessageKey(id)];
    }

    /**
    * @dev Internal function to set the message of a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param message The new message for the multi-signature proposal.
    * @notice Reverts if the provided message is the same as the current value or an empty string.
    * @notice Emits a `MultiSigProposalMessageSetTo` event.
    */
    function _setMultiSigProposalMessage(uint256 id, string memory message) internal virtual {
        string memory emptyString;
        message.onlynotMatchingValue(emptyString);
        _string[multiSigProposalMessageKey(id)].onlynotMatchingValue(message);
        _string[multiSigProposalMessageKey(id)] = message;
        emit MultiSigProposalMessageSetTo(id, message);
    }

    /** Creator */

    /**
    * @dev Emitted when the creator of a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the multi-signature proposal.
    * @param creator The new creator address for the multi-signature proposal.
    */
    event MultiSigProposalCreatorSetTo(uint256 indexed id, address indexed creator);

    /**
    * @dev Get the storage key for the creator of a specific multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_CREATOR" concatenated with the proposal ID.
    */
    function multiSigProposalCreatorKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_CREATOR", id));
    }

    /**
    * @dev Get the creator address of a specific multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The current creator address for the multi-signature proposal.
    */
    function multiSigProposalCreator(uint256 id) public view virtual returns (address) {
        return _address[multiSigProposalCreatorKey(id)];
    }

    /**
    * @dev Internal function to set the creator of a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param creator The new creator address for the multi-signature proposal.
    * @notice Reverts if the provided creator address is the same as the current value.
    * @notice Emits a `MultiSigProposalCreatorSetTo` event.
    */
    function _setMultiSigProposalCreator(uint256 id, address creator) internal virtual {
        _address[multiSigProposalCreatorKey(id)].onlynotAddress(creator);
        _address[multiSigProposalCreatorKey(id)] = creator;
        emit MultiSigProposalCreatorSetTo(id, creator);
    }

    /** Payload Target */

    /**
    * @dev Set the target address for a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param target The address of the target contract or account.
    */
    event MultiSigProposalTargetSetTo(uint256 indexed id, address indexed target);

    /**
    * @dev Get the storage key for the target address of a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_TARGET".
    */
    function multiSigProposalTargetKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_TARGET", id));
    }

    /**
    * @dev Gets the target address for a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The target address of the proposal.
    */
    function multiSigProposalTarget(uint256 id) public view virtual returns (address) {
        return _address[multiSigProposalTargetKey(id)];
    }

    /**
    * @dev Sets the target address for a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param target The target address to be set.
    * @dev Throws an `IsAddress` error if the target address is the zero address.
    * @param id The unique identifier of the multi-signature proposal.
    * @param target The target address set for the proposal.
    */
    function _setMultiSigProposalTarget(uint256 id, address target) internal virtual {
        _address[multiSigProposalTargetKey(id)].onlynotAddress(target);
        _address[multiSigProposalTargetKey(id)] = target;
        emit MultiSigProposalTargetSetTo(id, target);
    }

    /** Payload Data */

    /**
    * @dev Event emitted when the additional data of a multi-signature proposal is set.
    * @param id The unique identifier of the multi-signature proposal.
    * @param data The additional data set for the proposal.
    */
    event MultiSigProposalDataSetTo(uint256 indexed id, bytes indexed data);

    /**
    * @dev Get the storage key for the additional data of a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_DATA" concatenated with the proposal ID.
    */
    function multiSigProposalDataKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_DATA", id));
    }

    /**
    * @dev Get the additional data associated with a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The additional data associated with the proposal.
    */
    function multiSigProposalData(uint256 id) public view virtual returns (bytes memory) {
        return _bytes[multiSigProposalDataKey(id)];
    }

    /**
    * @dev Set additional data for a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param data The additional data to be associated with the proposal.
    * @dev Throws an error if the provided data is not different from the current data.
    */
    function _setMultiSigProposalData(uint256 id, bytes memory data) internal virtual {
        _bytes[multiSigProposalDataKey(id)].onlynotMatchingValue(data);
        _bytes[multiSigProposalDataKey(id)] = data;
        emit MultiSigProposalDataSetTo(id, data);
    }

    /** Required Quorum */

    /**
    * @dev Emitted when the required quorum percentage of a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the multi-signature proposal.
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    */
    event MultiSigProposalRequiredQuorumSetTo(uint256 indexed id, uint256 indexed bp);

    /**
    * @dev Get the storage key for the required quorum percentage of a specific multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_REQUIRED_QUORUM" concatenated with the proposal ID.
    */
    function multiSigProposalRequiredQuorumKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_REQUIRED_QUORUM", id));
    }

    /**
    * @dev Get the required quorum percentage of a specific multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The current basis points representing the required quorum percentage (0 to 10000).
    */
    function multiSigProposalRequiredQuorum(uint256 id) public view virtual returns (uint256) {
        return _uint256[multiSigProposalRequiredQuorumKey(id)];
    }

    /**
    * @dev Internal function to set the required quorum percentage of a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    * @notice Reverts if the provided basis points are out of bounds (0 to 10000) or equal to the current value.
    * @notice Emits a `MultiSigProposalRequiredQuorumSetTo` event.
    */
    function _setMultiSigProposalRequiredQuorum(uint256 id, uint256 bp) internal virtual {
        bp.onlyBetween(0, 10000);
        _uint256[multiSigProposalRequiredQuorumKey(id)].onlynotMatchingValue(bp);
        _uint256[multiSigProposalRequiredQuorumKey(id)] = bp;
        emit MultiSigProposalRequiredQuorumSetTo(id, bp);
    }

    /** Has Passed */

    /**
    * @dev Emitted when a multi-signature proposal has passed and received sufficient signatures.
    * @param id The unique identifier of the multi-signature proposal.
    * @notice This event indicates that the proposal has met the required quorum and can proceed to execution.
    */
    event MultiSigProposalHasPassed(uint256 id);

    /**
    * @dev Get the storage key indicating whether a specific multi-signature proposal has passed.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_HAS_PASSED" concatenated with the proposal ID.
    */
    function multiSigProposalHasPassedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_HAS_PASSED", id));
    }

    /**
    * @dev Check if a specific multi-signature proposal has passed and received sufficient signatures.
    * @param id The unique identifier of the multi-signature proposal.
    * @return True if the proposal has passed, indicating it has met the required quorum; otherwise, false.
    */
    function multiSigProposalHasPassed(uint256 id) public view virtual returns (bool) {
        return _bool[multiSigProposalHasPassedKey(id)];
    }

    /** Is Executed */

    /**
    * @dev Emitted when a multi-signature proposal has been successfully executed.
    * @param id The unique identifier of the multi-signature proposal.
    * @notice This event indicates that the proposal has been executed, and its intended actions have been performed.
    */
    event MultiSigProposalHasBeenExecuted(uint256 id);

    function multiSigProposalIsExecutedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_IS_EXECUTED", id));
    }

    /**
    * @dev Get the storage key indicating whether a specific multi-signature proposal has been executed.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_IS_EXECUTED" concatenated with the proposal ID.
    */
    function multiSigProposalIsExecuted(uint256 id) public view virtual returns (bool) {
        return _bool[multiSigProposalIsExecutedKey(id)];
    }

    /**
    * @dev Internal function to execute a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @notice Reverts if the proposal has not started, has already ended, is already executed, or has not passed.
    * @notice Emits a `MultiSigProposalHasBeenExecuted` event upon successful execution.
    */
    function _executeMultiSigProposal(uint256 id) internal virtual {
        require(multiSigProposalHasStarted(id), "ProposalStateMultiSigProposalsV1: !multiSigProposalHasStarted(id)");
        require(!multiSigProposalHasEnded(id), "ProposalStateMultiSigProposalsV1: multiSigProposalHasEnded(id)");
        require(!multiSigProposalIsExecuted(id), "ProposalStateMultiSigProposalsV1: multiSigProposalIsExecuted(id)");
        require(multiSigProposalHasPassed(id), "ProposalStateMultiSigProposalsV1: !MultiSigProposalHasPassed(id)");
        _bool[multiSigProposalIsExecutedKey(id)] = true;
        emit MultiSigProposalHasBeenExecuted(id);
    }

    /** Timestamp */

    /**
    * @dev Get the timestamp indicating the end of a specific multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The timestamp representing the end of the proposal calculated as the sum of its start timestamp and duration.
    */
    function multiSigProposalEndTimestamp(uint256 id) public view virtual returns (uint256) {
        return multiSigProposalStartTimestamp(id) + multiSigProposalDuration(id);
    }

    /**
    * @dev Check if a specific multi-signature proposal has started.
    * @param id The unique identifier of the multi-signature proposal.
    * @return True if the current block timestamp is greater than or equal to the start timestamp of the proposal; otherwise, false.
    */
    function multiSigProposalHasStarted(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= multiSigProposalStartTimestamp(id);
    }

    /**
    * @dev Check if a specific multi-signature proposal has ended.
    * @param id The unique identifier of the multi-signature proposal.
    * @return True if the current block timestamp is greater than or equal to the end timestamp of the proposal; otherwise, false.
    */
    function multiSigProposalHasEnded(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= multiSigProposalEndTimestamp(id);
    }

    /**
    * @dev Get the remaining seconds for a specific multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The number of seconds remaining for the proposal, considering its start timestamp, end timestamp, and the current block timestamp.
    */
    function multiSigProposalSecondsLeft(uint256 id) public view virtual returns (uint256) {
        if (multiSigProposalHasStarted(id) && !multiSigProposalHasEnded(id)) { return (multiSigProposalStartTimestamp(id) + multiSigProposalDuration(id)) - block.timestamp; }
        else if (!multiSigProposalHasStarted(id)) { return multiSigProposalDuration(id); }
        else { return 0; }
    }

    /** StartTimestamp */

    /**
    * @dev Emitted when the start timestamp of a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the multi-signature proposal.
    * @param timestamp The new start timestamp for the proposal.
    */
    event MultiSigProposalStartTimestampSetTo(uint256 indexed id, uint256 indexed timestamp);

    function multiSigProposalStartTimestampKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_START_TIMESTAMP", id));
    }

    /**
    * @dev Get the start timestamp of a specific multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The start timestamp of the proposal as stored in the contract state.
    */
    function multiSigProposalStartTimestamp(uint256 id) public view virtual returns (uint256) {
        return _uint256[multiSigProposalStartTimestampKey(id)];
    }

    /**
    * @dev Internal function to set the start timestamp of a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param timestamp The new start timestamp for the proposal.
    * @notice Emits a `MultiSigProposalStartTimestampSetTo` event.
    * @notice Reverts if the provided timestamp is the same as the current start timestamp.
    * @param id The unique identifier of the multi-signature proposal.
    * @param timestamp The new start timestamp for the proposal.
    */
    function _setMultiSigProposalStartTimestamp(uint256 id, uint256 timestamp) internal virtual {
        _uint256[multiSigProposalStartTimestampKey(id)].onlynotMatchingValue(timestamp);
        _uint256[multiSigProposalStartTimestampKey(id)] = timestamp;
        emit MultiSigProposalStartTimestampSetTo(id, timestamp);
    }

    /** Duration */

    /**
    * @dev Emitted when the duration of a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the multi-signature proposal.
    * @param seconds_ The new duration in seconds for the proposal.
    */
    event MultiSigProposalDurationSetTo(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Get the storage key for the duration of a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_DURATION".
    */
    function multiSigProposalDurationKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_DURATION", id));
    }

    /**
    * @dev Get the duration in seconds of a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The duration in seconds of the specified proposal.
    */
    function multiSigProposalDuration(uint256 id) public view virtual returns (uint256) {
        return _uint256[multiSigProposalDurationKey(id)];
    }

    /**
    * @dev Set the duration in seconds for a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param seconds_ The new duration in seconds to be set for the proposal.
    * @notice Emits a `MultiSigProposalDurationSetTo` event.
    * @dev Throws an error if the provided duration is the same as the current duration.
    * @param seconds_ The new duration in seconds to be set for the proposal.
    */
    function _setMultiSigProposalDuration(uint256 id, uint256 seconds_) internal virtual {
        _uint256[multiSigProposalDurationKey(id)].onlynotMatchingValue(seconds_);
        _uint256[multiSigProposalDurationKey(id)] = seconds_;
        emit MultiSigProposalDurationSetTo(id, seconds_);
    }

    /** Signers */

    /**
    * @dev Emitted when a signer is added to a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param account The address of the added signer.
    */
    event MultiSigProposalSignerAdded(uint256 indexed id, address indexed account);

    /**
    * @dev Get the storage key for the set of signers in a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_SIGNERS" concatenated with the proposal ID.
    */
    function multiSigProposalSignersKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_SIGNERS", id));
    }

    /**
    * @dev Get the address of a signer in a multi-signature proposal at a specific index.
    * @param id The unique identifier of the multi-signature proposal.
    * @param signerId The index of the signer in the set of signers for the proposal.
    * @return The address of the signer at the specified index.
    */
    function multiSigProposalSigners(uint256 id, uint256 signerId) public view virtual returns (address) {
        EnumerableSet.AddressSet storage signers = _addressSet[multiSigProposalSignersKey(id)];
        return signers.at(signerId);
    }

    /**
    * @dev Get the number of signers in a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The number of signers in the proposal.
    */
    function multiSigProposalSignersLength(uint256 id) public view virtual returns (uint256) {
        EnumerableSet.AddressSet storage signers = _addressSet[multiSigProposalSignersKey(id)];
        return signers.length();
    }

    /**
    * @dev Check if an address is a signer in a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param account The address to check.
    * @return True if the address is a signer in the proposal, false otherwise.
    */
    function isMultiSigProposalSigner(uint256 id, address account) public view virtual returns (bool) {
        EnumerableSet.AddressSet storage signers = _addressSet[multiSigProposalSignersKey(id)];
        return signers.contains(account);
    }

    /**
    * @dev Internal function to add an address as a signer to a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param account The address to be added as a signer.
    * @notice Emits a `MultiSigProposalSignerAdded` event.
    * @notice Reverts if the address is already a signer in the proposal.
    * @param account The address to be added as a signer.
    */
    function _addMultiSigProposalSigner(uint256 id, address account) internal virtual {
        if (isMultiSigProposalSigner(id, account)) { revert ErrorsV1.IsAlreadyInSet(account); }
        EnumerableSet.AddressSet storage signers = _addressSet[multiSigProposalSignersKey(id)];
        signers.add(account);
        emit MultiSigProposalSignerAdded(id, account);
    }

    /** Signatures */

    /**
    * @dev Emitted when a signer provides their signature for a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param signature The address of the signer providing the signature.
    * @notice This event signifies that a signer has endorsed the proposal.
    */
    event MultiSigProposalSigned(uint256 id, address indexed signature);

    /**
    * @dev Get the storage key for the set of signatures received for a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_SIGNATURES" concatenated with the proposal ID.
    */
    function multiSigProposalSignaturesKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_SIGNATURES", id));
    }

    /**
    * @dev Get the address of the signer at a specific index in the set of signatures for a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param signatureId The index of the signer in the set of signatures.
    * @return The address of the signer at the specified index.
    */
    function multiSigProposalSignatures(uint256 id, uint256 signatureId) public view virtual returns (address) {
        EnumerableSet.AddressSet storage signatures = _addressSet[multiSigProposalSignaturesKey(id)];
        return signatures.at(signatureId);
    }

    /**
    * @dev Get the number of signers in the set of signatures for a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @return The number of signers in the set of signatures.
    */
    function multiSigProposalSignaturesLength(uint256 id) public view virtual returns (uint256) {
        EnumerableSet.AddressSet storage signatures = _addressSet[multiSigProposalSignaturesKey(id)];
        return signatures.length();
    }

    /**
    * @dev Check if a signer has already signed a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @param account The address of the signer to check.
    * @return A boolean indicating whether the signer has already signed the proposal.
    */
    function hasSignedMultiSigProposal(uint256 id, address account) public view virtual returns (bool) {
        EnumerableSet.AddressSet storage signatures = _addressSet[multiSigProposalSignaturesKey(id)];
        return signatures.contains(account);
    }

    /**
    * @dev Sign a multi-signature proposal.
    * @param id The unique identifier of the multi-signature proposal.
    * @dev Throws an error if the proposal has not started, has ended, the sender is not a signer, or the sender has already signed.
    */
    function _signMultiSigProposal(uint256 id) internal virtual {
        require(multiSigProposalHasStarted(id), "ProposalStateMultiSigProposalsV1: !multiSigProposalHasStarted(id)");
        require(!multiSigProposalHasEnded(id), "ProposalStateMultiSigProposalsV1: multiSigProposalHasEnded(id)");
        require(isMultiSigProposalSigner(id, msg.sender), "ProposalStateMultiSigProposalV1: !isMultiSigProposalSigner(id,msg.sender)");
        require(!hasSignedMultiSigProposal(id, msg.sender), "ProposalStateMultiSigProposalV1: hasSignedMultiSigProposal(id,msg.sender)");
        EnumerableSet.AddressSet storage signatures = _addressSet[multiSigProposalSignaturesKey(id)];
        signatures.add(msg.sender);
        if (multiSigProposalHasSufficientSignatures(id)) {
            _bool[multiSigProposalHasPassedKey(id)] = true;
            emit MultiSigProposalHasPassed(id);
        }
        emit MultiSigProposalSigned(id, msg.sender);
    }
}