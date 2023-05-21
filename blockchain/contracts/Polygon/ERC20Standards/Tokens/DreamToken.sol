// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "blockchain/contracts/Polygon/Finance/Wallet.sol";

/**
* Dream Token
* desire or aspiration
* a reminder of the power of imagination and important of chasing one's passion
* native | gas | vote | governance | wild hunts*
 */

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, ERC20Permit, ERC20Votes {

    /** no need for basic meta data as that is covered by @openzeppelin */

    address public safe;
    uint256 public mintable;
    uint256 public maxSupply_;
    EmberToken emberToken;

    struct Settings {
        uint256 minimumBurnTranferFee;
        uint256 minimumBankTranferFee;
        uint256 maximumBurnTranferFee;
        uint256 maximumBankTranferFee;
        uint256 defaultBurnTransferFee;
        uint256 defaultBankTransferFee;
    }

    uint256 immutable maxSupply;

    Book public book;
    Settings public settings;
    Tracker public tracker;

    /** owner set to msg.sender in Ownable() */
    constructor() ERC20("Dreamcatcher", "DREAM") ERC20Permit("Dreamcatcher") Ownable() {
        /** burnt tokens cannot be minted again */
        mintable = _convertToWei(200000000);
        maxSupply_ = _convertToWei(200000000);

        /** for transparency reasons */
        enum team {weaver_}

        Wallet[] memory vestingWallet;
        uint256 now_ = block.timestamp;
        uint256 duration = 580608000 seconds; /** in the best interest of the project - 20 years */

        vestingWallet[team.weaver_] = new Wallet(0x000007c3E0A73f06A64F057e8cfe1848B239A19B, now_, duration); 
        _mint(address(vestingWallet[team.weaver_]), _convertToWei(5000000));

        /** ... others ... */


        /** deploy ember token contract */
        emberToken = new EmberToken();

        nonce = 0;
        
    }

    /*---------------------------------------------------------------- PRIVATE **/
    function _convertToWei(uint256 value) internal pure returns (uint256) {
        return value * 10**decimals();
    }

    /** burn and gas on transfer */
    function _transfer(address from, address to, uint256 amount) internal override {
        if (defaultBurnTransferFee != 0 || defaultBankTransferFee != 0) {
            uint256[] sum;

            if (defaultBurnTransferFee != 0) {
                sum[0] = (amount / 10000) * defaultBurnTransferFee;
                _burn(from, sum[0]);
            }

            if (defaultBankTransferFee != 0) {
                sum[1] = (amount / 10000) * defaultBankTransferFee;
                super._transfer(from, safe, sum[1]);
            }
            /** x + 0 or 0 + x if one of the fees are not present */
            uint256 newAmount = amount - (sum[0] + sum[1]);

            super._transfer(from, to, newAmount);
        } else {
            /** standard */
            super._transfer(from, to, amount);
        }
    }

    /** required overrides to merge inheritance conflicts */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        /** added our version of maxSupply: mintable */
        require(mintable <= amount, "max mintable is reached");
        mintable -= amount;
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }

    /*---------------------------------------------------------------- OWNER COMMANDS **/
    function snapshot() public onlyOwner {
        _snapshot();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function renounceOwnership() public override onlyOwner {
        super.renounceOwnership();
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
    }

    /*---------------------------------------------------------------- PUBLIC **/
    function maxSupply() public view returns (uint256) {
        return maxSupply_;
    }
}