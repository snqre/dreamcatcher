// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/slots/.components/UniswapV2OracleAdaptorComponent.sol";

contract UniswapV2OracleAdaptorSlot {
    bytes32 internal constant _UNISWAP_V2_ORACLE_ADAPTOR = keccak256("slot.uniswapV2OracleAdaptor");

    function uniswapV2OracleAdaptor() internal pure returns (UniswapV2OracleAdaptorComponent.UniswapV2OracleAdaptor storage s) {
        bytes32 location = _UNISWAP_V2_ORACLE_ADAPTOR;
        assembly {
            s.slot := location
        }
    }
}