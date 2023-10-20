// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

/** Adapted from openzepplin Pausable.sol */
abstract contract PausableLite is StorageLite {

    event Paused();

    event Unpaused();

    function paused() public view virtual returns (bool) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____paused()]) == keccak256(emptyBytes)) {
            return false;
        }
        return abi.decode(_bytes[____paused()], (bool));
    }

    function ____paused() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("PAUSED"));
    }

    function _whenPaused() internal view virtual {
        require(paused(), "PausableLite: is not paused");
    }

    function _whenNotPaused() internal view virtual {
        require(!paused(), "PausableLite: is paused");
    }

    function _pause() internal virtual {
        _whenNotPaused();
        _bytes[____paused()] = abi.encode(true);
        emit Paused();
    }

    function _unpause() internal virtual {
        _whenPaused();
        _bytes[____paused()] = abi.encode(false);
        emit Unpaused();
    }
}