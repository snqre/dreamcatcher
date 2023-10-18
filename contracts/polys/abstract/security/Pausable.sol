// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/StorageLite.sol";

abstract contract Pausable is StorageLite {
    event Paused();

    event Unpaused();

    function paused() public view virtual returns (bool) {
        return abi.decode(_bytes[____paused()], (bool));
    }

    function ____paused() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("PAUSED"));
    }

    function _whenPaused() internal view virtual {
        require(paused(), "Pausable: !paused()");
    }

    function _whenNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused()");
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