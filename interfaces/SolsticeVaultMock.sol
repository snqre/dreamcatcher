// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/abstract/State.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import "contracts/polygon/interfaces/IUniswapV2PriceFeedV1.sol";

import "contracts/polygon/interfaces/IMarketV1.sol";

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

contract SolsticeVault is State {

    using EnumerableSet for EnumerableSet.AddressSet;

    /** Function Modifiers. */

    /**
    * @dev Only the contract itself or a manager can call this
    *      function. This is useful for limiting access to functions
    *      like swapping or managing funds.
    *
    * REQUIRE: Only manager.
    * REQUIRE: Only self.
     */
    modifier onlySelfOrManager() {
        require(
            msg.sender == manager() ||
            msg.sender == address(this),
            "SolsticeVault: !address(this) || !manager"
        );
        _;
    }

    /**
    * @dev Only depositors can call this function.
    *      This is useful for withdrawal function which allows only
    *      depositors to access the function minimizing risk.
    *
    * REQUIRE: Only depositor.
     */
    modifier onlyDepositor() {
        bool contains = 
        _addressSet[keccak256(abi.encode("depositors"))]
        .contains(msg.sender);

        require(contains, "SolsticeVault: !depositor");
        _;
    }

    modifier onlyAllowedIn(address tokenIn) {
        bool contains = 
        _addressSet[keccak256(abi.encode("allowedIn"))]
        .contains(tokenIn);

        require(contains, "SolsticeVault: does not accept this token for deposit");
        _;
    }

    modifier onlyDuringClosedBeta() {
        
    }

    /** Constructor. */

    constructor(
        address manager
    ) payable {

        /** TODO */
        _setManager(manager);

        /**
        * @dev Exchanges are stored factory and router locations. Using
        *      this data we can get prices and make trades onchain.
        *      The exchanges store router, factory, and name.
         */
        _bytesArray[keccak256(abi.encode("exchanges"))]
        .push(
            abi.encode(
                0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff,
                0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32,
                "QuickSwap"
            )
        );

        _bytesArray[keccak256(abi.encode("exchanges"))]
        .push(
            abi.encode(
                0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506,
                0xc35DADB65012eC5796536bD9864eD8773aBc74C4,
                "SushiSwap"
            )
        );
    }

    /** Token. */

    /** Public View. */

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

    /** Internal. */

    function _mint(address account, uint256 amount) internal {
        /** TODO Encode functionality on token side. */
        IERC20Metadata(token()).mint(account, amount);
    }

    function _burn(uint256 amount) internal {
        /** TODO Encode functionality on token side. */
        IERC20Metadata(token()).burn(amount);
    }

    /** Permission. */

    /** Public View. */

    function manager() public view returns (address) {

        return _address[keccak256(abi.encode("manager"))];
    }

    function depositors() public view returns (address[] memory) {

        return _addressSet[keccak256(abi.encode("depositors"))].values();
    }

    /** Internal. */

    function _setManager(address account) internal {

        _address[keccak256(abi.encode("manager"))] = account;
    }

    function _addDepositor(address account) internal {
        
        _addressSet[keccak256(abi.encode("depositors"))].add(account);
    }

    function _removeDepositor(address account) internal {

        _addressSet[keccak256(abi.encode("depositors"))].remove(account);
    }

    /** Settings. */

    /** Public View. */

    /**
    * @dev Only tokens within this set are allowed in as deposits.
    *      This is typically to make sure users are only
    *      depositing tokens with enough liquidity to make swaps.
     */
    function allowedIn() public view returns (address[] memory) {

        return _addressSet[keccak256(abi.encode("allowedIn"))];
    }

    /**
    * @dev Only tokens within this set are allowed out as withdrawals.
    *      When a user withdraws funds from the vault they are given
    *      as these tokens. If there is not enough value within the
    *      allowed set, the contract will ignore this and pay the
    *      withdrawer in kind even if the token is not allowed out.
     */
    function allowedOut() public view returns (address[] memory) {

        return _addressSet[keccak256(abi.encode("allowedOut"))];
    }

    /**
    * @dev When this setting is not empty, it will swap the tokens
    *      allowed in automatically into this token. This means
    *      if the user deposits 3 different tokens, the contract
    *      will try to swap them into this token for the manager.
     */
    function swapIn() public view returns (address) {

        return _address[keccak256(abi.encode("swapIn"))];
    }

    /**
    * @dev This does the same as swapIn but this will do the same for
    *      withdrawals. It will try to consolidate the value in a single
    *      token. If one of the tokens does not have enough liqudidity
    *      to make the trade, this will be ignored and they will 
    *      be paid in kind.
     */
    function swapOut() public view returns (address) {

        return _address[keccak256(abi.encode("swapOut"))];
    }

    /**
    * @dev This points to the location of the price feed proxy
    *      which we use to get prices of tokens from various
    *      exchanges.
     */
    function feed() public view returns (address) {

        return _address[keccak256(abi.encode("feed"))];
    }

    /**
    * @dev This points to the location of the market proxy which
    *      is responsible for making trades with various 
    *      exchanges.
     */
    function market() public view returns (address) {

        return _address[keccak256(abi.encode("market"))];
    }

    /** Public. */

    /**
    * @dev Add a token that is to be allowed in.
     */
    function addAllowedIn(address token) public onlySelfOrManager() {

        _addressSet[keccak256(abi.encode("allowedIn"))].add(token);
    }

    /**
    * @dev Remove a token that should be allowed in.
     */
    function removeAllowedIn(address token) public onlySelfOrManager() {

        _addressSet[keccak256(abi.encode("allowedOut"))].remove(token);
    }

    function addAllowedOut(address token) public onlySelfOrManager() {

        _addressSet[keccak256(abi.encode("allowedOut"))].add(token);
    }

    function removeAllowedOut(address token) public onlySelfOrManager() {

        _addressSet[keccak256(abi.encode("allowedOut"))].remove(token);
    }

    /** Statistics. */

    function newAssetValue() public view returns (uint256) {

    }

    /** Core. */

    /** Public. */

    function deposit(address tokenIn, uint256 amountIn) public onlyAllowedIn(tokenIn) {

        IERC20Metadata(tokenIn)
        .transferFrom(msg.sender, address(this), amountIn);

        if (swapIn() != address(0)) {

            IMarketV1(market())
            .swapTokensSlippage(

            );
        }
    }

    /** Internal. */

    function _swap(
        address tokenIn, 
        address tokenOut, 
        int256 amountIn, 
        uint256 slippage, 
        address denominator, 
        address from, 
        address to
    ) internal {

        IUniswapV2PriceFeedV1 feed = IUniswapV2PriceFeedV1(feed());

        
    }
    
}   