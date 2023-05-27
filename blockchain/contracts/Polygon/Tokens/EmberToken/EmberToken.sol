// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

/** openzeppelin imports */
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

/** openzeppelin imports through github */
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

/** reputation token contract immutable */
contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, ERC20Permit, ERC20Votes {

    /** essential meta data already provided by openzeppelin */

    /** owner set to msg.sender in Ownable() */
    constructor() ERC20("EmberToken", "EMBER") ERC20Permit("EmberToken") Ownable() {}

    /** required override to merge inheritance conflicts */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {

        /** continue with default */
        super._beforeTokenTransfer(from, to, amount);

    }

    /** required override to merge inheritance conflicts */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        
        /** continue with default */
        super._afterTokenTransfer(from, to, amount);

    }

    /** required override to merge inheritance conflicts */
    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Votes) {

        /** continue with default */
        super._mint(to, amount);

    }

    /** required override to merge inheritance conflicts */
    function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {

        /** continue with default */
        super._burn(account, amount);

    }

    /** owner commands */

    /** snapshot */
    function snapshot() public onlyOwner {

        _snapshot();

    }

    /** mint */
    function mint(address to, uint256 amount) public onlyOwner {

        _mint(to, amount);

    }

    /** renounce ownership */
    function renounceOwnership() public override onlyOwner {

        super.renounceOwnership();

    }

    /** transfer ownership */
    function transferOwnership(address newOwner) public override onlyOwner {
        
        super.transferOwnership(newOwner);

    }

}