// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/deps/openzeppelin/access/Ownable.sol";
import "contracts/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/templates/libraries/Utils.sol";

contract StandardToken is ERC20, ERC20Burnable, Ownable {
    constructor(address owner) Ownable(owner) {}

    function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
    internal override {
        super._afterTokenTransfer(from, to, amount);
    }

    function mint(address to, uint256 amount)
    public virtual
    onlyOwner
    returns (bool) {
        _mint(to, amount);
        return true;
    }
}