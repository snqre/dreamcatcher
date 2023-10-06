// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IRepository {
    function getAdmins() external view returns (address[] memory);

    function getLogics() external view returns (address[] memory);

    function getString(bytes32 key) external view returns (string memory);

    function getBytes(bytes32 key) external view returns (bytes memory);

    function getUint(bytes32 key) external view returns (uint256);

    function getInt(bytes32 key) external view returns (int256);

    function getAddress(bytes32 key) external view returns (address);

    function getBool(bytes32 key) external view returns (bool);

    function getBytes32(bytes32 key) external view returns (bytes32);

    function getStringArray(bytes32 key)
        external
        view
        returns (string[] memory);

    function getBytesArray(bytes32 key) external view returns (bytes[] memory);

    function getUintArray(bytes32 key) external view returns (uint256[] memory);

    function getIntArray(bytes32 key) external view returns (int256[] memory);

    function getAddressArray(bytes32 key)
        external
        view
        returns (address[] memory);

    function getBoolArray(bytes32 key) external view returns (bool[] memory);

    function getBytes32Array(bytes32 key)
        external
        view
        returns (bytes32[] memory);

    function getIndexedStringArray(bytes32 key, uint256 index)
        external
        view
        returns (string memory);

    function getIndexedBytesArray(bytes32 key, uint256 index)
        external
        view
        returns (bytes memory);

    function getIndexedUintArray(bytes32 key, uint256 index)
        external
        view
        returns (uint256);

    function getIndexedIntArray(bytes32 key, uint256 index)
        external
        view
        returns (int256);

    function getIndexedAddressArray(bytes32 key, uint256 index)
        external
        view
        returns (address);

    function getIndexedBoolArray(bytes32 key, uint256 index)
        external
        view
        returns (bool);

    function getIndexedBytes32Array(bytes32 key, uint256 index)
        external
        view
        returns (bytes32);

    function getLengthStringArray(bytes32 key) external view returns (uint256);

    function getLengthBytesArray(bytes32 key) external view returns (uint256);

    function getLengthUintArray(bytes32 key) external view returns (uint256);

    function getLengthIntArray(bytes32 key) external view returns (uint256);

    function getLengthAddressArray(bytes32 key) external view returns (uint256);

    function getLengthBoolArray(bytes32 key) external view returns (uint256);

    function getLengthBytes32Array(bytes32 key) external view returns (uint256);

    function getAddressSet(bytes32 key)
        external
        view
        returns (address[] memory);

    function getUintSet(bytes32 key) external view returns (uint256[] memory);

    function getBytes32Set(bytes32 key)
        external
        view
        returns (bytes32[] memory);

    function getIndexedAddressSet(bytes32 key, uint256 index)
        external
        view
        returns (address);

    function getIndexedUintSet(bytes32 key, uint256 index)
        external
        view
        returns (uint256);

    function getIndexedBytes32Set(bytes32 key, uint256 index)
        external
        view
        returns (bytes32);

    function getLengthAddressSet(bytes32 key) external view returns (uint256);

    function getLengthUintSet(bytes32 key) external view returns (uint256);

    function getLengthBytes32Set(bytes32 key) external view returns (uint256);

    function addressSetContains(bytes32 key, address value)
        external
        view
        returns (bool);

    function uintSetContains(bytes32 key, uint256 value)
        external
        view
        returns (bool);

    function bytes32SetContains(bytes32 key, bytes32 value)
        external
        view
        returns (bool);

    function addAdmin(address account) external;

    function addLogic(address account) external;

    function removeAdmin(address account) external;

    function removeLogic(address account) external;

    function setString(bytes32 key, string memory value) external;

    function setBytes(bytes32 key, bytes memory value) external;

    function setUint(bytes32 key, uint256 value) external;

    function setInt(bytes32 key, int256 value) external;

    function setAddress(bytes32 key, address value) external;

    function setBool(bytes32 key, bool value) external;

    function setBytes32(bytes32 key, bytes32 value) external;

    function setStringArray(
        bytes32 key,
        uint256 index,
        string memory value
    ) external;

    function setBytesArray(
        bytes32 key,
        uint256 index,
        bytes memory value
    ) external;

    function setUintArray(
        bytes32 key,
        uint256 index,
        uint256 value
    ) external;

    function setIntArray(
        bytes32 key,
        uint256 index,
        int256 value
    ) external;

    function setAddressArray(
        bytes32 key,
        uint256 index,
        address value
    ) external;

    function setBoolArray(
        bytes32 key,
        uint256 index,
        bool value
    ) external;

    function setBytes32Array(
        bytes32 key,
        uint256 index,
        bytes32 value
    ) external;

    function pushStringArray(bytes32 key, string memory value) external;

    function pushBytesArray(bytes32 key, bytes memory value) external;

    function pushUintArray(bytes32 key, uint256 value) external;

    function pushIntArray(bytes32 key, int256 value) external;

    function pushAddressArray(bytes32 key, address value) external;

    function pushBoolArray(bytes32 key, bool value) external;

    function pushBytes32Array(bytes32 key, bytes32 value) external;

    function deleteStringArray(bytes32 key) external;

    function deleteBytesArray(bytes32 key) external;

    function deleteUintArray(bytes32 key) external;

    function deleteIntArray(bytes32 key) external;

    function deleteAddressArray(bytes32 key) external;

    function deleteBoolArray(bytes32 key) external;

    function deleteBytes32Array(bytes32 key) external;

    function addAddressSet(bytes32 key, address value) external;

    function addUintSet(bytes32 key, uint256 value) external;

    function addBytes32Set(bytes32 key, bytes32 value) external;

    function removeAddressSet(bytes32 key, address value) external;

    function removeUintSet(bytes32 key, uint256 value) external;

    function removeBytes32Set(bytes32 key, bytes32 value) external;
}

