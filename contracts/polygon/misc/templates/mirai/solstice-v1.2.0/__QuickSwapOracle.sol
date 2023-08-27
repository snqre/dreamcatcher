// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/quickswap-core/contracts/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/templates/mirai/solstice-v1.2.0/UniswapV2Twap.sol";

contract QuickSwapOracle {
    

    function deployObserver(UniswapV2Twap[] storage observers, bool isDeployed, address tokenA, address tokenB)
        public 
        returns (uint) {
        require(!isDeployed, "__QuickSwapOracle: observer is already deployed for this pair");
        observers.push();
        observers[observers.length - 1] = new UniswapV2Twap(getPair(tokenA, tokenB));
        return observers.length - 1;
    }
}