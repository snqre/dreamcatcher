// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @dev Library for managing multi-signature schemes.
 */
library MultiSigV1 {

    /**
    * @dev Error indicating that the account is not a signer in the multisignature scheme.
    */
    error IsNotASigner(address account);

    /**
    * @dev Error indicating that the execution condition has not been passed.
    */
    error HasNotPassed();

    /**
    * @dev Error indicating that the account is already a signer in the multisignature scheme.
    */
    error IsAlreadyASigner(address account);

    /**
    * @dev Error indicating that the provided value is outside the specified bounds.
    * @param min The minimum allowed value.
    * @param max The maximum allowed value.
    * @param value The value that is outside the allowed bounds.
    */
    error OutOfBounds(uint256 min, uint256 max, uint256 value);

    /**
    * @dev Error indicating that the specified account has already signed.
    * @param account The address of the account that has already signed.
    */
    error HasAlreadySigned(address account);

    /**
     * @dev This error is thrown when a particular operation has already been executed.
     */
    error HasAlreadyBeenExecuted();

    /**
    * @title MultiSig
    * @dev Represents a multi-signature structure for managing signed transactions.
    */
    struct MultiSig {
        string _caption;
        string _message;
        uint256 _startTimestamp;
        uint256 _duration;
        address[] _signers;
        address[] _signatures;
        uint256 _requiredQuorum;
        bool _hasPassed;
        bool _executed;
    }

    /**
    * @dev Get the caption of a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @return The caption associated with the multi-signature transaction.
    */
    function caption(MultiSig memory self) public pure returns (string memory) {
        return self._caption;
    }

    /**
    * @dev Get the message associated with a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @return The message associated with the multi-signature transaction.
    */
    function message(MultiSig memory self) public pure returns (string memory) {
        return self._message;
    }

    /**
    * @dev Get the build version of a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @return The build version associated with the multi-signature transaction.
    */
    function buildVersion(MultiSig memory self) public pure returns (uint256) {
        return 1;
    }

    /**
    * @dev Get the start timestamp of a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @return The start timestamp associated with the multi-signature transaction.
    */
    function startTimestamp(MultiSig memory self) public pure returns (uint256) {
        return self._startTimestamp;
    }

    /**
    * @dev Get the end timestamp of a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @return The end timestamp associated with the multi-signature transaction.
    */
    function endTimestamp(MultiSig memory self) public pure returns (uint256) {
        return startTimestamp(self) + duration(self);
    }

    /**
    * @dev Get the duration of a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @return The duration associated with the multi-signature transaction.
    */
    function duration(MultiSig memory self) public pure returns (uint256) {
        return self._duration;
    }

    /**
    * @dev Get the signer address at a specific index in the array of signers for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @param id The index of the signer in the array.
    * @return The address of the signer at the specified index.
    */
    function signers(MultiSig memory self, uint256 id) public pure returns (address) {
        return self._signers[id];
    }

    /**
    * @dev Get the number of signers in the array for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @return The number of signers in the array.
    */
    function signersLength(MultiSig memory self) public pure returns (uint256) {
        return self._signers.length;
    }

    /**
    * @dev Check if an account is one of the signers for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @param account The address to check for signer status.
    * @return True if the account is a signer, false otherwise.
    */
    function isSigner(MultiSig memory self, address account) public pure returns (bool) {
        bool isSigner;
        for (uint256 i = 0; i < signersLength(self); i++) {
            if (signers(self, i) == account) {
                isSigner = true;
                break;
            }
        }
        return isSigner;
    }

    /**
    * @dev Check if an account has already signed a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @param account The address to check for signing status.
    * @return True if the account has already signed, false otherwise.
    */
    function hasSigned(MultiSig memory self, address account) public pure returns (bool) {
        bool hasSigned;
        for (uint256 i = 0; i < signaturesLength(self); i++) {
            if (signatures(self, i) == account) {
                hasSigned = true;
                break;
            }
        }
        return hasSigned;
    }

    /**
    * @dev Get the signature at a specific index in the array of signatures for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @param id The index of the signature in the array.
    * @return The address of the signer at the specified index.
    */
    function signatures(MultiSig memory self, uint256 id) public pure returns (address) {
        return self._signatures[id];
    }

    /**
    * @dev Get the number of signatures in the array for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @return The number of signatures in the array.
    */
    function signaturesLength(MultiSig memory self) public pure returns (uint256) {
        return self._signatures.length;
    }

    /**
    * @dev Get the required quorum for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @return The required quorum for the multi-signature transaction.
    */
    function requiredQuorum(MultiSig memory self) public pure returns (uint256) {
        return self._requiredQuorum;
    }

    /**
    * @dev Get the number of required signatures for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction.
    * @return The number of required signatures based on the quorum percentage.
    */
    function requiredSignaturesLength(MultiSig memory self) public pure returns (uint256) {
        return (signersLength(self) * requiredQuorum(self)) / 10000;
    }

    /**
    * @dev Check if a multi-signature transaction has a sufficient number of signatures to meet the required quorum.
    * @param self The MultiSig structure representing the transaction.
    * @return True if there are sufficient signatures, false otherwise.
    */
    function hasSufficientSignatures(MultiSig memory self) public pure returns (bool) {
        return signaturesLength(self) >= requiredSignaturesLength(self);
    }

    /**
    * @dev Check if a multi-signature transaction has passed.
    * @param self The MultiSig structure representing the transaction.
    * @return True if the transaction has passed, false otherwise.
    */
    function hasPassed(MultiSig memory self) public pure returns (bool) {
        return self._hasPassed;
    }

    /**
    * @dev Check if a multi-signature transaction has been executed.
    * @param self The MultiSig structure representing the transaction.
    * @return True if the transaction has been executed, false otherwise.
    */
    function executed(MultiSig memory self) public pure returns (bool) {
        return self._executed;
    }

    /**
    * @dev Check if a multi-signature transaction has started.
    * @param self The MultiSig structure representing the transaction.
    * @return True if the transaction has started, false otherwise.
    */
    function hasStarted(MultiSig memory self) public view returns (bool) {
        return block.timestamp >= startTimestamp(self);
    }

    /**
    * @dev Check if a multi-signature transaction has ended.
    * @param self The MultiSig structure representing the transaction.
    * @return True if the transaction has ended, false otherwise.
    */
    function hasEnded(MultiSig memory self) public view returns (bool) {
        return block.timestamp >= endTimestamp(self);
    }

    /**
    * @dev Get the number of seconds left for a multi-signature transaction to complete.
    * @param self The MultiSig structure representing the transaction.
    * @return The number of seconds left. If the transaction has ended or hasn't started, it returns 0.
    */
    function secondsLeft(MultiSig memory self) public view returns (uint256) {
        if (hasStarted(self) && hasEnded(self)) {
            return (startTimestamp(self) + duration(self)) - block.timestamp;
        }
        else if (block.timestamp < startTimestamp(self)) {
            return duration(self);
        }
        else {
            return 0;
        }
    }

    /**
    * @dev Add a new signer to the list of signers for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @param signer The address of the new signer to be added.
    * @notice Reverts if the provided address is already a signer.
    */
    function addSigner(MultiSig storage self, address signer) public {
        if (isSigner(self, signer)) { revert IsAlreadyASigner(signer); }
        self._signers.push(signer);
    }

    /**
    * @dev Set the required quorum percentage for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @param bp The basis points representing the new required quorum percentage (0 to 10000).
    * @notice Reverts if the provided basis points are out of bounds (greater than 10000).
    */
    function setRequiredQuorum(MultiSig storage self, uint256 bp) public {
        if (bp > 10000) { revert OutOfBounds(0, 10000, bp); }
        self._requiredQuorum = bp;
    }

    /**
    * @dev Set the duration for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @param seconds_ The new duration in seconds.
    */
    function setDuration(MultiSig storage self, uint256 seconds_) public {
        self._duration = seconds_;
    }

    /**
    * @dev Increase the duration of a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @param seconds_ The number of seconds to increase the duration.
    */
    function increaseDuration(MultiSig storage self, uint256 seconds_) public {
        self._duration += seconds_;
    }

    /**
    * @dev Decrease the duration of a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @param seconds_ The number of seconds to decrease the duration.
    */
    function decreaseDuration(MultiSig storage self, uint256 seconds_) public {
        self._duration -= seconds_;
    }

    /**
    * @dev Set the caption for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @param caption The new caption for the transaction.
    */
    function setCaption(MultiSig storage self, string memory caption) public {
        self._caption = caption;
    }

    /**
    * @dev Set the message for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @param message The new message for the transaction.
    */
    function setMessage(MultiSig storage self, string memory message) public {
        self._message = message;
    }

    /**
    * @dev Set the start timestamp for a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @param timestamp The new start timestamp for the transaction.
    */
    function setStartTimestamp(MultiSig storage self, uint256 timestamp) public {
        self._startTimestamp = timestamp;
    }

    /**
    * @dev Increase the start timestamp of a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @param seconds_ The number of seconds to increase the start timestamp.
    */
    function increaseStartTimestamp(MultiSig storage self, uint256 seconds_) public {
        self._startTimestamp += seconds_;
    }

    /**
    * @dev Decrease the start timestamp of a multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @param seconds_ The number of seconds to decrease the start timestamp.
    */
    function decreaseStartTimestamp(MultiSig storage self, uint256 seconds_) public {
        self._startTimestamp -= seconds_;
    }

    /**
    * @dev Sign the multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @notice Reverts if the sender is not a signer or has already signed the transaction.
    */
    function sign(MultiSig storage self) public {
        if (!isSigner(self, msg.sender)) { revert IsNotASigner(msg.sender); }
        if (hasSigned(self, msg.sender)) { revert HasAlreadySigned(msg.sender); }
        self._signatures.push(msg.sender);
        if (hasSufficientSignatures(self)) { self._hasPassed = true; }
    }

    /**
    * @dev Execute the multi-signature transaction.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    * @notice Reverts if the transaction has already been executed or has not passed.
    */
    function execute(MultiSig storage self) public {
        if (executed(self)) { revert HasAlreadyBeenExecuted(); }
        if (!hasPassed(self)) { revert HasNotPassed(); }
        self._executed = true;
    }

    /**
    * @dev Reset the state of the multi-signature transaction to its initial values.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    */
    function reset(MultiSig storage self) public {
        delete self._caption;
        delete self._message;
        delete self._startTimestamp;
        delete self._duration;
        delete self._signers;
        delete self._signatures;
        delete self._requiredQuorum;
        delete self._hasPassed;
        delete self._executed;
    }

    /**
    * @dev Reset only the timer of a multi-signature transaction to the current block timestamp.
    * @param self The MultiSig structure representing the transaction. It is a storage reference.
    */
    function onlyResetTimer(MultiSig storage self) public {
        self._startTimestamp = block.timestamp;
    }
}