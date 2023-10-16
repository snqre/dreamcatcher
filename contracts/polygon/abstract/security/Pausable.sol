// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";

/** 
* pausedKey => bool
*/
abstract contract Pausable is Storage {

    /**
    * @dev Emitted when the contract is paused.
    */
    event Paused();

    /**
    * @dev Emitted when the contract is unpaused.
    */
    event Unpaused();

    /**
    * @dev Returns the key for the paused state.
    */
    function pausedKey() public pure virtual returns (bytes32) {
        keccak256(abi.encode("PAUSED"));
    }

    /**
    * @dev Returns the current paused state.
    */
    function paused() public view virtual returns (bool) {
        _bool[pausedKey()];
    }

    /**
    * @dev Ensures that the contract is not paused.
    */
    function _whenNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused()");
    }

    /**
    * @dev Ensures that the contract is paused.
    */
    function _whenPaused() internal view virtual {
        require(paused(), "Pausable: !paused()");
    }

    /**
    * @dev Pauses the contract.
    */
    function _pause() internal virtual {
        _whenNotPaused();
        _bool[pausedKey()] = true;
        emit Paused();
    }

    /**
    * @dev Unpauses the contract.
    */
    function _unpause() internal virtual {
        _whenPaused();
        _bool[pausedKey()] = false;
        emit Unpaused();
    }
}