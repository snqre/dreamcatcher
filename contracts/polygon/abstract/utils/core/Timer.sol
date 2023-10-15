// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

abstract contract Timer {

    /**
    * @dev Private variable to store the starting timestamp of the timer.
    */
    uint256 private _startTimestamp;

    /**
    * @dev Private variable to store the duration of the timer in seconds.
    */
    uint256 private _duration;

    /**
    * @notice Gets the start timestamp.
    * @dev Returns the start timestamp value.
    * @return uint256 The start timestamp value.
    */
    function startTimestamp() public view virtual returns (uint256) {
        return _startTimestamp;
    }

    /**
    * @notice Gets the end timestamp.
    * @dev Returns the calculated end timestamp based on the start timestamp and duration.
    * @return uint256 The end timestamp value.
    */
    function endTimestamp() public view virtual returns (uint256) {
        return startTimestamp() + duration();
    }

    /**
    * @notice Gets the duration.
    * @dev Returns the duration value.
    * @return uint256 The duration value.
    */
    function duration() public view virtual returns (uint256) {
        return _duration;
    }

    /**
    * @notice Checks if the timer has started.
    * @dev Returns a boolean indicating whether the timer has started.
    * @return bool True if the timer has started, false otherwise.
    */
    function hasStarted() public view virtual returns (bool) {
        return block.timestamp >= startTimestamp();
    }

    /**
    * @notice Checks if the timer has ended.
    * @dev Returns a boolean indicating whether the timer has ended.
    * @return bool True if the timer has ended, false otherwise.
    */
    function hasEnded() public view virtual returns (bool) {
        return block.timestamp >= endTimestamp();
    }

    /**
    * @notice Checks if the timer is currently counting.
    * @dev Returns a boolean indicating whether the timer is counting.
    * @return bool True if the timer is counting, false otherwise.
    */
    function counting() public view virtual returns (bool) {
        return hasStarted() && !hasEnded();
    }

    /**
    * @notice Gets the remaining seconds in the timer.
    * @dev If the timer is currently counting, returns the remaining seconds until it ends.
    *      If the timer has not started yet, returns the total duration.
    *      If the timer has already ended, returns 0.
    * @return uint256 Remaining seconds in the timer.
    */
    function secondsLeft() public view returns (uint256) {
        if (counting()) {
            return endTimestamp() - block.timestamp;
        }
        else if (!hasStarted()) {
            return duration();
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Sets the start timestamp of the timer.
    * @dev Internal function to update the start timestamp.
    * @param timestamp The new start timestamp to set.
    */
    function _setStartTimestamp(uint256 timestamp) internal virtual {
        _startTimestamp = timestamp;
    }

    /**
    * @notice Increases the start timestamp of the timer.
    * @dev Internal function to add seconds to the current start timestamp.
    * @param seconds_ The number of seconds to add to the start timestamp.
    */
    function _increaseStartTimestamp(uint256 seconds_) internal virtual {
        _startTimestamp += seconds_;
    }

    /**
    * @notice Decreases the start timestamp of the timer.
    * @dev Internal function to subtract seconds from the current start timestamp.
    * @param seconds_ The number of seconds to subtract from the start timestamp.
    */
    function _decreaseStartTimestamp(uint256 seconds_) internal virtual {
        _startTimestamp -= seconds_;
    }

    /**
    * @notice Sets the duration of the timer.
    * @dev Internal function to set the duration of the timer.
    * @param seconds_ The new duration in seconds.
    */
    function _setDuration(uint256 seconds_) internal virtual {
        _duration = seconds_;
    }

    /**
    * @notice Increases the duration of the timer.
    * @dev Internal function to increase the duration of the timer.
    * @param seconds_ The amount by which to increase the duration in seconds.
    */
    function _increaseDuration(uint256 seconds_) internal virtual {
        _duration += seconds_;
    }

    /**
    * @notice Decreases the duration of the timer.
    * @dev Internal function to decrease the duration of the timer.
    * @param seconds_ The amount by which to decrease the duration in seconds.
    */
    function _decreaseDuration(uint256 seconds_) internal virtual {
        _duration -= seconds_;
    }
}