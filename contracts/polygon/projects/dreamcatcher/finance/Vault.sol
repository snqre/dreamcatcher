// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/Authenticator.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

interface IVault {
    /// vault-transfer
    function transfer(address target, address to, uint amount_)
    external
    returns (bool);

    /// vault-transfer-from
    function transferFrom(address target, address from, address to, uint amount_)
    external
    returns (bool);

    function deposit()
    external payable
    returns (bool);

    /// vault-withdraw
    function withdraw(address to, uint value)
    external
    returns (bool);

    event Transfer(address target, address from, address to, uint amount);
    event BudgetCreated(string reason, address[] indexed contracts, uint[] indexed amounts, uint indexed amount, address[] payees, uint startTimestamp, uint duration);

    error UnableToMakeTransfer(address target, address from, address to, uint amount);
    error InsufficientBalance(address target, address from, address to, uint amount);
}

contract Vault is IVault {
    using EnumerableSet for EnumerableSet.AddressSet;
    IAuthenticator public authenticator;

    /// accounting.
    mapping(address => uint) public amounts;
    uint public amount;

    constructor(address authenticator_) {
        authenticator = IAuthenticator(authenticator_);
    }

    /// ---------------
    /// BASIC UTILITIES.
    /// ---------------

    function transfer(address target, address to, uint amount_)
        public
        returns (bool) {
        /// check balance.
        if (IERC20(target).balanceOf(address(this)) < amount_) {
            revert InsufficientBalance(target, address(this), to, amount_);
        }

        authenticator.authenticate(msg.sender, "vault-transfer", true, true);
        bool success = IERC20(target).transfer(to, amount_);
        if (!success) { revert UnableToMakeTransfer(target, address(this), to, amount_); }
        
        /// update
        amounts[target] = IERC20(target).balanceOf(address(this));

        emit Transfer(target, address(this), to, amount_);
        return success;
    }

    function transferFrom(address target, address from, address to, uint amount_)
        public
        returns (bool) {
        /// check balance.
        if (IERC20(target).balanceOf(from) < amount_) {
            revert InsufficientBalance(target, from, to, amount_);
        }
        
        authenticator.authenticate(msg.sender, "vault-transfer-from", true, true);
        bool success = IERC20(target).transferFrom(from, to, amount_);
        if (!success) { revert UnableToMakeTransfer(target, from, to, amount_); }

        /// update
        amounts[target] = IERC20(target).balanceOf(address(this));

        emit Transfer(target, from, to, amount_);
        return success;
    }

    function deposit()
        external payable
        returns (bool) {
        amount += msg.value;
        return true;
    }

    function withdraw(address to, uint value)
        external
        returns (bool) {
        authenticator.authenticate(msg.sender, "vault-withdraw", true, true);
        amount -= value;
        address payable recipient = payable(to);
        recipient.transfer(value);
        return true;
    }
}