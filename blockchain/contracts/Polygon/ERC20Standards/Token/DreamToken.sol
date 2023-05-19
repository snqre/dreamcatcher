// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "blockchain/contracts/Polygon/ERC20Standards/Token/Wallet.sol";

// not implemented yet, the idea is once testing is done on the Token, i'll merge what we've done there into the
// sister tokens concept ... maybe

/**
* $DREAM
* Meaning: Desire or Aspiration
* serve as a reminder of the power of imagination and the importance of chasing one's passion
* required to use our products, vote, and more
 */

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, ERC20Permit, ERC20Votes {

    /**
    * mintable: total amount of tokens that can be minted ever
    * emberKept: amount of $ember tokens kept by us from transfer burn fee
    * emberGift: amount of $ember tokens gifted transactor during burn fee
    * feeBurn: basis point for amount of $dream burnt
    * feeBank: basis point for amount of $dream sent to us
     */

    /** no need for basic meta data as that is covered by @openzeppelin */
    struct Book {
        address safe;
        address emberToken;
    }

    struct Settings {
        uint256 minimumBurnTranferFee;
        uint256 minimumBankTranferFee;
        uint256 maximumBurnTranferFee;
        uint256 maximumBankTranferFee;
        uint256 defaultBurnTransferFee;
        uint256 defaultBankTransferFee;
    }

    struct Tracker {
        uint256 mintable;
        uint256 maxSupply;
    }

    uint256 immutable maxSupply;

    Book internal book;
    Settings internal settings;
    Tracker internal tracker;

    /** owner set to msg.sender in Ownable() */
    constructor() ERC20("Dreamcatcher", "DREAM") ERC20Permit("Dreamcatcher") Ownable() {
        tracker.mintable = _convertToWei(200000000);
        maxSupply = _convertToWei(200000000);

        /** for transparency reasons */
        enum team {weaver_}

        Wallet[] memory vestingWallet;
        uint256 now_ = block.timestamp;
        uint256 duration = 580608000 seconds; /** in the best interest of the project - 20 years */

        vestingWallet[team.weaver_] = new Wallet(0x000007c3E0A73f06A64F057e8cfe1848B239A19B, now_, duration); 
        _mint(address(vestingWallet[team.weaver_]), _convertToWei(5000000));

        /** ... others ... */


        // deploy Ember contract? again do we need sister token?
        emberToken = new EmberToken();
        
    }

    /*---------------------------------------------------------------- PRIVATE **/

    function _convertToWei(uint256 value) internal pure returns (uint256) {
        return value * 10**decimals();
    }

    /**
    * overriden to allow for burn and native gas fees on transfer
     */
    function _transfer(address from, address to, uint256 amount) internal override {
        uint256[] sum;
        uint256 maxFee = 300; // 3% max fee
        bool isNotOverMaxFee = feeBurn + feeBank <= maxFee;

        delete maxFee;

        if (feeBurn != 0) {
            require(isNotOverMaxFee);
            sum[0] = (amount / 10000) * feeBurn;
            _burn(from, sum[0]);
        }

        if (feeBank != 0) {
            require(isNotOverMaxFee);
            sum[1] = (amount / 10000) * feeBank;
            super._transfer(from, safe, sum[0]);
        }

        delete isNotOverMaxFee;

        // fees cannot be more than the amount being sent
        require(sum[0] + sum[1] < amount);

        uint256 newValue = amount - (sum[0] + sum[1]);

        delete sum;
        // and finally use the _transfer stuff
        super._transfer(from, to, newValue);
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
        /** if we want to produce $ember on burn we need to do it here which we wont be able to change again */
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
}