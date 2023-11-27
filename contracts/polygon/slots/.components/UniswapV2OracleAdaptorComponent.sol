// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/libraries/OurMathLib.sol";

library UniswapV2OracleAdaptorComponent {
    using OurMathLib for uint;

    event UniswapV2OracleAdaptorFactorySet(address oldFactory, address newFactory);
    event UniswapV2OracleAdaptorRouterSet(address oldRouter, address newRouter);

    struct UniswapV2OracleAdaptor {
        IUniswapV2Factory _factory;
        IUniswapV2Router02 _router;
    }

    function factory(UniswapV2OracleAdaptor storage uniswapV2OracleAdaptor) internal view returns (address) {
        return address(uniswapV2OracleAdaptor._factory);
    }

    function router(UniswapV2OracleAdaptor storage uniswapV2OracleAdaptor) internal view returns (address) {
        return address(uniswapV2OracleAdaptor._router);
    }

    function quote(UniswapV2OracleAdaptor storage uniswapV2OracleAdaptor, address token0, address token1) internal view returns (uint) {
        IToken tkn0 = IToken(token0);
        IToken tkn1 = IToken(token1);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        address pair = uniswapV2OracleAdaptor._factories.getPair(token0, token1);
        if (pair == address(0)) { return 0; }
        IUniswapV2Pair pair_ = IUniswapV2Pair(pair);
        (uint res0, uint res1,) = pair_.getReserves();
        if (token0 == pair_.token0()) {
            uint amount = 10**decimals0;
            uint quote = uniswapV2OracleAdaptor._router.quote(amount, res0, res1);
            quote = quote.computeAsEtherValue(decimals1);
            return quote;
        } else {
            uint amount = 10**decimals1;
            uint quote = uniswapV2OracleAdaptor._router.quote(amount, res1, res0);
            quote = quote.computeAsEtherValue(decimals1);
            return quote;
        }
    }

    function amountOut(UniswapV2OracleAdaptor storage uniswapV2OracleAdaptor, address token0, address token1) internal view returns (uint) {
        IToken tkn0 = IToken(token0);
        IToken tkn1 = IToken(token1);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        address pair = uniswapV2OracleAdaptor._factory.getPair(token0, token1);
        if (pair == address(0)) { return 0; }
        IUniswapV2Pair pair_ = IUniswapV2Pair(pair);
        (uint res0, uint res1,) = pair_.getReserves();
        if (token0 == pair_.token0()) {
            uint amount = 10**decimals0;
            uint amountOut = uniswapV2OracleAdaptor._router.getAmountOut(amount, res0, res1);
            amountOut = amountOut.computeAsEtherValue(decimals1);
            return amountOut;
        } else {
            uint amount = 10**decimals0;
            uint amountOut = uniswapV2OracleAdaptor._router.getAmountOut(amount, res1, res0);
            amountOut = amountOut.computeAsEtherValue(decimals1);
            return amountOut;
        }
    }

    function amountsOut(UniswapV2OracleAdaptor storage uniswapV2OracleAdaptor, address[] memory path) internal view returns (uint) {
        IToken tkn0 = IToken(path[0]);
        IToken tkn1 = IToken(path[path.length - 1]);
        uint8 decimals0 = tkn0.decimals();
        uint8 decimals1 = tkn1.decimals();
        uint amount = 10**decimals0;
        uint[] memory amountsOut = uniswapV2OracleAdaptor._router.getAmountsOut(amount, path);
        uint amountOut = amountsOut.computeAsEtherValue(decimals1);
        return amountOut;
    }

    function setFactory(UniswapV2OracleAdaptor storage uniswapV2OracleAdaptor, address factory) internal returns (bool) {
        address oldFactory = factory(uniswapV2OracleAdaptor);
        uniswapV2OracleAdaptor._factory = factory;
        emit UniswapV2OracleAdaptorFactorySet(oldFactory, factory);
        return true;
    }

    function setRouter(UniswapV2OracleAdaptor storage uniswapV2OracleAdaptor, address router) internal returns (bool) {
        address oldRouter = router(uniswapV2OracleAdaptor);
        uniswapV2OracleAdaptor._router = router;
        emit UniswapV2OracleAdaptorRouterSet(oldRouter, router);
        return true;
    }

    function _setFactory(UniswapV2OracleAdaptor storage uniswapV2OracleAdaptor, address factory) private returns (bool) {
        uniswapV2OracleAdaptor._factory = IUniswapV2Factory(factory);
        return true;
    }

    function _setRouter(UniswapV2OracleAdaptor storage uniswapV2OracleAdaptor, address router) private returns (bool) {
        uniswapV2OracleAdaptor._router = IUniswapV2Router02(router);
        return true;
    }
}