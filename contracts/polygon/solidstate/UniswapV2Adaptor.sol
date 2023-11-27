// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/libraries/OurMathLib.sol";
import "contracts/polygon/libraries/OurAddressLib.sol";

contract UniswapV2Adaptor {
    using OurMathLib for uint;
    using OurAddressLib for address;

    IUniswapV2Factory private immutable _factory;
    IUniswapV2Router02 private immutable _router;

    constructor(address factory, address router) {
        _factory = IUniswapV2Factory(factory);
        _router = IUniswapV2Router02(router);
    }

    function quote(address token0, address token1) external view virtual returns (uint) {
        uint8 decimals0 = token0.decimals();
        uint8 decimals1 = token0.decimals();
        address pair = _factory.getPair(token0, token1);
        if (pair == address(0)) { return 0; }
        
    }

    function factory() public view virtual returns (address) {
        return address(_factory);
    }

    function router() public view virtual returns (address) {
        return address(_router);
    }
}