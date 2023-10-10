// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/interfaces/IUniswapV2Factory.sol";

import "contracts/polygon/interfaces/IUniswapV2Pair.sol";

import "contracts/polygon/ProxyStateOwnableContract.sol";

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

/**
* version 0.5.0
 */
contract UniswapV2PriceFeedV1 is ProxyStateOwnableContract {

    /** Public View. */

    /**
    * @dev Returns metadata of a pair. Will return empty data if
    *      pair address is zero.
     */
    function getMetadata(address factory, address tokenA, address tokenB) public view
    returns (
        address,
        address,
        address,
        string memory,
        string memory,
        string memory,
        string memory,
        uint256,
        uint256
    ) {
        address pairAddress = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        
        if (pairAddress == address(0)) {

            string memory emptyString;

            return (
                address(0),
                address(0),
                address(0),
                emptyString,
                emptyString,
                emptyString,
                emptyString,
                0,
                0
            );
        }

        require(pairAddress != address(0), "UniswapV2PriceFeedV1: unable to find pair");

        IUniswapV2Pair pairInterface = IUniswapV2Pair(pairAddress);

        IERC20Metadata tokenA_ = IERC20Metadata(pairInterface.token0());
        IERC20Metadata tokenB_ = IERC20Metadata(pairInterface.token1());

        return (
            pairAddress,
            pairInterface.token0(),
            pairInterface.token1(),
            tokenA_.name(),
            tokenB_.name(),
            tokenA_.symbol(),
            tokenB_.symbol(),
            tokenA_.decimals(),
            tokenB_.decimals()
        );
    }

    /**
    * @dev Returns the order in which the pair arranged the data.
    *      Will return 2 if the pair was not found or could not
    *      find any order in the data.
     */
    function isSameOrder(address factory, address tokenA, address tokenB) public view returns (uint256) {
        (
            ,
            address addressA,
            address addressB,
            string memory nameA,
            string memory nameB,
            string memory symbolA,
            string memory symbolB,
            uint256 decimalsA,
            uint256 decimalsB
        ) = getMetadata(factory, tokenA, tokenB);

        IERC20Metadata tokenA_ = IERC20Metadata(tokenA);
        IERC20Metadata tokenB_ = IERC20Metadata(tokenB);

        if (
            tokenA == addressA &&
            tokenB == addressB &&
            _isSameString(tokenA_.name(), nameA) &&
            _isSameString(tokenB_.name(), nameB) &&
            _isSameString(tokenA_.symbol(), symbolA) &&
            _isSameString(tokenB_.symbol(), symbolB) &&
            tokenA_.decimals() == decimalsA &&
            tokenB_.decimals() == decimalsB
        ) {
            
            return 0;
        }

        else if (
            tokenA == addressB &&
            tokenB == addressA &&
            _isSameString(tokenA_.name(), nameB) &&
            _isSameString(tokenB_.name(), nameA) &&
            _isSameString(tokenA_.symbol(), symbolB) &&
            _isSameString(tokenB_.symbol(), symbolA) &&
            tokenA_.decimals() == decimalsB &&
            tokenB_.decimals() == decimalsA
        ) {

            return 1;
        }

        else {

            return 2;
        }
    }

    /**
    * @dev Return price in 10**18 decimals of the asset against another asset.
     */
    function getPrice(address factory, address tokenA, address tokenB, uint256 amount) public view returns (uint256, uint256) {

        uint256 side = isSameOrder(factory, tokenA, tokenB);

        address pairAddress = IUniswapV2Factory(factory).getPair(tokenA, tokenB);

        /**
        * @dev Return zero if pair address is zero.
         */
        if (pairAddress == address(0)) {

            return (0, 0);
        }

        IUniswapV2Pair pairInterface = IUniswapV2Pair(pairAddress);

        IERC20Metadata tokenA_ = IERC20Metadata(pairInterface.token0());
        IERC20Metadata tokenB_ = IERC20Metadata(pairInterface.token1());

        (
            uint256 reserveA,
            uint256 reserveB,
            uint256 lastTimestamp
        ) = pairInterface.getReserves();

        if (side == 1) {
            
            uint256 rA = reserveA * (10**tokenB_.decimals());
            
            uint256 price = (amount * rA) / reserveB;

            price *= 10**18;

            price /= 10**tokenA_.decimals();

            return (price, lastTimestamp);
        }

        if (side == 0) {

            uint256 rB = reserveB * (10**tokenA_.decimals());

            uint256 price = (amount * rB) / reserveA;

            price *= 10**18;

            price /= 10**tokenB_.decimals();

            return (price, lastTimestamp);
        }

        /**
        * @dev Return zero if side is not 0 or 1.
         */
        else {

            return (0, 0);
        }
    }

    /** Internal View. */

    /**
    * @dev Return true if stringA is the same as stringB.
     */
    function _isSameString(string memory stringA, string memory stringB) internal pure returns (bool) {

        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }
}
