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

    function _isSameString(string memory stringA, string memory stringB) internal pure returns (bool) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    function _metadata(address factory, address tokenA, address tokenB) internal view 
    returns (
        address,
        address,
        address,
        string memory,
        string memory,
        string memory,
        string memory,
        uint8,
        uint8
    ) {
        require(factory != address(0), "UniswapV2PriceFeedV2: input address:factory is zero address");
        require(tokenA != address(0), "UniswapV2PriceFeedV2: input address:tokenA is zero address");
        require(tokenB != address(0), "UniswapV2PriceFeedV2: input address:tokenB is zero address");
        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        require(pair != address(0), "UniswapV2PriceFeedV2: address:pair is zero address");
        IUniswapV2Pair pairInterface = IUniswapV2Pair(pair);
        require(pairInterface.token0() != address(0), "UniswapV2PriceFeedV2: address:tokenA is zero address");
        require(pairInterface.token1() != address(0), "UniswapV2PriceFeedV2: address:tokenB is zero address");
        IERC20Metadata tknA = IERC20Metadata(pairInterface.token0());
        IERC20Metadata tknB = IERC20Metadata(pairInterface.token1());
        string memory emptyString;
        require(!_isSameString(tknA.name(), emptyString), "UniswapV2PriceFeedV2: tknA.name() is emptyString");
        require(!_isSameString(tknB.name(), emptyString), "UniswapV2PriceFeedV2: tknB.name() is emptyString");
        require(!_isSameString(tknA.symbol(), emptyString), "UniswapV2PriceFeedV2: tknA.symbol() is emptyString");
        require(!_isSameString(tknB.symbol(), emptyString), "UniswapV2PriceFeedV2: tknB.symbol() is emptyString");
        require(tknA,decimals() <= 18, "UniswapV2PriceFeedV2: tknA.decimals() is greater than 18");
        require(tknB.decimals() <= 18, "UniswapV2PriceFeedV2: tknB.decimals() is greater than 18");
        return (
            pair,
            pairInterface.token0(),
            pairInterface.token1(),
            tknA.name(),
            tknB.name(),
            tknA.symbol(),
            tknB.symbol(),
            tknA.decimals(),
            tknB.decimals()
        );
        
        function _isSameOrder(address factory, address tokenA, address tokenB) internal view returns (uint8) {
            
        }
    }
}

/**
* version 0.5.5
 */
contract UniswapV2PriceFeedV2B is ProxyStateOwnableContract {

    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @notice Modifier to check the validity of input addresses.
    * @param factory The address of the UniswapV2 factory contract.
    * @param tokenA The address of the first token in the pair.
    * @param tokenB The address of the second token in the pair.
    * @dev Requires that none of the input addresses are zero.
    */
    modifier check(address factory, address tokenA, address tokenB) {
        _check(factory, tokenA, tokenB);
        _;
    }

    /**
    * @notice Compares two strings for equality.
    * @param stringA The first string for comparison.
    * @param stringB The second string for comparison.
    * @return bool Returns true if the strings are equal, false otherwise.
    */
    function isSameString(string memory stringA, string memory stringB) public pure returns (bool) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    /**
    * @notice Retrieves metadata information for a given pair of tokens in a UniswapV2 pair.
    * @param factory The address of the UniswapV2 factory contract.
    * @param tokenA The address of the first token in the pair.
    * @param tokenB The address of the second token in the pair.
    * @return pair The address of the UniswapV2 pair.
    * @return addressA The address of the first token in the pair.
    * @return addressB The address of the second token in the pair.
    * @return nameA The name of the first token in the pair.
    * @return nameB The name of the second token in the pair.
    * @return symbolA The symbol of the first token in the pair.
    * @return symbolB The symbol of the second token in the pair.
    * @return decimalsA The decimal precision of the first token in the pair.
    * @return decimalsB The decimal precision of the second token in the pair.
    * Requirements:
    * - The provided factory address must not be zero.
    * - The provided token addresses must not be zero.
    * - The UniswapV2 pair must exist for the given tokens.
    * - Token names and symbols must not be empty strings.
    * - Decimal precision must be within the valid range [0, 18].
    */
    function metadata(address factory, address tokenA, address tokenB) public view returns (address pair, address addressA, address addressB, string memory nameA, string memory nameB, string memory symbolA, string memory symbolB, uint8 decimalsA, uint8 decimalsB) {
        
        require(factory != address(0x0), "UniswapV2PriceFeedV2: input factory address is zero");
        
        require(tokenA != address(0x0), "UniswapV2PriceFeedV2: input token A address is zero");
        
        require(tokenB != address(0x0), "UniswapV2PriceFeedV2: input token B address is zero");
        
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

    /**
    * @notice Checks the order of tokens in a UniswapV2 pair.
    * @param factory The address of the UniswapV2 factory contract.
    * @param tokenA The address of the first token in the pair.
    * @param tokenB The address of the second token in the pair.
    * @return 0 if the order of tokens in the pair is as expected.
    * @return 1 if the order of tokens in the pair is reversed.
    * Requirements:
    * - The provided factory address must not be zero.
    * - The provided token addresses must not be zero.
    * - The UniswapV2 pair must exist for the given tokens.
    * - Token names, symbols, and decimals must match the expected values.
    * - Reverts with an error message if the order is unknown.
    */
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

    /**
    * @notice Calculates the price of a given amount in one token in terms of another token in a UniswapV2 pair.
    * @param factory The address of the UniswapV2 factory contract.
    * @param tokenA The address of the first token in the pair.
    * @param tokenB The address of the second token in the pair.
    * @param amount The amount of tokenA or tokenB for which to calculate the price.
    * @return Returns the calculated price, denominated in the other token, for the specified amount.
    * Requirements:
    * - The provided factory address must not be zero.
    * - The provided token addresses must not be zero.
    * - The UniswapV2 pair must exist for the given tokens.
    * - Token names, symbols, and decimals must match the expected values.
    * - Reverts with an error message if the order is unknown.
    */
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

    /**
    * @notice Internal function to check input addresses in the UniswapV2PriceFeedV2 contract.
    * @param factory The address of the UniswapV2 factory contract.
    * @param tokenA The address of the first token.
    * @param tokenB The address of the second token.
    * Requirements:
    * - Token A address must not be zero.
    * - Token B address must not be zero.
    * - Factory address must not be zero.
    */
    function _check(address factory, address tokenA, address tokenB) internal view {
        
        require(tokenA != address(0x0), "UniswapV2PriceFeedV2: input token A address is zero");
        
        require(tokenB != address(0x0), "UniswapV2PriceFeedV2: input token B address is zero");
        
        require(factory != address(0x0), "UniswapV2PriceFeedV2: input factory address is zero");
    }
}