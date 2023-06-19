// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;



import "deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "deps/openzeppelin/token/ERC20/ERC20.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "deps/openzeppelin/access/AccessControl.sol";

import "smart_contracts/utils/Utils.sol";

contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, AccessControl {
    address[] accounts;
    
    mapping(address => bool) isRegistered;

    /**
     * @notice Only Dream can change Ember
     */
    constructor() ERC20("EmberToken", "EMBER") ERC20Permit("EmberToken") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _split(uint mul) internal {
        for (uint i = 0; i < accounts.length; i++) {
            uint balance = balanceOf(accounts[i]);
            uint newBalance = balance * mul;
            uint amountToMint = newBalance - balance;
            _mint(accounts[i], amountToMint);
        }
    }

    function _stack(uint div) internal {
        for (uint i = 0; i < accounts.length; i++) {
            uint balance = balanceOf(accounts[i]);
            uint newBalance = balance / div;
            uint amountToBurn = balance - newBalance;
            _burn(accounts[i], amountToBurn);
        }
    }

    function _mintByPoints(address to, uint points) internal {
        require(points >= 1);
        require(points <= 10000);

        uint amountToMint = (totalSupply() / 10000) * points;
        _mint(to, amountToMint);
    }

    function _mint(address to, uint amount) internal override {
        if (!isRegistered[to]) {
            accounts.push(to);
            isRegistered[to] = true;
        }

        super._mint(to, amount);
    }

    /**
     * @dev This is a required override
     */
    function _beforeTokenTransfer(address from, address to, uint amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function snapshot() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _snapshot();
    }

    function mint(address to, uint amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, amount);
    }

    function mintByPoints(address to, uint points) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mintByPoints(to, points);
    }

    // this is like a stock split everyone maintain the same ownership
    function split(uint mul) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _split(mul);
    }

    // this is like a stock merger everyone maintains the same ownership
    function stack(uint div) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _stack(div);
    }

    function getCurrentTotalSupply() public view returns (uint) {
        return totalSupplyAt(_getCurrentSnapshotId());
    }

    /**
     * @dev Make sure to snapshot from DreamToken before using this
     * @dev Without a valid current snapshotId it will not work
     */
    function getWeight(address account) public view returns (uint) {
        uint balance = balanceOfAt(account, _getCurrentSnapshotId());
        uint supply = totalSupplyAt(_getCurrentSnapshotId());

        require(balance >= 1, "EmberToken: insufficient balance");
        require(supply >= 1, "EmberToken: insufficient supply");

        // weight should be the percentage of ember token owned over supply
        return (balance * 10000) / supply;
    }

    function getPastWeight(address account, uint snapshotId) public view returns (uint) {
        require(snapshotId <= _getCurrentSnapshotId());

        uint balance = balanceOfAt(account, snapshotId);

        return (balance / totalSupplyAt(snapshotId)) * 10000;
    }
}