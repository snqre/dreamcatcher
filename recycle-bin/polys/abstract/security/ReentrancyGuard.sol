// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/StorageLite.sol";

abstract contract ReentrancyGuard is StorageLite {
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function ____locked() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("LOCKED"));
    }

    function _locked() internal view returns (bool) {
        /**
        * @dev Returns true if tthe reentrancy guard is currently set to locked, indicating that
        *      the nonReentrant function is currently in call.
         */
        return abi.decode(_bytes[____locked()], (bool));
    }

    function _nonReentrantBefore() private {
        require(!_locked(), "ReentrancyGuard: reentrant call");
        _lock();
    }

    function _nonReentrantAfter() private {
        _unlock();
    }

    function _lock() private {
        _bytes[____locked()] = abi.encode(true);
    }

    function _unlock() private {
        _bytes[____locked()] = abi.encode(false);
    }
}