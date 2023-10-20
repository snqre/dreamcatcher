// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract TimerLite is StorageLite {

    event StartTimestampUpdated(uint indexed previousTimestamp, uint indexed newTimestamp);

    event DurationUpdated(uint indexed previousSeconds, uint indexed newSeconds);

    function startTimestamp() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____startTimestamp()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____startTimestamp()], (uint));
    }

    function duration() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____duration()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____duration()], (uint));
    }

    function endTimestamp() public view virtual returns (uint) {
        return startTimestamp() + duration();
    }

    function started() public view virtual returns (bool) {
        return block.timestamp >= startTimestamp();
    }

    function ended() public view virtual returns (bool) {
        return block.timestamp >= endTimestamp();
    }

    function ticking() public view virtual returns (bool) {
        return started() && !ended();
    }

    function secondsLeft() public view virtual returns (uint) {
        if (ticking()) { return endTimestamp() - block.timestamp; }
        else if (!started()) { return duration(); }
        else { return 0; }
    }

    function ____startTimestamp() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("START_TIMESTAMP"));
    }

    function ____duration() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("DURATION"));
    }

    function _setStartTimestamp(uint newTimestamp) internal virtual {
        require(newTimestamp >= block.timestamp, "TimerLite: cannot start in the past");
        uint previousTimestamp = startTimestamp();
        _bytes[____startTimestamp()] = abi.encode(newTimestamp);
        emit StartTimestampUpdated(previousTimestamp, newTimestamp);
    }

    function _setDuration(uint newSeconds) internal virtual {
        require(newSeconds != 0, "TimerLite: cannot set zero seconds duration");
        uint previousSeconds = duration();
        _bytes[____duration()] = abi.encode(newSeconds);
        emit DurationUpdated(previousSeconds, newSeconds);
    }
}