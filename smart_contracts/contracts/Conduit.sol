// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/*
conduit is the way to interact with tokens just by needing the token contract
assuming all ERC20 have the same interface it should work
when the contract tries to use the function there is error handling so itll just not do it
with this we can access any tokens we have within the contract
 */

/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details

import "smart_contracts/contracts/Token.sol";

interface IConduit {

    function ITransfer(
        address indexed _token, 
        address indexed _to, 
        uint256 _value
    ) external returns (bool);

    function ITransferFrom(
        address indexed _token, 
        address indexed _sender, 
        address indexed _to, 
        uint256 _value
    ) external returns (bool);

    function IApprove(
        address indexed _token, 
        address indexed _spender,
        uint256 _value
    ) external returns (bool);

    function IBalanceOf(
        address indexed _token, 
        address indexed _owner
    ) external returns (bool);
}

contract Conduit is IConduit, Token {
    
    function ITransfer_(address _token, address _to, uint256 _value) internal onlyAdmin {
        require(
            _token != address(0) &&
            _to != address(0) &&
            _value >= 0
        );
        IERC20 _token = IERC20(_token);
        try _token.transfer(_to, _value) {
            // do nothing
        } catch Error(string memory _message) {
            revert(_message);
        } catch {
            revert();
        }
    }

    function ItransferFrom(address _token, address _sender, address _to, uint256 _value) external onlyAdmin {
        require(
            _token != address(0) &&
            _sender != address(0) &&
            _to != address(0) &&
            _value >= 0
        );
        IERC20 _token = IERC20(_token);
        try _token.transferFrom(_sender, _to, _value) {
            emit ItransferFrom(_token, _sender, _to, _value);
        } catch Error(string memory _message) {
            revert(_message);
        } catch {
            revert();
        }
    }

    function Iapprove(address _token, address _spender, uint256 _value) external onlyAdmin {
        IERC20 _token = IERC20(_token);
        try _token.approve(_spender, _value) {
            emit Ia
        }
        
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
