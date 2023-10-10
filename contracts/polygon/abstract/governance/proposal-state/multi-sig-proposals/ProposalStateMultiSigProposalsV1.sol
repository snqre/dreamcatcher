// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

/**
 * @title ProposalStateMultiSigProposalsV1
 * @dev A Solidity smart contract for managing multi-signature proposals.
 * 
 * This contract provides functionality to create, manage, and execute multi-signature proposals.
 * It includes features such as adding signers, setting quorum, managing proposal duration, and more.
 */
abstract contract ProposalStateMultiSigProposalsV1 is StateV1 {

    /**
    * @dev Use the `EnumerableSet` library to provide additional functionality for handling sets of addresses.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    /** Setter Events. */

    /**
    * @dev Emitted when a signer is added to a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param account The address of the added signer.
    */
    event MultiSigProposalSignerAdded(uint256 indexed id, address indexed account);

    /**
    * @dev Emitted when the required quorum for a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the proposal.
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    */
    event MultiSigProposalRequiredQuorumSetTo(uint256 indexed  id, uint256 indexed bp);

    /**
    * @dev Emitted when the duration for a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The new duration in seconds.
    */
    event MultiSigProposalDurationSetTo(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Emitted when the duration for a multi-signature proposal is increased.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The additional seconds by which the duration is increased.
    */
    event MultiSigProposalDurationIncreased(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Emitted when the duration for a multi-signature proposal is decreased.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The number of seconds by which the duration is decreased.
    */
    event MultiSigProposalDurationDecreased(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Emitted when the caption of a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the proposal.
    * @param caption The new caption for the proposal.
    */
    event MultiSigProposalCaptionSetTo(uint256 indexed id, string indexed caption);

    /**
    * @dev Emitted when the message of a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the proposal.
    * @param message The new message for the proposal.
    */
    event MultiSigProposalMessageSetTo(uint256 indexed id, string indexed message);

    /**
    * @dev Emitted when the creator of a multi-signature proposal is set to a new account.
    * @param id The unique identifier of the proposal.
    * @param account The address of the new creator for the proposal.
    */
    event MultiSigProposalCreatorSetTo(uint256 indexed id, address indexed account);

    /**
    * @dev Emitted when the start timestamp of a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the proposal.
    * @param timestamp The new start timestamp for the proposal.
    */
    event MultiSigproposalStartTimestampSetTo(uint256 indexed id, uint256 indexed timestamp);

    /**
    * @dev Emitted when the start timestamp of a multi-signature proposal is increased.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The number of seconds by which the start timestamp is increased.
    */
    event MultiSigProposalStartTimestampIncreased(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Emitted when the start timestamp of a multi-signature proposal is decreased.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The number of seconds by which the start timestamp is decreased.
    */
    event MultiSigProposalStartTimestampDecreased(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Emitted when a signer signs a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param signer The address of the signer.
    */
    event MultiSigProposalSigned(uint256 indexed id, address indexed signer);

    /**
    * @dev Emitted when a multi-signature proposal is executed.
    * @param id The unique identifier of the proposal.
    */
    event MultiSigProposalExecuted(uint256 indexed id);

    /**
    * @dev Emitted when the count of multi-signature proposals is incremented.
    * @param id The unique identifier of the proposal.
    */
    event MultiSigProposalCountIncremented(uint256 indexed id);

    /**
    * @dev Error indicating that an account is not a signer for a specific multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param account The address being checked.
    */
    error IsNotASigner(uint256 id, address account);

    /**
    * @dev Error indicating that a multi-signature proposal has not passed and cannot be executed.
    * @param id The unique identifier of the proposal.
    */
    error MultiSigProposalHasNotPassed(uint256 id);

    /**
    * @dev Error indicating that an account is already a signer for a specific multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param account The address of the account that is already a signer.
    */
    error IsAlreadyASigner(uint256 id, address account);

    /**
    * @dev Error indicating that a value is out of bounds.
    * @param min The minimum allowed value (inclusive).
    * @param max The maximum allowed value (inclusive).
    * @param value The value that is out of bounds.
    */
    error OutOfBounds(uint256 min, uint256 max, uint256 value);

    /**
    * @dev Error indicating that an account has already signed a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param account The address of the account that has already signed.
    */
    error HasAlreadySigned(uint256 id, address account);

    /**
    * @dev Error indicating that a multi-signature proposal has already been executed.
    * @param id The ID of the executed multi-signature proposal.
    */
    error MultiSigProposalHasAlreadyBeenExecuted(uint256 id);

    /** Keys. */

    /**
    * @dev Get the storage key for the signers of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_SIGNERS" concatenated with the proposal ID.
    */
    function multiSigProposalSignersKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_SIGNERS", id));
    }

    /**
    * @dev Get the storage key for the signatures of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_SIGNATURES" concatenated with the proposal ID.
    */
    function multiSigProposalSignaturesKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_SIGNATURES", id));
    }

    /**
    * @dev Get the storage key for the caption of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_CAPTION" concatenated with the proposal ID.
    */
    function multiSigProposalCaptionKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_CAPTION", id));
    }

    /**
    * @dev Get the storage key for the message of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_MESSAGE" concatenated with the proposal ID.
    */
    function multiSigProposalMessageKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_MESSAGE", id));
    }

    /**
    * @dev Get the storage key for the creator of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_CREATOR" concatenated with the proposal ID.
    */
    function multiSigProposalCreatorKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_CREATOR", id));
    }

    /**
    * @dev Get the storage key for the start timestamp of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_START_TIMESTAMP" concatenated with the proposal ID.
    */
    function multiSigProposalStartTimestampKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_START_TIMESTAMP", id));
    }

    /**
    * @dev Get the storage key for the duration of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_DURATION" concatenated with the proposal ID.
    */
    function multiSigProposalDurationKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_DURATION", id));
    }

    /**
    * @dev Get the storage key for the required quorum of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_REQUIRED_QUORUM" concatenated with the proposal ID.
    */
    function multiSigProposalRequiredQuorumKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_REQUIRED_QUORUM", id));
    }

    /**
    * @dev Get the storage key for the "has passed" flag of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_HAS_PASSED" concatenated with the proposal ID.
    */
    function multiSigProposalHasPassedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_HAS_PASSED", id));
    }

    /**
    * @dev Get the storage key for the "executed" flag of a multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSAL_EXECUTED" concatenated with the proposal ID.
    */
    function multiSigProposalExecutedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_EXECUTED", id));
    }

    /**
    * @dev Get the storage key for the count of multi-signature proposals.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSALS_COUNT".
    */
    function multiSigProposalsCountKey() public pure virtual returns (uint256) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSALS_COUNT"));
    }

    /** Getters. */

    /**
    * @dev Get the caption of a multi-signature proposal.
    * @param id The ID of the proposal.
    * @return The caption of the proposal.
    */
    function multiSigProposalCaption(uint256 id) public view virtual returns (string memory) {
        return _string[multiSigProposalCaptionKey(id)];
    }

    /**
    * @dev Get the message of a multi-signature proposal.
    * @param id The ID of the proposal.
    * @return The message of the proposal.
    */
    function multiSigProposalMessage(uint256 id) public view virtual returns (string memory) {
        return _string[multiSigProposalMessageKey(id)];
    }

    /**
    * @dev Get the creator of a multi-signature proposal.
    * @param id The ID of the proposal.
    * @return The address of the creator.
    */
    function multiSigProposalCreator(uint256 id) public view virtual returns (address) {
        return _address[multiSigProposalCreatorKey(id)];
    }

    /**
    * @dev Get the start timestamp of a multi-signature proposal.
    * @param id The ID of the proposal.
    * @return The start timestamp of the proposal.
    */
    function multiSigProposalStartTimestamp(uint256 id) public view virtual returns (uint256) {
        return _uint256[multiSigProposalStartTimestampKey(id)];
    }

    /**
    * @dev Get the end timestamp of a multi-signature proposal.
    * @param id The ID of the proposal.
    * @return The end timestamp of the proposal.
    */
    function multiSigProposalEndTimestamp(uint256 id) public view virtual returns (uint256) {
        return multiSigProposalStartTimestamp(id) + multiSigProposalDuration(id);
    }

    /**
    * @dev Get the duration of a multi-signature proposal.
    * @param id The ID of the proposal.
    * @return The duration of the proposal.
    */
    function multiSigProposalDuration(uint256 id) public view virtual returns (uint256) {
        return _uint256[multiSigProposalDurationKey(id)];
    }

    /**
    * @dev Get the address of a signer in a multi-signature proposal.
    * @param id The ID of the proposal.
    * @param signerId The index of the signer in the list.
    * @return The address of the signer at the specified index.
    */
    function multiSigProposalSigners(uint256 id, uint256 signerId) public view virtual returns (address) {
        return _addressSet[multiSigProposalSignersKey(id)].at(signerId);
    }

    /**
    * @dev Get the number of signers in a multi-signature proposal.
    * @param id The ID of the proposal.
    * @return The number of signers in the proposal.
    */
    function multiSigProposalSignersLength(uint256 id) public view virtual returns (uint256) {
        return _addressSet[multiSigProposalSignersKey(id)].length();
    }

    /**
    * @dev Check if an account is a signer in a multi-signature proposal.
    * @param id The ID of the proposal.
    * @param account The address to check.
    * @return True if the account is a signer, false otherwise.
    */
    function multiSigProposalIsSigner(uint256 id, address account) public view virtual returns (bool) {
        return _addressSet[multiSigProposalSignersKey(id)].contains(account);
    }

    /**
    * @dev Check if an account has signed a multi-signature proposal.
    * @param id The ID of the proposal.
    * @param account The address to check.
    * @return True if the account has signed, false otherwise.
    */
    function multiSigProposalHasSigned(uint256 id, address account) public view virtual returns (bool) {
        return _addressSet[multiSigProposalSignaturesKey(id)].contains(account);
    }

    /**
    * @dev Get the address of a signer in the list of signatures for a multi-signature proposal.
    * @param id The ID of the proposal.
    * @param signatureId The index of the signature in the list.
    * @return The address of the signer at the specified index.
    */
    function multiSigProposalSignatures(uint256 id, uint256 signatureId) public view virtual returns (address) {
        return _addressSet[multiSigProposalSignaturesKey(id)].at(signatureId);
    }

    /**
    * @dev Get the number of signatures in the list for a multi-signature proposal.
    * @param id The ID of the proposal.
    * @return The number of signatures in the list.
    */
    function multiSigProposalSignaturesLength(uint256 id) public view virtual returns (uint256) {
        return _addressSet[multiSigProposalSignaturesKey(id)].length();
    }

    /**
    * @dev Get the required quorum for a multi-signature proposal.
    * @param id The ID of the proposal.
    * @return The required quorum.
    */
    function multiSigProposalRequiredQuorum(uint256 id) public view virtual returns (uint256) {
        return _uint256[multiSigProposalRequiredQuorumKey(id)];
    }

    /**
    * @dev Get the required number of signatures for a multi-signature proposal.
    * @param id The ID of the proposal.
    * @return The required number of signatures.
    */
    function multiSigProposalRequiredSignaturesLength(uint256 id) public view virtual returns (uint256) {
        return (multiSigProposalSignersLength(id) * multiSigProposalRequiredQuorum(id)) / 10000;
    }

    /**
    * @dev Check if a multi-signature proposal has received sufficient signatures.
    * @param id The ID of the proposal.
    * @return True if the proposal has received sufficient signatures, false otherwise.
    */
    function multiSigProposalHasSufficientSignatures(uint256 id) public view virtual returns (bool) {
        return multiSigProposalSignaturesLength(id) >= multiSigProposalRequiredSignaturesLength(id);
    }

    /**
    * @dev Check if a multi-signature proposal has passed.
    * @param id The ID of the proposal.
    * @return True if the proposal has passed, false otherwise.
    */
    function multiSigProposalHasPassed(uint256 id) public view virtual returns (bool) {
        return _bool[multiSigProposalHasPassedKey(id)];
    }

    /**
    * @dev Check if a multi-signature proposal has been executed.
    * @param id The ID of the proposal.
    * @return True if the proposal has been executed, false otherwise.
    */
    function multiSigProposalExecuted(uint256 id) public view virtual returns (bool) {
        return _bool[multiSigProposalExecutedKey(id)];
    }

    /**
    * @dev Check if a multi-signature proposal has started.
    * @param id The ID of the proposal.
    * @return True if the proposal has started, false otherwise.
    */
    function multiSigProposalHasStarted(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= multiSigProposalStartTimestamp(id);
    }

    /**
    * @dev Check if a multi-signature proposal has ended.
    * @param id The ID of the proposal.
    * @return True if the proposal has ended, false otherwise.
    */
    function multiSigProposalHasEnded(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= multiSigProposalEndTimestamp(id);
    }

    /**
    * @dev Get the remaining seconds for a multi-signature proposal.
    * @param id The ID of the proposal.
    * @return The remaining seconds if the proposal is ongoing, 0 otherwise.
    */
    function multiSigProposalSecondsLeft(uint256 id) public view virtual returns (uint256) {
        if (multiSigProposalHasStarted(id) && !multiSigProposalHasEnded(id)) {
            return (multiSigProposalStartTimestamp(id) + multiSigProposalDuration(id)) - block.timestamp;
        }
        else if (!multiSigProposalHasStarted(id)) {
            return multiSigProposalDuration(id);
        }
        else {
            return 0;
        }
    }

    /**
    * @dev Get the total count of multi-signature proposals.
    * @return The total count of multi-signature proposals.
    */
    function multiSigProposalsCount() public view virtual returns (uint256) {
        return _uint256[multiSigProposalsCountKey()];
    }

    /** Flags. */

    /**
    * @dev Modifier to ensure that the caller is a signer of the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @notice Reverts if the caller is not a signer.
    */
    function _onlySigner(uint256 id) internal view virtual {
        if (multiSigProposalIsSigner(id, msg.sender)) { revert IsNotASigner(id, msg.sender); }
    }

    /**
    * @dev Modifier to ensure that the caller has not already signed the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @notice Reverts if the caller has already signed.
    */
    function _onlynotSigned(uint256 id) internal view virtual {
        if (multiSigProposalHasSigned(id, msg.sender)) { revert HasAlreadySigned(id, msg.sender); }
    }

    /** Setters. */

    /**
    * @dev Adds a signer to the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param account The address to be added as a signer.
    * @notice Reverts if the account is already a signer.
    */
    function _addSignerToMultiSigProposal(uint256 id, address account) internal virtual {
        if (multiSigProposalIsSigner(id, account)) { revert IsAlreadyASigner(id, account); }
        _addressSet[multiSigProposalSignersKey(id)].add(account);
        emit MultiSigProposalSignerAdded(id, account);
    }

    /**
    * @dev Sets the required quorum for the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param bp The basis points (bp) representing the required quorum.
    * @notice Reverts if the bp value is not within the valid range [0, 10000].
    */
    function _setMultiSigProposalRequiredQuorum(uint256 id, uint256 bp) internal virtual {
        if (bp > 10000) { revert OutOfBounds(0, 10000, bp); }
        _uint256[multiSigProposalRequiredQuorumKey(id)] = bp;
        emit MultiSigProposalRequiredQuorumSetTo(id, bp);
    }

    /**
    * @dev Sets the duration for the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param seconds_ The duration in seconds.
    */
    function _setMultiSigProposalDuration(uint256 id, uint256 seconds_) internal virtual {
        _uint256[multiSigProposalDurationKey(id)] = seconds_;
        emit MultiSigProposalDurationSetTo(id, seconds_);
    }

    /**
    * @dev Increases the duration for the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param seconds_ The additional duration in seconds.
    */
    function _increaseMultiSigProposalDuration(uint256 id, uint256 seconds_) internal virtual {
        _uint256[multiSigProposalDurationKey(id)] += seconds_;
        emit MultiSigProposalDurationIncreased(id, seconds_);
    }

    /**
    * @dev Decreases the duration for the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param seconds_ The reduction in duration in seconds.
    */
    function _decreaseMultiSigProposalDuration(uint256 id, uint256 seconds_) internal virtual {
        _uint256[multiSigProposalDurationKey(id)] -= seconds_;
        emit MultiSigProposalDurationDecreased(id, seconds_);
    }

    /**
    * @dev Sets the caption for the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param caption The new caption for the proposal.
    */
    function _setMultiSigProposalCaption(uint256 id, string memory caption) internal virtual {
        _string[multiSigProposalCaptionKey(id)] = caption;
        emit MultiSigProposalCaptionSetTo(id, caption);
    }

    /**
    * @dev Sets the message for the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param message The new message for the proposal.
    */
    function _setMultiSigProposalMessage(uint256 id, string memory message) internal virtual {
        _string[multiSigProposalMessageKey(id)] = message;
        emit MultiSigProposalMessageSetTo(id, message);
    }

    /**
    * @dev Sets the creator of the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param account The address of the new creator.
    */
    function _setMultiSigProposalCreator(uint256 id, address account) internal virtual {
        _address[multiSigProposalCreatorKey(id)] = account;
        emit MultiSigProposalCreatorSetTo(id, account);
    }

    /**
    * @dev Sets the start timestamp of the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param timestamp The new start timestamp.
    */
    function _setMultiSigProposalStartTimestamp(uint256 id, uint256 timestamp) internal virtual {
        _uint256[multiSigProposalStartTimestampKey(id)] = timestamp;
        emit MultiSigproposalStartTimestampSetTo(id, timestamp);
    }

    /**
    * @dev Increases the start timestamp of the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param seconds_ The number of seconds to increase the start timestamp.
    */
    function _increaseMultiSigProposalStartTimestamp(uint256 id, uint256 seconds_) internal virtual {
        _uint256[multiSigProposalStartTimestampKey(id)] += seconds_;
        emit MultiSigProposalStartTimestampIncreased(id, seconds_);
    }

    /**
    * @dev Decreases the start timestamp of the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    * @param seconds_ The number of seconds to decrease the start timestamp.
    */
    function _decreaseMultiSigProposalStartTimestamp(uint256 id, uint256 seconds_) internal virtual {
        _uint256[multiSigProposalStartTimestampKey(id)] -= seconds_;
        emit MultiSigProposalStartTimestampDecreased(id, seconds_);
    }

    /**
    * @dev Signs the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    */
    function _signMultiSigProposal(uint256 id) internal virtual {
        _onlySigner(id);
        _onlynotSigned(id);
        _addressSet[multiSigProposalSignaturesKey(id)].add(msg.sender);
        if (multiSigProposalHasSufficientSignatures(id)) { _bool[multiSigProposalHasPassedKey()] = true; }
        emit MultiSigProposalSigned(id, msg.sender);
    }

    /**
    * @dev Executes the multi-signature proposal.
    * @param id The ID of the multi-signature proposal.
    */
    function _executeMultiSigProposal(uint256 id) internal virtual {
        if (multiSigProposalExecuted(id)) { revert MultiSigProposalHasAlreadyBeenExecuted(id); }
        if (!multiSigProposalHasPassed(id)) { revert MultiSigProposalHasNotPassed(id); }
        _bool[multiSigProposalExecutedKey(id)] = true;
        emit MultiSigProposalExecuted(id);
    }

    /**
    * @dev Increments the count of multi-signature proposals.
    * @return The updated count of multi-signature proposals.
    */
    function _incrementMultiSigProposalsCount() internal virtual returns (uint256) {
        _uint256[multiSigProposalsCountKey()] += 1;
        emit MultiSigProposalCountIncremented(_uint256[multiSigProposalsCountKey()]);
        return _uint256[multiSigProposalsCountKey()];
    }
}