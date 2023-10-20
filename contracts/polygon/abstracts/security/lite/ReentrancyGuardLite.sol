// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

/** Adapted from openzeppelin ReentrancyGuard */
abstract contract ReentrancyGuardLite is StorageLite {

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _entered() public view virtual returns (bool) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____entered()]) == keccak256(emptyBytes)) {
            return false;
        }
        return abi.decode(_bytes[____entered()], (bool));
    }

    function ____entered() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("ENTERED"));
    }

    function _nonReentrantBefore() private {
        require(!_entered(), "ReentrancyGuardLite: reentrant call");
        _bytes[____entered()] = abi.encode(true);
    }

    function _nonReentrantAfter() private {
        _bytes[____entered()] = abi.encode(false);
    }
}