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

/** main dream token contract immutable */
contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, ERC20Permit, ERC20Votes {
    
    /** essential meta data already provided by openzeppelin */

    /**
    * mintable is the amount of tokens that can ever be minted
    * maxSupply_ is the maximum amount of tokens that can ever exist at once
     */
    uint256 private mintable_;
    uint256 private maxSupply_;

    /**
    * all fees in basis points divided by 10_000 not 100
    * burn is the amount in basis point of the transaction burnt during a transfer
    * bank is the amount in basis point that is sent back to the dao
     */
    uint16 minBurnTransferFee;
    uint16 minBankTransferFee;
    uint16 maxBurnTransferFee;
    uint16 maxBankTransferFee;
    uint16 burnTransferFee;
    uint16 bankTransferFee;

    /** dao safe */
    address safe;

    /** owner set to msg.sender in Ownable() */
    constructor() ERC20("DreamToken", "DREAM") ERC20Permit("DreamToken") Ownable() {
        
        /** set mintable and maxSupply_ */
        mintable_ = _convertToWei(200_000_000);
        maxSupply_ = _convertToWei(200_000_000);

        /** for transparency reasons */
        /** enum */
        enum team {weaver_}

        /** vesting wallets */
        
        /** assign weaver_ */

        /** others */
        
    }

    /** utils function to convert value into wei */
    function _convertToWei(uint256 value) internal pure returns (uint256) {

        return value * 10**decimals();

    }

    /** override for burn and bank feature */
    function _transfer(address from, address to, uint256 amount) internal override {

        /** sum of amount in fees */
        uint256[] sum;

        /** if burn fee is not zero */
        if (burnTransferFee != 0) {
            sum[0] = (amount / 10_000) * burnTransferFee;
            _burn(from, sum[0]);
        }

        /** if bank fee is not zero */
        if (bankTransferFee != 0) {
            sum[1] = (amount / 10_000) * bankTransferFee;
            super._transfer(from, safe, sum[1]);
        }

        /** new amount after fee */
        uint256 newAmount = amount - (sum[0] + sum[1]);

        /** continue with default transfer function */
        super._transfer(from, to, newAmount);

    }

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

    /** override _mint with our custom implementation */
    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Votes) {

        /** check how many tokens can be minted */
        require(mintable_ <= amount, "DreamToken::_mint: minting limit reached");
        
        mintable_ -= amount;

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

    /** sets new safe address where bank fee is sent on transfer */
    function setNewSafeAddress(address newSafeAddress) public onlyOwner {

        require(newSafeAddress != address(0), "DreamToken::setNewSafeAddress: newSafeAddress is address zero");
        safe = newSafeAddress;

    }

    /** public */

    /** view maxSupply */
    function maxSupply() public view returns (uint256) {
        
        return maxSupply_;

    }

    /** view mintable */
    function mintable() public view returns (uint256) {

        return mintable_;

    }

}