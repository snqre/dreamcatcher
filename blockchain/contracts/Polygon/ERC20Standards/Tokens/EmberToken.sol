// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

/**
* $EMBER
* Meaning: Devotion or Loyalty
* serve as a reminder of the strength and resilience required to maintain unwavering devotion
* obtained by burning $DREAM; extra voting power; gain a larger yield
 */

/** earned when voting, participating in governance, %chance burns, wild hunts */

contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, ERC20Permit, ERC20Votes {
    constructor() ERC20("Dreamcatcher", "EMBER") ERC20Permit("Dreamcatcher") {
        
    }

    /*---------------------------------------------------------------- PRIVATE **/
    function _convertToWei(uint256 value) internal pure returns (uint256) {
        return value * 10**decimals();
    }

    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal override onlyOwner {
        // Ember is not transferable therefore nothing happens here unless its dreamcatcher itself
        // super._transfer();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    /*---------------------------------------------------------------- OWNER COMMANDS **/
    function snapshot() public onlyOwner {
        _snapshot();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

}