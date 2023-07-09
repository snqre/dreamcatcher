// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/templates/libraries/Utils.sol";
import "contracts/polygon/templates/modular-upgradeable/Authenticator.sol";

/** NOTE
    dream token is completely decentralized hence there are no commands we can use on it.
 */

interface IDreamToken {
    error InsufficientMintableBalance();
}

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    uint256 private _mintable;
    uint256 private _maxSupply;

    constructor(address vault)
        ERC20("DreamToken", "DREAM")
        ERC20Permit("DreamToken") {
        uint256 initialSupply = 200000000;
        _mintable = Utils.convertToWei(initialSupply);
        _maxSupply = Utils.convertToWei(initialSupply);
        _mint(vault, Utils.convertToWei(initialSupply));
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
        internal override {
        if (amount > _mintable) { revert InsufficientMintableBalance(); }
        
        _mintable -= amount;
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal override {
        _maxSupply -= amount;
        super._burn(account, amount);
    }

    /// ------
    /// PUBLIC.
    /// ------

    /// standard snapshot mechanism.
    function snapshot()
        external
        returns (uint) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    /// gets max supply.
    function maxSupply() 
        public view 
        returns (uint) { 
        return _maxSupply; 
    }

    /// gets the remaining amount of tokens that can be minted.
    function mintable() 
        public view 
        returns (uint) {
        return _mintable;
    }

    /// gets the last snapshot id.
    function getCurrentSnapshotId()
        external view
        returns (uint) {
        return _getCurrentSnapshotId();
    }
}