// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/libraries/shared/errors/Errors.sol";

/**
* WARNING: The timer feature on SaferLock is designed for longer timeframes
*          due to its dependence on block.timestamp using it in short term
*          timeframes will cause unexpected behaviour. The SaferLock
*          can be used to set a timeout to a lock such that it reduces the risk
*          of denial of service, it can be set for ie. 2 hours and once
*          the time is over and the function is called the lock will
*          ignore the locked status or unlocked status allowing access to the
*          function. It can also be reversed, ie. once the timer has ended
*          it will reset the timer.
*
* WARNING: Timer will not be accurate during short timeframes.
*
* SETTINGS: isTimed is required to access timer functionality.
*
* SETTINGS: onlyDuringTimer will enforce whenLocked and whenNotLocked function
*           only when the timer is counting. This means that if the timer has
*           not started or has ended it will not enforce this.
*
* SETTINGS: resetOnCompletion will delete all timer settings and flag isTimed
*           as false. This will disable all timer related function.
*
* SETTINGS: reverseOnCompletion will reset the timer to the current block.timestamp
*           and start the count again. It will also switch the lock
*           from locked to unlocked, or unlocked to locked.
 */
library SaferLock {

    /**
    * @notice Represents a lock with various configuration options.
    */
    struct Lock {
        bool _locked;
        uint256 _startTimestamp;
        uint256 _duration;
        bool _isTimed;
        bool _reverseOnCompletion;
        bool _resetOnCompletion;
        bool _onlyDuringTimer;
    }

    /**
    * @notice Retrieves the version of the lock.
    * @dev Returns a constant version number associated with the lock.
    * @param self The Lock struct to query.
    * @return The version of the lock.
    */
    function version(Lock storage self) public pure returns (uint256) {
        return 1;
    }

    /**
    * @notice Checks if the lock is currently in a locked state.
    * @dev Returns true if the lock is in a locked state, otherwise returns false.
    * @param self The Lock struct to query.
    * @return True if the lock is currently locked, false otherwise.
    */
    function locked(Lock storage self) public view returns (bool) {
        return self._locked;
    }

    /**
    * @notice Checks if the lock is configured to reverse on completion.
    * @dev Returns true if the lock is configured to reverse on completion, otherwise returns false.
    * @param self The Lock struct to query.
    * @return True if the lock is configured to reverse on completion, false otherwise.
    */
    function reverseOnCompletion(Lock storage self) public view returns (bool) {
        return self._reverseOnCompletion;
    }

    /**
    * @notice Checks if the lock is configured to reset on completion.
    * @dev Returns true if the lock is configured to reset on completion, otherwise returns false.
    * @param self The Lock struct to query.
    * @return True if the lock is configured to reset on completion, false otherwise.
    */
    function resetOnCompletion(Lock storage self) public view returns (bool) {
        return self._resetOnCompletion;
    }

    /**
    * @notice Checks if certain operations are allowed only during the timer.
    * @dev Returns true if certain operations are allowed only during the timer, otherwise returns false.
    * @param self The Lock struct to query.
    * @return True if certain operations are allowed only during the timer, false otherwise.
    */
    function onlyDuringTimer(Lock storage self) public view returns (bool) {
        return self._onlyDuringTimer;
    }

    /**
    * @notice Modifier to ensure that certain operations are allowed only when the lock is not in a locked state.
    * @dev Checks if the lock is timed, allows operations only during the timer if configured,
    *      and verifies that the lock is not in a locked state.
    * @param self The Lock struct to query.
    */
    function whenNotLocked(Lock storage self) public view {
        if (isTimed({self: self}) && onlyDuringTimer({self: self}) && isCounting({self: self})) {
            if (locked({self: self})) {
                revert Errors.IsLocked();
            }
        }
        else {
            if (locked({self: self})) {
                revert Errors.IsLocked();
            }
        }
    }

    /**
    * @notice Modifier to ensure that certain operations are allowed only when the lock is in a locked state.
    * @dev Checks if the lock is timed, allows operations only during the timer if configured,
    *      and verifies that the lock is in a locked state.
    * @param self The Lock struct to query.
    */
    function whenLocked(Lock storage self) public view {
        if (isTimed({self: self}) && onlyDuringTimer({self: self}) && isCounting({self: self})) {
            if (!locked({self: self})) {
                revert Errors.IsNotLocked();
            }
        }
        else {
            if (!locked({self: self})) {
                revert Errors.IsNotLocked();
            }           
        }
    }

    /**
    * @notice Locks the specified lock.
    * @dev Sets the locked state of the lock to true.
    * @param self The Lock struct to update.
    */
    function lock(Lock storage self) public {
        self._locked = true;
    }

    /**
    * @notice Unlocks the specified lock.
    * @dev Sets the locked state of the lock to false.
    * @param self The Lock struct to update.
    */
    function unlock(Lock storage self) public {
        self._locked = false;
    }

    /**
    * @notice Sets the only during timer configuration for the lock.
    * @dev Allows updating the flag indicating whether certain operations are allowed only during the timer.
    * @param self The Lock struct to update.
    * @param boolean The boolean value to set for the only during timer configuration.
    */
    function setOnlyDuringTimer(Lock storage self, bool boolean) public {
        self._onlyDuringTimer = boolean;
    }

    /**
    * @notice Updates the lock based on its configuration.
    * @dev Checks if the lock is timed, and if configured to reverse or reset on completion, and whether it has ended.
    *      If configured to reverse on completion and has ended, it resets the timer and toggles the lock state.
    *      If configured to reset on completion and has ended, it sets the lock as non-timed and clears the timer values.
    * @param self The Lock struct to update.
    */
    function update(Lock storage self) public {
        if (isTimed({self: self}) && reverseOnCompletion({self: self}) && hasEnded({self: self})) {
            resetTimer({self: self});
            if (locked({self: self})) {
                unlock({self: self});
            }
            else {
                lock({self: self});
            }
        }
        if (isTimed({self: self}) && resetOnCompletion({self: self}) && hasEnded({self: self})) {
            setTimed({self: self, boolean: false});
            delete self._startTimestamp;
            delete self._duration;
        }
    }

    /** Timer */

    /**
    * @notice Retrieves the start timestamp of the lock.
    * @dev Returns the start timestamp if the lock is timed, otherwise returns 0.
    * @param self The Lock struct to query.
    * @return The start timestamp of the lock.
    */
    function startTimestamp(Lock storage self) public view returns (uint256) {
        if (isTimed({self: self})) {
            return self._startTimestamp;
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Retrieves the end timestamp of the lock.
    * @dev Returns the end timestamp if the lock is timed, otherwise returns 0.
    * @param self The Lock struct to query.
    * @return The end timestamp of the lock.
    */
    function endTimestamp(Lock storage self) public view returns (uint256) {
        if (isTimed({self: self})) {
            return startTimestamp({self: self}) + duration({self: self});
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Retrieves the duration of the lock.
    * @dev Returns the duration if the lock is timed, otherwise returns 0.
    * @param self The Lock struct to query.
    * @return The duration of the lock.
    */
    function duration(Lock storage self) public view returns (uint256) {
        if (isTimed({self: self})) {
            return self._duration;
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Checks if the lock has started.
    * @dev Returns true if the lock is timed and the current block timestamp is greater than or equal to the start timestamp, otherwise returns false.
    * @param self The Lock struct to query.
    * @return True if the lock has started, false otherwise.
    */
    function hasStarted(Lock storage self) public view returns (bool) {
        if (isTimed({self: self})) {
            return block.timestamp >= startTimestamp({self: self});
        }
        else {
            return false;
        }
    }

    /**
    * @notice Checks if the lock has ended.
    * @dev Returns true if the lock is timed and the current block timestamp is greater than or equal to the end timestamp, otherwise returns false.
    * @param self The Lock struct to query.
    * @return True if the lock has ended, false otherwise.
    */
    function hasEnded(Lock storage self) public view returns (bool) {
        if (isTimed({self: self})) {
            return block.timestamp >= endTimestamp({self: self});
        }
        else {
            return false;
        }
    }

    /**
    * @notice Checks if the lock is currently counting.
    * @dev Returns true if the lock is timed, has started, and has not ended, otherwise returns false.
    * @param self The Lock struct to query.
    * @return True if the lock is counting, false otherwise.
    */
    function isCounting(Lock storage self) public view returns (bool) {
        if (isTimed({self: self})) {
            return hasStarted({self: self}) && !hasEnded({self: self});
        }
        else {
            return false;
        }
    }

    /**
    * @notice Calculates the remaining seconds of the lock.
    * @dev Returns the remaining seconds if the lock is timed and counting, the total duration if not started, and 0 if not timed.
    * @param self The Lock struct to query.
    * @return The remaining seconds of the lock.
    */
    function secondsLeft(Lock storage self) public view returns (uint256) {
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
    * @notice Checks if the lock is timed.
    * @dev Returns true if the lock is configured as timed, otherwise returns false.
    * @param self The Lock struct to query.
    * @return True if the lock is timed, false otherwise.
    */
    function isTimed(Lock storage self) public view returns (bool) {
        return self._isTimed;
    }

    /**
    * @notice Sets the start timestamp for the lock.
    * @dev Allows updating the start timestamp value for a timed lock.
    * @param self The Lock struct to update.
    * @param timestamp The new start timestamp value to set.
    */
    function setStartTimestamp(Lock storage self, uint256 timestamp) public {
        self._startTimestamp = timestamp;
    }

    /**
    * @notice Increases the start timestamp for the lock.
    * @dev Allows increasing the start timestamp value for a timed lock.
    * @param self The Lock struct to update.
    * @param seconds_ The number of seconds to increase the start timestamp.
    */
    function increaseStartTimestamp(Lock storage self, uint256 seconds_) public {
        self._startTimestamp += seconds_;
    }

    /**
    * @notice Decreases the start timestamp for the lock.
    * @dev Allows decreasing the start timestamp value for a timed lock.
    * @param self The Lock struct to update.
    * @param seconds_ The number of seconds to decrease the start timestamp.
    */
    function decreaseStartTimestamp(Lock storage self, uint256 seconds_) public {
        self._startTimestamp -= seconds_;
    }

    /**
    * @notice Sets the duration for the lock.
    * @dev Allows updating the duration value for a timed lock.
    * @param self The Lock struct to update.
    * @param seconds_ The new duration value to set.
    */
    function setDuration(Lock storage self, uint256 seconds_) public {
        self._duration = seconds_;
    }

    /**
    * @notice Increases the duration for the lock.
    * @dev Allows increasing the duration value for a timed lock.
    * @param self The Lock struct to update.
    * @param seconds_ The number of seconds to increase the duration.
    */
    function increaseDuration(Lock storage self, uint256 seconds_) public {
        self._duration += seconds_;
    }

    /**
    * @notice Decreases the duration for the lock.
    * @dev Allows decreasing the duration value for a timed lock.
    * @param self The Lock struct to update.
    * @param seconds_ The number of seconds to decrease the duration.
    */
    function decreaseDuration(Lock storage self, uint256 seconds_) public {
        self._duration -= seconds_;
    }

    /**
    * @notice Sets the timed configuration for the lock.
    * @dev Allows updating the flag indicating whether the lock is configured as timed.
    * @param self The Lock struct to update.
    * @param boolean The boolean value to set for the timed configuration.
    */
    function setTimed(Lock storage self, bool boolean) public {
        self._isTimed = boolean;
    }

    /**
    * @notice Resets the timer for the lock.
    * @dev Sets the start timestamp to the current block timestamp.
    * @param self The Lock struct to update.
    */
    function resetTimer(Lock storage self) public {
        self._startTimestamp = block.timestamp;
    }
}