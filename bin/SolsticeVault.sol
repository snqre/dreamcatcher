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

    modifier onlySupported(address tokenIn) {
        bool success;
        success = isSupported(tokenIn);
        require(success, "!supported");
        _;
    }

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
    
    function token() public view returns (address) {
        return address(_vault.erc20);
    }

    function name() public view returns (string memory) {
        return _vault.erc20.name();
    }

    function symbol() public view returns (string memory) {
        return _vault.erc20.symbol();
    }

    function decimals() public view returns (uint8) {
        return _vault.erc20.decimals();
    }

    function supply() public view returns (uint256) {
        return _vault.erc20.totalSupply();
    }

    function description() public view returns (string memory) {
        return _vault.erc20.description();
    }

    function denominator() public view returns (address) {
        return _vault.denominator;
    }

    function isSupported(address tokenIn) public view returns (bool) {
        (uint256 priceA, uint256 priceB, uint256 priceC) = prices(tokenIn, denominator());
        if (
            priceA != 0 ||
            priceB != 0 ||
            priceC != 0
        ) { return true; }
        else { return false; }
    }

    function prices(address tokenA, address tokenB) public view returns (uint256, uint256, uint256) {
        uint256 priceA;
        uint256 priceB;
        uint256 priceC;
        uint256 a;
        uint256 b;
        uint256 o;
        Order oo;
        (, , , , , , , , , , , a, b, , , o) = pair(Exchange.MESHSWAP);
        oo = Order(o);
        if (oo.SAME) { priceA = a; } else if (oo.REVERSE) { priceA = b; }
        else { priceA = 0; }
        (, , , , , , , , , , , a, b, , , o) = pair(Exchange.QUICKSWAP);
        oo = Order(o);
        if (oo.SAME) { priceB = a; } else if (oo.REVERSE) { priceB = b; }
        else { priceB = 0; }
        (, , , , , , , , , , , a, b, , , o) = pair(Exchange.SUSHISWAP);
        oo = Order(o);
        if (oo.SAME) { priceC = a; } else if (oo.REVERSE) { priceC = b; }
        else { priceC = 0; }
        return (priceA, priceB, priceC);
    }

    function pair(Exchange exchange, address tokenA, address tokenB) public view returns (address, address, address, string memory, string memory, string memory, string memory, uint8, uint8, uint256, uint256, uint256, uint256, uint256, uint256) {
        address factory;
        if (exchange == Exchange.MESHSWAP) { factory = meshswap.factory; }
        else if (exchange == Exchange.SUSHISWAP) { factory = sushiswap.factory; }
        else if (exchange == Exchange.QUICKSWAP) { factory = quickswap.factory; }
        Pair memory pair;
        pair.pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        if (pair.pair == address(0x0)) {
            string memory emptyString;
            pair = Pair({
                pair: address(0x0),
                tokenA: address(0x0),
                tokenB: address(0x0),
                nameA: emptyString,
                nameB: emptyString,
                symbolA: emptyString,
                symbolB: emptyString,
                decimalsA: 0,
                decimalsB: 0,
                reserveA: 0,
                reserveB: 0,
                valueA: 0,
                valueB: 0,
                lastTimestamp: 0,
                order: Order.UNRECOGNIZED
            });
            return (
                pair.pair,
                pair.tokenA,
                pair.tokenB,
                pair.nameA,
                pair.nameB,
                pair.symbolA,
                pair.symbolB,
                pair.decimalsA,
                pair.decimalsB,
                pair.reserveA,
                pair.reserveB,
                pair.valueA,
                pair.valueB,
                pair.lastTimestamp,
                uint256(pair.order)
            );
        }
        else {
            IUniswapV2Pair interfacePair = IUniswapV2Pair(pair.pair);
            IERC20Metadata interfaceTokenA = IERC20Metadata(interfacePair.token0());
            IERC20Metadata interfaceTokenB = IERC20Metadata(interfacePair.token1());
            pair.tokenA = interfacePair.token0();
            pair.tokenB = interfacePair.token1();
            pair.nameA = interfaceTokenA.name();
            pair.nameB = interfaceTokenB.name();
            pair.symbolA = interfaceTokenA.symbol();
            pair.symbolB = interfaceTokenB.symbol();
            pair.decimalsA = interfaceTokenA.decimals();
            pair.decimalsB = interfaceTokenB.decimals();
            (
                uint256 reserveA,
                uint256 reserveB,
                uint256 lastTimestamp
            )
            = interfacePair.getReserves();
            pair.reserveA = reserveA;
            pair.reserveB = reserveB;
            pair.valueA = (1 * (reserveB * (10**tokenA_.decimals()))) / reserveA;
            pair.valueA *= 10**18;
            pair.valueA /= 10**tokenB_.decimals();
            pair.valueB = (1 * (reserveA * (10**tokenB_.decimals()))) / reserveB;
            pair.valueB *= 10**18;
            pair.valueB /= 10**tokenA_.decimals();
            pair.lastTimestamp = lastTimestamp;
            if (
                tokenA == pair.tokenA &&
                tokenB == pair.tokenB &&
                isSameString(interfaceTokenA.name(), pair.nameA) &&
                isSameString(interfaceTokenB.name(), pair.nameB) &&
                isSameString(interfaceTokenA.symbol(), pair.symbolA) &&
                isSameString(interfaceTokenB.symbol(), pair.symbolB) &&
                interfaceTokenA.decimals() == pair.decimalsA &&
                interfaceTokenB.decimals() == pair.decimalsB
            ) {
                pair.order = Order.SAME;
            }
            else if (
                tokenA == pair.tokenB &&
                tokenB == pair.tokenA &&
                isSameString(interfaceTokenA.name(), pair.nameB) &&
                isSameString(interfaceTokenB.name(), pair.nameA) &&
                isSameString(interfaceTokenA.symbol(), pair.symbolB) &&
                isSameString(interfaceTokenB.symbol(), pair.symbolA) &&
                interfaceTokenA.decimals() == pair.decimalsB &&
                interfaceTokenB.decimals() == pair.decimalsA
            ) {
                pair.order = Order.REVERSE;
            }
            else {
                pair.order = Order.UNRECOGNIZED;
            }
            return (
                pair.pair,
                pair.tokenA,
                pair.tokenB,
                pair.nameA,
                pair.nameB,
                pair.symbolA,
                pair.symbolB,
                pair.decimalsA,
                pair.decimalsB,
                pair.reserveA,
                pair.reserveB,
                pair.valueA,
                pair.valueB,
                pair.lastTimestamp,
                uint256(pair.order)
            );
        }
    }

    function sum() public view returns (uint256, uint256, uint256) {
        uint256 priceA;
        uint256 priceB;
        uint256 priceC;
        uint256 balance;
        uint256 sumA;
        uint256 sumB;
        uint256 sumC;
        for (uint256 i = 0; i < _vault.supported.length(); i++) {
            delete priceA;
            delete priceB;
            delete priceC;
            delete balance;
            (priceA, priceB, priceC) = prices(_vault.supported.at(i), denominator());
            //balance = IERC20Metadata(_vault.supported.at(i)).balanceOf(address(this));
            balance += 1;
            sumA += (balance * priceA);
            sumB += (balance * priceB);
            sumC += (balance * priceC);
        }
        return (sumA, sumB, sumC);
    }

    function addSupported(address tokenIn) public onlyOwner() onlySupported(tokenIn) whenNotPaused() returns (bool) {
        _vault.supported.add(tokenIn);
        return true;
    }
}