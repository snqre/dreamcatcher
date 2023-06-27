// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "deps/openzeppelin/token/ERC20/ERC20.sol";

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, Ownable {
    uint private _mintable;
    uint private _maxSupply;

    constructor() ERC20("DreamToken", "DREAM") ERC20Permit("DreamToken") Ownable() {
        /// initialize supply.
        _mintable = _convertToWei(200_000_000);
        _maxSupply = _convertToWei(200_000_000);

        _mint( /// mint all the supply to the deployer.
            _msgSender(),
            _convertToWei(200_000_000)
        );
    }

    function snapshot_() public returns (uint) {
        /// create a snapshot.
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function getCurrentSnapshotId() public view returns (uint) {
        /// returns the latest snapshot id.
        return _getCurrentSnapshotId();
    }

    function maxSupply() public view returns (uint) { 
        /// return true max supply taking account for amount burnt.
        return _maxSupply; 
    }

    function mintable() public view returns (uint) {
        /// when zero no more tokens can be minted regardless of max supply.
        return _mintable;
    }

    function _convertToWei(uint value) private pure returns (uint) {
        return value * decimals();
    }

    function _mustBeMintable(uint amount) private view {
        require(
            amount <= _mintable,
            "Insufficient mintable amount. The requested amount exceeds the available mintable tokens."
        );
    }

    function _beforeTokenTransfer(
        address from, 
        address to, 
        uint amount
    ) private override(
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
        uint amount
    ) private override {
        super._afterTokenTransfer(
            from,
            to,
            amount
        );
    }

    function _mint(
        address to,
        uint amount
    ) private override {
        /// check how many tokens can still be minted.
        _mustBeMintable(amount);
        _mintable -= amount;
        super._mint(
            to,
            amount
        );
    }

    function _burn(
        address account,
        uint amount
    ) private override {
        /// reduce max supply for each burn.
        _maxSupply -= amount;
        super._burn(
            account,
            amount
        );
    }
}