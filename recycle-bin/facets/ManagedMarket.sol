// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/Console.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router01.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/diamonds/facets/OracleReader.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

/// will clash with market
/// designed to be operated by managers
/// with slippage controls and checks
contract ManagedMarket {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 internal constant _MANAGED_MARKET = keccak256("slot.managed-market");

    event ManagerAdded(address account);
    event ManagerRemoved(address account);
    event SlippageControlsEnabled();
    event SlippageControlsDisabled();
    event SlippageThresholdChanged(uint oldThreshold, uint newThreshold);
    event SlippageAllowanceChanged(uint oldAllowance, uint newAllowance);
    event SlippageAllowanceSpent(uint allowanceSpent, uint allowanceLeft);
    event SlippageAllowanceReset();
    event SlippageCooldownChanged(uint oldCooldown, uint newCooldown);
    event NumSwapAllowanceChanged(uint oldValue, uint newValue);
    event NumSwapAllowanceSpent(uint valueLeft);
    event MinSwapValueChanged(uint oldValue, uint newValue);
    event MaxSwapValueChanged(uint oldValue, uint newValue);
    event SwapAllowanceReset();
    event SwapCooldownChanged(uint oldCooldown, uint newCooldown);

    struct ManagedMarketStorage {
        EnumerableSet.AddressSet managers;
        bool slippageControlsEnabled;
        bool swapControlsEnabled;
        uint slippageThreshold;
        uint slippageAllowance;
        uint slippageAllowanceSpent;
        uint slippageTimestamp;
        uint slippageCooldown;
        uint numSwapAllowance;
        uint numSwapAllowanceSpent;
        uint minSwapValue;
        uint maxSwapValue;
        uint swapTimestamp;
        uint swapCooldown;
        bool reentrancyLock;
    }

    modifier nonReentrant() {
        require(!managedMarket().reentrancyLock, "reentrant");
        managedMarket().reentrancyLock = true;
        _;
        managedMarket().reentrancyLock = false;
    }

    function managedMarket() internal pure virtual returns (ManagedMarket storage s) {
        bytes32 location = _MANAGED_MARKET;
        assembly {
            s.slot := location
        }
    }

    function managers(uint i) public view virtual returns (address) {
        return managedMarket().managers.at(i);
    }

    function managers() public view virtual returns (address[] memory) {
        return managedMarket().managers.values();
    }

    function isManager(address account) public view virtual returns (bool) {
        return managedMarket().managers.contains(account);
    }

    function managersLength() public view virtual returns (uint) {
        return managedMarket().managers.length();
    }

    function slippageControlsEnabled() public view virtual returns (bool) {
        return managedMarket().slippageControlsEnabled;
    }

    function swapControlsEnabled() public view virtual returns (bool) {
        return managedMarket().swapControlsEnabled;
    }

    function slippageThreshold() public view virtual returns (uint) {
        return managedMarket().slippageThreshold;
    }

    function slippageAllowance() public view virtual returns (uint) {
        return managedMarket().slippageAllowance;
    }

    function slippageAllowanceSpent() public view virtual returns (uint) {
        return managedMarket().slippageAllowanceSpent;
    }

    function slippageTimestamp() public view virtual returns (uint) {
        return managedMarket().slippageTimestamp;
    }

    function slippageCooldown() public view virtual returns (uint) {
        return managedMarket().slippageCooldown;
    }

    function numSwapAllowance() public view virtual returns (uint) {
        return managedMarket().numSwapAllowance;
    }

    function numSwapAllowanceSpent() public view virtual returns (uint) {
        return managedMarket().numSwapAllowanceSpent;
    }

    function minSwapValue() public view virtual returns (uint) {
        return managedMarket().minSwapValue;
    }

    function maxSwapValue() public view virtual returns (uint) {
        return managedMarket().maxSwapValue;
    }

    function swapTimestamp() public view virtual returns (uint) {
        return managedMarket().swapTimestamp;
    }

    function swapCooldown() public view virtual returns (uint) {
        return managedMarket().swapCooldown;
    }
}