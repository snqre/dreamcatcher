// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "blockchain/contracts/Polygon/Tokens/EmberToken/EmberToken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DreamToken is
    ERC20,
    ERC20Burnable,
    ERC20Snapshot,
    AccessControl,
    ERC20Permit
{
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
    uint256 immutable maxSupply_;
    uint16 public fee;
    uint256 public rate;
    address public safe;

    mapping(uint256 => Wallet) public wallets;
    uint256 public numberOfWallets;

    EmberToken public emberToken;

    constructor(address terminal)
        ERC20("DreamToken", "DREAM")
        ERC20Permit("DreamToken")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, address(this));

        if (msg.sender != terminal) {
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(DEFAULT_ADMIN_ROLE, terminal);
        } else {
            // msg.sender == terminal
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        }

        mintable_ = _convertToWei(200_000_000);
        maxSupply_ = _convertToWei(200_000_000);

        setFee(0);
        setRate(1_000);
        setSafe(terminal);

        _vestWithPreRelease(
            0x000007c3E0A73f06A64F057e8cfe1848B239A19B,
            960 weeks,
            100,
            _convertToWei(5_000_000)
        );
        _mint(safe, _convertToWei(80_000));

        emberToken = new EmberToken(terminal);
    }

    /** simple convert to wei from normal number */
    function _convertToWei(uint256 value) internal pure returns (uint256) {
        return value * 10**18;
    }

    function _vest(
        address member,
        uint64 duration,
        uint256 amount
    ) internal {
        uint64 now_ = uint64(block.timestamp);
        wallets[numberOfWallets] = new Wallet(member, now_, duration);
        _mint(wallets[numberOfWallets], amount);
        numberOfWallets += 1;
    }

    // release is the portion of the amount released in basis points
    function _vestWithPreRelease(
        address member,
        uint64 duration,
        uint256 release,
        uint256 amount
    ) internal {
        uint256 preReleasedAmount = amount.div(10_000).mul(release);
        _vest(member, duration, amount.sub(preReleasedAmount));
        _mint(member, preReleasedAmount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        uint256 feeAmount = amount.mul(fee).div(10_000);

        if (feeAmount == 0) {
            super._transfer(from, safe, feeAmount);
        }

        super._transfer(from, to, amount.sub(feeAmount));
    }

    function _mint(address to, uint256 amount) internal override {
        require(mintable_ <= amount, "DreamToken::_mint(): mintable_ > amount");

        mintable_ = mintable_.sub(amount);

        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override {
        super._burn(account, amount);

        if (rate != 0) {
            // generate $ember where $dream was burnt
            emberToken.mint(account, amount.div(rate));
        }
    }

    function snapshot() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _snapshot();
    }

    function mint(address to, uint256 amount)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _mint(to, amount);
    }

    function burn(uint256 amount) public override onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(msg.sender, amount);
    }

    function setFee(uint16 newFee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newFee >= 0, "DreamToken::setFee(): newFee < 0");
        require(newFee <= 10_000, "DreamToken::setFee(): newFee > 10000");

        fee = newFee;
    }

    function setRate(uint256 newRate) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newRate >= 0, "DreamToken::setRate(): newRate < 0");

        rate = newRate;
    }

    function setSafe(address newSafe) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            newSafe != address(0x0),
            "DreamToken::setSafe(): newSafe == address(0x0)"
        );

        safe = newSafe;
    }

    function maxSupply() public view returns (uint256) {
        return maxSupply_;
    }

    function mintable() public view returns (uint256) {
        return mintable_;
    }

    // use emberToken balance as weighting
    function getVotes(address account) public view returns (uint256) {
        uint256 balance = balanceOfAt(account, _getCurrentSnapshotId());
        uint256 weight = emberToken.getWeight(account);
        uint256 boost = balance.mul(weight).div(10_000);

        return balance.add(boost);
    }

    // $ember functions as weighting system
    function getPastVotes(address account, uint256 snapshotId)
        public
        view
        returns (uint256)
    {
        uint256 balance = balanceOfAt(account, snapshotId);
        uint256 weight = emberToken.getPastWeight(account, snapshotId);
        uint256 boost = balance.mul(weight).div(10_000);

        return balance.add(boost);
    }
}
