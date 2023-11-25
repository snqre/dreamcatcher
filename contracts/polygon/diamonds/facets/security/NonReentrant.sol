// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NonReentrant {
    bytes32 internal constant _NON_REENTRANT = keccak256("slot.nonReentrant");

    struct NonReentrantStorage {
        bool lock;
    }

    modifier nonReentrant() {
        require(!_isLocked, "!_islocked");
        _lock();
        _;
        _unlock();
    }

    function nonReentrant() internal pure virtual returns (NonReentrantStorage storage s) {
        bytes32 location = _NON_REENTRANT;
        assembly {
            s.slot := location
        }
    }

    function _isLocked() internal view virtual returns (bool) {
        return nonReentrant().lock;
    }

    function _lock() internal virtual {
        nonReentrant().lock = true;
    }

    function _unlock() internal virtual {
        nonReentrant().lock = false;
    }
}