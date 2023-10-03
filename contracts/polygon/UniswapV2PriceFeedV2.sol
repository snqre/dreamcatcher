// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/ProxyStateOwnableContract.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

/**
* version 0.5.5
 */
contract UniswapV2PriceFeedV2 is ProxyStateOwnableContract {
    using EnumerableSet for EnumerableSet.AddressSet;

    modifier check(address factory, address tokenA, address tokenB) {
        _check(factory, tokenA, tokenB);
        _;
    }

    function isSameString(string memory stringA, string memory stringB) public pure returns (bool) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    function metadata(address factory, address tokenA, address tokenB) public view check(factory, tokenA, tokenB) returns (address pair, address addressA, address addressB, string memory nameA, string memory nameB, string memory symbolA, string memory symbolB, uint8 decimalsA, uint8 decimalsB) {
        IUniswapV2Factory factory = IUniswapV2Factory(factory);
        address pair = factory.getPair(tokenA, tokenB);
        require(pair != address(0x0), "UniswapV2PriceFeedV2: pair address is zero");
        IUniswapV2Pair pairInterface = IUniswapV2Pair(pair);
        IERC20Metadata tokenA_ = IERC20Metadata(pairInterface.token0());
        IERC20Metadata tokenB_ = IERC20Metadata(pairInterface.token1());
        require(pairInterface.token0() != address(0x0), "UniswapV2PriceFeedV2: token A address is zero");
        require(pairInterface.token1() != address(0x0), "UniswapV2PriceFeedV2: token B address is zero");
        string memory emptyString;
        require(!isSameString(tokenA_.name(), emptyString), "UniswapV2PriceFeedV2: token A name is empty");
        require(!isSameString(tokenB_.name(), emptyString), "UniswapV2PriceFeedV2: token B name is empty");
        require(!isSameString(tokenA_.symbol(), emptyString), "UniswapV2PriceFeedV2: token A symbol is empty");
        require(!isSameString(tokenB_.symbol(), emptyString), "UniswapV2PriceFeedV2: token B symbol is empty");
        require(tokenA_.decimals() >= 0 && tokenA_.decimals() <= 18, "UniswapV2PriceFeedV2: token A decimals out of bounds");
        require(tokenB_.decimals() >= 0 && tokenB_.decimals() <= 18, "UniswapV2PriceFeedV2: token B decimals out of bounds");
        return(pair, pairInterface.token0(), pairInterface.token1(), tokenA_.name(), tokenB_.name(), tokenA_.symbol(), tokenB_.symbol(), tokenA_.decimals(), tokenB_.decimals());
    }

    function isSameOrder(address factory, address tokenA, address tokenB) public view check(factory, tokenA, tokenB) returns (uint8) {
        (, address addressA, address addressB, string memory nameA, string memory nameB, string memory symbolA, string memory symbolB, uint8 decimalsA, uint8 deecimalsB) = metadata(factory, tokenA, tokenB);
        IERC20Metadata tokenA_ = IERC20Metadata(tokenA);
        IERC20Metadata tokenB_ = IERC20Metadata(tokenB);
        if (
            tokenA == addressA &&
            tokenB == addressB &&
            isSameString(tokenA_.name(), nameA) &&
            isSameString(tokenB_.name(), nameB) &&
            isSameString(tokenA_.symbol(), symbolA) &&
            isSameString(tokenB_.symbol(), symbolB) &&
            tokenA_.decimals() == decimalsA &&
            tokenB_.decimals() == decimalsB
        ) {
            return 0;
        }
        else if (
            tokenA == addressB &&
            tokenB == addressA &&
            isSameString(tokenA_.name(), nameB) &&
            isSameString(tokenB_.name(), nameA) &&
            isSameString(tokenA_.symbol(), symbolB) &&
            isSameString(tokenB_.symbol(), symbolA) &&
            tokenA_.decimals() == decimalsB &&
            tokenB_.decimals() == decimalsA
        ) {
            return 1;
        }
        else {
            revert("UniswapV2PriceFeedV2: unknown order");
        }
    }

    function price(address factory, address tokenA, address tokenB, uint256 amount) public view check(factory, tokenA, tokenB) returns (uint256) {
        (address pair, , , , , , , uint8 decimalsA, uint8 decimalsB) = metadata(factory, tokenA, tokenB);
        IUniswapV2Pair pairInterface = IUniswapV2Pair(pair);
        (uint256 reserveA, uint256 reserveB, uint256 lastTimestamp) = pairInterface.getReserves();
        if (side == 1) {
            uint256 rA = reserveA * (10**decimalsB);
            uint256 price = (1 * rA) / reserveB;
            price *= 10**18;
            price /= 10**decimalsA;
            price /= 10**18;
            price *= amount;
            return price;
        }
        else if (side == 0) {
            uint256 rB = reserveB * (10**decimalsA);
            uint256 price = (1 * rB) / reserveA;
            price *= 10**18;
            price /= 10**decimalsB;
            price /= 10**18;
            price *= amount;
            return price;
        }
    }

    function _check(address factory, address tokenA, address tokenB) internal view {
        require(tokenA != address(0x0), "UniswapV2PriceFeedV2: input token A address is zero");
        require(tokenB != address(0x0), "UniswapV2PriceFeedV2: input token B address is zero");
        require(factory != address(0x0), "UniswapV2PriceFeedV2: input factory address is zero");
    }
}