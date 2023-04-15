// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
conduit is the way to interact with tokens just by needing the token contract
assuming all ERC20 have the same interface it should work
when the contract tries to use the function there is error handling so itll just not do it
with this we can access any tokens we have within the contract
 */

import "smart_contracts/contracts/Token.sol";
import "smart_contracts/libraries/Math.sol";

contract Conduit is Token {
    event Itransfer(address indexed token, address indexed recipient, uint256 amount);
    event ItransferFrom(address indexed token, address indexed sender, address indexed recipient, uint256 amount);
    event IApprove(address indexed token, address indexed spender, uint256 amount);
    event IBalanceOf(address indexed token, address indexed account);
    event IAllowance(address indexed token, address indexed owner, address indexed spender);

    function Itransfer(address token, address recipient, uint256 amount) public checkConduitIsPaused onlyAdmin {
        require(token != address(0), "zero address");
        require(recipient != address(0), "zero address");
        require(amount > 0, "transfer amount is equal or less than zero");
        IERC20 token = IERC20(token);
        try token.transfer(recipient, amount) {emit Itransfer(token, recipient, amount);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function ItransferFrom(address token, address sender, address recipient, uint256 amount) public checkConduitIsPaused onlyAdmin {
        require(token != address(0), "zero address");
        require(sender != address(0), "zero address");
        require(recipient != address(0), "zero address");
        require(amount > 0, "transfer amount is equal or less than zero");
        IERC20 token = IERC20(token);
        try token.transferFrom(sender, recipient, amount) {emit ItransferFrom(token, sender, recipient, amount);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IApprove(address token, address spender, uint256 amount) public checkConduitIsPaused onlyAdmin {
        IERC20 token = IERC20(token);
        try token.approve(spender, amount) {emit IApprove(token, spender, amount);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IBalanceOf(address token, address account) public checkConduitIsPaused returns (uint256) {
        IERC20 token = IERC20(token);
        try token.balanceOf(account) {return token.balanceOf(account); emit IBalanceOf(token, account);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IAllowance(address token, address owner, address spender) public checkConduitIsPaused onlyAdmin returns (uint256) {
        IERC20 token = IERC20(token);
        try token.allowance(owner, spender) {return token.allowance(owner, spender); emit IAllowance(token, owner, spender);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }
}
