// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol';

contract stPool {
    bytes32 internal constant _POOL = keccak256('node.pool');

    struct StPool {
        IERC20Metadata shares;
        mapping(address => uint) assets;
        Order[] orders;
    }

    struct Order {
        uint averageValue;
        uint timestamp;
        uint amountIn;
        uint amountOut;
        address tokenIn;
        address tokenOut;
    }

    struct StPoolStat {
        uint revenue;
    }

    function pool() internal pure virtual returns (StPool storage s) {
        bytes32 location = _POOL;
        assembly {
            s.slot := location
        }
    }
}