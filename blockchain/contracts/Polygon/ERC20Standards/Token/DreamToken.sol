// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

// not implemented yet, the idea is once testing is done on the Token, i'll merge what we've done there into the
// sister tokens concept ... maybe

/**
* $DREAM
* Meaning: Desire or Aspiration
* serve as a reminder of the power of imagination and the importance of chasing one's passion
* required to use our products, vote, and more
 */

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, ERC20Permit, ERC20Votes {

    uint256 mintable;
    // all fees are in basis points / 10000 instead of / 100
    uint256 emberKept;
    uint256 emberGift;
    uint256 feeBurn; // > burnt turned into ember / % completely removed / % gifted back to people limited to x amount at a time
    uint256 feeBank; // straight back into designated vault
    DreamcatcherEmberToken emberToken;

    // ownable constructor should set the creator as owner :: creator will be governor likely
    constructor() ERC20("Dreamcatcher", "DREAM") ERC20Permit("Dreamcatcher") Ownable() {
        // unlike cap, this ensures that even when below the cap, only 200million can ever be minted ever
        mintable = 200000000 * 10**decimals();
        _mint(msg.sender, 200000000 * 10 ** decimals());

        // deploy Ember contract?
        emberToken = new DreamcatcherEmberToken();
    }

    function snapshot() public onlyOwner {
        _snapshot();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // override to allow for transfer fees and creation of ember
    function _transfer(address from, address to, uint256 amount) internal override {
        uint256 burn = (amount / 10000) * feeBurn;
        uint256 bank = (amount / 10000) * feeBank;
        uint256 newValue = amount - (burn + bank);
        super._transfer(from, to, newValue);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }

    function renounceOwnership() public override onlyOwner {
        super.renounceOwnership();
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
    }
}