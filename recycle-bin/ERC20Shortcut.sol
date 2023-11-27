// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/solidstate/ERC20/Token.sol";

library ERC20Shortcut {

    error ERC20ShortcutInsufficientBalance();
    error ERC20ShortcutFailureToPullAsset();
    error ERC20ShortcutFailureToPushAsset();
    error ERC20ShortcutNonCompliant();

    function isCompliantERC20(address token) internal view returns (bool) {
        
    }

    function name(address token) internal view returns (string memory) {
        IToken tkn = IToken(token);
        return tkn.name();
    }

    function symbol(address token) internal view returns (string memory) {
        IToken tkn = IToken(token);
        return tkn.symbol();
    }

    function decimals(address token) internal view returns (uint8) {
        IToken tkn = IToken(token);
        return tkn.decimals();
    }

    function totalSupply(address token) internal view returns (uint) {
        IToken tkn = IToken(token);
        return tkn.totalSupply();
    }

    function balanceOf(address token, address account) internal view returns (uint) {
        IToken tkn = IToken(token);
        return tkn.balanceOf(account);
    }

    function transfer(address token, address to, uint amount) internal returns (bool) {
        IToken tkn = IToken(token);
        return tkn.transfer(to, amount);
    }

    function allowance(address token, address owner, address spender) internal view returns (uint) {
        IToken tkn = IToken(token);
        return tkn.allowance(owner, spender);
    }

    function approve(address token, address spender, uint amount) internal returns (bool) {
        IToken tkn = IToken(token);
        return tkn.approve(spender, amount);
    }

    function transferFrom(address token, address from, address to, uint amount) internal returns (bool) {
        IToken tkn = IToken(token);
        return tkn.transferFrom(from, to, amount);
    }

    function balance(address token) internal view returns (uint) {
        return balanceOf(token, address(this));
    }

    function requireBalance(address token, uint amount) internal view returns (bool) {
        if (balance(token) < amount) {
            revert ERC20ShortcutInsufficientBalance();
        }
        return true;
    }

    function safePull(address token, uint amount) internal returns (bool) {
        requireBalanceOf(token, amount);
        bool success = pull(token, amount);
        if (!success) {
            revert ERC20ShortcutFailureToPullAsset();
        }
    }

    function pull(address token, uint amount) internal returns (bool) {
        return transferFrom(token, msg.sender, address(this), amount);
    }

    function safePush(address token, address to, uint amount) internal returns (bool) {
        requireBalance(token, amount);
        bool success = push(token, to, amount);
        if (!success) {
            revert ERC20ShortcutFailureToPushAsset();
        }
    }

    function push(address token, address to, uint amount) internal returns (bool) {
        return transfer(token, to, amount);
    }

    function balanceOf(address token) internal view returns (uint) {
        return balanceOf(token, msg.sender);
    }

    function requireBalanceOf(address token, uint amount) internal view returns (bool) {
        if (balanceOf(token) < amount) {
            revert ERC20ShortcutInsufficientBalance();
        }
        return true;
    }
}