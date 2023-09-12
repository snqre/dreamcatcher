// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/deps/openzeppelin/utils/Context.sol";
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import "contracts/polygon/deps/openzeppelin/access/AccessControlEnumerable.sol";
import "contracts/polygon/interfaces/IRepository.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/Matcher.sol";

contract QuickSwapPlugIn is 
AccessControlEnumerable,
ReentrancyGuard,
Pausable 
{
    bytes32 admin;
    bytes32 consumer;

    address private _deployer;
    bool private _init;

    IUniswapV2Factory public uniswapV2Factory;
    IUniswapV2Router02 public uniswapV2Router02;
    IRepository public repository;

    modifier whenInitialized()
    {
        require(_init);
        _;
    }

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
        _deployer = msg.sender;
        _init = false;

        admin = keccak256(abi.encode("admin"));
        consumer = keccak256(abi.encode("consumer"));

        _grantRole(admin, msg.sender);
        _grantRole(consumer, msg.sender);
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
    whenInitialized
    onlyRole(consumer)
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
    whenInitialized
    onlyRole(consumer)
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
    whenInitialized
    onlyRole(consumer)
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
}