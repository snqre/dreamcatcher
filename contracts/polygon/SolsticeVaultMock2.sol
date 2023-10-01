// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/libraries/__Finance.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/IERC20Mintable.sol";
import "contracts/polygon/ERC20Mintable.sol";
import "contracts/polygon/external/openzeppelin/access/Ownable.sol";
import "contracts/polygon/external/openzeppelin/security/Pausable.sol";
import "contracts/polygon/external/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

contract SolsticeVault is Ownable, Pausable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    bool private _deficit;
    address private _denominator;
    UniswapV2[] private _uniswapV2s;
    ERC20Mintable private _erc20;
    EnumerableSet.AddressSet private _allowedIn;
    EnumerableSet.AddressSet private _allowedOut;
    EnumerableSet.AddressSet private _all;

    struct UniswapV2 {
        string name;
        address factory;
        address router;
    }

    modifier onlyAllowedIn(address tokenIn) {
        _onlyAllowedIn(tokenIn);
        _;
    }
    
    constructor(string memory name, string memory symbol) {
        _erc20 = new ERC20Mintable(name, symbol, address(this));
    }

    function token() public view returns (address) {
        return address(_erc20);
    }

    function name() public view returns (string memory) {
        return _erc20.name();
    }

    function symbol() public view returns (string memory) {
        return _erc20.symbol();
    }

    function decimals() public view returns (uint8) {
        return _erc20.decimals();
    }

    function totalSupply() public view returns (uint256) {
        return _erc20.totalSupply();
    }

    function totalValue() public view returns (uint256) {
        return __Finance.netAssetValue(factories(), _all.values(), denominator());
    }

    function denominator() public view returns (address) {
        return _denominator;
    }

    function factories() public view returns (address[] memory) {
        uint256 length = _uniswapV2s.length;
        require(length >= 1, "SolsticeVault: length is zero");
        address[] memory factories;
        factories = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            factories[i] = _uniswapV2s[i].factory;
        }
        return factories;
    }

    function value(address token, uint256 amount) public view returns (uint256) {
        return __Finance.meanPrice(factories(), token, denominator(), amount);
    }

    function amount(address token, uint256 value) public view returns (uint256) {
        uint256 unitValue = value(token, 1);
        uint256 amount = value / unitValue;
        require(amount * uintValue == value, "SolsticeVault: failed math");
        return amount;
    }

    function basis(address token) public view returns (uint256) {
        uint256 balance = IERC20Metadata(token).balanceOf(address(this));
        uint256 value = value(token, balance);
        uint256 basis = (value * 10000) / totalValue();
        return basis;
    }

    /**
    * @notice Allows a user to deposit a specified amount of a token into the SolsticeVault.
    * @param tokenIn The address of the token to be deposited.
    * @param amountIn The amount of the token to be deposited.
    * @return uint256 Returns the amount of tokens minted to the depositor's address.
    * @dev Calls internal functions to perform checks and actions before and after the deposit, respecting the pause state of the contract.
    */
    function deposit(address tokenIn, uint256 amountIn) public whenNotPaused() nonReentrant() returns (uint256) {
        _beforeDeposit(tokenIn, amountIn);
        _afterDeposit(tokenIn, amountIn);
    }

    function withdraw(uint256 amountIn) public whenNotPaused() {
        _beforeWithdraw(amountIn);
        _afterWithdraw(amountIn);
    }

    function emergencyWithdraw(uint256 amountIn) public whenNotPaused() {

    }

    function _onlyAllowedIn(address tokenIn) internal view {
        require(_allowedIn.contains(tokenIn), "SolsticeVault: !allowedIn");
    }

    function _repayInDenominator(uint256 required) internal returns (bool) {
        uint256 balance = IERC20Metadata(denominator()).balanceOf(address(this));
        uint256 value = value(denominator(), balance);
        if (value >= required) {
            uint256 amount = amount(denominator(), required);
            IERC20Metadata(denominator()).transfer(msg.sender, amount);
            return true;
        }
        return false;
    }

    function _repayInAllowedOut(uint256 required) internal returns (bool) {
        uint256[] memory balances;
        balances = new uint256[](_allowedOut.length());
        for (uint256 i = 0; i < balances.length; i++) {
            
        }
    }

    function _repayInKind(uint256 required) internal returns (bool) {

    }

    /**
    * @notice Performs checks and actions before initiating a withdrawal from the SolsticeVault.
    * @param amountIn The amount of tokens to be withdrawn.
    * @dev Ensures that the withdrawal amount, total supply, and total value are non-zero. Transfers the specified amount of tokens from the sender to the SolsticeVault and burns an equivalent amount of tokens from the SolsticeVault's ERC20 token supply.
    */
    function _beforeWithdraw(uint256 amountIn) internal {
        uint256 a = amountIn;
        uint256 s = totalSupply();
        uint256 b = totalValue();
        require(
            a != 0 &&
            s != 0 &&
            b != 0,
            "SolsticeVault: zero value"
        );
        _erc20.transferFrom(msg.sender, address(this), amountIn);
        _erc20.burn(amountIn);
    }

    /**
    * @notice Performs actions after a successful withdrawal from the SolsticeVault.
    * @param amountIn The amount of tokens that was withdrawn.
    * @dev Calculates the value (a) of the withdrawn tokens, gets the total supply (s) and total value (b) of the SolsticeVault, calculates the value to send using the Finance library, attempts to repay in the denominator token, and if unsuccessful, attempts to repay in any allowed output token. If both attempts fail, it repays in-kind.
    * @dev Includes a warning and notes about potential deficits in the vault value and provides guidance on how to mitigate and handle such situations.
    */
    function _afterWithdraw(uint256 amountIn) internal {
        uint256 a = amountIn;
        uint256 s = totalSupply();
        uint256 b = totalValue();
        uint256 value = __Finance.amountToSend(a, s, b);
        bool success = _repayInDenominator(value);
        if (!success) { _repayInAllowedOut(value); }
        if (!success) { _repayInKind(value); }
        
        /**
        * WARNING: This should never not have enough value
        *          to repay the depositors. The vault should
        *          always have enough value to repay
        *          the depositor. This may happen because one
        *          or more pairs report zero price because
        *          they may not have been found or are just
        *          not correct. It is important that all
        *          allowed in pairs are supported as
        *          TOKEN / DENOMINATOR before adding it
        *          to the allowedIn pair.
        *
        * NOTE Always make sure that allowedIn pairs are
        *      tradeable and price is correctly fetched.
        *
        * NOTE Mitigate this occurence by making sure 
        *      the vault holds a portion of holdings as
        *      denominator to ensure liquidity can be
        *      freely withdrawn.
        *
        * NOTE In the event of a deficit emergency withdrawals
        *      will be enabled allowing depositors to withdraw
        *      the owed value in any token or tokens they want
        *      directly from the vault.
         */
        if (!success) { _deficit = true; }
    }

    /**
    * @notice Performs checks and actions before accepting a deposit into the SolsticeVault.
    * @param tokenIn The address of the token to be deposited.
    * @param amountIn The amount of the token to be deposited.
    * @dev Ensures that the token being deposited is allowed, calculates its value, checks for non-zero values (v, s, b), and transfers the specified amount from the sender to the SolsticeVault.
    */
    function _beforeDeposit(address tokenIn, uint256 amountIn) internal {
        _onlyAllowedIn(tokenIn);
        uint256 v = value(tokenIn, amountIn);
        uint256 s = totalSupply();
        uint256 b = totalValue();
        require(
            v != 0 &&
            s != 0 &&
            b != 0,
            "SolsticeVault: zero value"
        );
        IERC20Metadata(tokenIn).transferFrom(msg.sender, address(this), amountIn);
    }

    /**
    * @notice Performs actions after a successful deposit into the SolsticeVault.
    * @param tokenIn The address of the token that was deposited.
    * @param amountIn The amount of the token that was deposited.
    * @dev Calculates the value (v) of the deposited token, gets the total supply (s) and total value (b) of the SolsticeVault, calculates the amount of tokens to mint based on the Finance library, and mints the calculated amount to the depositor's address.
    */
    function _afterDeposit(address tokenIn, uint256 amountIn) internal {
        uint256 v = value(tokenIn, amountIn);
        uint256 s = totalSupply();
        uint256 b = totalValue();
        uint256 amountToMint = __Finance.amountToMint(v, s, b);
        _erc20.mint(msg.sender, amountToMint);
    }
}