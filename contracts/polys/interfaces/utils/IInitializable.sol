// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IInitializable {

    /**
    * @dev Returns the key for checking if the contract has been initialized.
    */
    function initializedKey() external pure returns (bytes32);

    /**
    * @dev Checks if the contract has been initialized.
    */
    function initialized() external view returns (bool);
}