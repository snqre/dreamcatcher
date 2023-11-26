// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library PausableComponent {
    event Paused();
    event Unpaused();

    struct Pausable {
        bool _paused;
    }

    function paused(Pausable storage pausable) internal view returns (bool) {
        return pausable._paused;
    }

    function whenPaused(Pausable storage pausable) internal view returns (bool) {
        require(paused(pausable), "not paused");
        return true;
    }

    function whenUnpaused(Pausable storage pausable) internal view returns (bool) {
        require(!paused(pausable), "paused");
        return true;
    }

    function pause(Pausable storage pausable) internal returns (bool) {
        _pause(pausable);
        return true;
    }

    function unpause(Pausable storage pausable) internal returns (bool) {
        _unpause(pausable);
        return true;
    }

    function _pause(Pausable storage pausable) private returns (bool) {
        pausable._paused = true;
        return true;
    }

    function _unpause(Pausable storage pausable) private returns (bool) {
        pausable._paused = false;
        return true;
    }   
}