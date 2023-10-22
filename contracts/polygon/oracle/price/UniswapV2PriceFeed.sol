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

    function _price(address tokenA, address tokenB) internal view virtual returns (uint) {
        uint side = _isSameOrder(tokenA, tokenB);
        IUniswapV2Pair pair = IUniswapV2Pair(_factory.getPair(tokenA, tokenB));
        if (address(pair) == address(0)) { return 0; }
        (uint reserveA, uint reserveB,) = pair.getReserves();
        uint8 decimalsA = IERC20Metadata(tokenA).decimals();
        uint8 decimalsB = IERC20Metadata(tokenB).decimals();
        if (side == 0) {
            uint price = (1 * (reserveB * (10**decimalsA))) / reserveA;
            price *= 10**18;
            price /= 10**decimalsB;
            return price;
        } else if (side == 1) {
            uint price = (1 * (reserveA * (10**decimalsB))) / reserveB;
            price *= 10**18;
            price /= 10**decimalsA;
        } else {
            return 0;
        }
    }

    function _metadata(address tokenA, address tokenB) internal view virtual returns (address, address) {
        IUniswapV2Pair pair = IUniswapV2Pair(_factory.getPair(tokenA, tokenB));
        if (address(pair) == address(0)) { return (address(0), address(0)); }
        return (pair.token0(), pair.token1());
    }

    function _isSameOrder(address tokenA, address tokenB) internal view virtual returns (uint) {
        (address tknA, address tknB) = _metadata(tokenA, tokenB);
        if (tokenA == tknA) { 
            return 0; 
        } else if (tokenA == tknB) { 
            return 1; 
        } else {
            return 2;
        }
    }
}