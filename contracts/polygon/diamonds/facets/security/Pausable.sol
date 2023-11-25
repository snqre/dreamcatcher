// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Pausable {
    bytes32 internal constant _PAUSABLE = keccak256("slot.pausable");

    struct PausableStorage {
        bool paused;
    }

    modifier whenPaused() {
        require(_isPaused(), "_isPaused");
        _;
    }

    modifier whenNotPaused() {
        require(!_isPaused(), "!_isPaused");
    }

    function pausable() internal pure virtual returns (PausableStorage storage s) {
        bytes32 location = _PAUSABLE;
        assembly {
            s.slot := location
        }
    }

    function _isPaused() internal view virtual returns (bool) {
        return pausable().paused;
    }
}