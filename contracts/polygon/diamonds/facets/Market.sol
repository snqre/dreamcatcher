// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/Console.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router01.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/diamonds/facets/OracleReader.sol";
import "contracts/polygon/libraries/Finance.sol";

contract Market {
    bytes32 internal constant _MARKET = keccak256("slot.market");

    event RouterChanged(string exchange, address oldRouter, address newRouter);
    event SlippagedThresholdChanged(uint oldThreshold, uint newThreshold);
    event LiquidityTokenChanged(address oldToken, address newToken);

    struct MarketStorage {
        mapping(string => address) routers;
        uint slippageThreshold;
        address liquidityToken;
    }

    function market() internal pure virtual returns (MarketStorage storage s) {
        bytes32 location = _MARKET;
        assembly {
            s.slot := location
        }
    }

    ///

    function ____setRouter(string memory exchange, address newRouter) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        address oldRouter = routers(exchange);
        market().routers[exchange] = newRouter;
        emit RouterChanged(exchange, oldRouter, newRouter);
    }

    function ____setSlippageThreshold(uint newThreshold) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        uint oldThreshold = slippageThreshold();
        market().slippageThreshold = newThreshold;
        emit SlippagedThresholdChanged(oldThreshold, newThreshold);
    }

    function ____setLiquidityToken(uint newToken) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        address oldToken = liquidityToken();
        market().liquidityToken = newToken;
        emit LiquidityTokenChanged(oldToken, newToken);
    }

    /// amounts must be in 18 decimals
    function ____swap(address tokenIn, address tokenOut, uint amountIn) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        require(_hasAdaptor(tokenIn), "!_hasAdaptor");
        require(_hasAdaptor(tokenOut), "!_hasAdaptor");
        require(_hasEnoughBalance(tokenIn, amountIn), "!_hasEnoughBalance");
        uint priceIn = _price(tokenIn); /// as 10**18
        uint priceOut = _price(tokenOut); /// as 10**18
        /// values are the price of 1 ether of the amounts of the respective tokens
        amountIn *= 10**18;
        uint amountOut = amountIn.computeAmountOut(valueIn, valueOut);
        amountOut /= 10**18;
        amountOut -= ((amountOut * slippageThreshold()) / 10000);
        IToken tokenIn_ = IToken(tokenIn);
        /// 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45 uniswap v2 router on polygon
        address UNISWAP_V2_ROUTER = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
        tokenIn_.approve(UNISWAP_V2_ROUTER, amountIn.computeAsNativeValue(tokenIn_.decimals()));
        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        path[1] = liquidityToken();
        path[2] = tokenOut;
        IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokens(amountIn, amountOut, path, address(this), block.timestamp);
        tokenIn_.approve(UNISWAP_V2_ROUTER, 0);
    }

    ///

    function routers(string memory exchange) public view virtual returns (address) {
        return market().routers[exchange];
    }

    function hasRouter(string memory exchange) public view virtual returns (bool) {
        return routers(exchange) != address(0);
    }

    ///

    function slippageThreshold() public view virtual returns (uint) {
        return market().slippageThreshold;
    }

    ///

    function liquidityToken() public view virtual returns (address) {
        return market().liquidityToken;
    }

    ///

    function _isSelfOrAdmin() internal view virtual returns (bool) {
        return msg.sender == IConsole(address(this)).admin() || msg.sender == address(this);
    }

    ///

    function _hasEnoughBalance(address token, uint amount) internal view virtual returns (bool) {
        return IToken(token).balanceOf(address(this)) >= amount;
    }

    ///

    function _adaptor(address token) internal view virtual returns (address) {
        return IOracleReader(address(this)).adaptor(token);
    }

    function _hasAdaptor(address token) internal view virtual returns (bool) {
        return IOracleReader(address(this)).hasAdaptor(token);
    }

    ///

    function _symbolA(address token) internal view virtual returns (string memory) {
        return IOracleReader(address(this)).symbolA(token);
    }

    function _symbolB(address token) internal view virtual returns (string memory) {
        return IOracleReader(address(this)).symbolB(token);
    }

    function _decimals(address token) internal view virtual returns (uint8) {
        return IOracleReader(address(this)).decimals(token);
    }

    ///

    function _price(address token) internal view virtual returns (uint) {
        return IOracleReader(address(this)).price(token);
    }

    function _timestamp(address token) internal view virtual returns (uint) {
        return IOracleReader(address(this)).timestamp(token);
    }

    ///

    function _isWithinTheLastHour(address token) internal view virtual returns (bool) {
        return IOracleReader(address(this)).isWithinTheLastHour(token);
    }

    function _isWithinTheLastDay(address token) internal view virtual returns (bool) {
        return IOracleReader(address(this)).isWithinTheLastDay(token);
    }

    function _isWithinTheLastWeek(address token) internal view virtual returns (bool) {
        return IOracleReader(address(this)).isWithinTheLastWeek(token);
    }

    function _isWithinTheLastMonth(address token) internal view virtual returns (bool) {
        return IOracleReader(address(this)).isWithinTheLastMonth(token);
    }
}