// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "smart_contracts/libraries/Terminal.sol";
import "smart_contracts/libraries/Math.sol";

interface IERC20 {
    function balanceOf(address _account) external view returns (uint256);

    function transfer(address _recipient, uint256 _amount)
        external
        returns (bool);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external returns (bool);
}

contract Conduit {
    function Itransfer(
        address _token,
        address _recipient,
        uint256 _amount
    ) internal {
        IERC20.token = IERC20(_token);
        return token.transfer(_recipient, _amount);
    }

    function ItransferFrom(
        address _token,
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal {
        IERC20.token = IERC20(_token);
        token.transferFrom(_sender, _recipient, _amount);
    }

    function IApprove(
        address _token,
        address _spender,
        address _amount
    ) internal {
        IERC20.token = IERC20(_token);
        return token.approve(_spender, _amount);
    }

    function IBalanceOf(address _token, address _account) internal {
        IERC20.token = IERC20(_token);
        return token.balanceOf(_account);
    }

    function IAllowance(
        address _token,
        address _owner,
        address _spender
    ) internal {
        IERC20.token = IERC20(_token);
        return token.allowance(_owner, _spender);
    }
}
