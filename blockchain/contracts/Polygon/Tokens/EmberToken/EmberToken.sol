// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract EmberToken is
    ERC20,
    ERC20Burnable,
    ERC20Snapshot,
    AccessControl,
    ERC20Permit
{
    // safe math
    using SafeMath for uint256;

    address[] accounts;
    mapping(address => bool) private isRegistered;

    constructor(address terminal)
        ERC20("EmberToken", "EMBER")
        ERC20Permit("EmberToken")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, address(this));

        if (msg.sender != terminal) {
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(DEFAULT_ADMIN_ROLE, terminal);
        } else {
            // msg.sender == terminal
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        }
    }

    // ... private

    function _split(uint256 multiplier) internal {
        for (uint256 i = 0; i < accounts.length; i++) {
            uint256 balance = balanceOf(accounts[i]);
            uint256 newBalance = balance.mul(multiplier);
            uint256 amountToMint = newBalance.sub(balance);
            _mint(accounts[i], amountToMint);
        }
    }

    function _stack(uint256 divisor) internal {
        for (uint256 i = 0; i < accounts.length; i++) {
            uint256 balance = balanceOf(accounts[i]);
            uint256 newBalance = balance.div(divisor);
            uint256 amountToBurn = balance.sub(newBalance);
            _burn(accounts[i], amountToBurn);
        }
    }

    function _mintByPoints(address to, uint256 points) internal {
        require(points >= 0, "EmberToken::_mintByPoints(): points < 0");
        require(
            points <= 10_000,
            "EmberToken::_mintByPoints(): points > 10_000"
        );
        uint256 amountToMint = (totalSupply() / 10_000) * points;
        _mint(to, amountToMint);
    }

    function _burnByPoints(address account, uint256 points) internal {
        uint256 weight = getWeight(account);
        require(points >= 0, "EmberToken::_burnByPoints(): points < 0");
        require(
            points <= weight,
            "EmberToken::_burnByPoints(): insufficient weighting"
        );
        uint256 amountToBurn = (totalSupply() / 10_000) * points;
        require(
            balanceOf(account) >= amountToBurn,
            "EmberToken::_burnByPoints(): insufficient balance"
        );
        _burn(account, amountToBurn);
    }

    function _convertToWei(uint256 value) internal pure returns (uint256) {
        return value * 10**18;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    // non transferable
    function _transfer() internal override {}

    function _mint(address to, uint256 amount) internal override {
        if (!isRegistered[to]) {
            accounts.push(to);
            isRegistered[to] = true;
        }

        super._mint(to, amount);
    }

    // ... owner

    function snapshot() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _snapshot();
    }

    function mint(address to, uint256 amount)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _mint(to, amount);
    }

    // ... public

    function getCurrentTotalSupply() public view returns (uint256) {
        return totalSupplyAt(_getCurrentSnapshotId());
    }

    function getWeight(address account) public view returns (uint256) {
        uint256 balance = balanceOfAt(account, _getCurrentSnapshotId());

        return balance.div(getCurrentTotalSupply()).mul(10_000);
    }

    function getPastWeight(address account, uint256 snapshotId)
        public
        view
        returns (uint256)
    {
        require(
            snapshotId <= _getCurrentSnapshotId(),
            "EmberToken::getPastWeight(): future lookup"
        );

        balance = balanceOfAt(account, snapshotId);

        return balance.div(totalSupplyAt(snapshotId)).mul(10_000);
    }
}
