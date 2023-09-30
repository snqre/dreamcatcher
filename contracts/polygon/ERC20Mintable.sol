// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/token/ERC20/ERC20.sol";

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";

contract ERC20Mintable is ERC20, ERC20Burnable {

    /** State Variables. */

    address public vault;

    /** Function Modifiers. */

    modifier onlyVault() {

        bool authorized = msg.sender == vault;
        
        require(authorized, "SolsticeVaultToken: !authorized");

        _;
    }

    /** Constructor. */

    constructor(string memory name, string memory symbol, address vault) ERC20(name, symbol) {

        vault = vault;
    }

    /** Public. */

    function mint(address account, uint256 amount) public {

        _mint(account, amount);
    }

    /** Internal. */

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20) {

        super._beforeTokenTransfer(from, to, amount);
    }
}