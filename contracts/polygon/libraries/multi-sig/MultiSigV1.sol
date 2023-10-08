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
    * @dev Structure representing a multi-signature scheme.
    */
    struct MultiSig {
        uint256 startTimestamp;
        uint256 duration;
        address[] signers;
        address[] signatures;
        uint256 requiredQuorum;
        bool hasPassed;
        bool executed;
    }

    /**
    * @dev Checks if an account is a signer in the MultiSig.
    * @param self The MultiSig struct.
    * @param account The address to check for signer status.
    * @return bool indicating whether the account is a signer.
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
    * @dev Checks whether the specified account has already signed the multisignature transaction.
    * @param self The MultiSig struct to check.
    * @param account The address to check for signing status.
    * @return bool indicating whether the account has already signed.
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
    * @dev Retrieves the required quorum percentage for the MultiSig.
    * @param self The MultiSig struct.
    * @return uint256 representing the required quorum percentage.
    */
    function requiredQuorum(MultiSig memory self) public pure returns (uint256) {
        return self.requiredQuorum;
    }

    /**
    * @dev Retrieves the number of required signatures based on the quorum percentage.
    * @param self The MultiSig struct.
    * @return uint256 representing the required number of signatures.
    */
    function requiredSignatures(MultiSig memory self) public pure returns (uint256) {
        return (signersLength(self) * requiredQuorum(self)) / 10000;
    }

    /**
    * @dev Checks if the MultiSig struct has sufficient signatures.
    * @param self The MultiSig struct.
    * @return bool indicating whether there are sufficient signatures.
    */
    function hasSufficientSignatures(MultiSig memory self) public pure returns (bool) {
        return signaturesLength(self) >= requiredSignatures(self);
    }

    /**
    * @dev Public pure function to get the start timestamp of a timer.
    * @param self The Timer struct.
    * @return uint256 representing the start timestamp of the timer.
    */
    function startTimestamp(MultiSig memory self) public pure returns (uint256) {
        return self.startTimestamp;
    }

    /**
    * @dev Public pure function to get the end timestamp of a timer.
    * @param self The Timer struct.
    * @return uint256 representing the end timestamp of the timer.
    */
    function endTimestamp(MultiSig memory self) public pure returns (uint256) {
        return startTimestamp(self) + duration(self);
    }

    /**
    * @dev Public pure function to get the duration of a timer.
    * @param self The Timer struct.
    * @return uint256 representing the duration of the timer.
    */
    function duration(MultiSig memory self) public pure returns (uint256) {
        return self.duration;
    }

    /**
    * @dev Retrieves the address of a signer at the specified index in the MultiSig struct.
    * @param self The MultiSig struct.
    * @param id The index of the signer.
    * @return address representing the signer's address.
    */
    function signers(MultiSig memory self, uint256 id) public pure returns (address) {
        return self.signers[id];
    }

    /**
    * @dev Retrieves the number of signers in the MultiSig struct.
    * @param self The MultiSig struct.
    * @return uint256 representing the number of signers.
    */
    function signersLength(MultiSig memory self) public pure returns (uint256) {
        return self.signers.length;
    }

    /**
    * @dev Retrieves the address of the signer at a specified index in the list of signatures.
    * @param self The MultiSig struct.
    * @param id The index of the signature to retrieve.
    * @return address representing the signer's address.
    */
    function signatures(MultiSig memory self, uint256 id) public pure returns (address) {
        return self.signatures[id];
    }

    /**
    * @dev Retrieves the number of signatures appended to the multisignature transaction.
    * @param self The MultiSig struct.
    * @return uint256 representing the number of signatures.
    */
    function signaturesLength(MultiSig memory self) public pure returns (uint256) {
        return self.signatures.length;
    }

    /**
    * @dev Checks whether the multisignature transaction has passed.
    * @param self The MultiSig struct to check.
    * @return bool indicating whether the transaction has passed.
    */
    function hasPassed(MultiSig memory self) public pure returns (bool) {
        return self.hasPassed;
    }

    function executed(MultiSig memory self) public pure returns (bool) {
        return self.executed;
    }

    /**
    * @dev Public view function to check if a timer has started.
    * @param self The Timer struct to check.
    * @return bool indicating whether the timer has started.
    */
    function hasStarted(MultiSig memory self) public view returns (bool) {
        return block.timestamp >= startTimestamp(self);
    }

    /**
    * @dev Public view function to check if a timer has ended.
    * @param self The Timer struct to check.
    * @return bool indicating whether the timer has ended.
    */
    function hasEnded(MultiSig memory self) public view returns (bool) {
        return block.timestamp >= endTimestamp(self);
    }

    /**
    * @dev Get the remaining seconds on the timer.
    * @param self The Timer struct.
    * @return uint256 representing the remaining seconds on the timer.
    * @notice Returns the following:
    * - If the timer has started and not ended, it shows the seconds left.
    * - If the timer has not started, it returns the full duration.
    * - If the timer has ended, it returns 0.
    */
    function secondsLeft(MultiSig memory self) public view returns (uint256) {
        /**
        * @dev Will show seconds left if the timer has started and not
        *      ended. Will return full duration if the timer has 
        *      not started. Will return 0 if the timer has ended.
         */
        if (hasStarted(self) && hasEnded(self)) {
            return startTimestamp(self) + duration(self) - block.timestamp;
        }
        else if (block.timestamp < startTimestamp(self)) {
            return duration(self);
        }
        else {
            return 0;
        }
    }

    /**
    * @dev Adds the signature of the sender to the multisignature transaction.
    * @param self The storage reference to the MultiSig struct.
    * @notice This function checks if the sender is a signer. If not, it reverts with an error indicating that the sender is not a signer.
    * If the sender is a signer, it adds the sender's address to the list of signatures.
    * After adding the signature, it checks if the transaction now has sufficient signatures to pass. 
    * If it does, it marks the transaction as passed.
    */
    function sign(MultiSig storage self) public {
        if (!isSigner(self, msg.sender)) {
            revert IsNotASigner(msg.sender);
        }
        if (hasSigned(self, msg.sender)) {
            revert HasAlreadySigned(msg.sender);
        }
        self.signatures.push(msg.sender);
        if (hasSufficientSignatures(self)) {
            self.hasPassed = true;
        }
    }

    /**
    * @dev Executes the multisignature transaction if it has passed.
    * @param self The storage reference to the MultiSig struct.
    * @notice This function checks if the multisignature transaction has passed. 
    * If it has not passed, it reverts with an error indicating that the transaction has not passed.
    * If the transaction has passed, it marks the transaction as executed.
    */
    function execute(MultiSig storage self) public {
        if (!hasPassed(self)) {
            revert HasNotPassed();
        }
        self.executed = true;
    }

    /**
    * @dev Public function to add a new signer to the multi-signature scheme.
    * @param self The storage reference to the MultiSig struct.
    * @param account The address of the account to add as a signer.
    * @notice This function checks if the provided account is already a signer. If it is, it reverts with an error indicating that the account is already a signer. If not, it adds the account to the list of signers.
    */
    function addSigner(MultiSig storage self, address account) public {
        if (isSigner(self, account)) {
            revert IsAlreadyASigner(account);
        }
        self.signers.push(account);
    }

    /**
    * @dev Public function to set the required quorum for the multi-signature scheme.
    * @param self The storage reference to the MultiSig struct.
    * @param bp The new quorum percentage to set, represented in basis points (bp).
    * @notice This function checks if the provided quorum percentage is within the valid range [0, 10000] (0% to 100%). If it is not, it reverts with an error indicating that the quorum percentage is out of bounds. If the percentage is within the valid range, it sets the required quorum for the multi-signature scheme.
    */
    function setRequiredQuorum(MultiSig storage self, uint256 bp) public {
        if (bp > 10000) {
            revert OutOfBounds(0, 10000, bp);
        }
        self.requiredQuorum = bp;
    }

    /**
    * @dev Public function to set the start timestamp of a timer.
    * @param self The Timer struct to be modified.
    * @param startTimestamp The new start timestamp to set.
    */
    function setStartTimestamp(MultiSig storage self, uint256 startTimestamp) public {
        self.startTimestamp = startTimestamp;
    }

    /**
    * @dev Public function to increase the start timestamp of a timer by a specified number of seconds.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to increase the start timestamp by.
    */
    function increaseStartTimestamp(MultiSig storage self, uint256 seconds_) public {
        self.startTimestamp += seconds_;
    }

    /**
    * @dev Public function to decrease the start timestamp of a timer by a specified number of seconds.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to decrease the start timestamp by.
    */
    function decreaseStartTimestamp(MultiSig storage self, uint256 seconds_) public {
        self.startTimestamp -= seconds_;
    }

    /**
    * @dev Public function to set the duration of a timer.
    * @param self The Timer struct to be modified.
    * @param duration The new duration to set.
    */
    function setDuration(MultiSig storage self, uint256 duration) public {
        self.duration = duration;
    }

    /**
    * @dev Public function to increase the duration of a timer by a specified value.
    * @param self The Timer struct to update.
    * @param seconds_ The amount to increase the duration by.
    */
    function increaseDuration(MultiSig storage self, uint256 seconds_) public {
        self.duration += seconds_;
    }

    /**
    * @dev Public function to decrease the duration of a timer by a specified value.
    * @param self The Timer struct to update.
    * @param seconds_ The amount to decrease the duration by.
    */
    function decreaseDuration(MultiSig storage self, uint256 seconds_) public {
        self.duration -= seconds_;
    }

    /**
    * @dev Public function to reset the start timestamp of a timer to the current block timestamp.
    * @param self The Timer struct to reset.
    */
    function reset(MultiSig storage self) public {
        self.startTimestamp = block.timestamp;
        delete self.signers;
        delete self.signatures;
        delete self.hasPassed;
        delete self.executed;
    }

    /**
    * @dev Public function to reset the start timestamp of a timer to the current block timestamp without clearing existing signatures.
    * @param self The storage reference to the MultiSig struct.
    * @notice This function resets the start timestamp of the multi-signature scheme to the current block timestamp, keeping any existing signatures intact.
    */
    function onlyResetTimer(MultiSig storage self) public {
        self.startTimestamp = block.timestamp;
    }

    /**
    * @dev Public function to reset the signers list of a multi-signature scheme.
    * @param self The storage reference to the MultiSig struct.
    * @notice This function clears the list of signers in the multi-signature scheme, removing all existing signers.
    */
    function onlyResetSigners(MultiSig storage self) public {
        delete self.signers;
    }

    /**
    * @dev Public function to reset the signatures list of a multi-signature scheme.
    * @param self The storage reference to the MultiSig struct.
    * @notice This function clears the list of signatures in the multi-signature scheme, removing all existing signatures.
    */
    function onlyResetSignatures(MultiSig storage self) public {
        delete self.signatures;
    }
}