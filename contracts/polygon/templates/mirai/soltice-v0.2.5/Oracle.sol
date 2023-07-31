// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/templates/mirai/soltice-v0.2.5/UniswapV2Twap.sol";
import "contracts/polygon/templates/mirai/soltice-v0.2.5/__Oracle.sol";

contract Oracle {
    IUniswapV2Factory public factory;
    
}