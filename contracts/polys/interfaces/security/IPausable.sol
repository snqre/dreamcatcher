// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IPausable {

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
    function pausedKey() external pure returns (bytes32);

    /**
    * @dev Returns the current paused state.
    */
    function paused() external view returns (bool);
}