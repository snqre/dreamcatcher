// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IInitializableLite {

    /**
    * @notice Emitted when the contract is initialized by a sender.
    *         The `Initialized` event signals that the contract has been successfully initialized
    *         and can now perform its intended functions.
    * @dev This event provides information about the sender who triggered the initialization.
    *      It is recommended to perform necessary setup and configuration tasks in response
    *      to this event, as the contract is now ready for operation.
    * @param sender The address of the account that initiated the initialization process.
    * @dev It is crucial to pay attention to the `sender` parameter to track the origin of
    *      the initialization.
    */
    event Initialized(address indexed sender);

    /**
    * @notice Checks whether the contract has been initialized.
    * @dev This function returns a boolean indicating whether the contract has been initialized.
    * @return True if the contract is initialized, false otherwise.
    */
    function initialized() external view returns (bool);
}