// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";
import "contracts/polygon/abstract/utils/AddressTerminal.sol";
import "contracts/polygon/interfaces/main/terminal/implementation/ITerminalImplementation.sol";

abstract contract Ownable02 is Storage, AddressTerminal {

    /**
    * @dev Public function to check if an `account` has a specified `role` in the terminal.
    * It uses the `requireRole` function from the terminal implementation contract.
    * @param role The role identifier for which the check is performed.
    * @param account The address to be checked for the specified role.
    * throws Throws an error if the account does not have the required role.
    */
    function requireRole(string memory role, address account) public view virtual {
        ITerminalImplementation terminal = ITerminalImplementation(terminal());
        terminal.requireRole(terminal.roleKey(terminal.hash(role)), account);
    }

    /**
    * @dev Public function to set the terminal address. Only accessible by the default admin role.
    * It calls the internal function `_setTerminal` to update the terminal address.
    * @param account The new terminal address to be set.
    * throws Throws an error if the caller does not have the default admin role.
    */
    function setTerminal(address account) public virtual {
        _onlyDefaultAdminRole();
        _setTerminal(account);
    }

    /**
    * @dev Internal function to ensure that the caller has the default admin role.
    * It uses the `requireRole` function from the terminal implementation to check for the role.
    * throws Throws an error if the caller does not have the default admin role.
    */
    function _onlyDefaultAdminRole() internal view virtual {
        ITerminalImplementation terminal = ITerminalImplementation(terminal());
        requireRole("DEFAULT_ADMIN_ROLE", msg.sender);
    }

    /**
    * @dev Internal function to initialize the contract with the specified `account` as the terminal address.
    * It sets the terminal address in the contract state.
    * @param account The address to be set as the terminal address.
    */
    function _initialize(address account) internal virtual override {
        super._initialize(account);
    }
}