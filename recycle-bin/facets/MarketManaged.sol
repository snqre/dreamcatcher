// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/Console.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router01.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/diamonds/facets/OracleReader.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

/// makes use of the oracle or oracle reader for exchange router data
/// enables the diamond to swap tokens using v2 routers
/// when using oracle reader the same interface will work for oracle
/// because swap is an action that has to be done regularly it isnt designed to be timelocked
/// for timelock func use Market facet instead
/// MarketManaged and Market will clash
/// managed has inbuilt func to prevent abuse by its manager
/// these can be removed but contributors must be aware
/// more customization is planned further into dev
contract MarketManaged {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 internal constant _MARKET = keccak256("slot.market-managed");

    event ManagerAdded(address account);
    event ManagerRemoved(address account);

    /// slippage controls to prevent abuse and swappable value controls
    /// swap cooldowns help prevent abuse
    /// if contributors are looking to contribute to a vault
    /// it is important that they trust or can verify that the
    /// owners are legitimate partners if any of these controls arent set
    /// unlike other platforms there are over 50k pairs available for trade
    /// some may not have adequate liquidity but repayment in kind allows for this model
    struct MarketManagedStorage {
        EnumerableSet.AddressSet managers;
        SlippageControls slippageControls;
        SwapControls swapControls;
    }

    struct SlippageControls {
        bool hasSlippageThreshold;
        bool hasSlippageAllowance;
        bool hasSlippageAllowanceCooldown;
        uint slippageLastResetTimestamp;
        uint slippageThreshold;
        uint slippageAllowance;
        uint slippageCurrent;
        uint slippageAllowanceResetCooldown;
    }

    struct SwapControls {
        bool hasNumSwapAllowance;
        bool hasSwapAllowance;
        bool hasMinSwapSize;
        bool hasMaxSwapSize;
        bool hasSwapAllowanceCooldown;
        uint swapLastResetTimestamp;
        uint numSwapAllowance;
        uint swapAllowance;
        uint ;
        uint minSwapSize;
        uint maxSwapSize;
        uint swapAllowanceResetCooldown; /// for both num and allowance
    }

    modifier onlySelfOrAdmin() {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        _;
    }

    modifier onlyManager() {
        require(_isManager(), "!_isManager");
        _;
    }

    function marketManaged() internal pure virtual returns (MarketManagedStorage storage s) {
        bytes32 location = _MARKET;
        assembly {
            s.slot := location
        }
    }

    function ____addManager(adddress account) onlySelfOrAdmin() external virtual {
        _addManager(account);
    }

    function ____removeManager(address account) onlySelfOrAdmin() external virtual {
        _removeManager(account);
    }

    function managers(uint i) public view virtual returns (address) {
        return marketManaged().managers.at(i);
    }

    function managers() public view virtual returns (address[] memory) {
        return marketManaged().managers.values();
    }

    function managersContains(address account) public view virtual returns (bool) {
        return marketManaged().managers.contains(account);
    }

    function managersLength() public view virtual returns (uint) {
        return marketManaged().managers.length();
    }

    function hasSlippageThreshold() public view virtual returns (bool) {
        return market().slippageControls.hasSlippageThreshold;
    }

    function hasSlippageAllowance() public view virtual returns (bool) {
        return marketManaged().slippageControls.hasSlippageAllowance;
    }

    function hasSlippageAllowanceCooldown() public view virtual returns (bool) {
        return marketManaged().slippageControls.hasSlippageAllowanceCooldown;
    }

    function slippageLastResetTimestamp() public view virtual returns (uint) {
        return marketManaged().slippageControls.slippageLastResetTimestamp;
    }

    function slippageThreshold() public view virtual returns (uint) {
        return marketManaged().slippageControls.slippageThreshold;
    }

    function slippageAllowance() public view virtual returns (uint) {
        return marketManaged().slippageControls.slippageAllowance;
    }

    function slippageAllowanceResetCooldown() public view virtual returns (uint) {
        return marketManaged().slippageControls.slippageAllowanceResetCooldown;
    }

    function hasNumSwapAllowance() public view virtual returns (bool) {
        return marketManaged().swapControls.hasNumSwapAllowance;
    }

    function hasSwapAllowance() public view virtual returns (bool) {
        return marketManaged().swapControls.hasSwapAllowance;
    }

    function hasMinSwapSize() public view virtual returns (bool) {
        return marketManaged().swapControls.hasMinSwapSize;
    }

    function hasMaxSwapSize() public view virtual returns (bool) {
        return marketManaged().swapControls.hasMaxSwapSize;
    }

    function hasSwapAllowanceCooldown() public view virtual returns (bool) {
        return marketManaged().swapControls.hasSwapAllowanceCooldown;
    }

    function swapLastResetTimestamp() public view virtual returns (uint) {
        return marketManaged().swapControls.swapLastResetTimestamp;
    }

    function numSwapAllowance() public view virtual returns (uint) {
        return marketManaged().swapControls.numSwapAllowance;
    }

    function swapAllowance() public view virtual returns (uint) {
        return marketManaged().swapControls.swapAllowance;
    }

    function minSwapSize() public view virtual returns (uint) {
        return marketManaged().swapControls.minSwapSize;
    }

    function maxSwapSize() public view virtual returns (uint) {
        return marketManaged().swapControls.maxSwapSize;
    }

    function swapAllowanceResetCooldown() public view virtual returns (uint) {
        return marketManaged().swapControls.swapAllowanceResetCooldown;
    }

    function swap(address tokenOut, address tokenIn, uint amountIn) onlyManager() public virtual {
        /// reset before swap if applicable
        if (hasSlippageAllowanceCooldown()) {
            if (block.timestamp >= slippageLastResetTimestamp() + slippageAllowanceResetCooldown()) {
                marketManaged().slippageControls.slippageLastResetTimestamp = block.timestamp;
                marketManaged().slippageControls.slippageAllowance = 
            }
        }
    }

    /// amounts must be in 18 decimals
    function ____swap(address tokenIn, address tokenOut, uint amountIn) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        require(_hasAdaptor(tokenIn), "!_hasAdaptor");
        require(_hasAdaptor(tokenOut), "!_hasAdaptor");
        require(_hasEnoughBalance(tokenIn, amountIn), "!_hasEnoughBalance");
        uint priceIn = _price(tokenIn); /// as 10**18
        uint priceOut = _price(tokenOut); /// as 10**18
        /// values are the price of 1 ether of the amounts of the respective tokens
        amountIn *= 10**18;
        uint amountOut = amountIn.computeAmountOut(valueIn, valueOut);
        amountOut /= 10**18;
        amountOut -= ((amountOut * slippageThreshold()) / 10000);
        IToken tokenIn_ = IToken(tokenIn);
        /// 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45 uniswap v2 router on polygon
        address UNISWAP_V2_ROUTER = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
        tokenIn_.approve(UNISWAP_V2_ROUTER, amountIn.computeAsNativeValue(tokenIn_.decimals()));
        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        path[1] = liquidityToken();
        path[2] = tokenOut;
        IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokens(amountIn, amountOut, path, address(this), block.timestamp);
        tokenIn_.approve(UNISWAP_V2_ROUTER, 0);
    }

    function _isSelfOrAdmin() internal view virtual {
        return msg.sender == IConsole(address(this)).admin() || msg.sender == address(this);
    }

    function _isManager() internal view virtual {
        return managersContains(msg.sender);
    }

    function _addManager(address account) internal virtual {
        marketManaged().managers.add(account);
        emit ManagerAdded(account);
    }

    function _removeManager(address account) internal virtual {
        marketManaged().managers.remove(account);
        emit ManagerRemoved(account);
    }
}