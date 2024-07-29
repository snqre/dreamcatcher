// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;
import { IErc20 } from "../interfaces/standards/IErc20.sol";
import { UD60x18 } from "../imports/prb-math/UD60x18.sol";
import { Math } from "./math/Math.sol";
import { UD } from "./math/Math.sol";

library TokenIntegration {
    
    function name(IErc20 token) internal view returns (string memory) {
        try token.name() returns (string memory name) {
            return name;
        }
        catch {
            return "";
        }
    }

    function symbol(IErc20 tkn) internal view returns (string memory) {
        try tkn.symbol() returns (string memory symbol) {
            return symbol;
        }
        catch {
            return "";
        }
    }

    function decimals(IErc20 tkn) internal view returns (uint8, bool success) {
        try tkn.decimals() returns (uint8 decimals) {
            return decimals < 2 || decimals > 18 ? (0, false) : (decimals, true);
        }
        catch {
            return (0, false);
        }
    }

    function balanceOf(IErc20 tkn, address account) internal view returns (UD60x18) {
        (uint8 decimals_, bool success) = decimals(tkn);
        if (!success) {
            return UD(0);
        }
        try tkn.balanceOf(account) returns (uint256 balance) {
            return UD(Math.cst(balance, decimals_, 18));
        }
        catch {
            return UD(0);
        }
    }

    function allowance(IErc20 tkn, address owner, address spender) internal view returns (UD60x18) {
        (uint8 decimals_, bool success) = decimals(tkn);
        if (!success) {
            return UD(0);
        }
        try tkn.allowance(owner, spender) returns (uint256 allowance) {
            return UD(Math.cst(allowance, decimals_, 18));
        }
        catch {
            return UD(0);
        }
    }

    function totalSupply(IErc20 tkn) internal view returns (UD60x18) {
        (uint8 decimals_, bool success) = decimals(tkn);
        if (!success) {
            return UD(0);
        }
        try tkn.totalSupply() returns (uint256 totalSupply) {
            return UD(Math.cst(totalSupply, decimals_, 18));
        }
        catch {
            return UD(0);
        }
    }

    function transfer(IErc20 tkn, address to, UD60x18 amount) internal returns (bool) {
        (uint8 decimals_, bool success) = decimals(tkn);
        if (!success) {
            return false;
        }
        try tkn.transfer(to, Math.cst(amount.intoUint256(), 18, decimals_)) returns (bool success) {
            return success;
        }
        catch {
            return false;
        }
    }

    function transferFrom(IErc20 tkn, address from, address to, UD60x18 amount) internal returns (bool) {
        (uint8 decimals_, bool success) = decimals(tkn);
        if (!success) {
            return false;
        }
        try tkn.transferFrom(from, to, Math.cst(amount.intoUint256(), 18, decimals_)) returns (bool success) {
            return success;
        }
        catch {
            return false;
        }
    }

    function approve(IErc20 tkn, address spender, UD60x18 amount) internal returns (bool) {
        (uint8 decimals_, bool success) = decimals(tkn);
        if (!success) {
            return false;
        }
        try tkn.approve(spender, Math.cst(amount.intoUint256(), 18, decimals_)) returns (bool success) {
            return success;
        }
        catch {
            return false;
        }
    }
}