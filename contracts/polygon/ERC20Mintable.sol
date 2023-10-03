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
    * @dev The constructor initiates the ERC20 contract with a name
    *      and symbol. The owner of the contract is the address of
    *      the deployer.
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {}

    /**
    * @dev The single difference is that in this contract it is
    *      possible to mint unlimited amounts of tokens as the
    *      owner.
    *
    * WARNING: The owner should likely be another contract with 
    *          its own way of verifying when to mint tokens or
    *          be used by a governor system which is community
    *          owned.
     */
    function mint(address account, uint256 amount) public onlyOwner() {
        _mint(account, amount);
    }

    /**
    * @dev Required override.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20) {
        super._beforeTokenTransfer(from, to, amount);
    }
}