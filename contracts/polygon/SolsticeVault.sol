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

    Vault public vault;

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
    }

    constructor(string memory name, string memory symbol) Ownable(msg.sender) {
        vault.erc20 = new ERC20Mintable(name, symbol, address(this));
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

    function isSameString(string memory stringA, string memory stringB) public pure returns (bool) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

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
            pair.valueA = (amount * (reserveA * (10**tokenB_.decimals()))) / reserveB;
            pair.valueA *= 10**18;
            pair.valueA /= 10**tokenA_.decimals();
            pair.valueB = (amount * (reserveB * (10**tokenA_.decimals()))) / reserveA;
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

}