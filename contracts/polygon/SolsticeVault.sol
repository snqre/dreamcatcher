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

    function deposit(address tokenIn, uint256 amountIn) public onlyAllowedIn(tokenIn) whenNotPaused() returns (uint256) {
        IERC20Metadata(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        uint256 v = value(tokenIn, amountIn);
        require(v != 0, "SolsticeVault: v == 0");
        uint256 s = totalSupply();
        require(s != 0, "SolsticeVault: s == 0");
        uint256 b = totalValue();
        require(b != 0, "SolsticeVault: b == 0");
        uint256 mintable = __Finance.amountToMint(v, s, b);
        _erc20.mint(msg.sender, mintable);
    }

    function withdraw(uint256 amountIn) public whenNotPaused() {
        require(amountIn != 0, "SolsticeVault: amountIn == 0");
        _erc20.transferFrom(msg.sender, address(this), amountIn);
        _erc20.burn(amountIn);
        uint256 s = totalSupply();
        require(s != 0, "SolsticeVault: s == 0");
        uint256 b = totalValue();
        require(b != 0, "SolsticeVault: b == 0");
        uint256 sendable = __Finance.amountToSend(amountIn, s, b);
        bool success;
        success = _repayInDenominator(sendable);
        if (!success) { success = _repayInAllowedOut(sendable); }
        if (!success) { success = _repayInKind(sendable); }
        if (!success) {
            /**
            * WARNING: This should never be the case. The vault
            *          should always have enough value to repay
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
            _deficit = true;
        }
        else {

        }
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
}