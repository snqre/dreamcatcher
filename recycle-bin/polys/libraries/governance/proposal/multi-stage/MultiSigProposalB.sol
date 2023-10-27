// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/libraries/shared/errors/Errors.sol";

library MultiSigProposal {

    /**
    * @notice Represents a proposal with details such as caption, message, creator, signers, start timestamp, duration, required quorum, target, data, approval status, execution status, timed configuration, and requirement for call success.
    */
    struct Proposal {
        string _caption;
        string _message;
        address _creator;
        address[] _signers;
        address[] _signatures;
        uint256 _startTimestamp;
        uint256 _duration;
        uint256 _requiredQuorum;
        address _target;
        bytes _data;
        bool _hasBeenApproved;
        bool _hasBeenExecuted;
        bool _isTimed;
        bool _requireCallSuccess;
    }

    /**
    * @notice Retrieves the caption of the proposal.
    * @dev Returns the caption or title of the proposal.
    * @param self The Proposal struct to query.
    * @return The caption of the proposal.
    */
    function caption(Proposal storage self) public view returns (string memory) {
        return self._caption;
    }

    /**
    * @notice Retrieves the message of the proposal.
    * @dev Returns the detailed message or content of the proposal.
    * @param self The Proposal struct to query.
    * @return The message of the proposal.
    */
    function message(Proposal storage self) public view returns (string memory) {
        return self._message;
    }

    /**
    * @notice Retrieves the creator of the proposal.
    * @dev Returns the address of the creator/initiator of the proposal.
    * @param self The Proposal struct to query.
    * @return The address of the creator of the proposal.
    */
    function creator(Proposal storage self) public view returns (address) {
        return self._creator;
    }

    /**
    * @notice Retrieves the signer at a specific index in the list of signers.
    * @dev Returns the address of the signer at the specified index in the signers array.
    * @param self The Proposal struct to query.
    * @param signerId The index of the signer to retrieve.
    * @return The address of the signer at the specified index.
    */
    function signers(Proposal storage self, uint256 signerId) public view returns (address) {
        return self._signers[signerId];
    }

    /**
    * @notice Retrieves the length of the signers array in the proposal.
    * @dev Returns the number of signers in the proposal.
    * @param self The Proposal struct to query.
    * @return The length of the signers array in the proposal.
    */
    function signersLength(Proposal storage self) public view returns (uint256) {
        return self._signers.length;
    }

    /**
    * @notice Checks if an account is a signer in the proposal.
    * @dev Returns true if the specified account is a signer in the proposal, otherwise returns false.
    * @param self The Proposal struct to query.
    * @param account The address of the account to check for signer status.
    * @return True if the account is a signer, false otherwise.
    */
    function isSigner(Proposal storage self, address account) public view returns (bool) {
        for (uint256 i = 0; i < signersLength({self: self}); i++) {
            if (signers({self: self, signerId: i}) == account) {
                return true;
            }
        }
        return false;
    }

    /**
    * @notice Retrieves the signature at a specific index in the list of signatures.
    * @dev Returns the address of the signature at the specified index in the signatures array.
    * @param self The Proposal struct to query.
    * @param signatureId The index of the signature to retrieve.
    * @return The address of the signature at the specified index.
    */
    function signatures(Proposal storage self, uint256 signatureId) public view returns (address) {
        return self._signatures[signatureId];
    }

    /**
    * @notice Retrieves the length of the signatures array in the proposal.
    * @dev Returns the number of signatures in the proposal.
    * @param self The Proposal struct to query.
    * @return The length of the signatures array in the proposal.
    */
    function signaturesLength(Proposal storage self) public view returns (uint256) {
        return self._signatures.length;
    }

    /**
    * @notice Checks if an account has signed the proposal.
    * @dev Returns true if the specified account has a corresponding signature in the proposal, otherwise returns false.
    * @param self The Proposal struct to query.
    * @param account The address of the account to check for signature status.
    * @return True if the account has signed, false otherwise.
    */
    function hasSigned(Proposal storage self, address account) public view returns (bool) {
        for (uint256 i = 0; i < signersLength({self: self}); i++) {
            if (signatures({self: self, signatureId: i}) == account) {
                return true;
            }
        }
        return false;
    }

    /**
    * @notice Retrieves the required quorum for the proposal.
    * @dev Returns the minimum number of approvals required for the proposal to be considered approved.
    * @param self The Proposal struct to query.
    * @return The required quorum for the proposal.
    */
    function requiredQuorum(Proposal storage self) public view returns (uint256) {
        return self._requiredQuorum;
    }

    /**
    * @notice Retrieves the length of required signatures for the proposal.
    * @dev Calculates and returns the number of required signatures based on the product of the number of signers and the required quorum, divided by 10,000.
    * @param self The Proposal struct to query.
    * @return The length of required signatures for the proposal.
    */
    function requiredSignaturesLength(Proposal storage self) public view returns (uint256) {
        return (signersLength({self: self}) * requiredQuorum({self: self})) / 10_000;
    }

    /**
    * @notice Checks if the proposal has a sufficient number of signatures.
    * @dev Returns true if the number of signatures in the proposal is greater than or equal to the calculated required number of signatures, otherwise returns false.
    * @param self The Proposal struct to query.
    * @return True if the proposal has sufficient signatures, false otherwise.
    */
    function hasSufficientSignatures(Proposal storage self) public view returns (bool) {
        return signaturesLength({self: self}) >= requiredSignaturesLength({self: self});
    }

    /**
    * @notice Retrieves the target address of the proposal.
    * @dev Returns the target address where the proposed action or function call is intended.
    * @param self The Proposal struct to query.
    * @return The target address of the proposal.
    */
    function target(Proposal storage self) public view returns (address) {
        return self._target;
    }

    /**
    * @notice Retrieves the data payload of the proposal.
    * @dev Returns the data payload, containing encoded parameters or information for the proposed action or function call.
    * @param self The Proposal struct to query.
    * @return The data payload of the proposal.
    */
    function data(Proposal storage self) public view returns (bytes memory) {
        return self._data;
    }

    /**
    * @notice Checks if the proposal has been approved.
    * @dev Returns true if the proposal has been approved, indicating that it has received sufficient signatures, otherwise returns false.
    * @param self The Proposal struct to query.
    * @return True if the proposal has been approved, false otherwise.
    */
    function hasBeenApproved(Proposal storage self) public view returns (bool) {
        return self._hasBeenApproved;
    }

    /**
    * @notice Checks if the proposal has been executed.
    * @dev Returns true if the proposal has been executed, indicating that the proposed action or function call has been performed, otherwise returns false.
    * @param self The Proposal struct to query.
    * @return True if the proposal has been executed, false otherwise.
    */
    function hasBeenExecuted(Proposal storage self) public view returns (bool) {
        return self._hasBeenExecuted;
    }

    /**
    * @notice Checks if the proposal is timed.
    * @dev Returns true if the proposal has a specified duration, indicating it is timed, otherwise returns false.
    * @param self The Proposal struct to query.
    * @return True if the proposal is timed, false otherwise.
    */
    function isTimed(Proposal storage self) public view returns (bool) {
        return self._isTimed;
    }

    /**
    * @notice Checks if the proposal requires the underlying call to succeed.
    * @dev Returns true if the proposal requires the success of the underlying call, indicating that the proposed action or function call must execute without errors, otherwise returns false.
    * @param self The Proposal struct to query.
    * @return True if the proposal requires call success, false otherwise.
    */
    function requireCallSuccess(Proposal storage self) public view returns (bool) {
        return self._requireCallSuccess;
    }

    /**
    * @notice Ensures that the proposal has been approved.
    * @dev Reverts if the proposal has not been approved, indicating that it has not received sufficient signatures.
    * @param self The Proposal struct to check for approval status.
    */
    function onlyApproved(Proposal storage self) public view {
        if (!hasBeenApproved({self: self})) {
            revert Errors.HasNotBeenApproved();
        }
    }

    /**
    * @notice Ensures that the proposal has not been executed.
    * @dev Reverts if the proposal has already been executed, indicating that the proposed action or function call has been performed.
    * @param self The Proposal struct to check execution status.
    */
    function onlynotExecuted(Proposal storage self) public view {
        if (hasBeenExecuted({self: self})) {
            revert Errors.HasAlreadyBeenExecuted();
        }
    }

    /**
    * @notice Sets the caption of the proposal.
    * @dev Updates the caption with the provided text.
    * @param self The Proposal struct to modify.
    * @param text The new caption text to set.
    */
    function setCaption(Proposal storage self, string memory text) public {
        self._caption = text;
    }

    /**
    * @notice Sets the message of the proposal.
    * @dev Updates the message with the provided text.
    * @param self The Proposal struct to modify.
    * @param text The new message text to set.
    */
    function setMessage(Proposal storage self, string memory text) public {
        self._message = text;
    }

    /**
    * @notice Sets the creator of the proposal.
    * @dev Updates the creator with the provided account address.
    * @param self The Proposal struct to modify.
    * @param account The new creator's address to set.
    */
    function setCreator(Proposal storage self, address account) public {
        self._creator = account;
    }

    /**
    * @notice Sets the required quorum for the proposal.
    * @dev Updates the required quorum with the provided basis points (bp).
    * @param self The Proposal struct to modify.
    * @param bp The new required quorum in basis points to set.
    */
    function setRequiredQuorum(Proposal storage self, uint256 bp) public {
        if (bp > 10_000) {
            revert Errors.OutOfBounds({min: 0, max: 10_000, value: bp});
        }
        self._requiredQuorum = bp;
    }

    /**
    * @notice Adds a signer to the list of signers for the proposal.
    * @dev Appends the provided account address to the list of signers.
    * @param self The Proposal struct to modify.
    * @param account The address of the signer to add.
    */
    function addSigner(Proposal storage self, address account) public {
        if (isSigner({self: self, account: account})) {
            revert Errors.IsAlreadySigner({account: account});
        }
        self._signers.push(account);
    }

    /**
    * @notice Signs the proposal.
    * @dev Adds the sender's address to the list of signatures if the sender is a signer and has not already signed.
    * @param self The Proposal struct to modify.
    */
    function sign(Proposal storage self) public {
        if (!isSigner({self: self, account: msg.sender})) {
            revert Errors.HasAlreadySigned({account: msg.sender});
        }
        if (hasSigned({self: self, account: msg.sender})) {
            revert Errors.HasAlreadySigned({account: msg.sender});
        }
        self._signatures.push(msg.sender);
    }

    /**
    * @notice Executes the proposal.
    * @dev Marks the proposal as executed if it has been approved and has not already been executed.
    * @param self The Proposal struct to modify.
    */
    function execute(Proposal storage self) public {
        onlyApproved({self: self});
        onlynotExecuted({self: self});
        self._hasBeenExecuted = true;
    }

    /**
    * @notice Executes the proposal using a low-level call.
    * @dev Marks the proposal as executed if it has been approved and has not already been executed.
    * Executes a low-level call to the target address with the provided data.
    * Reverts if the call fails and `requireCallSuccess` is true.
    * @param self The Proposal struct to modify.
    * @return response The response from the low-level call.
    */
    function executeWithLowLevelCall(Proposal storage self) public returns (bytes memory) {
        onlyApproved({self: self});
        onlynotExecuted({self: self});
        (bool success, bytes memory response)
        = address(target({self: self}))
        .call(data({self: self}));
        if (requireCallSuccess({self: self})) {
            if (!success) {
                revert Errors.FailedLowLevelCall({target: target({self: self}), data: data({self: self})});
            }
        }
        self._hasBeenExecuted = true;
        return response;
    }

    /**
    * @notice Sets the approval status of the proposal.
    * @dev Updates the approval status with the provided boolean value.
    * @param self The Proposal struct to modify.
    * @param boolean The boolean value to set as the approval status.
    */
    function setHasBeenApproved(Proposal storage self, bool boolean) public {
        self._hasBeenApproved = boolean;
    }

    /**
    * @notice Sets the execution status of the proposal.
    * @dev Updates the execution status with the provided boolean value.
    * @param self The Proposal struct to modify.
    * @param boolean The boolean value to set as the execution status.
    */
    function setHasBeenExecuted(Proposal storage self, bool boolean) public {
        self._hasBeenExecuted = boolean;
    }

    /**
    * @notice Sets the timed status of the proposal.
    * @dev Updates the timed status with the provided boolean value.
    * @param self The Proposal struct to modify.
    * @param boolean The boolean value to set as the timed status.
    */
    function setTimed(Proposal storage self, bool boolean) public {
        self._isTimed = boolean;
    }

    /**
    * @notice Updates the approval status of the proposal based on sufficient signatures.
    * @dev Marks the proposal as approved if it has sufficient signatures.
    * @param self The Proposal struct to modify.
    */
    function update(Proposal storage self) public {
        if (hasSufficientSignatures({self: self})) {
            self._hasBeenApproved = true;
        }
    }

    /** Timer */

    /**
    * @notice Retrieves the start timestamp of a Timer.
    * @param self The Timer struct to query.
    * @return The timestamp when the timer started.
    */
    function startTimestamp(Proposal storage self) public view returns (uint256) {
        if (isTimed({self: self})) {
            return self._startTimestamp;
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Calculates and returns the end timestamp of a Timer.
    * @dev Uses the start timestamp and duration to determine the end timestamp.
    * @param self The Timer struct to calculate the end timestamp for.
    * @return The timestamp when the timer is expected to end.
    */
    function endTimestamp(Proposal storage self) public view returns (uint256) {
        if (isTimed({self: self})) {
            return startTimestamp({self: self}) + duration({self: self});
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Retrieves the duration of a Timer.
    * @param self The Timer struct to query.
    * @return The duration of the timer in seconds.
    */
    function duration(Proposal storage self) public view returns (uint256) {
        if (isTimed({self: self})) {
            return self._duration;
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Checks whether the Timer has started.
    * @dev Compares the current block timestamp with the start timestamp of the Timer.
    * @param self The Timer struct to check.
    * @return True if the Timer has started, false otherwise.
    */
    function hasStarted(Proposal storage self) public view returns (bool) {
        if (isTimed({self: self})) {
            return block.timestamp >= startTimestamp({self: self});
        }
        else {
            return false;
        }
    }

    /**
    * @notice Checks whether the Timer has ended.
    * @dev Compares the current block timestamp with the calculated end timestamp of the Timer.
    * @param self The Timer struct to check.
    * @return True if the Timer has ended, false otherwise.
    */
    function hasEnded(Proposal storage self) public view returns (bool) {
        if (isTimed({self: self})) {
            return block.timestamp >= endTimestamp({self: self});
        }
        else {
            return false;
        }
    }

    /**
    * @notice Checks whether the Timer is currently counting.
    * @dev Returns true if the Timer has started and has not yet ended.
    * @param self The Timer struct to check.
    * @return True if the Timer is counting, false otherwise.
    */
    function isCounting(Proposal storage self) public view returns (bool) {
        if (isTimed({self: self})) {
            return hasStarted({self: self}) && !hasEnded({self: self});
        }
        else {
            return false;
        }
    }

    /**
    * @notice Calculates the remaining seconds of the Timer.
    * @dev Returns the remaining time if the Timer is currently counting,
    *      the total duration if the Timer has not started, and 0 if the Timer has ended.
    * @param self The Timer struct to calculate remaining seconds for.
    * @return The remaining seconds on the Timer.
    */
    function secondsLeft(Proposal storage self) public view returns (uint256) {
        if (isTimed({self: self})) {
            if (isCounting({self: self})) {
                return (startTimestamp({self: self}) + duration({self: self})) - block.timestamp;
            } 
            else if (!hasStarted({self: self})) {
                return duration({self: self});
            } 
            else {
                return 0;
            }
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Sets the start timestamp of the Timer.
    * @dev Allows updating the start timestamp of the Timer.
    * @param self The Timer struct to update.
    * @param timestamp The new start timestamp to set.
    */
    function setStartTimestamp(Proposal storage self, uint256 timestamp) public {
        self._startTimestamp = timestamp;
    }

    /**
    * @notice Increases the start timestamp of the Timer by a specified number of seconds.
    * @dev Allows advancing the start timestamp of the Timer.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to increase the start timestamp by.
    */
    function increaseStartTimestamp(Proposal storage self, uint256 seconds_) public {
        self._startTimestamp += seconds_;
    }

    /**
    * @notice Decreases the start timestamp of the Timer by a specified number of seconds.
    * @dev Allows moving back the start timestamp of the Timer.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to decrease the start timestamp by.
    */
    function decreaseStartTimestamp(Proposal storage self, uint256 seconds_) public {
        self._startTimestamp -= seconds_;
    }

    /**
    * @notice Sets the duration of the Timer.
    * @dev Allows updating the duration of the Timer.
    * @param self The Timer struct to update.
    * @param seconds_ The new duration to set in seconds.
    */
    function setDuration(Proposal storage self, uint256 seconds_) public {
        self._duration = seconds_;
    }

    /**
    * @notice Increases the duration of the Timer by a specified number of seconds.
    * @dev Allows extending the duration of the Timer.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to increase the duration by.
    */
    function increaseDuration(Proposal storage self, uint256 seconds_) public {
        self._duration += seconds_;
    }

    /**
    * @notice Decreases the duration of the Timer by a specified number of seconds.
    * @dev Allows shortening the duration of the Timer.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to decrease the duration by.
    */
    function decreaseDuration(Proposal storage self, uint256 seconds_) public {
        self._duration -= seconds_;
    }

    /**
    * @notice Resets the Timer to its initial state by clearing start timestamp and duration.
    * @dev Allows resetting the Timer by removing the start timestamp and duration.
    * @param self The Timer struct to reset.
    */
    function reset(Proposal storage self) public {
        self._startTimestamp = block.timestamp;
    }
}