// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/libraries/proposal/multi-sig/MultiSigV1.sol";
import "contracts/polygon/libraries/bytes-array/BytesArrayV1.sol";

/**
 * @title ProposalStateMultiSigProposalsV1
 * @dev An abstract contract for managing multi-signature proposals.
 * Provides functionality to create, manage, and execute multi-signature proposals.
 * Uses the `MultiSigV1` and `BytesArrayV1` contracts for multi-signature functionality and handling arrays of bytes, respectively.
 */
abstract contract ProposalStateMultiSigProposalsV1 is StateV1 {

    /**
    * @dev Import the `MultiSigV1` contract and use it for MultiSig functionality.
    */
    using MultiSigV1 for MultiSigV1.MultiSig;

    /**
    * @dev Import the `BytesArrayV1` contract and use it for handling arrays of bytes.
    */
    using BytesArrayV1 for bytes[];

    /**
    * @dev Emitted when a signer is added to a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param account The address of the added signer.
    */
    event MultiSigProposalSignerAdded(uint256 indexed id, address indexed account);

    /**
    * @dev Emitted when the required quorum percentage for a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the proposal.
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    */
    event MultiSigProposalRequiredQuorumSetTo(uint256 indexed id, uint256 indexed bp);

    /**
    * @dev Emitted when the duration for a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The new duration in seconds.
    */
    event MultiSigProposalDurationSetTo(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Emitted when the duration for a multi-signature proposal is increased.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The additional duration in seconds.
    */
    event MultiSigProposalDurationIncreased(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Emitted when the duration for a multi-signature proposal is decreased.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The reduced duration in seconds.
    */
    event MultiSigProposalDurationDecreased(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Emitted when the caption for a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the proposal.
    * @param caption The new caption for the proposal.
    */
    event MultiSigProposalCaptionSetTo(uint256 indexed id, string indexed caption);

    /**
    * @dev Emitted when the message for a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the proposal.
    * @param message The new message for the proposal.
    */
    event MultiSigProposalMessageSetTo(uint256 indexed id, string indexed message);

    /**
    * @dev Emitted when the start timestamp for a multi-signature proposal is set to a new value.
    * @param id The unique identifier of the proposal.
    * @param timestamp The new start timestamp for the proposal.
    */
    event MultiSigProposalStartTimestampSetTo(uint256 indexed id, uint256 indexed timestamp);

    /**
    * @dev Emitted when the start timestamp for a multi-signature proposal is increased.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The additional duration in seconds by which the start timestamp is increased.
    */
    event MultiSigProposalStartTimestampIncreased(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Emitted when the start timestamp for a multi-signature proposal is decreased.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The reduced duration in seconds by which the start timestamp is decreased.
    */
    event MultiSigProposalStartTimestampDecreased(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Emitted when an address signs a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param signer The address of the signer.
    */
    event MultiSigProposalSigned(uint256 indexed id, address indexed signer);

    /**
    * @dev Emitted when a multi-signature proposal is executed.
    * @param id The unique identifier of the executed proposal.
    */
    event MultiSigProposalExecuted(uint256 indexed id);

    /**
    * @dev Emitted when a multi-signature proposal is reset.
    * @param id The unique identifier of the reset proposal.
    */
    event MultiSigProposalReset(uint256 indexed id);

    /**
    * @dev Emitted when the timer of a multi-signature proposal is reset.
    * @param id The unique identifier of the proposal.
    */
    event MultiSigProposalTimerReset(uint256 indexed id);

    /** @dev Keys. */

    /**
    * @dev Get the storage key for multi-signature proposals.
    * @return The keccak256 hash of the string "MULTI_SIG_PROPOSALS".
    */
    function multiSigProposalsKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSALS"));
    }

    /** @dev Getters. */

    /**
    * @dev Get the caption of a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @return The caption of the proposal.
    */
    function multiSigProposalCaption(uint256 id) public view virtual returns (string memory) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.caption();
    }

    /**
    * @dev Get the message of a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @return The message of the proposal.
    */
    function multiSigProposalMessage(uint256 id) public view virtual returns (string memory) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.message();
    }

    /**
    * @dev Get the start timestamp of a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @return The start timestamp of the proposal.
    */
    function multiSigProposalStartTimestamp(uint256 id) public view virtual returns (uint256) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.startTimestamp();
    }

    /**
    * @dev Get the end timestamp of a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @return The end timestamp of the proposal.
    */
    function multiSigProposalEndTimestamp(uint256 id) public view virtual returns (uint256) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.endTimestamp();
    }

    /**
    * @dev Get the duration of a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @return The duration of the proposal.
    */
    function multiSigProposalDuration(uint256 id) public view virtual returns (uint256) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.duration();
    }

    /**
    * @dev Get the address of a signer in a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param signerId The index of the signer in the proposal.
    * @return The address of the signer.
    */
    function multiSigProposalSigners(uint256 id, uint256 signerId) public view virtual returns (address) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.signers(signerId);
    }

    /**
    * @dev Get the number of signers in a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @return The number of signers in the proposal.
    */
    function multiSigProposalSignersLength(uint256 id) public view virtual returns (uint256) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.signersLength();
    }

    /**
    * @dev Check if an account is a signer in a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param account The address to check.
    * @return True if the account is a signer in the proposal, false otherwise.
    */
    function multiSigProposalsIsSigner(uint256 id, address account) public view virtual returns (bool) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.isSigner(account);
    }

    /**
    * @dev Check if an account has signed a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param account The address to check.
    * @return True if the account has signed the proposal, false otherwise.
    */
    function multiSigProposalHasSigned(uint256 id, address account) public view virtual returns (bool) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.hasSigned(account);
    }

    /**
    * @dev Get the address of a signer in the list of signatures for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param signatureId The index of the signature in the list.
    * @return The address of the signer at the specified index.
    */
    function multiSigProposalSignatures(uint256 id, uint256 signatureId) public view virtual returns (address) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.signatures(signatureId);
    }

    /**
    * @dev Get the number of signatures in the list for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @return The number of signatures in the list.
    */
    function multiSigProposalSignaturesLength(uint256 id) public view virtual returns (uint256) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.signaturesLength();
    }

    /**
    * @dev Get the required quorum percentage for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @return The required quorum percentage (basis points).
    */
    function multiSigProposalRequiredQuorum(uint256 id) public view virtual returns (uint256) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.requiredQuorum();
    }

    /**
    * @dev Get the number of required signatures for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @return The number of required signatures.
    */
    function multiSigProposalRequiredSignaturesLength(uint256 id) public view virtual returns (uint256) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.requiredSignaturesLength();
    }

    /**
    * @dev Check if a multi-signature proposal has sufficient signatures.
    * @param id The unique identifier of the proposal.
    * @return True if the proposal has sufficient signatures, false otherwise.
    */
    function multiSigProposalHasSufficientSignatures(uint256 id) public view virtual returns (bool) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.hasSufficientSignatures();
    }

    /**
    * @dev Check if a multi-signature proposal has passed.
    * @param id The unique identifier of the proposal.
    * @return True if the proposal has passed, false otherwise.
    */
    function multiSigProposalHasPassed(uint256 id) public view virtual returns (bool) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.hasPassed();
    }

    /**
    * @dev Check if a multi-signature proposal has been executed.
    * @param id The unique identifier of the proposal.
    * @return True if the proposal has been executed, false otherwise.
    */
    function multiSigProposalExecuted(uint256 id) public view virtual returns (bool) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.executed();
    }

    /**
    * @dev Check if a multi-signature proposal has started.
    * @param id The unique identifier of the proposal.
    * @return True if the proposal has started, false otherwise.
    */
    function multiSigProposalHasStarted(uint256 id) public view virtual returns (bool) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.hasStarted();
    }

    /**
    * @dev Check if a multi-signature proposal has ended.
    * @param id The unique identifier of the proposal.
    * @return True if the proposal has ended, false otherwise.
    */
    function multiSigProposalHasEnded(uint256 id) public view virtual returns (bool) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.hasEnded();
    }

    /**
    * @dev Get the remaining time in seconds for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @return The remaining time in seconds.
    */
    function multiSigProposalSecondsLeft(uint256 id) public view virtual returns (uint256) {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        return proposal.secondsLeft();
    }

    /** @dev Pull proposal object from bytes array storage. */

    /**
    * @dev Internal function to retrieve a multi-signature proposal by its unique identifier.
    * @param id The unique identifier of the proposal.
    * @return The multi-signature proposal.
    */
    function _multiSigProposals(uint256 id) internal view virtual returns (MultiSigV1.MultiSig) {
        bytes[] storage multiSigProposals = _bytesArray[multiSigProposalsKey()];
        return abi.decode(multiSigProposals[id], (MultiSigV1.MultiSig));
    }

    /** @dev Setters. */

    /**
    * @dev Internal function to add a signer to a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param account The address of the signer to be added.
    * @notice Emits a `MultiSigProposalSignerAdded` event.
    */
    function _addMultiSigProposalSigner(uint256 id, address account) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.addSigner(account);
        emit MultiSigProposalSignerAdded(id, account);
    }

    /**
    * @dev Internal function to set the required quorum for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param bp The new basis points representing the required quorum percentage (0 to 10000).
    * @notice Emits a `MultiSigProposalRequiredQuorumSetTo` event.
    */
    function _setMultiSigProposalRequiredQuorum(uint256 id, uint256 bp) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.setRequiredQuorum(self, bp);
        emit MultiSigProposalRequiredQuorumSetTo(id, bp);
    }

    /**
    * @dev Internal function to set the duration for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The new duration in seconds.
    * @notice Emits a `MultiSigProposalDurationSetTo` event.
    */
    function _setMultiSigProposalDuration(uint256 id, uint256 seconds_) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.setDuration(self, seconds_);
        emit MultiSigProposalDurationSetTo(id, seconds_);
    }

    /**
    * @dev Internal function to increase the duration for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The additional duration in seconds.
    * @notice Emits a `MultiSigProposalDurationIncreased` event.
    */
    function _increaseMultiSigProposalDuration(uint256 id, uint256 seconds_) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.increaseDuration(self, seconds_);
        emit MultiSigProposalDurationIncreased(id, seconds_);
    }

    /**
    * @dev Internal function to decrease the duration for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The reduction in duration in seconds.
    * @notice Emits a `MultiSigProposalDurationDecreased` event.
    */
    function _decreaseMultiSigProposalDuration(uint256 id, uint256 seconds_) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.decreaseDuration(self, seconds_);
        emit MultiSigProposalDurationDecreased(id, seconds_);
    }

    /**
    * @dev Internal function to set the caption for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param caption The new caption for the proposal.
    * @notice Emits a `MultiSigProposalCaptionSetTo` event.
    */
    function _setMultiSigProposalCaption(uint256 id, string memory caption) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.setCaption(self, caption);
        emit MultiSigProposalCaptionSetTo(id, caption);
    }

    /**
    * @dev Internal function to set the message for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param message The new message for the proposal.
    * @notice Emits a `MultiSigProposalMessageSetTo` event.
    */
    function _setMultiSigProposalMessage(uint256 id, string memory message) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.setMessage(self, message);
        emit MultiSigProposalMessageSetTo(id, message);
    }

    /**
    * @dev Internal function to set the start timestamp for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param timestamp The new start timestamp for the proposal.
    * @notice Emits a `MultiSigProposalStartTimestampSetTo` event.
    */
    function _setMultiSigProposalStartTimestamp(uint256 id, uint256 timestamp) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.setStartTimestamp(self, timestamp);
        emit MultiSigProposalStartTimestampSetTo(id, timestamp);
    }

    /**
    * @dev Internal function to increase the start timestamp for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The number of seconds by which to increase the start timestamp.
    * @notice Emits a `MultiSigProposalStartTimestampIncreased` event.
    */
    function _increaseMultiSigProposalStartTimestamp(uint256 id, uint256 seconds_) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.increaseStartTimestamp(self, seconds_);
        emit MultiSigProposalStartTimestampIncreased(id, seconds_);
    }

    /**
    * @dev Internal function to decrease the start timestamp for a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @param seconds_ The number of seconds by which to decrease the start timestamp.
    * @notice Emits a `MultiSigProposalStartTimestampDecreased` event.
    */
    function _decreaseMultiSigProposalStartTimestamp(uint256 id, uint256 seconds_) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.decreaseStartTimestamp(self, seconds_);
        emit MultiSigProposalStartTimestampDecreased(id, seconds_);
    }

    /**
    * @dev Internal function to sign a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @notice Emits a `MultiSigProposalSigned` event.
    */
    function _signMultiSigProposal(uint256 id) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.sign(self);
        emit MultiSigProposalSigned(id, msg.sender);
    }

    /**
    * @dev Internal function to execute a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @notice Emits a `MultiSigProposalExecuted` event.
    */
    function _executeMultiSigProposal(uint256 id) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.execute(self);
        emit MultiSigProposalExecuted(id);
    }

    /**
    * @dev Internal function to reset a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @notice Emits a `MultiSigProposalReset` event.
    */
    function _resetMultiSigProposal(uint256 id) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.reset(self);
        emit MultiSigProposalReset(id);
    }

    /**
    * @dev Internal function to reset the timer of a multi-signature proposal.
    * @param id The unique identifier of the proposal.
    * @notice Emits a `MultiSigProposalTimerReset` event.
    */
    function _resetTimerMultiSigProposal(uint256 id) internal virtual {
        MultiSigV1.MultiSig storage proposal = _multiSigProposals(id);
        proposal.onlyResetTimer(self);
        emit MultiSigProposalTimerReset(id);
    }   
}