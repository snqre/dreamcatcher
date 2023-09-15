// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

import "contracts/polygon/external/uniswap/interfaces/IUniswapV2Factory.sol";

import "contracts/polygon/external/uniswap/interfaces/IUniswapV2Pair.sol";

contract OracleUniswapFeedV2 {

    /** @dev state variables */

    struct Dat { string name; }

    IUniswapV2Factory public uniswapV2Factory;

    /** @dev constructor */

    constructor(address uniswapV2Factory_) {
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Factory_);
    }

    /** @dev public view */

    /** @dev get details of tokens within a pair */
    function getPair(address tokenA, address tokenB) public view
    returns (
        address addressPair,
        address addressTokenA,
        address addressTokenB,
        string memory nameTokenA,
        string memory nameTokenB,
        string memory symbolTokenA,
        string memory symbolTokenB,
        uint8 decimalsTokenA,
        uint8 decimalsTokenB
    ) {
        addressPair = uniswapV2Factory.getPair(tokenA, tokenB);
        require(addressPair != address(0), "OracleUniswapFeedV2: pair not found");
        IUniswapV2Pair iUV2Pair = IUniswapV2Pair(addressPair);
        _verifyPair(tokenA, tokenB, iUV2Pair);
        IERC20Metadata iERC20TokenA = IERC20Metadata(iUV2Pair.token0());
        IERC20Metadata iERC20TokenB = IERC20Metadata(iUV2Pair.token1());
        addressTokenA = iUV2Pair.token0();
        addressTokenB = iUV2Pair.token1();
        nameTokenA = iERC20TokenA.name();
        nameTokenB = iERC20TokenB.name();
        symbolTokenA = iERC20TokenA.symbol();
        symbolTokenB = iERC20TokenB.symbol();
        decimalsTokenA = uint8(iERC20TokenA.decimals());
        decimalsTokenB = uint8(iERC20TokenB.decimals());
        return (
            addressPair,
            addressTokenA,
            addressTokenB,
            nameTokenA,
            nameTokenB,
            symbolTokenA,
            symbolTokenB,
            decimalsTokenA,
            decimalsTokenB
        );
    }

    /**
    * @dev calculate the price of an asset
    * @return price * (10**18)
    * note price will always be returned as 18 decimals
    * note input -> BTC / USD -> $20000 * (10*18)
     */
    function getPrice(address tokenA, address tokenB, uint256 amount) public view returns (uint256) {
        uint8 order = _isSameOrder(tokenA, tokenB);
        address addressPair = uniswapV2Factory.getPair(tokenA, tokenB);
        require(addressPair != address(0), "OracleUniswapFeedV2: pair not found");
        IUniswapV2Pair iUV2Pair = IUniswapV2Pair(addressPair);
        _verifyPair(tokenA, tokenB, iUV2Pair);
        IERC20Metadata iERC20TokenA = IERC20Metadata(iUV2Pair.token0());
        IERC20Metadata iERC20TokenB = IERC20Metadata(iUV2Pair.token1());
        (uint256 reserveA, uint256 reserveB, ,) = iUV2Pair.getReserves();
        require(
            reserveA != 0 &&
            reserveB != 0,
            "OracleUniswapFeedV2: pair reserve is default"
        );
        if (order == 0) {
            uint256 rA = reserveA * (10**iERC20TokenA.decimals());
            uint256 price = (amount * rA) / reservB;
            price *= 10**18;
            price /= 10**iERC20TokenA.decimals();
            return price;
        }
        else if (order == 1) {
            uint256 rB = reserveB * (10**iERC20TokenB.decimals());
            uint256 price = (amount * rB) / reserveA;
            price *= 10**18;
            price /= 10**iERC20TokenB.decimals();
            return price;
        }
        else { revert("OracleUniswapFeedV2: pair not found"); }
    }

    /** @dev private pure */

    function _isSameString(string memory stringA, string memory stringB) private pure returns (bool) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    /** @dev private view */

    function _isSameOrder(address tokenA, address tokenB) private view returns (uint8) {
        (
            ,
            address addressTokenA,
            address addressTokenB,
            string memory nameTokenA,
            string memory nameTokenB,
            string memory symbolTokenA,
            string memory symbolTokenB,
            uint8 decimalsTokenA,
            uint8 decimalsTokenB
        ) = getPair(tokenA, tokenB);
        IERC20Metadata iERC20TokenA = IERC20Metadata(tokenA);
        IERC20Metadata iERC20TokenB = IERC20Metadata(tokenB);
        if (
            tokenA == addressTokenA &&
            tokenB == addressTokenB &&
            _isSameString(iERC20TokenA.name(), nameTokenA) &&
            _isSameString(iERC20TokenB.name(), nameTokenB) &&
            _isSameString(iERC20TokenA.symbol(), symbolTokenA) &&
            _isSameString(iERC20TokenB.symbol(), symbolTokenB) &&
            iERC20TokenA.decimals() == decimalsTokenA &&
            iERC20TokenB.decimals() == decimalsTokenB
        ) { return 1; }
        else if (
            tokenA == addressTokenB &&
            tokenB == addressTokenA &&
            _isSameString(iERC20TokenA.name(), nameTokenB) &&
            _isSameString(iERC20TokenB.name(), nameTokenA) &&
            _isSameString(iERC20TokenA.name(), symbolTokenB) &&
            _isSameString(iERC20TokenB.name(), symbolTokenA) &&
            iERC20TokenA.decimals() == decimalsTokenB &&
            iERC20TokenB.decimals() == decimalsTokenA
        ) { return 0; }
        revert("OracleUniswapFeedV2: pair not found");
    }

    function _verifyPair(address inputTokenA, address inputTokenB, IUniswapV2Pair iUV2Pair) private view {
        uint8 order = _isSameOrder(tokenA, tokenB);
        if (order == 1) {
            /** @dev inputTokenA == iUVPair.token0 | is same order as input */
            string memory emptyString;
            bytes32 emptyBytes32;
            
            /** 
            * @dev verify pair interface compliance and token match 
            * if any of these fields dont match it should revert anyway but the protocol will double check
             */
            require(
                !_isSameString(iUV2Pair.name(), emptyString) &&
                !_isSameString(iUV2Pair.symbol(), emptyString) &&
                iUV2Pair.decimals() != 0 &&
                iUV2Pair.DOMAIN_SEPARATOR() != emptyBytes32 &&
                iUV2Pair.PERMIT_TYPEHASH() != emptyBytes32 &&
                iUV2Pair.MINIMUM_LIQUIDITY() != 0 &&
                iUV2Pair.factory() == address(uniswapV2Factory) &&
                iUV2Pair.token0() == inputTokenA &&
                iUV2Pair.token1() == inputTokenB,
                "OracleUniswapFeedV2: pair verification failed"
            );
        }
        else if (order == 2) {
            /** @dev inputTokenA == iUVPair.token1 | is reverse order as input */
            string memory emptyString;
            bytes32 emptyBytes32;

            /** 
            * @dev verify pair interface compliance and token match 
            * if any of these fields dont match it should revert anyway but the protocol will double check
             */
            require(
                !_isSameString(iUV2Pair.name(), emptyString) &&
                !_isSameString(iUV2Pair.symbol(), emptyString) &&
                iUV2Pair.decimals() != 0 &&
                iUV2Pair.DOMAIN_SEPARATOR() != emptyBytes32 &&
                iUV2Pair.PERMIT_TYPEHASH() != emptyBytes32 &&
                iUV2Pair.MINIMUM_LIQUIDITY() != 0 &&
                iUV2Pair.factory() == address(uniswapV2Factory) &&
                iUV2Pair.token0() == inputTokenB &&
                iUV2Pair.token1() == inputTokenA,
                "OracleUniswapFeedV2: pair verification failed"
            );
        }
    }
}