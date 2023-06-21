// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "deps/openzeppelin/token/ERC20/ERC20.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "deps/openzeppelin/access/AccessControl.sol";

import "smart_contracts/utils/Utils.sol";

interface IDreamToken {
    function totalSupply() external returns (uint);

    // Admin Commands
    function snapshot() external returns (uint snapshotId);
    
    // View
    function mintable() external view returns (uint remaining);
    function maxSupply() external view returns (uint maxSupply);
    function getVotes(address account) external view returns (uint votes);
    function getVotesAt(address account, uint snapshotId) external view returns (uint votes);
}

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, AccessControl {
    uint private _mintable;
    
    constructor(address[] memory admins) ERC20("DreamToken", "DREAM") ERC20Permit("DreamToken") {
        _mintable = Utils.convertToWei(200000000);

        for (uint i = 0; i < admins.length; i++) {
            _grantRole(DEFAULT_ADMIN_ROLE, admins[i]);
        }

        _mint(msg.sender, 200000000);
    }

    function _mustBeAdmin() internal view {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "DreamToken: must be an admin");
    }

    function _mustNotBeFutureLookup(uint snapshotId) internal view {
        require(snapshotId <= _getCurrentSnapshotId(), "DreamToken: must not be future lookup");
    }

    function _mustBeMintable(uint amount) internal view {
        require(amount <= _mintable, "DreamToken: insufficient amount left");
    }

    function _beforeTokenTransfer(address from, address to, uint amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint amount) internal override {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint amount) internal virtual override {
        _mustBeMintable(amount);
        _mintable -= amount;
        super._mint(to, amount);
    }

    function snapshot() public returns (uint snapshotId) {
        _mustBeAdmin();
        _snapshot();

        return _getCurrentSnapshotId();
    }

    function burn(uint amount) public override {
        _mustBeAdmin();
        _burn(msg.sender, amount);
    }

    function burnFrom(address from, uint amount) public override {
        _mustBeAdmin();
        _burn(from, amount);
    }

    function mintable() public view returns (uint) {
        return _mintable;
    }

    function maxSupply() public view returns (uint) {
        return totalSupply() + _mintable;
    }

    function getVotes(address account) public view returns (uint) {
        return balanceOfAt(account, _getCurrentSnapshotId());
    }

    function getVotesAt(address account, uint snapshotId) public view returns (uint) {
        _mustNotBeFutureLookup(snapshotId);
        return balanceOfAt(account, snapshotId);
    }
}