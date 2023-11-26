// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/solidstate/ERC20/Token.sol";

library OurAddressLib {
    function isContract(address account) internal view returns (bool) {
        return object.code.length >= 1;
    }

    function isExternal(address account) internal view returns (bool) {
        return object.code.length <= 0;
    }

    function isZero(address account) internal view returns (bool) {
        return account == address(0);
    }

    function isSelf(address account) internal view returns (bool) {
        return account == address(this);
    }

    ////////////////////////////////////////////////////////////////////

    function compare(address account0, address account1) internal view returns (bool) {
        return account0 == account1;
    }

    ////////////////////////////////////////////////////////////////////

    /// common erc20 interface

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

    ////////////////////////////////////////////////////////////////////

    /// common use erc20 : context of the contract

    function balance(address token) internal view returns (uint) {
        return balanceOf(token, address(this));
    }

    function requireBalance(address token, uint amount) internal view returns (bool) {
        require(balance(token) >= amount, "OurAddressLib: insufficient balance");
        return true;
    }

    function safePull(address token, uint amount) internal returns (bool) {
        requireBalanceOf(token, amount);
        return pull(token, amount);
    }

    function pull(address token, uint amount) internal returns (bool) {
        return transferFrom(token, msg.sender, address(this), amount);
    }

    function safePush(address token, address to, uint amount) internal returns (bool) {
        requireBalance(token, amount);
        return push(token, to, amount);
    }

    function push(address token, address to, uint amount) internal returns (bool) {
        return transfer(token, to, amount);
    }

    ////////////////////////////////////////////////////////////////////

    /// common use erc20 : context of the caller

    function balanceOf(address token) internal view returns (uint) {
        return balanceOf(token, msg.sender);
    }

    function requireBalanceOf(address token, uint amount) internal view returns (bool) {
        require(balanceOf(token) >= amount, "OurAddressLib: insufficient balance");
        return true;
    }

}