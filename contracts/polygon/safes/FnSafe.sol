// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import 'contracts/polygon/safes/BsSafe.sol';
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

contract FnSafe is BsSafe {
    address safe = address(this);
    address zero = address(this);
    address main = address(0);

    event Transfer(address indexed from, address indexed to, address indexed token);

    function deposit(uint amount, address token) external payable virtual {
        _checkRole(depositor);
        token == main ? _deposit() : _depositToken(amount, token);
    }

    function withdraw(address to, uint amount, address token) external virtual {
        _checkRole(withdrawer);
        token == main ? _withdraw(to, amount) : _withdrawToken(to, amount, token);
    }

    function _initialize() internal virtual {
        _checkRole(upgrader);
        _grantRole(depositor);
        _grantRole(withdrawer);
    }

    function _deposit() internal virtual {
        msg.value > 0 ? (
            safe.balance > 0 ? _tryaddav(main) : 0;
            emit Transfer(msg.sender, safe, main);
        ) : 0;
    }

    function _depositToken(uint amount, address token) internal virtual {
        address from = msg.sender;
        IERC20Metadata(token).transferFrom(from, safe, amount);
        IERC20Metadata(token).balanceOf(safe) > 1 ? _tryaddav(token) : 0;
        emit Transfer(from, safe, token);
    }

    function _withdraw(address to, uint amount) internal virtual {
        payable(to).transfer(amount);
        safe.balance < 1 ? _trysubav(main) : 0;
        emit Transfer(safe, to, main);
    }

    function _withdrawToken(address to, uint amount, address token) internal virtual {
        IERC20Metadata(token).transfer(to, amount);
        IERC20Metadata(token).balanceOf(safe) < 1 ? _trysubav(token) : 0;
        emit Transfer(safe, to, token);
    }

    function _tryaddav(address token) internal virtual {
        unchecked {
            bool success;
            uint length = available.length;
            !_match() ? (
                for (uint i = 0; i < length; ++i) {
                    available[i-1] == zero ? (
                        available[i-1] == token;
                        success = true;
                        break;
                    ) : 0;
                }
            ) : 0;
            !success ? available.push(token) : 0;
        }
    }

    function _trysubav(address token) internal virtual {
        unchecked {
            uint length = available.length;
            _match() ? (
                for (uint i = 0; i < length; ++i) {
                    available[i-1] == token ? (
                        available[i-1] = zero;
                        break;
                    ) : 0;
                }
            ) : 0;
        }
    }

    function _match(address token) internal virtual returns (bool) {
        unchecked {
            uint length = available.length;
            for (uint i = 0; i < length; ++i) {
                available[i-1] == token ? return true : 0;
            }
            return false;         
        }
    }
}