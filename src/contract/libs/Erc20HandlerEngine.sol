// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;
import { IErc20 } from "../interfaces/standards/IErc20.sol";
import { FixedPointEngine } from "./math/FixedPointEngine.sol";

contract Erc20HandlerEngine is FixedPointEngine {
    function _name(IErc20 erc20) internal view virtual returns (Result memory, string memory) {
        try erc20.name() returns (string memory name) {
            return (Ok(), name);
        }
        catch Error(string memory reason) {
            return (Err(reason), "");
        }
        catch {
            return (Err("unableToFetchErc20Name"), "");
        }
    }

    function _symbol(IErc20 erc20) internal view virtual returns (Result memory, string memory) {
        try erc20.symbol() returns (string memory symbol) {
            return (Ok(), symbol);
        }
        catch Error(string memory reason) {
            return (Err(reason), "");
        }
        catch {
            return (Err("unableToFetchErc20Symbol"), "");
        }
    }

    function _decimals(IErc20 erc20) internal view virtual returns (Result memory, uint8) {
        try erc20.decimals() returns (uint8 decimals) {
            return (Ok(), decimals);
        }
        catch Error(string memory reason) {
            return (Err(reason), 0);
        }
        catch {
            return (Err("unableToFetchErc20Decimals"), 0);
        }
    }

    function _balance(IErc20 erc20, Rounding rounding) internal view virtual returns (Result memory, uint256) {
        uint8 decimals; {
            (Result memory result, uint8 decimals_) = _decimals(erc20);
            if (_isErr(result)) {
                return (result, 0);
            }
            decimals = decimals_;
        }
        uint256 balanceN; {
            (Result memory result, uint256 balanceN_) = _balanceN(erc20);
            if (_isErr(result)) {
                return (result, 0);
            }
            balanceN = balanceN_;
        }
        return _cst(balanceN, decimals, 18, rounding);
    }

    function _balanceN(IErc20 erc20) internal view virtual returns (Result memory, uint256) {
        return _balanceOfN(erc20, address(this));
    }

    function _balanceOf(IErc20 erc20, address account, Rounding rounding) internal view virtual returns (Result memory, uint256) {
        uint8 decimals; {
            (Result memory result, uint8 decimals_) = _decimals(erc20);
            if (_isErr(result)) {
                return (result, 0);
            }
            decimals = decimals_;
        }
        uint256 balanceN; {
            (Result memory result, uint256 balanceN_) = _balanceOfN(erc20, account);
            if (_isErr(result)) {
                return (result, 0);
            }
            balanceN = balanceN_;
        }
        return _cst(balanceN, decimals, 18, rounding);
    }

    function _balanceOfN(IErc20 erc20, address account) internal view virtual returns (Result memory, uint256) {
        try erc20.balanceOf(account) returns (uint256 balanceN) {
            return (Ok(), balanceN);
        }
        catch Error(string memory reason) {
            return (Err(reason), 0);
        }
        catch {
            return (Err("unableToFetchErc20Balance"), 0);
        }
    }

    function _allowance(IErc20 erc20, address owner, address spender, Rounding rounding) internal view virtual returns (Result memory, uint256) {
        uint8 decimals; {
            (Result memory result, uint8 decimals_) = _decimals(erc20);
            if (_isErr(result)) {
                return (result, 0);
            }
            decimals = decimals_;
        }
        uint256 allowanceN; {
            (Result memory result, uint256 allowanceN_) = _allowanceN(erc20, owner, spender);
            if (_isErr(result)) {
                return (result, 0);
            }
            allowanceN = allowanceN_;
        }
        return _cst(allowanceN, decimals, 18, rounding);   
    }

    function _allowanceN(IErc20 erc20, address owner, address spender) internal view virtual returns (Result memory, uint256) {
        try erc20.allowance(owner, spender) returns (uint256 allowance) {
            return (Ok(), allowance);
        }
        catch Error(string memory reason) {
            return (Err(reason), 0);
        }
        catch {
            return (Err("unableToFetchErc20Allowance"), 0);
        }
    }

    function _totalSupply(IErc20 erc20, Rounding rounding) internal view virtual returns (Result memory, uint256) {
        uint8 decimals; {
            (Result memory result, uint8 decimals_) = _decimals(erc20);
            if (_isErr(result)) {
                return (result, 0);
            }
            decimals = decimals_;
        }
        uint256 totalSupplyN; {
            (Result memory result, uint256 totalSupplyN_) = _totalSupplyN(erc20);
            if (_isErr(result)) {
                return (result, 0);
            }
            totalSupplyN = totalSupplyN_;
        }
        return _cst(totalSupplyN, decimals, 18, rounding);
    }

    function _totalSupplyN(IErc20 erc20) internal view virtual returns (Result memory, uint256) {
        try erc20.totalSupply() returns (uint256 totalSupply) {
            return (Ok(), totalSupply);
        }
        catch Error(string memory reason) {
            return (Err(reason), 0);
        }
        catch {
            return (Err("unableToFetchErc20TotalSupply"), 0);
        }
    }

    function _transfer(IErc20 erc20, address to, uint256 amount, Rounding rounding) internal virtual returns (Result memory) {
        uint8 decimals; {
            (Result memory result, uint8 decimals_) = _decimals(erc20);
            if (_isErr(result)) {
                return result;
            }
            decimals = decimals_;
        }
        uint256 amountN; {
            (Result memory result, uint256 amountN_) = _cst(amount, 18, decimals, rounding);
            if (_isErr(result)) {
                return result;
            }
            amountN = amountN_;
        }
        return _transferN(erc20, to, amountN);
    }

    function _transferN(IErc20 erc20, address to, uint256 amountN) internal virtual returns (Result memory) {
        try erc20.transfer(to, amountN) {
            return Ok();
        }
        catch Error(string memory reason) {
            return Err(reason);
        }
        catch {
            return Err("unableToTransferErc20");
        }
    }

    function _transferFrom(IErc20 erc20, address from, address to, uint256 amount, Rounding rounding) internal virtual returns (Result memory) {
        uint8 decimals; {
            (Result memory result, uint8 decimals_) = _decimals(erc20);
            if (_isErr(result)) {
                return result;
            }
            decimals = decimals_;
        }
        uint256 amountN; {
            (Result memory result, uint256 amountN_) = _cst(amount, 18, decimals, rounding);
            if (_isErr(result)) {
                return result;
            }
            amountN = amountN_;
        }
        return _transferFromN(erc20, from, to, amountN);
    }

    function _transferFromN(IErc20 erc20, address from, address to, uint256 amountN) internal virtual returns (Result memory) {
        try erc20.transferFrom(from, to, amountN) {
            return Ok();
        }
        catch Error(string memory reason) {
            return Err(reason);
        }
        catch {
            return Err("unableToTransferErc20FromAccount");
        }
    }

    function _approve(IErc20 erc20, address spender, uint256 amount, Rounding rounding) internal virtual returns (Result memory) {
        uint8 decimals; {
            (Result memory result, uint8 decimals_) = _decimals(erc20);
            if (_isErr(result)) {
                return result;
            }
            decimals = decimals_;
        }
        uint256 amountN; {
            (Result memory result, uint256 amountN_) = _cst(amount, 18, decimals, rounding);
            if (_isErr(result)) {
                return result;
            }
            amountN = amountN_;
        }
        return _approveN(erc20, spender, amountN);
    }

    function _approveN(IErc20 erc20, address spender, uint256 amountN) internal virtual returns (Result memory) {
        try erc20.approve(spender, amountN) {
            return Ok();
        }
        catch Error(string memory reason) {
            return Err(reason);
        }
        catch {
            return Err("unableToApproveErc20");
        }
    }
}