// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
import "contracts/polygon/slots/.components/UniswapV3OracleAdaptorComponent.sol";

contract UniswapV3OracleAdaptorSlot {
    bytes32 internal constant _UNISWAP_V3_ORACLE_ADAPTOR = keccak256("slot.uniswapV3OracleAdaptor");

    function uniswapV3OracleAdaptor() internal pure returns (UniswapV3OracleAdaptorComponent.UniswapV3OracleAdaptor storage s) {
        bytes32 location = _UNISWAP_V3_ORACLE_ADAPTOR;
        assembly {
            s.slot := location
        }
    }
}