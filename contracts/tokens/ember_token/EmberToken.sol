// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

// these imports dont work need the actual physical libraries
// need to replace these
import ".deps/npm/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import ".deps/npm/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import ".deps/npm/@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import ".deps/npm/@openzeppelin/contracts/access/AccessControl.sol";
import ".deps/npm/@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "smart_contracts/utils/Utils.sol";

contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, AccessControl {
    address[] accounts;
    
    mapping(address => bool) isRegistered;

    constructor(address terminal) ERC20("EmberToken", "EMBER") ERC20Permit("EmberToken") {
        if (msg.sender == terminal) {
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        }

        else {
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(DEFAULT_ADMIN_ROLE, terminal);
        }
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