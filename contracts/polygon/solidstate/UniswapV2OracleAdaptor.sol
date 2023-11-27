// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/slots/adaptors/UniswapV2OracleAdaptorSlot.sol";
import "contracts/polygon/slots/.components/UniswapV2OracleAdaptorComponent.sol";

interface IUniswapV2OracleAdaptor {
    function factory() external view returns (address);
    function router() external view returns (address);
    function quote(address token0, address token1) external view returns (uint);
    function amountOut(address token0, address token1) external view returns (uint);
    function amountsOut(address token0, address token1) external view returns (uint);
}

contract UniswapV2OracleAdaptor is UniswapV2OracleAdaptorSlot {
    using UniswapV2OracleAdaptorComponent for UniswapV2OracleAdaptorComponent.UniswapV2OracleAdaptor;

    constructor(address factory_, address router_) {
        uniswapV2OracleAdaptor().setFactory(factory_);
        uniswapV2OracleAdaptor().setRouter(router_);
    }

    function factory() external view virtual returns (address) {
        return uniswapV2OracleAdaptor().factory();
    }

    function router() external view virtual returns (address) {
        return uniswapV2OracleAdaptor().router();
    }

    function quote(address token0, address token1) external view virtual returns (uint) {
        return uniswapV2OracleAdaptor().quote(token0, token1);
    }

    function amountOut(address token0, address token1) external view virtual returns (uint) {
        return uniswapV2OracleAdaptor().amountOut(token0, token1);
    }

    function amountsOut(address[] memory path) external view virtual returns (uint) {
        return uniswapV2OracleAdaptor().amountsOut(path);
    }
}