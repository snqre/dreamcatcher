// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/interfaces/token/dream/IDream.sol";

/**
 * @title ReferendumV1
 * @dev A library for managing governance referendums.
 */
library ReferendumV1 {

    /**
    * @dev Error indicating that the account has an insufficient balance at the snapshot.
    */
    error InsufficientBalanceAtSnapshot(address account);

    /**
    * @dev Error indicating that the account has already voted.
    */
    error HasAlreadyVoted(address account);

    /**
    * @dev Error indicating that the multisignature transaction has not passed.
    */
    error HasNotPassed();

    /**
    * @dev Error indicating that the provided value is outside the specified bounds.
    * @param min The minimum allowed value.
    * @param max The maximum allowed value.
    * @param value The value that is outside the allowed bounds.
    */
    error OutOfBounds(uint256 min, uint256 max, uint256 value);

    /**
    * @dev Structure representing a governance referendum.
    */
    struct Referendum {
        uint256 startTimestamp;
        uint256 duration;
        address votingERC20;
        uint256 snapshotId;
        address[] voters;
        uint256 support;
        uint256 against;
        uint256 abstain;
        uint256 requiredQuorum;
        uint256 requiredThreshold;
        uint256 minBalanceToVote;
        bool hasPassed;
        bool executed;
    }

    /**
    * @dev Public pure function to get the start timestamp of a referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the start timestamp of the referendum.
    */
    function startTimestamp(Referendum memory self) public pure returns (uint256) {
        return self.startTimestamp;
    }

    /**
    * @dev Public pure function to get the end timestamp of a referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the end timestamp of the referendum.
    */
    function endTimestamp(Referendum memory self) public pure returns (uint256) {
        return startTimestamp(self) + duration(self);
    }

    /**
    * @dev Public pure function to get the duration of a referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the duration of the referendum.
    */
    function duration(Referendum memory self) public pure returns (uint256) {
        return self.duration;
    }

    /**
    * @dev Public pure function to get the ERC20 token used for voting in a referendum.
    * @param self The Referendum struct.
    * @return address representing the ERC20 token address.
    */
    function votingERC20(Referendum memory self) public pure returns (address) {
        return self.votingERC20;
    }

    /**
    * @dev Public pure function to get the snapshot ID used for voting in a referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the snapshot ID.
    */
    function snapshotId(Referendum memory self) public pure returns (uint256) {
        return self.snapshotId;
    }

    /**
    * @dev Retrieves the address of a voter at the specified index in the Referendum struct.
    * @param self The Referendum struct.
    * @param id The index of the voter.
    * @return address representing the voter's address.
    */
    function voters(Referendum memory self, uint256 id) public pure returns (address) {
        return self.voters[id];
    }

    /**
    * @dev Retrieves the number of voters in the Referendum struct.
    * @param self The Referendum struct.
    * @return uint256 representing the number of voters.
    */
    function votersLength(Referendum memory self) public pure returns (uint256) {
        return self.voters.length;
    }

    /**
    * @dev Checks whether an account has voted in the referendum.
    * @param self The Referendum struct.
    * @param account The address to check for voting status.
    * @return bool indicating whether the account has voted.
    */
    function hasVoted(Referendum memory self, address account) public pure returns (bool) {
        /** 
        * WARNING: This is not suitable for large amounts of voters.
        *          But for 1.0.0 we dont anticipate too many voters.
        *          This will be upgradeed in the future.
         */
        bool hasVoted;
        for (uint256 i = 0; i < votersLength(self); i++) {
            if (voters(self, i) == account) {
                hasVoted = true;
                break;
            }
        }
        return hasVoted;
    }

    /**
    * @dev Retrieves the support count for the referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the number of votes in support.
    */
    function support(Referendum memory self) public pure returns (uint256) {
        return self.support;
    }

    /**
    * @dev Retrieves the against count for the referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the number of votes against.
    */
    function against(Referendum memory self) public pure returns (uint256) {
        return self.against;
    }

    /**
    * @dev Retrieves the abstain count for the referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the number of abstain votes.
    */
    function abstain(Referendum memory self) public pure returns (uint256) {
        return self.abstain;
    }

    /**
    * @dev Retrieves the total number of votes cast in the referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the total number of votes cast.
    */
    function quorum(Referendum memory self) public pure returns (uint256) {
        return support(self) + against(self) + abstain(self);
    }

    /**
    * @dev Retrieves the required quorum percentage for the referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the required quorum percentage.
    */
    function requiredQuorum(Referendum memory self) public pure returns (uint256) {
        return self.requiredQuorum;
    }

    /**
    * @dev Retrieves the number of required votes based on the quorum percentage.
    * @param self The Referendum struct.
    * @return uint256 representing the required number of votes.
    */
    function requiredVotes(Referendum memory self) public pure returns (uint256) {
        return (quorum(self) * requiredQuorum(self)) / 10000;
    }

    /**
    * @dev Checks if the Referendum struct has sufficient votes.
    * @param self The Referendum struct.
    * @return bool indicating whether there are sufficient votes.
    */
    function hasSufficientVotes(Referendum memory self) public pure returns (bool) {
        return quorum(self) >= requiredVotes(self);
    }

    /**
    * @dev Retrieves the required threshold percentage for the Referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the required threshold percentage.
    */
    function requiredThreshold(Referendum memory self) public pure returns (uint256) {
        return self.requiredThreshold;
    }

    /**
    * @dev Retrieves the current support threshold percentage for the Referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the current support threshold percentage.
    */
    function threshold(Referendum memory self) public pure returns (uint256) {
        return (support(self) * 10000) / quorum(self);
    }

    /**
    * @dev Checks if the Referendum struct has sufficient support threshold.
    * @param self The Referendum struct.
    * @return bool indicating whether the support threshold is sufficient.
    */
    function hasSufficientThreshold(Referendum memory self) public pure returns (bool) {
        return threshold(self) >= requiredThreshold(self);
    }

    /**
    * @dev Retrieves the minimum balance required to vote in the Referendum.
    * @param self The Referendum struct.
    * @return uint256 representing the minimum balance required to vote.
    */
    function minBalanceToVote(Referendum memory self) public pure returns (uint256) {
        return self.minBalanceToVote;
    }

    /**
    * @dev Checks whether the Referendum has passed.
    * @param self The Referendum struct to check.
    * @return bool indicating whether the Referendum has passed.
    */
    function hasPassed(Referendum memory self) public pure returns (bool) {
        return self.hasPassed;
    }

    /**
    * @dev Public view function to check if a Referendum has started.
    * @param self The Referendum struct to check.
    * @return bool indicating whether the Referendum has started.
    */
    function hasStarted(Referendum memory self) public view returns (bool) {
        return block.timestamp >= startTimestamp(self);
    }

    /**
    * @dev Public view function to check if a Referendum has ended.
    * @param self The Referendum struct to check.
    * @return bool indicating whether the Referendum has ended.
    */
    function hasEnded(Referendum memory self) public view returns (bool) {
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
    function secondsLeft(Referendum memory self) public view returns (uint256) {
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
    * @dev Checks if an account is a voter in the Referendum.
    * @param self The Referendum struct.
    * @param account The address to check for voter status.
    * @return bool indicating whether the account is a voter.
    */
    function isVoter(Referendum memory self, address account) public view returns (bool) {
        uint256 balance;
        IDream token = IDream(votingERC20(self));
        balance = token.balanceOfAt(account, snapshotId(self));
        if (balance < minBalanceToVote(self)) { return false; }
        else { return true; }
    }

    /**
    * @dev Adds the vote of the sender to the Referendum.
    * @param self The storage reference to the Referendum struct.
    * @param side The side of the vote (0: abstain, 1: against, 2: support).
    * @notice This function checks if the sender is a voter and has not already voted. 
    * If the sender is not a voter, it reverts with an error indicating insufficient balance.
    * If the sender has already voted, it reverts with an error indicating that the sender has already voted.
    * If the conditions are met, it adds the sender's address to the list of voters and updates the vote counts.
    * After adding the vote, it checks if the referendum now has sufficient votes and sufficient threshold to pass. 
    * If it does, it marks the referendum as passed.
    */
    function vote(Referendum storage self, uint256 side) public {
        if (!isVoter(self, msg.sender)) {
            revert InsufficientBalanceAtSnapshot(msg.sender);
        }
        if (hasVoted(self, msg.sender)) {
            revert HasAlreadyVoted(msg.sender);
        }
        self.voters.push(msg.sender);
        IDream token = IDream(votingERC20(self));
        uint256 balance = token.balanceOfAt(msg.sender, snapshotId(self));
        if (side == 0) {
            self.abstain += balance;
        }
        else if (side == 1) {
            self.against += balance;
        }
        else if (side == 2) {
            self.support += balance;
        }
        if (hasSufficientVotes(self) && hasSufficientThreshold(self)) {
            self.hasPassed = true;
        }
    }

    /**
    * @dev Executes the referendum if it has passed.
    * @param self The storage reference to the Referendum struct.
    * @notice This function checks if the referendum has passed. 
    * If it has not passed, it reverts with an error indicating that the referendum has not passed.
    * If the referendum has passed, it marks the referendum as executed.
    */
    function execute(Referendum storage self) public {
        if (!hasPassed(self)) {
            revert HasNotPassed();
        }
        self.executed = true;
    }

    /**
    * @dev Sets the required quorum percentage for the referendum.
    * @param self The storage reference to the Referendum struct.
    * @param bp The new required quorum percentage to set.
    * @notice This function sets the required quorum for the referendum. 
    * It checks if the provided percentage is within bounds (0 to 10000, inclusive). 
    * If not, it reverts with an error indicating the out-of-bounds condition.
    */
    function setRequiredQuorum(Referendum storage self, uint256 bp) public {
        if (bp > 10000) {
            revert OutOfBounds(0, 10000, bp);
        }
        self.requiredQuorum = bp;
    }

    /**
    * @dev Sets the required threshold percentage for the referendum.
    * @param self The storage reference to the Referendum struct.
    * @param bp The new required threshold percentage to set.
    * @notice This function sets the required threshold for the referendum. 
    * It checks if the provided percentage is within bounds (0 to 10000, inclusive). 
    * If not, it reverts with an error indicating the out-of-bounds condition.
    */
    function setRequiredThreshold(Referendum storage self, uint256 bp) public {
        if (bp > 10000) {
            revert OutOfBounds(0, 10000, bp);
        }
        self.requiredThreshold = bp;
    }

    /**
    * @dev Sets the minimum balance required to participate in the referendum.
    * @param self The storage reference to the Referendum struct.
    * @param balance The new minimum balance to set.
    * @notice This function sets the minimum balance required to vote in the referendum. 
    * It updates the `minBalanceToVote` parameter in the storage.
    */
    function setMinBalanceToVote(Referendum storage self, uint256 balance) public {
        self.minBalanceToVote = balance;
    }

    /**
    * @dev Public function to set the start timestamp of a timer.
    * @param self The Timer struct to be modified.
    * @param startTimestamp The new start timestamp to set.
    */
    function setStartTimestamp(Referendum storage self, uint256 startTimestamp) public {
        self.startTimestamp = startTimestamp;
    }

    /**
    * @dev Public function to increase the start timestamp of a timer by a specified number of seconds.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to increase the start timestamp by.
    */
    function increaseStartTimestamp(Referendum storage self, uint256 seconds_) public {
        self.startTimestamp += seconds_;
    }

    /**
    * @dev Public function to decrease the start timestamp of a timer by a specified number of seconds.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to decrease the start timestamp by.
    */
    function decreaseStartTimestamp(Referendum storage self, uint256 seconds_) public {
        self.startTimestamp -= seconds_;
    }

    /**
    * @dev Public function to set the duration of a timer.
    * @param self The Timer struct to be modified.
    * @param duration The new duration to set.
    */
    function setDuration(Referendum storage self, uint256 duration) public {
        self.duration = duration;
    }

    /**
    * @dev Public function to increase the duration of a timer by a specified value.
    * @param self The Timer struct to update.
    * @param seconds_ The amount to increase the duration by.
    */
    function increaseDuration(Referendum storage self, uint256 seconds_) public {
        self.duration += seconds_;
    }

    /**
    * @dev Public function to decrease the duration of a timer by a specified value.
    * @param self The Timer struct to update.
    * @param seconds_ The amount to decrease the duration by.
    */
    function decreaseDuration(Referendum storage self, uint256 seconds_) public {
        self.duration -= seconds_;
    }

    /**
    * @dev Public function to reset the start timestamp of a timer to the current block timestamp.
    * @param self The Timer struct to reset.
    */
    function reset(Referendum storage self) public {
        self.startTimestamp = block.timestamp;
        delete self.voters;
        delete self.support;
        delete self.against;
        delete self.abstain;
        delete self.hasPassed;
        delete self.executed;
    }

    /**
    * @dev Only resets the start timestamp of the referendum to the current block timestamp.
    * @param self The storage reference to the Referendum struct.
    * @notice This function resets the start timestamp of the referendum to the current block timestamp.
    * It does not perform any other operations.
    */
    function onlyResetTimer(Referendum storage self) public {
        self.startTimestamp = block.timestamp;
    }

    /**
    * @dev Only resets the votes-related properties of the referendum.
    * @param self The storage reference to the Referendum struct.
    * @notice This function deletes the list of voters and resets the vote counts for support, against, and abstain to zero.
    * It does not perform any other operations.
    */
    function onlyResetVotes(Referendum storage self) public {
        delete self.voters;
        delete self.support;
        delete self.against;
        delete self.abstain;
    }
}