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

contract Conduit is Token {
    
    function ITransfer(address _token, address _to, uint256 _value) external onlyAdmin returns (bool) {
        require(
            _token != address(0) &&
            _to != address(0) &&
            _value >= 0
        );
        IERC20 _t = IERC20(_token);
        _t.transfer(_to, _value);
        return true;
    }

    function ITransferFrom(address _token, address _sender, address _to, uint256 _value) external onlyAdmin returns (bool) {
        require(
            _token != address(0) &&
            _sender != address(0) &&
            _to != address(0) &&
            _value >= 0
        );
        IERC20 _t = IERC20(_token);
        _t.transferFrom(_sender, _to, _value);
        return true;
    }

    function IApprove(address _token, address _spender, uint256 _value) external onlyAdmin returns (bool) {
        IERC20 _t = IERC20(_token);
        _t.approve(_spender, _value);
        return true;
    }

    function IBalanceOf(address _token, address _owner) external view returns (uint256) {
        IERC20 _t = IERC20(_token);
        return _t.balanceOf(_owner);
    }
}
