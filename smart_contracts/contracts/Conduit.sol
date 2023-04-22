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
    
    function ITransfer_(address _token, address _to, uint256 _value) internal onlyAdmin returns (bool) {
        require(
            _token != address(0) &&
            _to != address(0) &&
            _value >= 0
        );
        IERC20 _token = IERC20(_token);
        _token.transfer(_to, _value);
    }

    function ITransferFrom_(address _token, address _sender, address _to, uint256 _value) internal onlyAdmin returns (bool) {
        require(
            _token != address(0) &&
            _sender != address(0) &&
            _to != address(0) &&
            _value >= 0
        );
        IERC20 _token = IERC20(_token);
        _token.transferFrom(_sender, _to, _value);
    }

    function IApprove_(address _token, address _spender, uint256 _value) internal onlyAdmin returns (bool) {
        IERC20 _token = IERC20(_token);
        _token.approve(_spender, _value);
    }

    function IBalanceOf_(address _token) internal returns (uint256) {
        IERC20 _token = IERC20(_token);
        _token.balanceOf(meta.vault);
    }
}
