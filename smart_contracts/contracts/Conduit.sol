// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
conduit is the way to interact with tokens just by needing the token contract
assuming all ERC20 have the same interface it should work
when the contract tries to use the function there is error handling so itll just not do it
with this we can access any tokens we have within the contract
 */

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
        require(_token != address(0), "Invalid token address");
        require(_recipient != address(0), "Invalid recipient address");
        require(_amount > 0, "Invalid transfer amount");

        IERC20.tokenContract = IERC20(_token);
        // error handling so if there is no matching interface we dont blow up the whole contract
        try tokenContract.transfer(_recipient, _amount) {
            // success
        } catch Error(string memory _errorMessage) {
            // revert with a custom error message
            revert(_errorMessage);
        } catch {
            // revert with a generic error message
            revert("transfer() failed");
        }
    }

    function ItransferFrom(
        address _token,
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal {
        require(_token != address(0), "Invalid token address");
        require(_sender != address(0), "Invalid sender address");
        require(_recipient != address(0), "Invalid recipient address");
        require(_amount > 0, "Invalid transfer amount");
        IERC20.token = IERC20(_token);
        // error handling so if there is no matching interface we dont blow up the whole contract
        try token.transferFrom(_sender, _recipient, _amount) {
            // success
        } catch Error(string memory _errorMessage) {
            // revert with a custom error message
            revert(_errorMessage);
        } catch {
            // revert with a generic error message
            revert("transferFrom() failed");
        }
    }

    function IApprove(
        address _token,
        address _spender,
        address _amount
    ) internal {
        IERC20.token = IERC20(_token);
        // error handling so if there is no matching interface we dont blow up the whole contract
        try token.approve(_spender, _amount) {
            // success
        } catch Error(string memory _errorMessage) {
            // revert with a custom error message
            revert(_errorMessage);
        } catch {
            // revert with a generic error message
            revert("approve() failed");
        }
    }

    function IBalanceOf(address _token, address _account) internal {
        IERC20.token = IERC20(_token);
        // error handling so if there is no matching interface we dont blow up the whole contract
        try token.balanceOf(_account) {
            // success
            return token.balanceOf(_account);
        } catch Error(string memory _errorMessage) {
            // revert with a custom error message
            revert(_errorMessage);
        } catch {
            // revert with a generic error message
            revert("balanceOf() failed");
        }
    }

    function IAllowance(
        address _token,
        address _owner,
        address _spender
    ) internal {
        IERC20.token = IERC20(_token);
        // error handling so if there is no matching interface we dont blow up the whole contract
        try token.allowance(_owner, _spender) {
            // success
            return token.allowance(_owner, _spender);
        } catch Error(string memory _errorMessage) {
            // revert with a custom error message
            revert(_errorMessage);
        } catch {
            // revert with a generic error message
            revert("allowance() failed");
        }
    }
}
