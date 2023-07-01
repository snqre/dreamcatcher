// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "deps/openzeppelin/token/ERC20/ERC20.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Permit.sol";
import "deps/openzeppelin/access/Ownable.sol";

contract StandardToken is ERC20, ERC20Burnable, ERC20Permit, Ownable {
    constructor(string memory name, string memory symbol) 
    ERC20(name, symbol) 
    ERC20Permit(name) 
    Ownable() {
        _transferOwnership(msg.sender);
    }

    function _beforeTokenTransfer(address from, address to, uint amount)
    internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
    }

    function mint(address to, uint amount)
    external
    onlyOwner
    returns (bool) {
        _mint(to, amount);
    }
}