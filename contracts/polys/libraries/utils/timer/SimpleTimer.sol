// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

library SimpleTimer {

    /**
    * @title Timer
    * @notice A smart contract struct representing a timer with a start timestamp and a duration.
    * @dev This struct is designed to be used within a smart contract to manage time-related functionality.
    */
    struct Timer {
        uint256 _startTimestamp;
        uint256 _duration;
    }

    /**
    * @notice Returns the version of the Timer smart contract.
    * @dev Provides the current version number of the Timer smart contract.
    * @return The version number.
    */
    function version(Timer storage self) public pure returns (uint256) {
        return 1;
    }

    /**
    * @notice Retrieves the start timestamp of a Timer.
    * @param self The Timer struct to query.
    * @return The timestamp when the timer started.
    */
    function startTimestamp(Timer storage self) public view returns (uint256) {
        return self._startTimestamp;
    }

    /**
    * @notice Calculates and returns the end timestamp of a Timer.
    * @dev Uses the start timestamp and duration to determine the end timestamp.
    * @param self The Timer struct to calculate the end timestamp for.
    * @return The timestamp when the timer is expected to end.
    */
    function endTimestamp(Timer storage self) public view returns (uint256) {
        return startTimestamp({self: self}) + duration({self: self});
    }

    /**
    * @notice Retrieves the duration of a Timer.
    * @param self The Timer struct to query.
    * @return The duration of the timer in seconds.
    */
    function duration(Timer storage self) public view returns (uint256) {
        return self._duration;
    }

    /**
    * @notice Checks whether the Timer has started.
    * @dev Compares the current block timestamp with the start timestamp of the Timer.
    * @param self The Timer struct to check.
    * @return True if the Timer has started, false otherwise.
    */
    function hasStarted(Timer storage self) public view returns (bool) {
        return block.timestamp >= startTimestamp({self: self});
    }

    /**
    * @notice Checks whether the Timer has ended.
    * @dev Compares the current block timestamp with the calculated end timestamp of the Timer.
    * @param self The Timer struct to check.
    * @return True if the Timer has ended, false otherwise.
    */
    function hasEnded(Timer storage self) public view returns (bool) {
        return block.timestamp >= endTimestamp({self: self});
    }

    /**
    * @notice Checks whether the Timer is currently counting.
    * @dev Returns true if the Timer has started and has not yet ended.
    * @param self The Timer struct to check.
    * @return True if the Timer is counting, false otherwise.
    */
    function isCounting(Timer storage self) public view returns (bool) {
        return hasStarted({self: self}) && !hasEnded({self: self});
    }

    /**
    * @notice Calculates the remaining seconds of the Timer.
    * @dev Returns the remaining time if the Timer is currently counting,
    *      the total duration if the Timer has not started, and 0 if the Timer has ended.
    * @param self The Timer struct to calculate remaining seconds for.
    * @return The remaining seconds on the Timer.
    */
    function secondsLeft(Timer storage self) public view returns (uint256) {
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

    /**
    * @notice Sets the start timestamp of the Timer.
    * @dev Allows updating the start timestamp of the Timer.
    * @param self The Timer struct to update.
    * @param timestamp The new start timestamp to set.
    */
    function setStartTimestamp(Timer storage self, uint256 timestamp) public {
        self._startTimestamp = timestamp;
    }

    /**
    * @notice Increases the start timestamp of the Timer by a specified number of seconds.
    * @dev Allows advancing the start timestamp of the Timer.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to increase the start timestamp by.
    */
    function increaseStartTimestamp(Timer storage self, uint256 seconds_) public {
        self._startTimestamp += seconds_;
    }

    /**
    * @notice Decreases the start timestamp of the Timer by a specified number of seconds.
    * @dev Allows moving back the start timestamp of the Timer.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to decrease the start timestamp by.
    */
    function decreaseStartTimestamp(Timer storage self, uint256 seconds_) public {
        self._startTimestamp -= seconds_;
    }

    /**
    * @notice Sets the duration of the Timer.
    * @dev Allows updating the duration of the Timer.
    * @param self The Timer struct to update.
    * @param seconds_ The new duration to set in seconds.
    */
    function setDuration(Timer storage self, uint256 seconds_) public {
        self._duration = seconds_;
    }

    /**
    * @notice Increases the duration of the Timer by a specified number of seconds.
    * @dev Allows extending the duration of the Timer.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to increase the duration by.
    */
    function increaseDuration(Timer storage self, uint256 seconds_) public {
        self._duration += seconds_;
    }

    /**
    * @notice Decreases the duration of the Timer by a specified number of seconds.
    * @dev Allows shortening the duration of the Timer.
    * @param self The Timer struct to update.
    * @param seconds_ The number of seconds to decrease the duration by.
    */
    function decreaseDuration(Timer storage self, uint256 seconds_) public {
        self._duration -= seconds_;
    }

    /**
    * @notice Resets the Timer to its initial state by clearing start timestamp and duration.
    * @dev Allows resetting the Timer by removing the start timestamp and duration.
    * @param self The Timer struct to reset.
    */
    function reset(Timer storage self) public {
        self._startTimestamp = block.timestamp;
    }
}