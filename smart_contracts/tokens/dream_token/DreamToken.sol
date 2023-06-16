// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "deps/openzeppelin/token/ERC20/ERC20.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "deps/openzeppelin/access/AccessControl.sol";

import "smart_contracts/utils/Utils.sol";

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, AccessControl {
    uint private mintable_;

    constructor(address[] memory admins) ERC20("DreamToken", "DREAM") ERC20Permit("DreamToken") {
        mintable_ = Utils.convertToWei(200000000);

        for (uint i = 0; i < admins.length; i++) {
            _grantRole(DEFAULT_ADMIN_ROLE, admins[i]);
        }
    }

    function _mustBeAdmin() internal view {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "DreamToken: must be an admin");
    }

    function _mustNotBeFutureLookup(uint snapshotId) internal view {
        require(snapshotId <= _getCurrentSnapshotId(), "DreamToken: must not be future lookup");
    }

    function _mustBeMintable(uint amount) internal view {
        require(amount <= mintable_, "DreamToken: insufficient mintable amount left");
    }

    function _beforeTokenTransfer(address from, address to, uint amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint amount) internal override {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint amount) internal override {
        _mustBeMintable(amount);
        mintable_ -= amount;
        super._mint(to, amount);
    }

    function snapshot() public returns (uint snapshotId) {
        _mustBeAdmin();
        _snapshot();

        return _getCurrentSnapshotId();
    }

    function mint(address to, uint amount) public {
        _mustBeAdmin();
        _mint(to, amount);
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
        return mintable_;
    }

    function maxSupply() public view returns (uint) {
        return totalSupply() + mintable_;
    }

    function getVotes(address account) 
        public view returns (uint) {
        return balanceOfAt(
            account,
            _getCurrentSnapshotId()
        );
    }

    function getPastVotes(address account, uint snapshotId)
        public view returns (uint) {
        _mustNotBeFutureLookup(snapshotId);
        return balanceOfAt(
            account,
            snapshotId
        );
    }

    /**
     * @dev Get weight of user from $DREAM
     */
    function getWeight(address account) public view returns (uint) {
        uint balance = balanceOfAt(account, _getCurrentSnapshotId());
        uint totalSupply = totalSupplyAt(_getCurrentSnapshotId());

        require(balance >= 1, "DreamToken: insufficient balance");
        require(totalSupply >= 1, "DreamToken: insufficient totalSupply");

        return (balance * 10000) / totalSupply;
    }

    function getPastWeight(address account, uint snapshotId) public view returns (uint) {
        _mustNotBeFutureLookup(snapshotId);
        uint balance = balanceOfAt(account, _getCurrentSnapshotId());
        uint totalSupply = totalSupplyAt(_getCurrentSnapshotId());

        require(balance >= 1, "DreamToken: insufficient balance");
        require(totalSupply >= 1, "DreamToken: insufficient totalSupply");

        return (balance * 10000) / totalSupply;
    }
}