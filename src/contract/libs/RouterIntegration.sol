// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;
import { IUniswapV2Router02 } from "../imports/uniswap/v2/interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Factory } from "../imports/uniswap/v2/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "../imports/uniswap/v2/interfaces/IUniswapV2Pair.sol";
import { IErc20 } from "../interfaces/standards/IErc20.sol";
import { UD60x18 } from "../imports/prb-math/UD60x18.sol";
import { Math } from "./math/Math.sol";
import { UD } from "./math/Math.sol";
import { TokenIntegration } from "./TokenIntegration.sol";

library RouterIntegration {

    struct Pair {
        IUniswapV2Pair intf;
        IErc20 token0;
        IErc20 token1;
        uint256 reserve0;
        uint256 reserve1;
        uint8 decimals0;
        uint8 decimals1;
    }

    function _getPair(IUniswapV2Router02 router, IErc20 token0, IErc20 token1) private view returns (Pair memory) {
        IUniswapV2Pair pair_ = IUniswapV2Pair(IUniswapV2Factory(router.factory()).getPair(address(token0), address(token1)));
        (uint256 reserve0, uint256 reserve1,) = pair_.getReserves();
        uint8 decimals0 = token0.decimals();
        uint8 decimals1 = token1.decimals();
        IErc20 pairToken0 = IErc20(pair_.token0());
        IErc20 pairToken1 = IErc20(pair_.token1());
        Sortable memory sortable;
        sortable.token0 = token0;
        sortable.token1 = token1;
        sortable.pairToken0 = pairToken0;
        sortable.pairToken1 = pairToken1;
        sortable.reserve0 = reserve0;
        sortable.reserve1 = reserve1;
        sortable.decimals0 = decimals0;
        sortable.decimals1 = decimals1;
        (uint256 sorted0, uint256 sorted1) = _sort(sortable);
        Pair memory pair;
        pair.intf = pair_;
        pair.token0 = token0;
        pair.token1 = token1;
        pair.reserve0 = sorted0;
        pair.reserve1 = sorted1;
        pair.decimals0 = decimals0;
        pair.decimals1 = decimals1;
        return pair;
    }

    struct Sortable {
        IErc20 token0;
        IErc20 token1;
        IErc20 pairToken0;
        IErc20 pairToken1;
        uint256 reserve0;
        uint256 reserve1;
        uint8 decimals0;
        uint8 decimals1;
    }

    function _sort(Sortable memory sortable) private pure returns (uint256, uint256) {
        require(address(sortable.token0) != address(0));
        require(address(sortable.token1) != address(0));
        require(address(sortable.pairToken0) != address(0));
        require(address(sortable.pairToken1) != address(0));
        require(sortable.reserve0 != 0);
        require(sortable.reserve1 != 0);
        require(sortable.decimals0 >= 2 && sortable.decimals0 <= 18);
        require(sortable.decimals1 >= 2 && sortable.decimals1 <= 18);
        if (address(sortable.token0) != address(sortable.pairToken0)) {
            uint256 temp0 = sortable.reserve0;
            uint256 temp1 = sortable.reserve1;
            temp0 = sortable.reserve0;
            temp1 = sortable.reserve1;
            sortable.reserve0 = temp0;
            sortable.reserve1 = temp1;
        }
        return (
            Math.cst(sortable.reserve0, sortable.decimals0, 18),
            Math.cst(sortable.reserve1, sortable.decimals1, 18)
        );
    }
}