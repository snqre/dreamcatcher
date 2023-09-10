// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

interface IERC20 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name()
    external view
    returns (
        string memory
    );

    function symbol()
    external view
    returns (
        string memory
    );

    function decimals()
    external view
    returns (
        uint8
    );

    function totalSupply()
    external view
    returns (
        uint256
    );

    function balanceOf(
        address account
    )
    external view
    returns (
        uint256
    );

    function transfer(
        address to,
        uint256 amount
    )
    external
    returns (
        bool
    );

    function allowance(
        address owner,
        address spender
    )
    external view
    returns (
        uint256
    );

    function approve(
        address spender,
        uint256 amount
    )
    external
    returns (
        bool
    );

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
    external
    returns (
        bool
    );
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IQuickSwapPlugIn {
    function metadata(
        address tokenA,
        address tokenB
    )
    external view
    returns (
        address addressPair,
        address addressA,
        address addressB,
        string memory nameA,
        string memory nameB,
        string memory symbolA,
        string memory symbolB,
        uint decimalsA,
        uint decimalsB
    );
    
    function isSameOrder(
        address tokenA,
        address tokenB
    )
    external view
    returns (
        QuickSwapPlugIn.ORDER
    );

    function price(
        address tokenA,
        address tokenB,
        uint amount
    )
    external view
    returns (
        uint price,
        uint lastTimestamp
    );

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        uint gate,
        address from,
        address to
    )
    external;

    function swapTokensSlippage(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint slippage,
        uint gate,
        address from,
        address to
    )
    external;
}

