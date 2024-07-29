// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;
import { IUniswapV2Router02 } from "../imports/uniswap/v2/interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Factory } from "../imports/uniswap/v2/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "../imports/uniswap/v2/interfaces/IUniswapV2Pair.sol";
import { IErc20 } from "../interfaces/standards/IErc20.sol";
import { Erc20HandlerEngine } from "./Erc20HandlerEngine.sol";

contract RouterAdaptorEngine is Erc20HandlerEngine {
    function _slippage(IUniswapV2Router02 router, address[] memory path, uint256 amountIn, Rounding rounding) internal view returns (Result memory, uint256) {
        uint256 real; {
            (Result memory result, uint256 real_) = _realQuote(router, path, amountIn, rounding);
            if (_isErr(result)) {
                return (result, 0);
            }
            real = real_;
        }
        uint256 best; {
            (Result memory result, uint256 best_) = _bestQuote(router, path, amountIn, rounding);
            if (_isErr(result)) {
                return (result, 0);
            }
            best = best_;
        }
        return
            real == 0 && best != 0 ? (Ok(), 0) :
            real != 0 && best == 0 ? (Ok(), 100 ether) :
            real == 0 && best == 0 ? (Ok(), 100 ether) :
            real >= best ? (Ok(), 0) :
            _lss(real, best, 18, rounding);
    }

    function _bestQuote(IUniswapV2Router02 router, address[] memory path, uint256 amountIn, Rounding rounding) internal view returns (Result memory, uint256) {
        if (amountIn == 0) {
            return (Err("insufficientAmountIn"), 0);
        }
        IErc20 token0 = IErc20(path[0]);
        IErc20 token1 = IErc20(path[path.length - 1]);
        uint8 decimals0; {
            (Result memory result, uint8 decimals) = _decimals(token0);
            if (_isErr(result)) {
                return (result, 0);
            }
            decimals0 = decimals;
        }
        uint8 decimals1; {
            (Result memory result, uint8 decimals) = _decimals(token1);
            if (_isErr(result)) {
                return (result, 0);
            }
            decimals1 = decimals;
        }
        IUniswapV2Pair pair; {
            IUniswapV2Factory factory; {
                try router.factory() returns (address factory_) {
                    if (factory_ == address(0)) {
                        return (Err("invalidFactory"), 0);
                    }
                    factory = IUniswapV2Factory(factory_);
                }
                catch Error(string memory reason) {
                    return (Err(reason), 0);
                }
                catch {
                    return (Err("unableToFetchFactory"), 0);
                }
            }
            try factory.getPair(address(token0), address(token1)) returns (address pair_) {
                if (pair_ == address(0)) {
                    return (Err("pairNotFound"), 0);
                }
                pair = IUniswapV2Pair(pair_);
            }
            catch Error(string memory reason) {
                return (Err(reason), 0);
            }
            catch {
                return (Err("unableToFetchPair"), 0);
            }
        }
        uint256 reserve0;
        uint256 reserve1; {
            try pair.getReserves() returns (uint112 reserve0_, uint112 reserve1_, uint32) {
                if (reserve0_ == 0 || reserve1_ == 0) {
                    return (Err("insufficientLiquidity"), 0);
                }
                reserve0 = reserve0_;
                reserve1 = reserve1_;
            }
            catch Error(string memory reason) {
                return (Err(reason), 0);
            }
            catch {
                return (Err("unableToFetchReserves"), 0);
            }
        }
        IErc20[] memory pairTokens = new IErc20[](2); {
            try pair.token0() returns (address pairToken0_) {
                if (pairToken0_ == address(0)) {
                    return (Err("invalidPairToken0"), 0);
                }
                pairTokens[0] = IErc20(pairToken0_);
            }
            catch Error(string memory reason) {
                return (Err(reason), 0);
            }
            catch {
                return (Err("unableToFetchPairToken0"), 0);
            }
            try pair.token0() returns (address pairToken1_) {
                if (pairToken1_ == address(0)) {
                    return (Err("invalidPairToken1"), 0);
                }
                pairTokens[1] = IErc20(pairToken1_);
            }
            catch Error(string memory reason) {
                return (Err(reason), 0);
            }
            catch {
                return (Err("unableToFetchPairToken1"), 0);
            }
        }
        {
            (Result memory result, uint256 reserve0_, uint256 reserve1_) = _sort(address(token0), address(pairTokens[0]), reserve0, reserve1, decimals0, decimals1, Rounding.DOWN);
            if (_isErr(result)) {
                return (result, 0);
            }
            reserve0 = reserve0_;
            reserve0 = reserve1_;
        }
        try router.quote(amountIn, reserve0, reserve1) returns (uint256 quote) {
            return (Ok(), quote);
        }
        catch Error(string memory reason) {
            return (Err(reason), 0);
        }
        catch {
            return (Err("unableToFetchQuote"), 0);
        }
    }

    function _realQuote(IUniswapV2Router02 router, address[] memory path, uint256 amountIn, Rounding rounding) internal view returns (Result memory, uint256) {
        if (amountIn == 0) {
            return (Err("insufficientAmountIn"), 0);
        }
        IErc20 token0 = IErc20(path[0]);
        IErc20 token1 = IErc20(path[path.length - 1]);
        uint8 decimals0; {
            (Result memory result, uint8 decimals) = _decimals(token0);
            if (_isErr(result)) {
                return (result, 0);
            }
            decimals0 = decimals;
        }
        uint8 decimals1; {
            (Result memory result, uint8 decimals) = _decimals(token1);
            if (_isErr(result)) {
                return (result, 0);
            }
            decimals1 = decimals;
        }
        uint256 amountInN; {
            (Result memory result, uint256 amountInN_) = _cst(amountIn, 18, decimals0, rounding);
            if (_isErr(result)) {
                return (result, 0);
            }
            amountInN = amountInN_;
        }
        try IUniswapV2Router02(router).getAmountsOut(amountInN, path) returns (uint256[] memory amountsN) {
            uint256 amountN = amountsN[amountsN.length - 1];
            uint256 amount; {
                (Result memory result, uint256 amount_) = _cst(amountN, decimals1, 18, rounding);
                if (_isErr(result)) {
                    return (result, 0);
                }
                amount = amount_;
            }
            return (Ok(), amount);
        }
        catch Error(string memory reason) {
            return (Err(reason), 0);
        }
        catch {
            return (Err("unableToFetchAmountsOut"), 0);
        }
    }

    function _swap(IUniswapV2Router02 router, address[] memory path, uint256 amountIn, uint256 slippageThreshold) internal returns (Result memory, uint256) {
        /** @validation */ {
            uint256 slippage; {
                (Result memory result, uint256 slippage_) = _slippage(router, path, amountIn, Rounding.ZERO);
                if (_isErr(result)) {
                    return (result, 0);
                }
                slippage = slippage_;
            }
            if (slippage > slippageThreshold) {
                return (Err("slippageExceedsThreshold"), 0);
            }
            IErc20 token0 = IErc20(path[0]);
            IErc20 token1 = IErc20(path[path.length - 1]);
            uint8 decimals0; {
                (Result memory result, uint8 decimals) = _decimals(token0);
                if (_isErr(result)) {
                    return (result, 0);
                }
                decimals0 = decimals;
            }
            uint8 decimals1; {
                (Result memory result, uint8 decimals) = _decimals(token1);
                if (_isErr(result)) {
                    return (result, 0);
                }
                decimals1 = decimals;
            }
            uint256 balance; {
                (Result memory result, uint256 balance_) = _balance(token0, Rounding.DOWN);
                if (_isErr(result)) {
                    return (result, 0);
                }
                balance = balance_;
            }
            if (balance < amountIn) {
                return (Err("insufficientFunds"), 0);
            }
            uint256 amountInN; {
                (Result memory result, uint256 amountInN_) = _cst(amountIn, 18, decimals0, Rounding.DOWN);
                if (_isErr(result)) {
                    return (result, 0);
                }
                amountInN = amountInN_;
            }
            /** @approve */ {
                Result memory result = _approve(token0, address(router), 0, Rounding.ZERO);
                if (_isErr(result)) {
                    return (result, 0);
                }
            }
            /** @approve */ {
                Result memory result = _approve(token0, address(router), amountIn, Rounding.UP);
                if (_isErr(result)) {
                    return (result, 0);
                }
            }
            try router.swapExactTokensForTokens(amountInN, 0, path, address(this), block.timestamp) returns (uint256[] memory amountsOutN) {
                uint256 amountOutN = amountsOutN[amountsOutN.length - 1];
                uint256 amountOut; {
                    (Result memory result, uint256 amountOut_) = _cst(amountOutN, decimals0, 18, Rounding.DOWN);
                    if (_isErr(result)) {
                        return (result, 0);
                    }
                    amountOut = amountOut_;
                }
                return (Ok(), amountOut);
            }
            catch Error(string memory reason) {
                return (Err(reason), 0);
            }
            catch {
                return (Err("unableToSwap"), 0);
            }
        }
    }

    function _sort(address token0, address pairToken0, uint256 reserve0, uint256 reserve1, uint8 decimals0, uint8 decimals1, Rounding rounding) private pure returns (Result memory, uint256, uint256) {
        if (address(token0) == address(pairToken0)) {
            uint256 temp0;
            uint256 temp1;
            temp0 = reserve0;
            temp1 = reserve1;
            reserve0 = temp0;
            reserve1 = temp1;
        } 
        {
            (Result memory result, uint256 reserve0_) = _cst(reserve0, decimals0, 18, rounding);
            if (_isErr(result)) {
                return (result, 0, 0);
            }
            reserve0 = reserve0_;
        } 
        {
            (Result memory result, uint256 reserve1_) = _cst(reserve1, decimals1, 18, rounding);
            if (_isErr(result)) {
                return (result, 0, 0);
            }
            reserve1 = reserve1_;
        }
        return (Ok(), reserve0, reserve1);
    }
}