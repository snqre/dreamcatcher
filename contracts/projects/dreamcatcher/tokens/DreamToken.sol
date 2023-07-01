// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "contracts/deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/templates/libraries/Utils.sol";

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    uint256 private _mintable;
    uint256 private _maxSupply;

    modifier onlyIfMintable(uint256 amount) {
        require(
            amount <= _mintable,
            "DreamToken: The requested amount exceeds the available mintable tokens."
        );
        _;
    }

    constructor(address vault)
    ERC20("DreamToken", "DREAM")
    ERC20Permit("DreamToken") {
        uint256 initialSupply = 200_000_000;
        _mintable = Utils.convertToWei(initialSupply);
        _maxSupply = Utils.convertToWei(initialSupply);
        _mint(vault, Utils.convertToWei(initialSupply));
    }

    function snapshot_()
    external
    returns (uint256) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function getCurrentSnapshotId() public view returns (uint256) {
        return _getCurrentSnapshotId();
    }

    function maxSupply() public view returns (uint256) { 
        return _maxSupply; 
    }

    function mintable() public view returns (uint256) {
        return _mintable;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
    internal override {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
    internal override
    onlyIfMintable(amount) {
        _mintable -= amount;
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
    internal override {
        _maxSupply -= amount;
        super._burn(account, amount);
    }
}