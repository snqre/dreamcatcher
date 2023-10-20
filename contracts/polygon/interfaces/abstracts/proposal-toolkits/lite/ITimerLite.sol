// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ITimerLite {
    event StartTimestampUpdated(uint indexed previousTimestamp, uint indexed newTimestamp);

    event DurationUpdated(uint indexed previousSeconds, uint indexed newSeconds);

    function startTimestamp() external view returns (uint);

    function duration() external view returns (uint);

    function endTimestamp() external view returns (uint);

    function started() external view returns (bool);

    function ended() external view returns (bool);

    function ticking() external view returns (bool);

    function secondsLeft() external view returns (uint);
}