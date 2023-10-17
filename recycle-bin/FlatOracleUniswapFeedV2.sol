// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// File: contracts\polygon\external\openzeppelin\token\ERC20\IERC20.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: contracts\polygon\external\openzeppelin\token\ERC20\extensions\IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: contracts\polygon\external\uniswap\interfaces\IUniswapV2Factory.sol

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// File: contracts\polygon\external\uniswap\interfaces\IUniswapV2Pair.sol

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// File: contracts\polygon\OracleUniswapFeedV2.sol

contract OracleUniswapFeedV2 {

    /** @dev state variables */

    IUniswapV2Factory public uniswapV2Factory;

    /** @dev structs arrays enums */

    struct Dat { string name; }

    Dat private _dat;

    /** @dev constructor */

    constructor(address uniswapV2Factory_, string memory name_) {
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Factory_);
        _dat.name = name_;
    }

    /** @dev external view */

    function name() external view returns (string memory) {
        return _dat.name;
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
        IERC20Metadata iERC20TokenA = IERC20Metadata(iUV2Pair.token0());
        IERC20Metadata iERC20TokenB = IERC20Metadata(iUV2Pair.token1());
        addressTokenA = iUV2Pair.token0();
        addressTokenB = iUV2Pair.token1();
        nameTokenA = iERC20TokenA.name();
        nameTokenB = iERC20TokenB.name();
        symbolTokenA = iERC20TokenA.symbol();
        symbolTokenB = iERC20TokenB.symbol();
        decimalsTokenA = iERC20TokenA.decimals();
        decimalsTokenB = iERC20TokenB.decimals();
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
        IERC20Metadata iERC20TokenA = IERC20Metadata(iUV2Pair.token0());
        IERC20Metadata iERC20TokenB = IERC20Metadata(iUV2Pair.token1());
        (uint256 reserveA, uint256 reserveB,) = iUV2Pair.getReserves();
        require(
            reserveA != 0 &&
            reserveB != 0,
            "OracleUniswapFeedV2: pair reserve is default"
        );
        if (order == 0) {
            uint256 rA = reserveA * (10**iERC20TokenA.decimals());
            uint256 price = (amount * rA) / reserveB;
            price *= 10**18;
            price /= 10**iERC20TokenB.decimals();
            return price;
        }
        else if (order == 1) {
            uint256 rB = reserveB * (10**iERC20TokenB.decimals());
            uint256 price = (amount * rB) / reserveA;
            price *= 10**18;
            price /= 10**iERC20TokenA.decimals();
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
            tokenB == addressTokenB
        ) { return 1; }
        else if (
            tokenA == addressTokenB &&
            tokenB == addressTokenA
        ) { return 0; }
        else { revert("OracleUniswapFeedV2: pair not found"); }
    }
}
