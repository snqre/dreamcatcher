// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/utils/IAddressTerminal.sol";

interface IOwnable02 is IAddressTerminal {

    /**
    * @dev Public function to check if an `account` has a specified `role` in the terminal.
    * It uses the `requireRole` function from the terminal implementation contract.
    * @param role The role identifier for which the check is performed.
    * @param account The address to be checked for the specified role.
    */
    function requireRole(string memory role, address account) external view;

    /**
    * @dev Public function to set the terminal address. Only accessible by the default admin role.
    * It calls the internal function `_setTerminal` to update the terminal address.
    * @param account The new terminal address to be set.
    */
    function setTerminal(address account) external;
}