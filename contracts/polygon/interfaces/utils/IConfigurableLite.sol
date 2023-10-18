// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IConfigurableLite {

    /**
    * @notice Emitted when the contract is configured.
    *         The `Configured` event signals that the contract has been successfully configured.
    * @dev This event provides information about the sender who triggered the configuration.
    * @param sender The address of the account that initiated the configuration process.
    * @dev It is recommended to listen for this event to track changes in the contract configuration
    *      and perform necessary actions accordingly.
    */
    event Configured(address indexed sender);

    /**
    * @notice Checks whether the contract is configured.
    * @dev This function returns a boolean indicating whether the contract has been configured.
    * @return True if the contract is configured, false otherwise.
    */
    function configured() external view returns (bool);
}