contract QuickSwapPlugIn is IQuickSwapPlugIn {
    enum GATE { WMATIC, WBTC, WETH, USDC, USDT, DAI }
    enum ORDER { REVERSE, SAME }
    address constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address constant WBTC = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6;
    address constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address constant DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    IUniswapV2Factory constant FACTORY = IUniswapV2Factory(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32);
    IUniswapV2Router02 constant ROUTER = IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);

    event SWAP(
        address indexed tokenIn,
        address indexed tokenOut,
        uint indexed amountIn,
        uint amountOutMin,
        address to
    );

    error PAIR_NOT_FOUND();
    error UNRECOGNIZED_GATE();

    constructor() {}

    function isSameString(
        string memory stringA,
        string memory stringB
    )
    public pure
    returns (bool isMatch) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    function metadata(
        address tokenA,
        address tokenB
    )
    public view
    returns (
        address addressPair,
        address addressA,
        address addressB,
        string memory nameA,
        string memory nameB,
        string memory symbolA,
        string memory symbolB,
        uint decimalsA,
        uint decimalsB
    ) {
        addressPair = FACTORY.getPair({tokenA: tokenA, tokenB: tokenB});
        if (addressPair == address(0)) { revert PAIR_NOT_FOUND(); }
        IUniswapV2Pair interface_ = IUniswapV2Pair(addressPair);
        IERC20 tokenA_ = IERC20(interface_.token0());
        IERC20 tokenB_ = IERC20(interface_.token1());
        return (
            addressPair,
            interface_.token0(),
            interface_.token1(),
            tokenA_.name(),
            tokenB_.name(),
            tokenA_.symbol(),
            tokenB_.symbol(),
            tokenA_.decimals(),
            tokenB_.decimals()
        );
    }

    function isSameOrder(
        address tokenA,
        address tokenB
    )
    public view
    returns (
        ORDER
    ) {
        (
            ,
            address addressA,
            address addressB,
            string memory nameA,
            string memory nameB,
            string memory symbolA,
            string memory symbolB,
            uint decimalsA,
            uint decimalsB
        ) = metadata({tokenA: tokenA, tokenB: tokenB});
        IERC20 tokenA_ = IERC20(tokenA);
        IERC20 tokenB_ = IERC20(tokenB);
        if (
            tokenA == addressA &&
            tokenB == addressB &&
            isSameString(tokenA_.name(), nameA) &&
            isSameString(tokenB_.name(), nameB) &&
            isSameString(tokenA_.symbol(), symbolA) &&
            isSameString(tokenB_.symbol(), symbolB) &&
            tokenA_.decimals() == decimalsA &&
            tokenB_.decimals() == decimalsB
        ) { return ORDER.SAME; }
        else if (
            tokenA == addressB &&
            tokenB == addressA &&
            isSameString(tokenA_.name(), nameB) &&
            isSameString(tokenB_.name(), nameA) &&
            isSameString(tokenA_.symbol(), symbolB) &&
            isSameString(tokenB_.symbol(), symbolA) &&
            tokenA_.decimals() == decimalsB &&
            tokenB_.decimals() == decimalsA
        ) { return ORDER.REVERSE; }
        else { revert PAIR_NOT_FOUND(); }
    }

    function price(
        address tokenA,
        address tokenB,
        uint amount
    )
    public view
    returns (
        uint price, /// will always return (price * (10**18))
        uint lastTimestamp
    ) {
        ORDER order = isSameOrder({tokenA: tokenA, tokenB: tokenB});
        address addressPair = FACTORY.getPair({tokenA: tokenA, tokenB: tokenB});
        if (addressPair == address(0)) { revert PAIR_NOT_FOUND(); }
        IUniswapV2Pair interface_ = IUniswapV2Pair(addressPair);
        IERC20 tokenA_ = IERC20(interface_.token0());
        IERC20 tokenB_ = IERC20(interface_.token1());
        (
            uint reserveA,
            uint reserveB,
            uint lastTimestamp_
        ) = interface_.getReserves();
        if (order == ORDER.SAME) {
            price = (amount * (reserveA * (10**tokenB_.decimals()))) / reserveB;
            price *= 10**18;
            price /= 10**tokenA_.decimals();
            return (price, lastTimestamp_);
        }
        else if (order == ORDER.REVERSE) {
            price = (amount * (reserveB * (10**tokenA_.decimals()))) / reserveA;
            price *= 10**18;
            price /= 10**tokenB_.decimals();
            return (price, lastTimestamp_);
        }
    }

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        uint gate,
        address from,
        address to
    )
    public {
        if (gate > 5) { revert UNRECOGNIZED_GATE(); }
        IERC20(tokenIn).transferFrom({from: from, to: address(this), amount: amountIn});
        IERC20(tokenIn).approve({spender: address(ROUTER), amount: amountIn});
        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        if (GATE(gate) == GATE.WMATIC) { path[1] = WMATIC; }
        else if (GATE(gate) == GATE.WBTC) { path[1] = WBTC; }
        else if (GATE(gate) == GATE.WETH) { path[1] = WETH; }
        else if (GATE(gate) == GATE.USDC) { path[1] = USDC; }
        else if (GATE(gate) == GATE.USDT) { path[1] = USDT; }
        else if (GATE(gate) == GATE.DAI) { path[1] = DAI; }
        path[2] = tokenOut;
        ROUTER.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: amountOutMin,
            path: path,
            to: to,
            deadline: block.timestamp
        });
        emit SWAP(tokenIn, tokenOut, amountIn, amountOutMin, to);
    }

    function swapTokensSlippage(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint slippage,
        uint gate,
        address from,
        address to
    )
    public {
        if (gate > 5) { revert UNRECOGNIZED_GATE(); }
        IERC20(tokenIn).transferFrom({from: from, to: address(this), amount: amountIn});
        IERC20(tokenIn).approve({spender: address(ROUTER), amount: amountIn});
        (uint amountOutMin,) = price({tokenA: tokenIn, tokenB: tokenOut, amount: amountIn});
        amountOutMin = (amountOutMin * (10000 - slippage)) / 10000;
        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        if (GATE(gate) == GATE.WMATIC) { path[1] = WMATIC; }
        else if (GATE(gate) == GATE.WBTC) { path[1] = WBTC; }
        else if (GATE(gate) == GATE.WETH) { path[1] = WETH; }
        else if (GATE(gate) == GATE.USDC) { path[1] = USDC; }
        else if (GATE(gate) == GATE.USDT) { path[1] = USDT; }
        else if (GATE(gate) == GATE.DAI) { path[1] = DAI; }
        path[2] = tokenOut;
        ROUTER.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: amountOutMin,
            path: path,
            to: to,
            deadline: block.timestamp
        });
        emit SWAP(tokenIn, tokenOut, amountIn, amountOutMin, to);
    }
}