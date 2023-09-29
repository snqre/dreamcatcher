// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/abstract/State.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import "contracts/polygon/interfaces/IUniswapV2PriceFeedV1.sol";

import "contracts/polygon/interfaces/IMarketV1.sol";

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

import "contracts/polygon/libraries/Bytes.sol";

contract SolsticeVault is State {

    using EnumerableSet for EnumerableSet.AddressSet;

    address immutable USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;

    /** Function Modifiers. */

    /**
    * @dev Only the manager can call this function.
     */
    modifier onlyManager() {
        require(msg.sender == manager(), "SolsticeVault: !manager");
        _;
    }

    /** Constructor. */

    constructor(address token, address manager) {

        _pushExchange("quickswap", 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32, 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);

        _pushExchange("sushiswap", 0xc35DADB65012eC5796536bD9864eD8773aBc74C4, 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);

        _setToken(token);

        _setManager(manager);
    }

    /** External. */

    function swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 exchange) external onlyManager() {

        _swapTokens(tokenIn, tokenOut, amountIn, exchange);
    }

    /**
    * @dev Deposit function takes the address of the token contract
    *      being deposited and the amount of the token and does
    *      a check for if the token is allowed.
    *
     */
    function deposit(address tokenIn, uint256 amountIn) external {

        /**
        * Require that the deposited token is allowed in.
         */
        require(isAllowedIn(tokenIn), "SolsticeVault: tokenIn !allowed");

        
        IERC20Metadata(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        (uint256 value, uint256 averageLastTimestamp) = _averagePrice(tokenA, USDT, amountIn);

        /**
        * @dev Check the averageLastTimestamp to make sure it isn't
        *      too outdated and is recent.
         */
        require(
            averageLastTimestamp
            >= block.timestamp
            - 1 days,
            "SolsticeVault: valuation is outdated"
        );

        require(averageLastTimestamp >= block.timestamp - 1 days);
    }

    function withdraw(uint256 amountIn) external {

    }

    /** Public View. */

    function exchange(uint256 index) public view returns (string memory name, address factory, address router) {

        bytes[] memory exchanges = _bytesArray[keccak256(abi.encode("exchanges"))];

        (name, factory, router) = abi.decode(exchanges[index], (string,address,address));

        return (name, factory, router);
    }

    function exchangeCount() public view returns (uint256 count) {

        bytes[] memory exchanges = _bytesArray[keccak256(abi.encode("exchanges"))];

        return exchanges.length;
    }

    function depositor(uint256 index) public view returns (address) {

        EnumerableSet.AddressSet memory depositors = _addressSet[keccak256(abi.encode("depositors"))];

        return depositors.at(index);
    }

    function depositors() public view returns (address[] memory) {

        EnumerableSet.AddressSet memory depositors = _addressSet[keccak256(abi.encode("depositors"))];

        return depositors.values();
    }

    function isDepositor(address account) public view returns (bool) {

        EnumerableSet.AddressSet memory depositors = _addressSet[keccak256(abi.encode("depositors"))];

        return depositors.contains(account);
    }

    function depositorCount() public view returns (uint256 count) {

        EnumerableSet.AddressSet memory depositors = _addressSet[keccak256(abi.encode("depositors"))];

        return depositors.length();
    }

    function allowedIn() public view returns (address[] memory) {

        EnumerableSet.AddressSet memory allowedIn = _addressSet[keccak256(abi.encode("allowedIn"))];

        return allowedIn.values();
    }

    function isAllowedIn(address token) public view returns (bool) {

        EnumerableSet.AddressSet memory allowedIn = _addressSet[keccak256(abi.encode("allowedIn"))];

        return allowedIn.contains(token);
    }

    function allowedOut() public view returns (address[] memory) {

        EnumerableSet.AddressSet memory allowedOut = _addressSet[keccak256(abi.encode("allowedOut"))];

        return allowedOut.values();
    }

    function isAllowedOut(address token) public view returns (bool) {

        EnumerableSet.AddressSet memory allowedOut = _addressSet[keccak256(abi.encode("allowedOut"))];

        return allowedOut.contains(token);
    }

    /**
    * @dev When this setting is not address zero, during a deposit
    *      the contract will swap the deposited allowed tokens
    *      into the given token.
    *
    * WARNING: If the token transaction does not have enough liquidity
    *          or slippage is high, it will revert. It is important
    *          to choose liquid tokens when this setting is enabled.
     */
    function swapIn() public view returns (address) {

        return _address[keccak256(abi.encode("swapIn"))];
    }

    /**
    * @dev This does the same as swapIn but does it for withdrawals
    *      and will consolidate value into this token to send back
    *      to the depositor.
    *
    * WARNING: If the token transaction does not have enough liquidity
    *          or slippage is high, it will revert. It is important
    *          to choose liquid tokens when this setting is enabled.
    *          If this fails, an emergency withdrawal option will
    *          become available for the depositor which will
    *          pay them in kind regardless of any settings.
     */
    function swapOut() public view returns (address) {

        return _address[keccak256(abi.encode("swapOut"))];
    }

    function token() public view returns (address) {

        return _address[keccak256(abi.encode("token"))];
    }

    function name() public view returns (string memory) {

        return IERC20Metadata(token()).name();
    }

    function symbol() public view returns (string memory) {

        return IERC20Metadata(token()).symbol();
    }

    function decimals() public view returns (uint8) {

        return IERC20Metadata(token()).decimals();
    }

    function totalSupply() public view returns (uint256) {

        return IERC20Metadata(token()).totalSupply();
    }

    function balanceOf(address account) public view returns (uint256) {

        return IERC20Metadata(token()).balanceOf(account);
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return IERC20Metadata(token()).allowance(owner, spender);
    }

    function manager() public view returns (address) {

        address manager = _address[keccak256(abi.encode("manager"))];

        return manager;
    }

    function balance() public view returns (uint256 balance) {
        
        address[] memory allowedIn = allowedIn();

        for (uint256 i = 0; i < allowedIn().length; i ++) {

            _averagePrice(allowedIn()[i], USDT, IERC20Metadata(allowedIn()[i])).balanceOf(address(this));
        }
    }

    /** Internal Pure. */
    
    /**
    * @param v The amount of value in tokens being sent.
    *
    * @param s The totalSupply of the vault token.
    *
    * @param b The balance in value in the vault.
     */
    function _amountToMint(uint256 v, uint256 s, uint256 b) internal pure returns (uint256) {

        require(v >= 1, "SolsticeVault: v < 1");
        require(s >= 1, "SolsticeVault: s < 1");
        require(b >= 1, "SolsticeVault: b < 1");

        return ((v * s) / b);
    }

    /**
    * @param v The amount of tokens that are being sent back.
    * 
    * @param s The totalSupply of the vault token.
    *
    * @param b The balance in value in the vault.
     */
    function _amountToSend(uint256 v, uint256 s, uint256 b) internal pure returns (uint256) {

        require(v >= 1, "SolsticeVault: v < 1");
        require(s >= 1, "SolsticeVault: s < 1");
        require(b >= 1, "SolsticeVault: b < 1");

        return ((v * b) / s);
    }

    /** Internal View. */

    function _averagePrice(address tokenA, address tokenB, uint256 amount) internal view returns (uint256 averagePrice, uint256 averageLastTimestamp) {

        uint256 active;

        for (uint256 i = 0; i < exchangeCount(); i++) {

            (, address factory,) = exchange(i);

            (uint256 price, uint256 lastTimestamp)
            = IUniswapV2PriceFeedV1(0xfFe1137aBB8075682f3547C3Bd7C803049bfAA71)
            .getPrice(factory, tokenA, tokenB, amount);

            if (price != 0 && lastTimestamp >= block.timestamp - 1 days) {

                averagePrice += price;

                averageLastTimestamp += lastTimestamp;

                active += 1;
            }
        }

        averagePrice /= active;

        averageLastTimestamp /= active;

        return (averagePrice, averageLastTimestamp);
    }

    /** Internal. */

    function _pushExchange(string memory name, address factory, address router) internal returns (uint256 index) {

        bytes[] storage exchanges = _bytesArray[keccak256(abi.encode("exchanges"))];

        Bytes.pushBytesArray(exchanges, abi.encode(name, factory, router));
    }

    function _pullExchange(uint256 index) internal {

        bytes[] storage exchanges = _bytesArray[keccak256(abi.encode("exchanges"))];

        bytes memory emptyBytes;

        exchanges[index] = emptyBytes;
    }

    function _swapTokens(address tokenIn, address tokenOut, uint256 amountIn, uint256 exchange) internal {

        IERC20Metadata(tokenIn).approve(0x2ed202130fc522AD1711395b40f5118a28A41dDb, amountIn);

       (, address factory, address router) = exchange(exchange);

        IMarketV1(0x2ed202130fc522AD1711395b40f5118a28A41dDb)
        .swapTokensSlippage(
            router, 
            factory, 
            0xfFe1137aBB8075682f3547C3Bd7C803049bfAA71, 
            tokenIn, 
            tokenOut, 
            amountIn, 
            100, 
            0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 
            address(this), 
            address(this)
        );
    }

    function _setToken(address token) internal {

        _address[keccak256(abi.encode("token"))] = token;
    }

    function _mint(address account, uint256 amount) internal {

        IERC20Metadata(token()).mint(account, amount);
    }

    function _burn(uint256 amount) internal {

        IERC20Metadata(token()).burn(amount);
    }

    function _setManager(address account) internal {

        _address[keccak256(abi.encode("manager"))] = account;
    }

    function _pushDepositor(address account) internal {

        _address[keccak256(abi.encode("depositors"))].add(account);
    }

    function _pullDepositor(address account) internal {

        _address[keccak256(abi.encode("depositors"))].remove(account);
    }

    function _pushAllowedIn(address token) internal {

        _addressSet[keccak256(abi.encode("allowedIn"))].add(token);
    }

    function _pullAllowedIn(address token) internal {

        _addressSet[keccak256(abi.encode("allowedIn"))].remove(token);
    }

    function _pushAllowedOut(address token) internal {

        _addressSet[keccak256(abi.encode("allowedOut"))].add(token);
    }

    function _pullAllowedOut(address token) internal {

        _addressSet[keccak256(abi.encode("allowedOut"))].remove(token);
    }

    function _setSwapIn(address token) internal {

        _address[keccak256(abi.encode("swapIn"))] = token;
    }

    function _setSwapOut(address token) internal {

        _address[keccak256(abi.encode("swapOut"))] = token;
    }
}