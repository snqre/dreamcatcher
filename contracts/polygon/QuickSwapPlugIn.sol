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
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name()
    external view
    returns (
        string memory
    );

    function symbol()
    external view
    returns (
        string memory
    );

    function decimals()
    external view
    returns (
        uint8
    );

    function totalSupply()
    external view
    returns (
        uint256
    );

    function balanceOf(
        address account
    )
    external view
    returns (
        uint256
    );

    function transfer(
        address to,
        uint256 amount
    )
    external
    returns (
        bool
    );

    function allowance(
        address owner,
        address spender
    )
    external view
    returns (
        uint256
    );

    function approve(
        address spender,
        uint256 amount
    )
    external
    returns (
        bool
    );

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
    external
    returns (
        bool
    );
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IRepository {
    function getAdmins() external view returns (address[] memory);
    function getLogics() external view returns (address[] memory);

    function getString(bytes32 key) external view returns (string memory);
    function getBytes(bytes32 key) external view returns (bytes memory);
    function getUint(bytes32 key) external view returns (uint);
    function getInt(bytes32 key) external view returns (int);
    function getAddress(bytes32 key) external view returns (address);
    function getBool(bytes32 key) external view returns (bool);
    function getBytes32(bytes32 key) external view returns (bytes32);

    function getStringArray(bytes32 key) external view returns (string[] memory);
    function getBytesArray(bytes32 key) external view returns (bytes[] memory);
    function getUintArray(bytes32 key) external view returns (uint[] memory);
    function getIntArray(bytes32 key) external view returns (int[] memory);
    function getAddressArray(bytes32 key) external view returns (address[] memory);
    function getBoolArray(bytes32 key) external view returns (bool[] memory);
    function getBytes32Array(bytes32 key) external view returns (bytes32[] memory);

    function getIndexedStringArray(bytes32 key, uint index) external view returns (string memory);
    function getIndexedBytesArray(bytes32 key, uint index) external view returns (bytes memory);
    function getIndexedUintArray(bytes32 key, uint index) external view returns (uint);
    function getIndexedIntArray(bytes32 key, uint index) external view returns (int);
    function getIndexedAddressArray(bytes32 key, uint index) external view returns (address);
    function getIndexedBoolArray(bytes32 key, uint index) external view returns (bool);
    function getIndexedBytes32Array(bytes32 key, uint index) external view returns (bytes32);
    
    function getLengthStringArray(bytes32 key) external view returns (uint);
    function getLengthBytesArray(bytes32 key) external view returns (uint);
    function getLengthUintArray(bytes32 key) external view returns (uint);
    function getLengthIntArray(bytes32 key) external view returns (uint);
    function getLengthAddressArray(bytes32 key) external view returns (uint);
    function getLengthBoolArray(bytes32 key) external view returns (uint);
    function getLengthBytes32Array(bytes32 key) external view returns (uint);

    function getAddressSet(bytes32 key) external view returns (address[] memory);
    function getUintSet(bytes32 key) external view returns (uint[] memory);
    function getBytes32Set(bytes32 key) external view returns (bytes32[] memory);

    function getIndexedAddressSet(bytes32 key, uint index) external view returns (address);
    function getIndexedUintSet(bytes32 key, uint index) external view returns (uint);
    function getIndexedBytes32Set(bytes32 key, uint index) external view returns (bytes32);

    function getLengthAddressSet(bytes32 key) external view returns (uint);
    function getLengthUintSet(bytes32 key) external view returns (uint);
    function getLengthBytes32Set(bytes32 key) external view returns (uint);
    
    function addressSetContains(bytes32 key, address value) external view returns (bool);
    function uintSetContains(bytes32 key, uint value) external view returns (bool);
    function bytes32SetContains(bytes32 key, bytes32 value) external view returns (bool);

    function addAdmin(address account) external;
    function addLogic(address account) external;
    
    function removeAdmin(address account) external;
    function removeLogic(address account) external;

    function setString(bytes32 key, string memory value) external;
    function setBytes(bytes32 key, bytes memory value) external;
    function setUint(bytes32 key, uint value) external;
    function setInt(bytes32 key, int value) external;
    function setAddress(bytes32 key, address value) external;
    function setBool(bytes32 key, bool value) external;
    function setBytes32(bytes32 key, bytes32 value) external;

    function setStringArray(bytes32 key, uint index, string memory value) external;
    function setBytesArray(bytes32 key, uint index, bytes memory value) external;
    function setUintArray(bytes32 key, uint index, uint value) external;
    function setIntArray(bytes32 key, uint index, int value) external;
    function setAddressArray(bytes32 key, uint index, address value) external;
    function setBoolArray(bytes32 key, uint index, bool value) external;
    function setBytes32Array(bytes32 key, uint index, bytes32 value) external;

    function pushStringArray(bytes32 key, string memory value) external;
    function pushBytesArray(bytes32 key, bytes memory value) external;
    function pushUintArray(bytes32 key, uint value) external;
    function pushIntArray(bytes32 key, int value) external;
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
    function addUintSet(bytes32 key, uint value) external;
    function addBytes32Set(bytes32 key, bytes32 value) external;

    function removeAddressSet(bytes32 key, address value) external;
    function removeUintSet(bytes32 key, uint value) external;
    function removeBytes32Set(bytes32 key, bytes32 value) external;
}