interface IQuickSwapPlugIn {}

contract QuickSwapPlugIn is IQuickSwapPlugIn, Pausable {
    enum GATE {
        WMATIC,
        WBTC,
        WETH,
        USDC,
        USDT,
        DAI
    }
    enum ORDER {
        REVERSE,
        SAME
    }
    address constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address constant WBTC = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6;
    address constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address constant DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    IUniswapV2Factory constant FACTORY =
        IUniswapV2Factory(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32);
    IUniswapV2Router02 constant ROUTER =
        IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
    IRepository constant REPOSITORY =
        IRepository(0xE2578e92fB2Ba228b37eD2dFDb1F4444918b64Aa);
    address private _deployer;
    bool private _init;

    event SWAP(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 indexed amountIn,
        uint256 amountOutMin,
        address to
    );

    event ACCOUNT_WHITELISTED(address indexed account);

    event ACCOUNT_BLACKLISTED(address indexed account);

    event ADMIN_ROLE_GRANTED(address indexed account);

    event ADMIN_ROLE_REVOKED(address indexed account);

    error PAIR_NOT_FOUND();
    error UNRECOGNIZED_GATE();
    error ALREADY_WHITELISTED();
    error ALREADY_BLACKLISTED();
    error ALREADY_ADMIN();
    error NOT_ADMIN();
    error ONLY_WHITELIST();
    error ONLY_ADMIN();
    error ALREADY_INITIALIZED();
    error NOT_INITIALIZED();
    error ONLY_DEPLOYER();
    error INSUFFICIENT_MATH();

    modifier onlyWhitelist() {
        _onlyWhitelist();
        _;
    }

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    modifier onlyDeployer() {
        _onlyDeployer();
        _;
    }

    modifier whenInitialized() {
        _whenInitialized();
        _;
    }

    constructor() {
        _deployer = msg.sender;
    }

    function isSameString(string memory stringA, string memory stringB)
        public
        pure
        returns (bool isMatch)
    {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    function metadata(address tokenA, address tokenB)
        public
        view
        whenNotPaused
        whenInitialized
        returns (
            address addressPair,
            address addressA,
            address addressB,
            string memory nameA,
            string memory nameB,
            string memory symbolA,
            string memory symbolB,
            uint256 decimalsA,
            uint256 decimalsB
        )
    {
        addressPair = FACTORY.getPair({tokenA: tokenA, tokenB: tokenB});
        if (addressPair == address(0)) {
            revert PAIR_NOT_FOUND();
        }
        IUniswapV2Pair interface_ = IUniswapV2Pair(addressPair);
        IERC20 tokenA_ = IERC20(interface_.token0());
        IERC20 tokenB_ = IERC20(interface_.token1());
        return (
            addressPair,
            interface_.token0(),
            interface_.token1(),
            tokenA_.name(),
            tokenB_.name(),
            tokenA_.symbol(),
            tokenB_.symbol(),
            tokenA_.decimals(),
            tokenB_.decimals()
        );
    }

    function isSameOrder(address tokenA, address tokenB)
        public
        view
        whenNotPaused
        whenInitialized
        returns (ORDER)
    {
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
        ) = metadata({tokenA: tokenA, tokenB: tokenB});
        IERC20 tokenA_ = IERC20(tokenA);
        IERC20 tokenB_ = IERC20(tokenB);
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
            return ORDER.SAME;
        } else if (
            tokenA == addressB &&
            tokenB == addressA &&
            isSameString(tokenA_.name(), nameB) &&
            isSameString(tokenB_.name(), nameA) &&
            isSameString(tokenA_.symbol(), symbolB) &&
            isSameString(tokenB_.symbol(), symbolA) &&
            tokenA_.decimals() == decimalsB &&
            tokenB_.decimals() == decimalsA
        ) {
            return ORDER.REVERSE;
        } else {
            revert PAIR_NOT_FOUND();
        }
    }
    /// IS REVERSED NOTE RE REVERSE IT BACK SO EG BTC / USDT -> price
    function getPrice(
        address tokenA,
        address tokenB,
        uint256 amount
    )
        public
        view
        whenNotPaused
        whenInitialized
        returns (uint256 price, uint256)
    {
        ORDER order = isSameOrder({tokenA: tokenA, tokenB: tokenB});
        address addressPair = FACTORY.getPair(tokenA, tokenB);
        if (addressPair == address(0)) {
            revert PAIR_NOT_FOUND();
        }
        IUniswapV2Pair interface_ = IUniswapV2Pair(addressPair);
        IERC20 tokenA_ = IERC20(interface_.token0());
        IERC20 tokenB_ = IERC20(interface_.token1());
        (uint256 reserveA, uint256 reserveB, uint256 lastTimestamp) = interface_
            .getReserves();
        if (order == ORDER.SAME) {
            price = (amount * (reserveA * (10**tokenB_.decimals()))) / reserveB;
            price *= 10**18;
            price /= 10**tokenA_.decimals();
            return (price, lastTimestamp);
        } else if (order == ORDER.REVERSE) {
            price = (amount * (reserveB * (10**tokenA_.decimals()))) / reserveA;
            price *= 10**18;
            price /= 10**tokenB_.decimals();
            return (price, lastTimestamp);
        } else {
            revert PAIR_NOT_FOUND();
        }
    }

    /**
     * @dev calculates the total value in the denominator for all the tokens within a vault
     *
     * @param contracts tokens within the vault
     * @param amounts corresponding amounts of each token
     * @param denominator the currency in which value is being calculated
     */
    function getValue(
        address[] memory contracts,
        uint256[] memory amounts,
        address denominator
    )
        public
        view
        whenNotPaused
        whenInitialized
        returns (uint256 value, uint256 averageTimestamp)
    {
        for (uint256 i = 0; i < contracts.length; i++) {
            (uint256 price, uint256 lastTimestamp) = getPrice({
                tokenA: denominator,
                tokenB: contracts[i],
                amount: amounts[i]
            });
            value += price;
            averageTimestamp += lastTimestamp;
        }
        averageTimestamp /= contracts.length;
        return (value, averageTimestamp);
    }

    function getValuePerShare(
        address[] memory contracts,
        uint256[] memory amounts,
        address denominator,
        address tokenOut
    )
        public
        view
        whenNotPaused
        whenInitialized
        returns (uint256 valuePerShare, uint256 averageTimestamp)
    {
        (valuePerShare, averageTimestamp) = getValue({
            contracts: contracts,
            amounts: amounts,
            denominator: denominator
        });
        valuePerShare /= IERC20(tokenOut).totalSupply();
        return (valuePerShare, averageTimestamp);
    }

    /**
     * @dev returns the amount that should be minted within a vault based on the value of the token sent
     *
     * @param contracts array of tokens contained within the vault
     * @param amounts array of corresponding amounts of each token within the vault
     * @param denominator base pricing for the vault **recommended to keep this the same for all calculations
     * @param tokenOut token acting as shares for the vault that should be minted
     * @param tokenIn the token being deposited
     * @param amountIn the amount of the deposited token
     *
     * @return amountToMint the amount of tokens that should be minted from the tokenOut address
     */
    function getAmountToMint(
        address[] memory contracts,
        uint256[] memory amounts,
        address denominator,
        address tokenOut,
        address tokenIn,
        uint256 amountIn
    ) public view whenNotPaused whenInitialized returns (uint256 amountToMint) {
        (uint256 valueIn, ) = getPrice({
            tokenA: denominator,
            tokenB: tokenIn,
            amount: amountIn
        });
        (uint256 balance, ) = getValue({
            contracts: contracts,
            amounts: amounts,
            denominator: denominator
        });
        uint256 totalSupply = IERC20(tokenOut).totalSupply();
        if (valueIn == 0) {
            revert INSUFFICIENT_MATH();
        }
        if (totalSupply == 0) {
            revert INSUFFICIENT_MATH();
        }
        if (balance == 0) {
            revert INSUFFICIENT_MATH();
        }
        return (valueIn * balance) / totalSupply;
    }

    /**
     * @dev returns the value in the denominator that should be sent back **this could be paid of if a combination of assets up to that value
     *
     * @param contracts array of tokens contained within the vault
     * @param amounts array of corresponding amounts of each token within the vault
     * @param denominator base pricing for the vault **recommended to keep this the same for all calculations
     * @param tokenOut token acting as shares for the vault that is being deposited
     * @param amountIn the amount of the deposited token
     *
     * @return valueToSend the amount in value that should be sent back
     */
    function getValueToSend(
        address[] memory contracts,
        uint256[] memory amounts,
        address denominator,
        address tokenOut,
        uint256 amountIn
    ) public view whenNotPaused whenInitialized returns (uint256 valueToSend) {
        (uint256 balance, ) = getValue(contracts, amounts, denominator);
        uint256 totalSupply = IERC20(tokenOut).totalSupply();
        if (amountIn == 0) {
            revert INSUFFICIENT_MATH();
        }
        if (totalSupply == 0) {
            revert INSUFFICIENT_MATH();
        }
        if (balance == 0) {
            revert INSUFFICIENT_MATH();
        }
        return (amountIn * balance) / totalSupply;
    }

    function init() public onlyDeployer {
        if (_init) {
            revert ALREADY_INITIALIZED();
        }
        bytes32 quickSwapPlugInV000 = keccak256(
            abi.encode("quickSwapPlugInV000", "admins")
        );
        if (!REPOSITORY.addressSetContains(quickSwapPlugInV000, _deployer)) {
            REPOSITORY.addAddressSet(quickSwapPlugInV000, _deployer);
        }
        _init = true;
        emit ADMIN_ROLE_GRANTED(msg.sender);
    }

    /// @dev only whitelisted accounts can swap using this contract
    function whitelist(address account)
        public
        onlyAdmin
        whenInitialized
        whenNotPaused
    {
        bytes32 quickSwapPlugInV000 = keccak256(
            abi.encode("quickSwapPlugInV000", "whitelist")
        );
        if (REPOSITORY.addressSetContains(quickSwapPlugInV000, account)) {
            revert ALREADY_WHITELISTED();
        }
        REPOSITORY.addAddressSet(quickSwapPlugInV000, account);
        emit ACCOUNT_WHITELISTED(account);
    }

    function blacklist(address account)
        public
        onlyAdmin
        whenInitialized
        whenNotPaused
    {
        bytes32 quickSwapPlugInV000 = keccak256(
            abi.encode("quickSwapPlugInV000", "whitelist")
        );
        if (!REPOSITORY.addressSetContains(quickSwapPlugInV000, account)) {
            revert ALREADY_BLACKLISTED();
        }
        REPOSITORY.removeAddressSet(quickSwapPlugInV000, account);
        emit ACCOUNT_BLACKLISTED(account);
    }

    function grantRoleAdmin(address account)
        public
        onlyAdmin
        whenInitialized
        whenNotPaused
    {
        bytes32 quickSwapPlugInV000 = keccak256(
            abi.encode("quickSwapPlugInV000", "admins")
        );
        if (REPOSITORY.addressSetContains(quickSwapPlugInV000, account)) {
            revert ALREADY_ADMIN();
        }
        REPOSITORY.addAddressSet(quickSwapPlugInV000, account);
        emit ADMIN_ROLE_GRANTED(account);
    }

    function revokeRoleAdmin(address account)
        public
        onlyAdmin
        whenInitialized
        whenNotPaused
    {
        bytes32 quickSwapPlugInV000 = keccak256(
            abi.encode("quickSwapPlugInV000", "admins")
        );
        if (REPOSITORY.addressSetContains(quickSwapPlugInV000, account)) {
            revert NOT_ADMIN();
        }
        REPOSITORY.removeAddressSet(quickSwapPlugInV000, account);
        emit ADMIN_ROLE_REVOKED(account);
    }

    function pause() public onlyAdmin whenInitialized {
        _pause();
    }

    function unpause() public onlyAdmin whenInitialized {
        _unpause();
    }

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn, /// (amountIn * (10**18))
        uint256 amountOutMin,
        uint256 gate,
        address from,
        address to
    ) public onlyWhitelist whenInitialized whenNotPaused {
        if (gate > 5) {
            revert UNRECOGNIZED_GATE();
        }
        amountIn *= 10**IERC20(tokenIn).decimals();
        amountIn /= 10**18;
        IERC20(tokenIn).transferFrom({
            from: from,
            to: address(this),
            amount: amountIn
        });
        IERC20(tokenIn).approve({spender: address(ROUTER), amount: amountIn});
        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        if (GATE(gate) == GATE.WMATIC) {
            path[1] = WMATIC;
        } else if (GATE(gate) == GATE.WBTC) {
            path[1] = WBTC;
        } else if (GATE(gate) == GATE.WETH) {
            path[1] = WETH;
        } else if (GATE(gate) == GATE.USDC) {
            path[1] = USDC;
        } else if (GATE(gate) == GATE.USDT) {
            path[1] = USDT;
        } else if (GATE(gate) == GATE.DAI) {
            path[1] = DAI;
        }
        path[2] = tokenOut;
        ROUTER.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: amountOutMin,
            path: path,
            to: to,
            deadline: block.timestamp
        });
        emit SWAP(tokenIn, tokenOut, amountIn, amountOutMin, to);
    }

    function swapTokensSlippage(
        address tokenIn,
        address tokenOut,
        uint256 amountIn, /// (amountIn * (10**18))
        uint256 slippage,
        uint256 gate,
        address from,
        address to
    ) public onlyWhitelist whenInitialized whenNotPaused {
        if (gate > 5) {
            revert UNRECOGNIZED_GATE();
        }
        amountIn *= 10**IERC20(tokenIn).decimals();
        amountIn /= 10**18;
        IERC20(tokenIn).transferFrom({
            from: from,
            to: address(this),
            amount: amountIn
        });
        IERC20(tokenIn).approve({spender: address(ROUTER), amount: amountIn});
        (uint256 amountOutMin, ) = getPrice({
            tokenA: tokenIn,
            tokenB: tokenOut,
            amount: amountIn
        });
        amountOutMin = (amountOutMin * (10000 - slippage)) / 10000;
        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        if (GATE(gate) == GATE.WMATIC) {
            path[1] = WMATIC;
        } else if (GATE(gate) == GATE.WBTC) {
            path[1] = WBTC;
        } else if (GATE(gate) == GATE.WETH) {
            path[1] = WETH;
        } else if (GATE(gate) == GATE.USDC) {
            path[1] = USDC;
        } else if (GATE(gate) == GATE.USDT) {
            path[1] = USDT;
        } else if (GATE(gate) == GATE.DAI) {
            path[1] = DAI;
        }
        path[2] = tokenOut;
        ROUTER.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: amountOutMin,
            path: path,
            to: to,
            deadline: block.timestamp
        });
        emit SWAP(tokenIn, tokenOut, amountIn, amountOutMin, to);
    }

    function _onlyWhitelist() private view {
        bytes32 quickSwapPlugInV000 = keccak256(
            abi.encode("quickSwapPlugInV000", "whitelist")
        );
        if (!REPOSITORY.addressSetContains(quickSwapPlugInV000, msg.sender)) {
            revert ONLY_WHITELIST();
        }
    }

    function _onlyAdmin() private view {
        bytes32 quickSwapPlugInV000 = keccak256(
            abi.encode("quickSwapPlugInV000", "admins")
        );
        if (!REPOSITORY.addressSetContains(quickSwapPlugInV000, msg.sender)) {
            revert ONLY_ADMIN();
        }
    }

    function _onlyDeployer() private view {
        if (msg.sender != _deployer) {
            revert ONLY_DEPLOYER();
        }
    }

    function _whenInitialized() private view {
        if (!_init) {
            revert NOT_INITIALIZED();
        }
    }
}
