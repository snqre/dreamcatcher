// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "blockchain/contracts/Polygon/Finance/Wallet.sol";
import "blockchain/contracts/Polygon/Tokens/EmberToken/EmberToken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DreamToken is
ERC20,
ERC20Burnable,
ERC20Snapshot,
AccessControl,
ERC20Permit {
    /** safe math */
    using SafeMath for uint256;

    /**

        mintable_: amount of tokens left that can every be minted
        maxSupply_: supply cap
        fee: transfer fee in basis points
        rate: how many $dream to burn per $ember
        safe: where fees go during transfer
        vestingWallets: keep track of team vesting wallets
        emberToken: dual token model
    
     */
    uint256 public mintable_;
    uint256 public maxSupply_;
    uint16 public fee;
    uint256 public rate;
    address public safe;
    Wallet[] public wallets;
    EmberToken public emberToken;

    constructor(address terminal) ERC20("DreamToken", "DREAM") ERC20Permit("DreamToken") {
        _grantRole(DEFAULT_ADMIN_ROLE, terminal);

        mintable_ = _convertToWei(200000000);
        maxSupply_ = _convertToWei(200000000);

        fee = 0;
        rate = 100000;
        safe = terminal;

        uint64 now_ = block.timestamp;
        uint64 duration = 960 weeks;

        address weaver_ = 0x000007c3E0A73f06A64F057e8cfe1848B239A19B;
        wallets[0] = new Wallet(weaver_, now_, duration);

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
        
        _mint(safe, _convertToWei(180000000));
        emberToken = new EmberToken(terminal);


    }

    /** simple convert to wei from normal number */
    function _convertToWei(uint256 value) internal pure returns (uint256) {
        return value * 10**18;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (
            fee
            != 0
        ) {
            /** (amount * fee) / 10000 */
            uint256 feeAmount = amount.mul(
                fee
            ).div(
                10000
            );
        }
        

        super._transfer(
            from,
            safe,
            feeAmount
        );

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

    /** implementation of mintable */
    function _mint(
        address to,
        uint256 amount
    ) internal override {
        require(
            mintable_
            <= amount,
            "DreamToken::_mint(): mintable_ > amount"
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
    ) internal override {
        super._burn(
            account,
            amount
        );
        
        /** generate $ember */
        emberToken.mint(
            account,
            amount
            / rate
        );
    }

    function snapshot() public onlyRole(
        DEFAULT_ADMIN_ROLE
    ) {_snapshot();}

    function mint(
        address to,
        uint256 amount
    ) public onlyRole(
        DEFAULT_ADMIN_ROLE
    ) {
        _mint(
            to,
            amount
        );
    }

    /** no one can burn tokens from anyone else's address with this function */
    function burn(
        uint256 amount
    ) public override onlyRole(
        DEFAULT_ADMIN_ROLE
    ) {
        _burn(
            msg.sender,
            amount
        );
    }

    function setFee(
        uint16 newFee
    ) public onlyRole(
        DEFAULT_ADMIN_ROLE
    ) {
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

    /** set the rate of $dream to $ember */
    function setRate(
        uint256 newRate
    ) public onlyRole(
        DEFAULT_ADMIN_ROLE
    ) {
        require(
            newRate
            >= 0,
            "DreamToken::setRate(): newRate < 0"
        );

        rate = newRate;
    }

    function setSafe(
        address newSafe
    ) public onlyRole(
        DEFAULT_ADMIN_ROLE
    ) {
        require(
            newSafe
            != address(
                0x0
            ),
            "DreamToken::setSafe(): newSafe == address(0x0)"
        );

        safe = newSafe;
    }

    /** return max supply */
    function maxSupply() public view returns (
        uint256
    ) {
        return maxSupply_;
    }

    /** return remaining amount that can be minted ever */
    function mintable() public view returns (
        uint256
    ) {
        return mintable_;
    }

    function getVotes(
        address account
    ) public view returns (
        uint256
    ) {
        /** get account balance */
        uint256 balance = balanceOfAt(
            account,
            _getCurrentSnapshotId()
        );

        /** get emberToken weighting */
        uint256 weighting = emberToken.getWeight(
            account
        );

        /** calculate emberToken boost */
        uint256 boost = balance.mul(
            weighting
        ).div(
            10000
        );

        /** return votes with weighting */
        return balance.add(
            boost
        );
    }

    function getPastVotes(
        address account,
        uint256 snapshotId
    ) public view returns (
        uint256
    ) {
        /** get past account balance */
        uint256 balance = balanceOfAt(
            account,
            snapshotId
        );

        /** get past emberToken weight */
        uint256 weighting = emberToken.getPastWeight(
            account, 
            snapshotId
        );

        /** calculate emberToken past boost */
        uint256 boost = balance.mul(
            weighting
        ).div(
            10000
        );

        /** return past votes with weighting */
        return balance.add(
            boost
        );
    }
}