// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/libraries/OurMathLib.sol";

library OracleLib {
    using OurMathLib for uint;

    struct Oracle {
        mapping(string => address) _factories;
        mapping(string => address) _routers;
    }

    function factories(Oracle storage oracle, string memory exchange) internal view returns (address) {
        return oracle._factories[exchange];
    }

    function routers(Oracle storage oracle, string memory exchange) internal view returns (address) {
        return oracle._routers[exchange];
    }

    function quote(Oracle storage oracle, string memory exchange, address token0, address token1) internal view returns (uint) {
        IToken tkn0 = IToken(token0);
        IToken tkn1 = IToken(token1);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        IUniswapV2Factory fctr = IUniswapV2Factory(oracle._factories[exchange]);
        address pair = fctr.getPair(token0, token1);
        if (pair == address(0)) { return 0; }
        /// ...
    }

    function amountOut(Oracle storage oracle, string memory exchange, address token0, address token1) internal view returns (uint) {
        IToken tkn0 = IToken(token0);
        IToken tkn1 = IToken(token1);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        IUniswapV2Factory fctr = IUniswapV2Factory(oracle._factories[exchange]);
        address pair = fctr.getPair(token0, token1);
        if (pair == address(0)) { return 0; }
        IUniswapV2Pair pr = IUniswapV2Pair(pair);
        (uint res0, uint res1,) = pr.getReserves();
        if (token0 == pr.token0()) {
            uint amount = 10**decimals0;
            IUniswapV2Router02 rtr = IUniswapV2Router02(oracle._routers[exchange]);
            uint amountOut = rtr.getAmountOut(amount, res0, res1);
            amountOut = amountOut.computeAsEtherValue(decimals1);
            return amountOut;
        } else {
            uint amount = 10**decimals1;
            IUniswapV2Router02 rtr = IUniswapV2Router02(oracle._routers[exchange]);
            uint amountOut = rtr.getAmountOut(amount, res0, res1);
            amountOut = amountOut.computeAsEtherValue(decimals1);
            return amountOut;
        }
    }

    function amountsOut(Oracle storage oracle, string memory exchange, address[] memory path) internal view returns (uint) {
        IToken tkn0 = IToken(path[0]);
        IToken tkn1 = IToken(path[path.length - 1]);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        uint amount = 10**decimals0;
        IUniswapV2Router02 rtr = IUniswapV2Router02(oracle._routers[exchange]);
        uint[] memory amountsOut = rtr.getAmountsOut(amount, path);
        uint amountOut = amountsOut[amountsOut.length - 1];
        amountOut = amountOut.computeAsEtherValue(decimals1);
        return amountOut;
    }

    function link(Oracle storage oracle, string memory exchange, address factory, address router) internal {
        oracle._factories[exchange] = factory;
        oracle._routers[exchange] = router;
    }
}