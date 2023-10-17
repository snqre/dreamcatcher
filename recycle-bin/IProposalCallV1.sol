// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/interfaces/IProposalV1.sol";

interface IProposalCallV1 is IProposalV1 {

    /**
    * @dev Emitted when the target address is set to a new value.
    * @param account The address that the contract's target is set to.
    * @dev The `indexed` keyword is used for efficient event filtering based on the specified address.
    */
    event TargetSetTo(address indexed account);

    /**
    * @dev Emitted when the signature is set to a new value.
    * @param signature The string representing the new signature set in the contract.
    * @dev The `indexed` keyword is used for efficient event filtering based on the specified signature.
    */
    event SignatureSetTo(string indexed signature);

    /**
    * @dev Emitted when the arguments are set to a new value.
    * @param args The binary data (bytes) representing the new arguments set in the contract.
    * @dev The `indexed` keyword is used for efficient event filtering based on the specified arguments.
    */
    event ArgsSetTo(bytes indexed args);

    /**
    * @dev Public function to retrieve the current target address.
    * @return The current target address stored in the contract.
    */
    function target() external view returns (address);

    /**
    * @dev Public function to retrieve the current signature.
    * @return The current signature stored in the contract as a string.
    */
    function signature() external view returns (string memory);

    /**
    * @dev Public function to retrieve the current arguments.
    * @return The current arguments stored in the contract as binary data (bytes).
    */
    function args() external view returns (bytes memory);
}