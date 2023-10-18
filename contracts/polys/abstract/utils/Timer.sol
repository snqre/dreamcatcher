// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";

/**
* startTimestampKey => uint256
* durationKey => uint256
 */
abstract contract Timer is Storage {

    /**
    * @dev Returns the key for the start timestamp.
    */
    function startTimestampKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("START_TIMESTAMP"));
    }

    /**
    * @dev Returns the key for the duration.
    */
    function durationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DURATION"));
    }

    /**
    * @dev Returns the start timestamp.
    */
    function startTimestamp() public view virtual returns (uint256) {
        return _uint256[startTimestampKey()];
    }

    /**
    * @dev Returns the end timestamp.
    */
    function endTimestamp() public view virtual returns (uint256) {
        return startTimestamp() + duration();
    }

    /**
    * @dev Returns the duration.
    */
    function duration() public view virtual returns (uint256) {
        return _uint256[durationKey()];
    }

    /**
    * @dev Checks if the timer has started.
    */
    function started() public view virtual returns (bool) {
        return block.timestamp >= startTimestamp();
    }

    /**
    * @dev Checks if the timer has ended.
    */
    function ended() public view virtual returns (bool) {
        return block.timestamp >= endTimestamp();
    }

    /**
    * @dev Checks if the timer is actively counting.
    */
    function counting() public view virtual returns (bool) {
        return started() && !ended();
    }

    /**
    * @dev Calculates the remaining seconds in the timer.
    */
    function secondsLeft() public view virtual returns (uint256) {
        if (counting()) {
            return endTimestamp() - block.timestamp;
        }
        else if (started()) {
            return duration();
        }
        else {
            return 0;
        }
    }

    /**
    * @dev Sets the start timestamp for the timer.
    * @param timestamp The new start timestamp.
    */
    function _setStartTimestamp(uint256 timestamp) internal virtual {
        _uint256[startTimestampKey()] = timestamp;
    }

    /**
    * @dev Sets the duration for the timer.
    * @param seconds_ The new duration in seconds.
    */
    function _setDuration(uint256 seconds_) internal virtual {
        _uint256[durationKey()] = seconds_;
    }
}