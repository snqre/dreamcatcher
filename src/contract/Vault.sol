// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;
import { IUniswapV2Router02 } from "./imports/uniswap/v2/interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Factory } from "./imports/uniswap/v2/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "./imports/uniswap/v2/interfaces/IUniswapV2Pair.sol";
import { IErc20 } from "./interfaces/standards/IErc20.sol";
import { IVToken } from "./interfaces/standards-native/IVToken.sol";
import { ERC20 } from "./imports/openzeppelin/token/ERC20/ERC20.sol";
import { Ownable } from "./imports/openzeppelin/access/Ownable.sol";

contract Vault {
    event Mint(address account);
    event Burn(address account);

    enum Side {
        TKN_CUR_PATH,
        CUR_TKN_PATH
    }

    struct Asset {
        IErc20 token;
        IErc20 currency;
        address[] tknCurPath; /// tkn -> curr
        address[] curTknPath; /// curr -> tkn
        uint256 targetAllocation;
    }

    struct Quote {  
        uint256 real;
        uint256 best;
        uint256 slippage;
    }

    struct Pair {
        IUniswapV2Pair pair;
        IErc20 token0;
        IErc20 token1;
        uint256 reserve0;
        uint256 reserve1;
        uint8 decimals0;
        uint8 decimals1;
    }

    Asset[] private _assets;
    IVToken private _vToken;
    IUniswapV2Router02 private _quickswap = IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
    IErc20 private _usdc = IErc20(0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359);
    uint256 private _nextRebalanceTimestamp;

    constructor(IVToken vToken, Asset[] memory assets) {
        require(vToken.decimals() == 18, "vTokenUnsupported");
        _vToken = vToken;
        for (uint256 i = 0; i < assets.length; i += 1) {
            _assets.push(assets[i]);
        }
        _nextRebalanceTimestamp = block.timestamp;
    }

    function secondsLeftToNextRebalance() public view returns (uint256) {
        if (_nextRebalanceTimestamp <= block.timestamp) {
            return 0;
        }
        return _nextRebalanceTimestamp - block.timestamp;
    }

    function previewMint(uint256 assetsIn) public view returns (uint256) {
        uint256 totalAssets_ = totalAssets().best;
        uint256 totalSupply_ = totalSupply();
        return _previewMint(assetsIn, totalAssets_, totalSupply_);
    }

    function _previewMint(uint256 assetsIn, uint256 totalAssets, uint256 totalSupply) private pure returns (uint256) {
        if (assetsIn == 0) {
            return 0;
        }
        return
            totalAssets == 0 && totalSupply == 0 ? 1_000_000e18 :
            totalAssets != 0 && totalSupply == 0 ? 1_000_000e18 :
            totalAssets == 0 && totalSupply != 0 ? 0 :
            _div(_mul(assetsIn, totalSupply), totalAssets);
    }

    function previewBurn(uint256 supplyIn) public view returns (uint256) {
        uint256 totalAssets_ = totalAssets().best;
        uint256 totalSupply_ = totalSupply();
        return _previewBurn(supplyIn, totalAssets_, totalSupply_);
    }

    function _previewBurn(uint256 supplyIn, uint256 totalAssets, uint256 totalSupply) public pure returns (uint256) {
        if (supplyIn == 0) {
            return 0;
        }
        return
            totalAssets == 0 && totalSupply == 0 ? 0 :
            totalAssets != 0 && totalSupply == 0 ? 0 :
            totalAssets == 0 && totalSupply != 0 ? 0 :
            _div(_mul(supplyIn, totalAssets), totalSupply);
    }

    function quote() public view returns (Quote memory) {
        Quote memory quote = totalAssets();
        if (totalSupply() == 0) {
            return Quote({
                real: 0,
                best: 0,
                slippage: 0
            });
        }
        return Quote({
            real: _div(quote.real, totalSupply()),
            best: _div(quote.best, totalSupply()),
            slippage: quote.slippage
        });
    }

    function totalAssets() public view returns (Quote memory) {
        uint256 usdcBalance = _toNewPrecision(_usdc.balanceOf(address(this)), _usdc.decimals(), 18);
        uint256 realTotalAssets = usdcBalance;
        uint256 bestTotalAssets = usdcBalance;
        for (uint256 i = 0; i < _assets.length; i += 1) {
            Asset storage asset = _assets[i];
            uint256 balance = _toNewPrecision(asset.token.balanceOf(address(this)), asset.token.decimals(), 18);
            if (balance != 0) {
                Quote memory quote = _fetchQuote(asset, balance, Side.TKN_CUR_PATH);
                realTotalAssets += quote.real;
                bestTotalAssets += quote.best;
            }
        }
        uint256 slippage = _lss(realTotalAssets, bestTotalAssets);
        if (bestTotalAssets == 0) {
            slippage = 0;
        }
        return Quote({
            real: realTotalAssets,
            best: bestTotalAssets,
            slippage: slippage
        });
    }

    function totalSupply() public view returns (uint256) {
        return _vToken.totalSupply();
    }

    function rebalance() public {
        require(secondsLeftToNextRebalance() == 0, "cooldown");
        _nextRebalanceTimestamp += (block.timestamp + 1 weeks);
        for (uint256 i = 0; i < _assets.length; i += 1) {
            Asset storage asset = _assets[i];
            uint256 actualAllocation = _pct(_toNewPrecision(asset.token.balanceOf(address(this)), asset.token.decimals(), 18), totalAssets().best);
            uint256 targetAllocation = asset.targetAllocation;
            if (actualAllocation < targetAllocation) {
                uint256 actualValue = _mul(_div(totalAssets().best, 100e18), actualAllocation);
                uint256 targetValue = _mul(_div(totalAssets().best, 100e18), targetAllocation);
                uint256 valueDeficit = targetValue - actualValue;
                uint256 balance = _toNewPrecision(_usdc.balanceOf(address(this)), _usdc.decimals(), 18);
                if (valueDeficit > 0 && valueDeficit <= balance) {
                    Quote memory quote = _fetchQuote(asset, valueDeficit, Side.CUR_TKN_PATH);
                    if (quote.slippage <= 2e18) {
                        _usdc.approve(address(_quickswap), _toNewPrecision(valueDeficit, 18, _usdc.decimals()));
                        _quickswap.swapExactTokensForTokens(_toNewPrecision(valueDeficit, 18, _usdc.decimals()), 0, asset.curTknPath, address(this), block.timestamp);
                    }
                }
            }
            else if (actualAllocation > targetAllocation) {
                uint256 actualValue = _mul(_div(totalAssets().best, 100e18), actualAllocation);
                uint256 targetValue = _mul(_div(totalAssets().best, 100e18), targetAllocation);
                uint256 valueSurplus = actualValue - targetValue;
                Quote memory quote = _fetchQuote(asset, 1e18, Side.TKN_CUR_PATH);
                uint256 surplusBalance = _div(valueSurplus, quote.best);
                uint256 balance = _toNewPrecision(asset.token.balanceOf(address(this)), asset.token.decimals(), 18);
                if (surplusBalance > 0 && surplusBalance <= balance) {
                    Quote memory quote = _fetchQuote(asset, surplusBalance, Side.TKN_CUR_PATH);
                    if (quote.slippage <= 2e18) {
                        asset.token.approve(address(_quickswap), _toNewPrecision(surplusBalance, 18, asset.token.decimals()));
                        _quickswap.swapExactTokensForTokens(_toNewPrecision(surplusBalance, 18, asset.token.decimals()), 0, asset.tknCurPath, address(this), block.timestamp);
                    }
                }
            }
        }
    }

    function mint(uint256 assetsIn) public {
        uint256 amount = previewMint(assetsIn);
        require(_usdc.transferFrom(msg.sender, address(this), _toNewPrecision(assetsIn, 18, _usdc.decimals())), "transferFailed");
        _mint(msg.sender, amount);
        emit Mint(msg.sender);
        return;
    }

    function burn(uint256 supplyIn) public {
        require(_vToken.transferFrom(msg.sender, address(this), supplyIn), "failedTransfer");
        uint256 ownership = _pct(supplyIn, totalSupply());
        uint256 payableUsdcBalance = _slc(_toNewPrecision(_usdc.balanceOf(address(this)), _usdc.decimals(), 18), ownership);
        _burn(address(this), supplyIn);
        _usdc.transfer(msg.sender, _toNewPrecision(payableUsdcBalance, 18, _usdc.decimals()));
        for (uint256 i = 0; i < _assets.length; i += 1) {
            Asset storage asset = _assets[i];
            uint256 payableBalance = _slc(_toNewPrecision(asset.token.balanceOf(address(this)), asset.token.decimals(), 18), ownership);
            if (payableBalance > 0) {
                Quote memory quote = _fetchQuote(asset, payableBalance, Side.TKN_CUR_PATH);
                if (quote.slippage <= 2e18) {
                    asset.token.approve(address(_quickswap), _toNewPrecision(payableBalance, 18, asset.token.decimals()));
                    _quickswap.swapExactTokensForTokens(_toNewPrecision(payableBalance, 18, asset.token.decimals()), 0, asset.tknCurPath, msg.sender, block.timestamp);
                }
                else {
                    asset.token.transfer(msg.sender, _toNewPrecision(payableBalance, 18, asset.token.decimals()));
                }
            }
        }
        emit Burn(msg.sender);
        return;
    }

    function _mint(address account, uint256 amount) private {
        return _vToken.mint(account, amount);
    }

    function _burn(address account, uint256 amount) private {
        return _vToken.burn(account, amount);
    }

    function _fetchQuote(Asset memory asset, uint256 amount, Side side) private view returns (Quote memory) {
        uint256 real = _fetchRealQuote(asset, amount, side);
        uint256 best = _fetchBestQuote(asset, amount, side);
        uint256 slippage = _lss(real, best);
        if (best == 0) {
            slippage = 0;
        }
        return Quote({
            real: real,
            best: best,
            slippage: slippage
        });
    }

    function _fetchRealQuote(Asset memory asset, uint256 amount, Side side) private view returns (uint256) {
        uint8 decimals0 = asset.token.decimals();
        uint8 decimals1 = asset.currency.decimals();
        if (side == Side.TKN_CUR_PATH) {
            uint256 amountX = _toNewPrecision(amount, 18, decimals0);
            uint256[] memory amountsOutX = _quickswap.getAmountsOut(amountX, asset.tknCurPath);
            uint256 amountOutX = amountsOutX[amountsOutX.length - 1];
            return _toNewPrecision(amountOutX, decimals1, 18);
        }
        else {
            uint256 amountX = _toNewPrecision(amount, 18, decimals1);
            uint256[] memory amountsOutX = _quickswap.getAmountsOut(amountX, asset.curTknPath);
            uint256 amountOutX = amountsOutX[amountsOutX.length - 1];
            return _toNewPrecision(amountOutX, decimals0, 18);
        }
    }

    function _fetchBestQuote(Asset memory asset, uint256 amount, Side side) private view returns (uint256) {
        IErc20 token0 = asset.token;
        IErc20 token1 = asset.currency;
        uint8 decimals0 = asset.token.decimals();
        uint8 decimals1 = asset.currency.decimals();
        if (side == Side.TKN_CUR_PATH) {
            uint256 amountX = _toNewPrecision(amount, 18, decimals0);
            Pair memory pair = _fetchPair(token0, token1);
            return _quickswap.quote(amountX, pair.reserve0, pair.reserve1);
        }
        else {
            uint256 amountX = _toNewPrecision(amount, 18, decimals1);
            Pair memory pair = _fetchPair(token1, token0);
            return _quickswap.quote(amountX, pair.reserve0, pair.reserve1);
        }
    }

    function _fetchPair(IErc20 token0, IErc20 token1) private view returns (Pair memory) {
        IUniswapV2Factory factory = IUniswapV2Factory(_quickswap.factory());
        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(address(token0), address(token1)));
        IErc20 pairToken0 = IErc20(pair.token0());
        IErc20 pairToken1 = IErc20(pair.token1());
        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
        if (address(token0) != address(pairToken0) || address(token1) != address(pairToken1)) {
            uint256 temp0 = reserve0;
            uint256 temp1 = reserve1;
            reserve0 = temp1;
            reserve1 = temp0;
        }
        uint8 decimals0 = token0.decimals();
        uint8 decimals1 = token1.decimals();
        return Pair({
            pair: pair,
            token0: token0,
            token1: token1,
            reserve0: _toNewPrecision(reserve0, decimals0, 18),
            reserve1: _toNewPrecision(reserve1, decimals1, 18),
            decimals0: decimals0,
            decimals1: decimals1
        });
    }

    function _slc(uint256 x, uint256 percentage) private pure returns (uint256) {
        return _mul(_div(x, 100e18), percentage);
    }

    function _lss(uint256 x, uint256 y) private pure returns (uint256 percentage) {
        return 100e18 - _yld(x, y);
    }

    function _yld(uint256 x, uint256 y) private pure returns (uint256 percentage) {
        return 
            x == 0 ? 0 :
            x >= y ? 100e18 : 
            _pct(x, y);
    }

    function _pct(uint256 x, uint256 y) private pure returns (uint256 percentage) {
        return _mul(_div(x, y), 100e18);
    }

    function _mul(uint256 x, uint256 y) private pure returns (uint256) {
        return _muldiv(x, y, 1e18);
    }

    function _div(uint256 x, uint256 y) private pure returns (uint256) {
        return _muldiv(x, 1e18, y);
    }

    function _toNewPrecision(uint256 x, uint8 decimals0, uint8 decimals1) private pure returns (uint256) {
        return x == 0 || decimals0 == decimals1 ? x : _muldiv(x, 10**decimals1, 10**decimals0);
    }

    function _muldiv(uint256 x, uint256 y, uint256 z) private pure returns (uint256) {
        unchecked {
            uint256 prod0;
            uint256 prod1;
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                return prod0 / z;
            }
            require(z > prod1, "overf");
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, z)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = z & (~z + 1);
            assembly {
                z := div(z, twos)
                prod0 := div(prod0, twos)
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;
            uint256 inverse = (3 * z) ^ 2;
            inverse *= 2 - z * inverse;
            inverse *= 2 - z * inverse;
            inverse *= 2 - z * inverse;
            inverse *= 2 - z * inverse;
            inverse *= 2 - z * inverse;
            inverse *= 2 - z * inverse;
            return prod0 * inverse;
        }
    }
}