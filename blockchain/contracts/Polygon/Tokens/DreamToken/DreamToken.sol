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
    uint256 private mintable;
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
    
    /** owner set to msg.sender in Ownable() */
    constructor() ERC20("DreamToken", "DREAM") ERC20Permit("DreamToken") Ownable() {
        
        /** set mintable and maxSupply_ */
        mintable = _convertToWei(200_000_000);
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
}