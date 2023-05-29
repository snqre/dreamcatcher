// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Token is
ERC20,
ERC20Burnable,
ERC20Snapshot,
Ownable,
ERC20Permit,
ERC20Votes {

    constructor(
        string memory name,
        string memory symbol
    ) ERC20(
        name,
        symbol
    ) ERC20Permit(
        name
    ) Ownable() {}

    /** -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.- */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(
        ERC20,
        ERC20Snapshot
    ) {

        super._beforeTokenTransfer(
            from,
            to,
            amount
        );

    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(
        ERC20,
        ERC20Votes
    ) {

        super._afterTokenTransfer(
            from,
            to,
            amount
        );

    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(
        ERC20,
        ERC20Votes
    ) {

        super._mint(
            to,
            amount
        );

    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(
        ERC20,
        ERC20Votes
    ) {

        super._burn(
            account,
            amount
        );

    }

    /** -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.- */
    function snapshot() public onlyOwner {

        _snapshot();

    }

    function mint(
        address to,
        uint256 amount
    ) public onlyOwner {

        _mint(
            to,
            amount
        );

    }

    function renounceOwnership() public override onlyOwner {

        super.renounceOwnership();

    }

    function transferOwnership(
        address newOwner
    ) public override onlyOwner {

        super.transferOwnership(
            newOwner
        );

    }

}