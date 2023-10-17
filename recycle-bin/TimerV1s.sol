// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title TimerV1
 * @dev A library for managing timers with start timestamps and durations.
 */
library TimerV1 {

    /**
    * @dev Structure representing a timer with a start timestamp and duration.
    */
    struct Timer {
        uint256 startTimestamp;
        uint256 duration;
    }

    /**
    * @dev Public pure function to get the start timestamp of a timer.
    * @param self The Timer struct.
    * @return uint256 representing the start timestamp of the timer.
    */
    function startTimestamp(Timer memory self) public pure returns (uint256) {
        return self.startTimestamp;
    }

    /**
    * @dev Public pure function to get the end timestamp of a timer.
    * @param self The Timer struct.
    * @return uint256 representing the end timestamp of the timer.
    */
    function endTimestamp(Timer memory self) public pure returns (uint256) {
        return startTimestamp(self) + duration(self);
    }

    /**
    * @dev Public pure function to get the duration of a timer.
    * @param self The Timer struct.
    * @return uint256 representing the duration of the timer.
    */
    function duration(Timer memory self) public pure returns (uint256) {
        return self.duration;
    }

    /**
    * @dev Public view function to check if a timer has started.
    * @param self The Timer struct to check.
    * @return bool indicating whether the timer has started.
    */
    function hasStarted(Timer memory self) public view returns (bool) {
        return block.timestamp >= startTimestamp(self);
    }

    /**
    * @dev Public view function to check if a timer has ended.
    * @param self The Timer struct to check.
    * @return bool indicating whether the timer has ended.
    */
    function hasEnded(Timer memory self) public view returns (bool) {
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
    function secondsLeft(Timer memory self) public view returns (uint256) {
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
    * @dev Public function to set the start timestamp of a timer.
    * @param self The Timer struct to be modified.
    * @param startTimestamp The new start timestamp to set.
    */
    function setStartTimestamp(Timer storage self, uint256 startTimestamp) public {
        self.startTimestamp = startTimestamp;
    }

    /**
    * @dev Public function to increase the start timestamp of a timer by a specified number of seconds.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to increase the start timestamp by.
    */
    function increaseStartTimestamp(Timer storage self, uint256 seconds_) public {
        self.startTimestamp += seconds_;
    }

    /**
    * @dev Public function to decrease the start timestamp of a timer by a specified number of seconds.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to decrease the start timestamp by.
    */
    function decreaseStartTimestamp(Timer storage self, uint256 seconds_) public {
        self.startTimestamp -= seconds_;
    }

    /**
    * @dev Public function to set the duration of a timer.
    * @param self The Timer struct to be modified.
    * @param duration The new duration to set.
    */
    function setDuration(Timer storage self, uint256 duration) public {
        self.duration = duration;
    }

    /**
    * @dev Public function to increase the duration of a timer by a specified value.
    * @param self The Timer struct to update.
    * @param seconds_ The amount to increase the duration by.
    */
    function increaseDuration(Timer storage self, uint256 seconds_) public {
        self.duration += seconds_;
    }

    /**
    * @dev Public function to decrease the duration of a timer by a specified value.
    * @param self The Timer struct to update.
    * @param seconds_ The amount to decrease the duration by.
    */
    function decreaseDuration(Timer storage self, uint256 seconds_) public {
        self.duration -= seconds_;
    }

    /**
    * @dev Public function to reset the start timestamp of a timer to the current block timestamp.
    * @param self The Timer struct to reset.
    */
    function reset(Timer storage self) public {
        self.startTimestamp = block.timestamp;
    }
}