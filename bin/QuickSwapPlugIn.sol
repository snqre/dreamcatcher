// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/deps/openzeppelin/utils/Context.sol";
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import "contracts/polygon/deps/openzeppelin/access/AccessControlEnumerable.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/Matcher.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

contract QuickSwapPlugIn is 
AccessControlEnumerable,
ReentrancyGuard,
Pausable 
{
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 constant CONSUMER = keccak256("CONSUMER");

    IUniswapV2Factory public uniswapV2Factory
    = IUniswapV2Factory(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32);

    IUniswapV2Router02 public uniswapV2Router02
    = IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);

    event Swap
    (
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 indexed amountIn,
        uint256 amountOutMin,
        uint256 amountOut,
        address from,
        address to
    );

    constructor() 
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(CONSUMER, msg.sender);
    }

    /**
        @return
        pair address
        tokenA address
        tokenB address
        tokenA name
        tokenB name
        tokenA symbol
        tokenB symbol
        tokenA decimals
        tokenB decimals
    */
    function getContext
    (
        address tokenA,
        address tokenB
    )
    public view
    whenNotPaused
    onlyRole(CONSUMER)
    returns
    (
        address,
        address,
        address,
        string memory,
        string memory,
        string memory,
        string memory,
        uint256,
        uint256
    )
    {
        address pair = uniswapV2Factory.getPair(tokenA, tokenB);
        require
        (
            pair != address(0),
            "QuickSwapPlugIn: pair not found"
        );

        IUniswapV2Pair conn = IUniswapV2Pair(pair);
        IERC20Metadata tknA = IERC20Metadata(conn.token0());
        IERC20Metadata tknB = IERC20Metadata(conn.token1());
        return
        (
            pair,
            conn.token0(),
            conn.token1(),
            tknA.name(),
            tknB.name(),
            tknA.symbol(),
            tknB.symbol(),
            tknA.decimals(),
            tknB.decimals()
        );
    }

    function isSameOrder
    (
        address tokenA,
        address tokenB
    )
    public view
    whenNotPaused
    onlyRole(CONSUMER)
    returns (uint8)
    {
        (
            ,
            address addressTknA,
            address addressTknB,
            string memory nameTknA,
            string memory nameTknB,
            string memory symbolTknA,
            string memory symbolTknB,
            uint256 decimalsTknA,
            uint256 decimalsTknB
        ) = getContext(tokenA, tokenB);

        IERC20Metadata tknA = IERC20Metadata(tokenA);
        IERC20Metadata tknB = IERC20Metadata(tokenB);
        if 
        (
            tknA == addressTknA &&
            tknB == addressTknB &&
            Matcher.isSameString(tknA.name(), nameTknA) &&
            Matcher.isSameString(tknB.name(), nameTknB) &&
            Matcher.isSameString(tknA.symbol(), symbolTknA) &&
            Matcher.isSameString(tknB.symbol(), symbolTknB) &&
            tknA.decimals() == decimalsTknA &&
            tknB.decimals() == decimalsTknB
        )
        {
            return 1;
        }

        else if 
        (
            tknA == addressTknB &&
            tknB == addressTknA &&
            Matcher.isSameString(tknA.name(), nameTknB) &&
            Matcher.isSameString(tknB.name(), nameTknA) &&
            Matcher.isSameString(tknA.symbol(), symbolTknB) &&
            Matcher.isSameString(tknB.symbol(), symbolTknA) &&
            tknA.decimals() == decimalsTknB &&
            tknB.decimals() == decimalsTknA
        )
        {
            return 0;
        }

        else
        {
            revert
            (
                "QuickSwapPlugIn: pair not found"
            );
        }
    }

    function getPrice
    (
        address tokenA,
        address tokenB,
        uint256 amount
    )
    public view
    whenNotPaused
    onlyRole(CONSUMER)
    returns 
    (
        uint256,
        uint64
    )
    {
        uint8 side = isSameOrder(tokenA, tokenB);
        address pair = uniswapV2Factory.getPair(tokenA, tokenB);
        require
        (
            pair != address(0),
            "QuickSwapPlugIn: pair not found"
        );

        IUniswapV2Pair conn = IUniswapV2Pair(pair);
        IERC20Metadata tknA = IERC20Metadata(conn.token0());
        IERC20Metadata tknB = IERC20Metadata(conn.token1());
        
        (
            uint256 reserveA,
            uint256 reserveB,
            uint256 lastTimestamp
        ) = conn.getReserves();

        if (side == 0)
        {
            uint256 rA = reserveA * (10**tknB.decimals());
            uint256 price = (amount * rA) / reserveB;
            price *= 10**18;
            price /= 10**tknA.decimals();
            return
            (
                price,
                uint64(lastTimestamp)
            );
        }

        if (side == 1)
        {
            uint256 rB = reserveB * (10**tknA.decimals());
            uint256 price = (amount * rB) / reserveA;
            price *= 10**18;
            price /= 10**tknB.decimals();
            return
            (
                price,
                uint64(lastTimestamp)
            );
        }

        else {
            revert
            (
                "QuickSwapPlugIn: pair not found"
            );
        }
    }

    function swapTokens
    (
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address gate,
        address from,
        address to
    )
    public
    whenNotPaused
    onlyRole(CONSUMER)
    returns (uint256[] memory)
    {
        IERC20Metadata tknIn = IERC20Metadata(tokenIn);
        amountIn *= 10**tknIn.decimals();
        amountIn /= 10**18;
        tknIn.transferFrom(from, address(this), amountIn);
        tknIn.approve(
            address(uniswapV2Router02),
            amountIn
        );

        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        path[1] = gate;
        path[2] = tokenOut;
        uint256[] memory amounts 
        = uniswapV2Router02.swapExactTokensForTokens
        (
            amountIn,
            amountOutMin,
            path,
            to,
            block.timestamp
        );

        emit Swap
        (
            tokenIn,
            tokenOut,
            amountIn,
            amountOutMin,
            amountOut,
            from,
            to
        );

        return amounts;
    }

    function swapTokensSlippage
    (
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 slippage,
        address gate,
        address from,
        address to
    )
    public
    whenNotPaused
    onlyRole(CONSUMER)
    returns (uint256[] memory)
    {
        IERC20Metadata tknIn = IERC20Metadata(tokenIn);
        amountIn *= 10**tknIn.decimals();
        amountIn /= 10**18;
        tknIn.transferFrom(from, address(this), amountIn);
        tknIn.approve(
            address(uniswapV2Router02),
            amountIn
        );
        /// needs to be double checked because price form changed
        (uint256 amountOutMin,) = getPrice
        (
            tokenOut,
            tokenIn,
            amountIn
        );

        amountOutMin *= 10000 - slippage;
        amountOutMin /= 10000;

        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        path[1] = gate;
        path[2] = tokenOut;
        uint256[] memory amounts 
        = uniswapV2Router02.swapExactTokensForTokens
        (
            amountIn,
            amountOutMin,
            path,
            to,
            block.timestamp
        );

        emit Swap
        (
            tokenIn,
            tokenOut,
            amountIn,
            amountOutMin,
            amountOut,
            from,
            to
        );

        return amounts;
    }
}