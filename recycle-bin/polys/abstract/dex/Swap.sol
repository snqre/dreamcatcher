// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";
import "contracts/polygon/interfaces/uniswap/uniswap-v2/IUniswapV2Factory.sol";
import "contracts/polygon/interfaces/uniswap/uniswap-v2/IUniswapV2Pair.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import "contracts/polygon/interfaces/uniswap/uniswap-v2/IUniswapV2Router01.sol";
import "contracts/polygon/interfaces/uniswap/uniswap-v2/IUniswapV2Router02.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

abstract contract Swap is Storage {

    using EnumerableSet for EnumerableSet.AddressSet;

    event Swap(address indexed router, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOutMin, address denominator, address from, address to);

    function supportedFactoriesKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("SUPPORTED_FACTORIES"));
    }

    function supportedRoutersKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("SUPPORTED_ROUTERS"));
    }

    function supportedFactories(uint256 factoryId) public view virtual returns (address) {
        EnumerableSet.AddressSet storage factories = _addressSet[supportedFactoriesKey()];
        return factories.at(factoryId);
    }

    function supportedFactoriesLength() public view virtual returns (uint256) {
        EnumerableSet.AddressSet storage factories = _addressSet[supportedFactoriesKey()];
        return factories.length();
    }

    function supportedRouters(uint256 routerId) public view virtual returns (address) {
        EnumerableSet.AddressSet storage routers = _addressSet[supportedRoutersKey()];
        return routers.at(routerId);
    }

    function supportedRoutersLength() public view virtual returns (uint256) {
        EnumerableSet.AddressSet storage routers = _addressSet[supportedRoutersKey()];
        return routers.length();
    }

    function metadata(uint256 factoryId, address tokenA, address tokenB) public view virtual returns (address, address, address, string memory, string memory, string memory, string memory, uint8, uint8) {
        IUniswapV2Pair pair = IUniswapV2Pair(_pair(factoryId, tokenA, tokenB));
        address addressA = pair.token0();
        address addressB = pair.token1();
        string memory nameA = IERC20Metadata(addressA).name();
        string memory nameB = IERC20Metadata(addressB).name();
        string memory symbolA = IERC20Metadata(addressA).symbol();
        string memory symbolB = IERC20Metadata(addressB).symbol();
        uint8 decimalsA = IERC20Metadata(addressA).decimals();
        uint8 decimalsB = IERC20Metadata(addressB).decimals();
        return (pair, addressA, addressB, nameA, nameB, symbolA, symbolB, decimalsA, decimalsB);
    }

    function isSameOrder(uint256 factoryId, address tokenA, address tokenB) public view virtual returns (uint8) {
        address addressA;
        address addressB;
        string memory nameA;
        string memory nameB;
        string memory symbolA;
        string memory symbolB;
        uint8 decimalsA;
        uint8 decimalsB;
        (, addressA, addressB, nameA, nameB, symbolA, symbolB, decimalsA, decimalsB) = metadata(factoryId, tokenA, tokenB);
        IERC20Metadata tokenA_ = IERC20Metadata(tokenA);
        IERC20Metadata tokenB_ = IERC20Metadata(tokenB);
        if (
            tokenA == addressA &&
            tokenB == addressB &&
            _isSameString(tokenA_.name(), nameA) &&
            _isSameString(tokenB_.name(), nameB) &&
            _isSameString(tokenA_.symbol(), symbolA) &&
            _isSameString(tokenB_.symbol(), symbolB) &&
            tokenA_.decimals() == decimalsA &&
            tokenB_.decimals() == decimalsB
        ) {
            return 0;
        }
        else if (
            tokenA == addressB &&
            tokenB == addressA &&
            _isSameString(tokenA_.name(), nameB) &&
            _isSameString(tokenB_.name(), nameA) &&
            _isSameString(tokenA_.symbol(), symbolB) &&
            _isSameString(tokenB_.symbol(), symbolA) &&
            tokenA_.decimals() == decimalsB &&
            tokenB_.decimals() == decimalsA
        ) {
            return 1;
        }
        else {
            revert("Swap: failed to determine pair order");
        }
    }

    function price(
        address factory,
        address tokenA,
        address tokenB,
        uint256 amount
    ) public view virtual
    returns (
        uint256,
        uint256
    ) {
        uint256 side = isSameOrder(factory, tokenA, tokenB);
        IUniswapV2Factory factory_ = IUniswapV2Factory(factory);
        address pair = factory_.getPair(tokenA, tokenB);
        require(pair != address(0), "Swap: pair == address(0)");
        IUniswapV2Pair pair_ = IUniswapV2Pair(pair);
        IERC20Metadata tokenA_ = IERC20Metadata(pair_);
        IERC20Metadata tokenB_ = IERC20Metadata(pair_);
        (
            uint256 reserveA,
            uint256 reserveB,
            uint256 lastTimestamp
        )
        = pair_.getReserves();
        if (side == 1) {
            uint256 rA = reserveA * (10**tokenB_.decimals());
            uint256 price = (amount * rA) / reserveB;
            price *= 10**18;
            price /= 10**tokenA_.decimals();
            return (price, lastTimestamp);
        }
        else if (side == 0) {
            uint256 rB = reserveB * (10**tokenA_.decimals());
            uint256 price = (amount * rB) / reserveA;
            price *= 10**18;
            price /= 10**tokenB_.decimals();
            return (price, lastTimestamp);
        }
        else {
            revert("Swap: failed to determine pair order");
        }
    }

    function _isSameString(string memory stringA, string memory stringB) internal pure virtual returns (bool) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    function _mustNotBeZeroPair(address pair) internal view virtual {
        require(pair != address(0), "Swap: pair is zero");
    }

    function _pair(uint256 factoryId, address tokenA, address tokenB) internal view virtual returns (address) {
        address pair = IUniswapV2Factory(supportedFactories(factoryId)).getPair(tokenA, tokenB);
        _mustNotBeZeroPair(pair);
        return pair;
    }

    function _swapTokens(
        address router,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address denominator,
        address from,
        address to
    ) internal virtual {
        amountIn *= 10**IERC20Metadata(tokenIn).decimals();
        amountIn /= 10**18;
        IERC20Metadata tokenIn_ = IERC20Metadata(tokenIn);
        tokenIn.approve(router, amountIn);
        tokenIn.transferFrom(from, to, amountIn);
        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        path[1] = denominator;
        path[2] = tokenOut;
        IUniswapV2Router02 router_ = IUniswapV2Router02(router);
        router_.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            block.timestamp
        );
        emit Swap(
            router,
            tokenIn,
            tokenOut,
            amountIn,
            amountOutMin,
            denominator,
            from,
            to
        );   
    }

    function _swapTokensSlippage(
        address router,
        address factory,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 slippage,
        address denominator,
        address from,
        address to
    ) internal virtual {
        (uint256 amountOutMin,)
        = price(factory, tokenA, tokenB, amountIn);
        _swapTokens(
            router,
            tokenIn,
            tokenOut,
            amountIn,
            (amountOutMin * (10000 - slippage)) / 10000,
            denominator,
            from,
            to
        );
    }
}