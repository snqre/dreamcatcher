// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
import "contracts/polygon/slots/adaptors/UniswapV3OracleAdaptorSlot.sol";
import "contracts/polygon/slots/.components/UniswapV3OracleAdaptorComponent.sol";

interface IUniswapV3OracleAdaptor {
    function factory() external view returns (address);
    function secondsAgo() external view returns (uint);
    function quote(address token0, address token1) external view returns (uint);
}

contract UniswapV3OracleAdaptor is UniswapV3OracleAdaptorSlot {
    constructor(address factory, uint32 secondsAgo) {
        uniswapV3OracleAdaptor().setFactory(factory);
        uniswapV3OracleAdaptor().setSecondsAgo(secondsAgo seconds);
    }

    function factory() external view virtual returns (address) {
        return uniswapV3OracleAdaptor().factory();
    }

    function secondsAgo() external view virtual returns (uint) {
        return uint(uniswapV3OracleAdaptor().secondsAgo());
    }

    function quote(address token0, address token1) external view virtual returns (uint) {
        return uniswapV3OracleAdaptor().quote(token0, token1);
    }
}