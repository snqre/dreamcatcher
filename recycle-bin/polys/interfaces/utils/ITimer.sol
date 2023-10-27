// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ITimer {

    /**
    * @dev Returns the key for the start timestamp.
    */
    function startTimestampKey() external pure returns (bytes32);

    /**
    * @dev Returns the key for the duration.
    */
    function durationKey() external pure returns (bytes32);

    /**
    * @dev Returns the start timestamp.
    */
    function startTimestamp() external view returns (uint256);

    /**
    * @dev Returns the end timestamp.
    */
    function endTimestamp() external view returns (uint256);

    /**
    * @dev Returns the duration.
    */
    function duration() external view returns (uint256);

    /**
    * @dev Checks if the timer has started.
    */
    function started() external view returns (bool);

    /**
    * @dev Checks if the timer has ended.
    */
    function ended() external view returns (bool);

    /**
    * @dev Checks if the timer is actively counting.
    */
    function counting() external view returns (bool);

    /**
    * @dev Calculates the remaining seconds in the timer.
    */
    function secondsLeft() external view returns (uint256);
}