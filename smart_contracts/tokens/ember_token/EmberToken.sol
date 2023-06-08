// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "deps/openzeppelin/token/ERC20/ERC20.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";

// im still being a pig and pulling this from github
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

// yup ...
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

import "deps/openzeppelin/access/AccessControl.sol";
import "smart_contracts/utils/Utils.sol";

contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, AccessControl {
    address[] accounts;
    
    mapping(address => bool) isRegistered;

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

    // $ember is non transferable
    function _transfer() internal override {}

    function _mint(address to, uint amount) internal override {
        if (!isRegistered[to]) {
            accounts.push(to);
            isRegistered[to] = true;
        }

        super._mint(to, amount);
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

    function getWeight(address account) public view returns (uint) {
        uint balance = balanceOfAt(account, _getCurrentSnapshotId());

        return (balance / getCurrentTotalSupply()) * 10000;
    }

    function getPastWeight(address account, uint snapshotId) public view returns (uint) {
        require(snapshotId <= _getCurrentSnapshotId());

        balance = balanceOfAt(account, snapshotId);

        return (balance / totalSupplyAt(snapshotId)) * 10000;
    }
}