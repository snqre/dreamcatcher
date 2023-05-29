// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

import "blockchain/contracts/Polygon/Finance/Wallet.sol";

contract DreamToken is 
ERC20, 
ERC20Burnable, 
ERC20Snapshot, 
Ownable, 
ERC20Permit, 
ERC20Votes {
    
    uint256 private mintable_;
    uint256 private maxSupply_;

    uint16 fee;

    address safe;

    Wallet[] memory vestingWallets;
    
    constructor() ERC20(
        "DreamToken",
        "DREAM"
    ) ERC20Permit(
        "DreamToken"
    ) Ownable() {

        mintable_ = _convertToWei(
            200000000
        );

        maxSupply_ = _convertToWei(
            200000000
        );

        enum team {

            weaver_,
            r,
            a,
            d

        }

        uint64 now_ = block.timestamp;
        uint64 duration = 960 weeks;

        vestingWallets[
            team.weaver_
        ] = new Wallet(
            0x000007c3E0A73f06A64F057e8cfe1848B239A19B,
            now_,
            duration
        );

        vestingWallets[
            team.r
        ] = new Wallet(
            ,
            now_,
            duration
        );

        /**

            20,000,000 Team
            12,000,000 $.035
            10,000,000 $.100
            10,000,000 $.250
            10,000,000 $.500
            10,000,000 $1.00
            50,000,000 obsidian program
            17,500,000 participation
            50,000,000 liquidity
            10,000,000 reserve
            500,000 contractors

         */

        _mint(
            safe,
            _convertToWei(
                180000000
            )
        );

    }

    /** -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.- */
    function _convertToWei(
        uint256 value
    ) internal pure returns (
        uint256
    ) {

        return value * 10**decimals();

    }

    function _transfer(
        address from, 
        address to, 
        uint256 amount
    ) internal override {

        if (fee != 0) {

            super._transfer(
                from,
                safe,
                (
                    amount
                    / 10000
                ) * fee
            );

        }

        super._transfer(
            from,
            to,
            amount - (
                (
                    amount
                    / 10000
                ) * fee
            )
        );

    }

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
        )

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

        require(
            mintable_
            <= amount,
            "DreamToken::_mint: mintable_ > amount"
        );

        mintable_ -= amount;

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

    function setFee(
        uint16 newFee
    ) public onlyOwner {

        require(
            newFee
            >= 0,
            "DreamToken::setFee(): newFee < 0"
        );

        require(
            newFee
            <= 10000,
            "DreamToken::setFee(): newFee > 10000"
        );

        fee = newFee;

    }

    function setSafe(
        address newSafe
    ) public onlyOwner {

        require(
            newSafe
            != address(
                0x0
            ),
            "DreamToken::setSafe(): newSafe == address(0x0)"
        );

        safe = newSafe;

    }

    /** -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.- */
    function maxSupply() public view returns (
        uint256
    ) {

        return maxSupply_;

    }

    function mintable() public view returns (
        uint256
    ) {

        return mintable_;

    }
    
}