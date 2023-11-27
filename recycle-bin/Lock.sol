// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

interface ILock {
    event SetUp(uint startTimestamp, uint duration);
    event DurationChanged(uint oldDuration, uint newDuration);
    event Passed();
    event OwnershipTransferred(address indexed oldThreshold, uint newThreshold);

    function startTimestamp() external view returns (uint);
    function duration() external view returns (uint);
    function time() external view returns (uint);
    function begun() external view returns (bool);
    function ended() external view returns (bool);
    function isInSession() external view returns (bool);

    function success() external view returns (bool);

    function ready() external view returns (bool);

    function conditionsHaveBeenMet() external view returns (bool);

    function start() external; 
    function setDuration(uint newDuration) external;

    function check() external;

    function owner() external view returns (address);

    function renounceOwnership() external;
    function transferOwnership(address newOwner) external;
}

contract Lock is Ownable {
    uint private _startTimestamp;
    uint private _duration;
    bool private _success;
    bool private _ready;
    
    event SetUp(uint startTimestamp, uint duration);
    event DurationChanged(uint oldDuration, uint newDuration);
    event Passed();

    constructor() Ownable(msg.sender) {}

    ///

    function startTimestamp() public view virtual returns (uint) {
        return _startTimestamp;
    }

    function duration() public view virtual returns (uint) {
        return _duration;
    }

    function time() public view virtual returns (uint) {
        return block.timestamp;
    }

    function begun() public view virtual returns (bool) {
        return time() >= startTimestamp() && ready();
    }

    function ended() public view virtual returns (bool) {
        return time() >= startTimestamp() + duration() && ready();
    }

    function isInSession() public view virtual returns (bool) {
        return begun() && !ended() && ready();
    }

    ///

    function success() public view virtual returns (bool) {
        return _success;
    }

    ///

    function ready() public view virtual returns (bool) {
        return _ready;
    }

    ///

    function conditionsHaveBeenMet() public view virtual returns (bool) {
        if (!success()) {
            return time() >= startTimestamp() + duration();
        }
        return success();
    }

    ///

    function start() onlyOwner public virtual {
        require(!begun(), "begun");
        _ready = true;
        _startTimestamp = time();
        emit SetUp(startTimestamp(), duration());
    }

    function setDuration(uint newDuration) onlyOwner public virtual {
        require(!begun(), "begun");
        uint oldDuration = duration();
        _duration = newDuration;
        emit DurationChanged(oldDuration, newDuration);
    }

    ///

    function check() public virtual {
        require(begun(), "!begun");
        if (conditionsHaveBeenMet() && ended() && !success()) {
            _success = true;
            emit Passed();
        }
    }
}