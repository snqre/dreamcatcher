// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/IERC20Mintable.sol";
import "contracts/polygon/ERC20Mintable.sol";
import "contracts/polygon/external/openzeppelin/access/Ownable.sol";
import "contracts/polygon/external/openzeppelin/security/Pausable.sol";
import "contracts/polygon/external/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import "contracts/polygon/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/external/openzeppelin/utils/Context.sol";

contract SolsticeVault is Ownable, Pausable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;

    enum Exchange { QUICKSWAP, SUSHISWAP, MESHSWAP }
    enum Order { SAME, REVERSE, UNRECOGNIZED }

    Market public quickswap;
    Market public sushiswap;
    Market public meshswap;

    Vault private _vault;

    struct Pair {
        address pair;
        address tokenA;
        address tokenB;
        string nameA;
        string nameB;
        string symbolA;
        string symbolB;
        uint8 decimalsA;
        uint8 decimalsB;
        uint256 reserveA;
        uint256 reserveB;
        uint256 valueA;
        uint256 valueB;
        uint256 lastTimestamp;
        Order order;
    }

    struct Market {
        address factory;
        address router;
    }

    struct Vault {
        string name;
        string description;
        address denominator;
        ERC20Mintable erc20;
        EnumerableSet.AddressSet supported;
    }

    constructor(string memory name, string memory symbol) Ownable(msg.sender) {
        _vault.erc20 = new ERC20Mintable(name, symbol, address(this));
        quickswap = Market({
            factory: 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32,
            router: 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff
        });
        sushiswap = Market({
            factory: 0xc35DADB65012eC5796536bD9864eD8773aBc74C4,
            router: 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
        });
        meshswap = Market({
            factory: 0x9F3044f7F9FC8bC9eD615d54845b4577B833282d,
            router: 0x10f4A785F458Bc144e3706575924889954946639
        });
    }

    /**
    * @notice Check if two strings are identical.
    * @param stringA The first string.
    * @param stringB The second string.
    * @return Whether the two strings are identical.
    */
    function isSameString(string memory stringA, string memory stringB) public pure returns (bool) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    /**
    * @notice Get information about a UniswapV2 pair on a specific exchange.
    * @param exchange The UniswapV2 exchange (e.g., MESHSWAP, SUSHISWAP, QUICKSWAP).
    * @param tokenA The address of the first token in the pair.
    * @param tokenB The address of the second token in the pair.
    * @return pair Information about the UniswapV2 pair, including token details, reserves, values, and order.
    * @dev If the pair does not exist, the returned pair will have default values and an order of UNRECOGNIZED.
    */
    function pair(Exchange exchange, address tokenA, address tokenB) public view returns (Pair memory pair) {
        address factory;
        if (exchange == Exchange.MESHSWAP) { factory = meshswap.factory; }
        else if (exchange == Exchange.SUSHISWAP) { factory = sushiswap.factory; }
        else if (exchange == Exchange.QUICKSWAP) { factory = quickswap.factory; }
        pair.pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        if (pair.pair == address(0x0)) {
            string memory emptyString;
            pair.tokenA = address(0x0);
            pair.tokenB = address(0x0);
            pair.nameA = emptyString;
            pair.nameB = emptyString;
            pair.symbolA = emptyString;
            pair.symbolB = emptyString;
            pair.decimalsA = 0;
            pair.decimalsB = 0;
            pair.reserveA = 0;
            pair.reserveB = 0;
            pair.valueA = 0;
            pair.valueB = 0;
            pair.lastTimestamp = 0;
            pair.order = Order.UNRECOGNIZED;
        }
        else {
            IUniswapV2Pair interface_ = IUniswapV2Pair(pair.pair);
            IERC20Metadata tokenA_ = IERC20Metadata(interface_.token0());
            IERC20Metadata tokenB_ = IERC20Metadata(interface_.token1());
            pair.tokenA = interface_.token0();
            pair.tokenB = interface_.token1();
            pair.nameA = tokenA_.name();
            pair.nameB = tokenB_.name();
            pair.symbolA = tokenA_.symbol();
            pair.symbolB = tokenB_.symbol();
            pair.decimalsA = tokenA_.decimals();
            pair.decimalsB = tokenB_.decimals();
            (uint256 reserveA, uint256 reserveB, uint256 lastTimestamp) = interface_.getReserves();
            pair.reserveA = reserveA;
            pair.reserveB = reserveB;
            pair.valueA = (1 * (reserveA * (10**tokenB_.decimals()))) / reserveB;
            pair.valueA *= 10**18;
            pair.valueA /= 10**tokenA_.decimals();
            pair.valueB = (1 * (reserveB * (10**tokenA_.decimals()))) / reserveA;
            pair.valueB *= 10**18;
            pair.valueB /= 10**tokenB_.decimals();
            pair.lastTimestamp = lastTimestamp;
            if (
                tokenA == pair.tokenA &&
                tokenB == pair.tokenB &&
                isSameString(tokenA_.name(), pair.nameA) &&
                isSameString(tokenB_.name(), pair.nameB) &&
                isSameString(tokenA_.symbol(), pair.symbolA) &&
                isSameString(tokenB_.symbol(), pair.symbolB) &&
                tokenA_.decimals() == pair.decimalsA &&
                tokenB_.decimals() == pair.decimalsB
            ) {
                pair.order = Order.SAME;
            }
            else if (
                tokenA == pair.tokenB &&
                tokenB == pair.tokenA &&
                isSameString(tokenA_.name(), pair.nameB) &&
                isSameString(tokenB_.name(), pair.nameA) &&
                isSameString(tokenA_.symbol(), pair.symbolB) &&
                isSameString(tokenB_.symbol(), pair.symbolA) &&
                tokenA_.decimals() == pair.decimalsB &&
                tokenB_.decimals() == pair.decimalsA
            ) {
                pair.order = Order.REVERSE;
            }
        }
        return pair;
    }

    /**
    * @notice Calculate the total value of assets in the vault, denominated in a specified token.
    * @param exchange The Uniswap exchange to use for price information.
    * @param denominator The token in which the total value is denominated.
    * @return uint256 The total value of assets in the vault denominated in the specified token.
    */
    function sum(Exchange exchange, address denominator) public view returns (uint256) {
        uint256 sum;
        uint256 balance;
        uint256 price;
        for (uint256 i = 0; i < _vault.supported.length(); i++) {
            balance = 0;
            price = 0;
            Pair memory pair = pair(exchange, _vault.supported.at(i), denominator);
            if (pair.order == Order.SAME) { price = pair.valueA; }
            else if (pair.order ==  Order.REVERSE) { price = pair.valueB; }
            else {}
            balance = IERC20Metadata(_vault.supported.at(i)).balanceOf(address(this));
            sum += (balance * price);
        }
        return sum;
    }

    function addSupported(address erc20) onlyOwner() public returns (bool) {
        Vault.supported.add(erc20);
        return true;
    }

}