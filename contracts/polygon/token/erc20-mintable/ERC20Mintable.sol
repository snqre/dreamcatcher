// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/external/openzeppelin/access/Ownable.sol";

/**
* @dev Ownable and mintable ERC20 contract.
 */
contract ERC20Mintable is ERC20, ERC20Burnable, Ownable {

    /**
    * @dev Constructor for the DreamToken contract.
    * @param name The name of the token.
    * @param symbol The symbol of the token.
    * @dev Initializes the DreamToken with the specified name and symbol.
    * @dev Inherits from ERC20 for standard token functionality and Ownable for ownership control.
    * @dev The contract deployer becomes the initial owner.
    */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {}

    /**
    * @dev External function to mint new tokens and assign them to a specified account.
    * @param account The address to which the newly minted tokens will be assigned.
    * @param amount The amount of tokens to mint.
    * @dev This function can only be called by the owner of the contract, as specified by the onlyOwner modifier.
    * @dev It mints the specified amount of tokens and assigns them to the specified account.
    */
    function mint(address account, uint256 amount) public onlyOwner() {
        _mint(account, amount);
    }

    /**
    * @dev Internal function invoked before a token transfer.
    * @param from The address from which the tokens are transferred.
    * @param to The address to which the tokens are transferred.
    * @param amount The amount of tokens being transferred.
    * @dev This function is part of the ERC20 contract.
    * @dev It ensures that necessary checks and actions are performed before the token transfer.
    */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20) {
        super._beforeTokenTransfer(from, to, amount);
    }
}