// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IDRC001 {

    /**
    * @notice Emitted when the tier of the contract is changed.
    * @param sender The address initiating the tier change.
    * @param oldTier The old tier value before the change.
    * @param newTier The new tier value after the change.
    * @dev Use this event to track changes in the contract's tier.
    */
    event TierChanged(address indexed sender, uint8 indexed oldTier, uint8 indexed newTier);

    /**
    * @notice Emitted when the class of the contract is changed.
    * @param sender The address initiating the class change.
    * @param oldClass The old class value before the change.
    * @param newClass The new class value after the change.
    * @dev Use this event to track changes in the contract's class.
    */
    event ClassChanged(address indexed sender, string indexed oldClass, string indexed newClass);

    /**
    * @notice Emitted when the terminal address of the contract is changed.
    * @param sender The address initiating the terminal change.
    * @param oldTerminal The old terminal address before the change.
    * @param newTerminal The new terminal address after the change.
    * @dev Use this event to track changes in the contract's terminal address.
    */
    event TerminalChanged(address indexed sender, address indexed oldTerminal, address indexed newTerminal);

    /**
    * @notice Retrieves the current tier of the contract.
    * @return The current tier as a uint8.
    * @dev Use this function to get the current tier of the contract.
    */
    function tier() external view returns (uint8);

    /**
    * @notice Retrieves the current class of the contract.
    * @return The current class as a string.
    * @dev Use this function to get the current class of the contract.
    */
    function class() external view returns (string memory);

    /**
    * @notice Retrieves the current terminal address of the contract.
    * @return The current terminal address.
    * @dev Use this function to get the current terminal address of the contract.
    */
    function terminal() external view returns (address);
}