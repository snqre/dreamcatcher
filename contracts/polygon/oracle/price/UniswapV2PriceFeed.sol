// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/uniswap/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/external/uniswap/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

contract UniswapV2PriceFeed {
    IUniswapV2Factory internal _factory;

    constructor(address factory) {
        _factory = IUniswapV2Factory(factory);
    }

    function price(address tokenA, address tokenB) public view virtual returns (uint) {
        return _price(tokenA, tokenB);
    }

    function _calculate(uint reserveA, uint reserveB, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint) {
        uint price = (reserveB * 10**decimalsA) / reserveA;
        price *= 10**18;
        price /= 10**decimalsB;
        return price;
    }

    function _price(address tokenA, address tokenB) internal view virtual returns (uint) {
        uint side = _isSameOrder(tokenA, tokenB);
        IUniswapV2Pair pair = IUniswapV2Pair(_factory.getPair(tokenA, tokenB));
        if (address(pair) == address(0)) { 
            return 0; 
        }
        (uint reserveA, uint reserveB,) = pair.getReserves();
        uint8 decimalsA = IERC20Metadata(tokenA).decimals();
        uint8 decimalsB = IERC20Metadata(tokenB).decimals();
        (address tknA, address tknB) = _metadata(tokenA, tokenB);
        if (tokenA == tknA) {
            return _calculate(reserveB, reserveA, decimalsB, decimalsA);
        } else if (tokenA == tknB) {
            return _calculate(reserveA, reserveB, decimalsA, decimalsB);
        } else {
            return 0;
        }
    }

    function _metadata(address tokenA, address tokenB) internal view virtual returns (address, address) {
        IUniswapV2Pair pair = IUniswapV2Pair(_factory.getPair(tokenA, tokenB));
        if (address(pair) == address(0)) { return (address(0), address(0)); }
        return (pair.token0(), pair.token1());
    }
}