interface IQuickSwapPlugIn {
    function metadata(
        address tokenA,
        address tokenB
    )
    external view
    returns (
        address addressPair,
        address addressA,
        address addressB,
        string memory nameA,
        string memory nameB,
        string memory symbolA,
        string memory symbolB,
        uint decimalsA,
        uint decimalsB
    );
    
    function isSameOrder(
        address tokenA,
        address tokenB
    )
    external view
    returns (
        QuickSwapPlugIn.ORDER
    );

    function price(
        address tokenA,
        address tokenB,
        uint amount
    )
    external view
    returns (
        uint price,
        uint lastTimestamp
    );

    function whitelist(
        address account
    )
    external;

    function blacklist(
        address account
    )
    external;

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        uint gate,
        address from,
        address to
    )
    external;

    function swapTokensSlippage(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint slippage,
        uint gate,
        address from,
        address to
    )
    external;
}

contract QuickSwapPlugIn is IQuickSwapPlugIn, Pausable {
    enum GATE { WMATIC, WBTC, WETH, USDC, USDT, DAI }
    enum ORDER { REVERSE, SAME }
    address constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address constant WBTC = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6;
    address constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address constant DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    IUniswapV2Factory constant FACTORY = IUniswapV2Factory(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32);
    IUniswapV2Router02 constant ROUTER = IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
    IRepository constant REPOSITORY = IRepository(0xE2578e92fB2Ba228b37eD2dFDb1F4444918b64Aa);
    address private _deployer;
    bool private _init;

    event SWAP(
        address indexed tokenIn,
        address indexed tokenOut,
        uint indexed amountIn,
        uint amountOutMin,
        address to
    );

    event ACCOUNT_WHITELISTED(
        address indexed account
    );

    event ACCOUNT_BLACKLISTED(
        address indexed account
    );

    event ADMIN_ROLE_GRANTED(
        address indexed account
    );

    event ADMIN_ROLE_REVOKED(
        address indexed account
    );

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

    constructor() { _deployer = msg.sender; }

    function isSameString(
        string memory stringA,
        string memory stringB
    )
    public pure
    returns (bool isMatch) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    function metadata(
        address tokenA,
        address tokenB
    )
    public view
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
        uint decimalsA,
        uint decimalsB
    ) {
        addressPair = FACTORY.getPair({tokenA: tokenA, tokenB: tokenB});
        if (addressPair == address(0)) { revert PAIR_NOT_FOUND(); }
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

    function isSameOrder(
        address tokenA,
        address tokenB
    )
    public view
    whenNotPaused
    whenInitialized
    returns (
        ORDER
    ) {
        (
            ,
            address addressA,
            address addressB,
            string memory nameA,
            string memory nameB,
            string memory symbolA,
            string memory symbolB,
            uint decimalsA,
            uint decimalsB
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
        ) { return ORDER.SAME; }
        else if (
            tokenA == addressB &&
            tokenB == addressA &&
            isSameString(tokenA_.name(), nameB) &&
            isSameString(tokenB_.name(), nameA) &&
            isSameString(tokenA_.symbol(), symbolB) &&
            isSameString(tokenB_.symbol(), symbolA) &&
            tokenA_.decimals() == decimalsB &&
            tokenB_.decimals() == decimalsA
        ) { return ORDER.REVERSE; }
        else { revert PAIR_NOT_FOUND(); }
    }

    function price(
        address tokenA,
        address tokenB,
        uint amount
    )
    public view
    whenNotPaused
    whenInitialized
    returns (
        uint price, /// will always return (price * (10**18))
        uint lastTimestamp
    ) {
        ORDER order = isSameOrder({tokenA: tokenA, tokenB: tokenB});
        address addressPair = FACTORY.getPair({tokenA: tokenA, tokenB: tokenB});
        if (addressPair == address(0)) { revert PAIR_NOT_FOUND(); }
        IUniswapV2Pair interface_ = IUniswapV2Pair(addressPair);
        IERC20 tokenA_ = IERC20(interface_.token0());
        IERC20 tokenB_ = IERC20(interface_.token1());
        (
            uint reserveA,
            uint reserveB,
            uint lastTimestamp_
        ) = interface_.getReserves();
        if (order == ORDER.SAME) {
            price = (amount * (reserveA * (10**tokenB_.decimals()))) / reserveB;
            price *= 10**18;
            price /= 10**tokenA_.decimals();
            return (price, lastTimestamp_);
        }
        else if (order == ORDER.REVERSE) {
            price = (amount * (reserveB * (10**tokenA_.decimals()))) / reserveA;
            price *= 10**18;
            price /= 10**tokenB_.decimals();
            return (price, lastTimestamp_);
        }
    }

    function init() 
    public 
    onlyDeployer {
        if (_init) { revert ALREADY_INITIALIZED(); }
        bytes32 quickSwapPlugInV000 = keccak256(abi.encode("quickSwapPlugInV000", "admins"));
        if (!REPOSITORY.addressSetContains(quickSwapPlugInV000, _deployer)) {
            REPOSITORY.addAddressSet(quickSwapPlugInV000, _deployer);
        }
        _init = true;
        emit ADMIN_ROLE_GRANTED(msg.sender);
    }

    function whitelist(
        address account
    )
    public 
    onlyAdmin 
    whenInitialized 
    whenNotPaused {
        bytes32 quickSwapPlugInV000 = keccak256(abi.encode("quickSwapPlugInV000", "whitelist"));
        if (REPOSITORY.addressSetContains(quickSwapPlugInV000, account)) { revert ALREADY_WHITELISTED(); }
        REPOSITORY.addAddressSet(quickSwapPlugInV000, account);
        emit ACCOUNT_WHITELISTED(account);
    }

    function blacklist(
        address account
    )
    public 
    onlyAdmin 
    whenInitialized 
    whenNotPaused {
        bytes32 quickSwapPlugInV000 = keccak256(abi.encode("quickSwapPlugInV000", "whitelist"));
        if (!REPOSITORY.addressSetContains(quickSwapPlugInV000, account)) { revert ALREADY_BLACKLISTED(); }
        REPOSITORY.removeAddressSet(quickSwapPlugInV000, account);
        emit ACCOUNT_BLACKLISTED(account);
    }

    function grantRoleAdmin(
        address account
    )
    public 
    onlyAdmin 
    whenInitialized 
    whenNotPaused {
        bytes32 quickSwapPlugInV000 = keccak256(abi.encode("quickSwapPlugInV000", "admins"));
        if (REPOSITORY.addressSetContains(quickSwapPlugInV000, account)) { revert ALREADY_ADMIN(); }
        REPOSITORY.addAddressSet(quickSwapPlugInV000, account);
        emit ADMIN_ROLE_GRANTED(account);
    }

    function revokeRoleAdmin(
        address account
    )
    public 
    onlyAdmin 
    whenInitialized 
    whenNotPaused {
        bytes32 quickSwapPlugInV000 = keccak256(abi.encode("quickSwapPlugInV000", "admins"));
        if (REPOSITORY.addressSetContains(quickSwapPlugInV000, account)) { revert NOT_ADMIN(); }
        REPOSITORY.removeAddressSet(quickSwapPlugInV000, account);
        emit ADMIN_ROLE_REVOKED(account);
    }

    function pause()
    public
    onlyAdmin
    whenInitialized {
        _pause();
    }

    function unpause()
    public
    onlyAdmin
    whenInitialized {
        _unpause();
    }

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn, /// (amountIn * (10**18))
        uint amountOutMin,
        uint gate,
        address from,
        address to
    )
    public
    onlyWhitelist
    whenInitialized 
    whenNotPaused {
        if (gate > 5) { revert UNRECOGNIZED_GATE(); }
        amountIn *= 10**IERC20(tokenIn).decimals();
        amountIn /= 10**18;
        IERC20(tokenIn).transferFrom({from: from, to: address(this), amount: amountIn});
        IERC20(tokenIn).approve({spender: address(ROUTER), amount: amountIn});
        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        if (GATE(gate) == GATE.WMATIC) { path[1] = WMATIC; }
        else if (GATE(gate) == GATE.WBTC) { path[1] = WBTC; }
        else if (GATE(gate) == GATE.WETH) { path[1] = WETH; }
        else if (GATE(gate) == GATE.USDC) { path[1] = USDC; }
        else if (GATE(gate) == GATE.USDT) { path[1] = USDT; }
        else if (GATE(gate) == GATE.DAI) { path[1] = DAI; }
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
        uint amountIn, /// (amountIn * (10**18))
        uint slippage,
        uint gate,
        address from,
        address to
    )
    public 
    onlyWhitelist
    whenInitialized 
    whenNotPaused {
        if (gate > 5) { revert UNRECOGNIZED_GATE(); }
        amountIn *= 10**IERC20(tokenIn).decimals();
        amountIn /= 10**18;
        IERC20(tokenIn).transferFrom({from: from, to: address(this), amount: amountIn});
        IERC20(tokenIn).approve({spender: address(ROUTER), amount: amountIn});
        (uint amountOutMin,) = price({tokenA: tokenIn, tokenB: tokenOut, amount: amountIn});
        amountOutMin = (amountOutMin * (10000 - slippage)) / 10000;
        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        if (GATE(gate) == GATE.WMATIC) { path[1] = WMATIC; }
        else if (GATE(gate) == GATE.WBTC) { path[1] = WBTC; }
        else if (GATE(gate) == GATE.WETH) { path[1] = WETH; }
        else if (GATE(gate) == GATE.USDC) { path[1] = USDC; }
        else if (GATE(gate) == GATE.USDT) { path[1] = USDT; }
        else if (GATE(gate) == GATE.DAI) { path[1] = DAI; }
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

    function _onlyWhitelist()
    private view {
        bytes32 quickSwapPlugInV000 = keccak256(abi.encode("quickSwapPlugInV000", "whitelist"));
        if (!REPOSITORY.addressSetContains(quickSwapPlugInV000, msg.sender)) { revert ONLY_WHITELIST(); }
    }

    function _onlyAdmin()
    private view {
        bytes32 quickSwapPlugInV000 = keccak256(abi.encode("quickSwapPlugInV000", "admins"));
        if (!REPOSITORY.addressSetContains(quickSwapPlugInV000, msg.sender)) { revert ONLY_ADMIN(); }
    }
    
    function _onlyDeployer()
    private view {
        if (msg.sender != _deployer) { revert ONLY_DEPLOYER(); }
    }

    function _whenInitialized()
    private view {
        if (!_init) { revert NOT_INITIALIZED(); }
    }
}