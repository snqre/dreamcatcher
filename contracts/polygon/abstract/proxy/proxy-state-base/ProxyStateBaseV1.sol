// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state-router/ProxyStateRouterV1.sol";
import "contracts/polygon/abstract/proxy/proxy-state-history/ProxyStateHistoryV1.sol";
import "contracts/polygon/abstract/access-control/role-state/RoleStateV1.sol";

/**
 * @dev Abstract contract combining functionality from ProxyStateRouterV1, ProxyStateHistoryV1, and RoleStateV1.
 */
abstract contract ProxyStateBaseV1 is ProxyStateRouterV1, ProxyStateHistoryV1, RoleStateV1 {

    /**
    * @dev Error indicating that the contract has already been initialized.
    */
    error AlreadyInitialized();

    /**
    * @dev Error indicating that the contract has not been initialized yet.
    */
    error HasNotBeenInitializedYet();

    /**
    * @dev Public pure virtual function to generate a unique key for tracking initialization status.
    * @return bytes32 representing the unique key for tracking initialization status.
    * @dev This function must be implemented in derived contracts to provide a unique key for initialization status.
    */
    function initializedKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("INITIALIZED"));
    }

    /**
    * @dev Public view virtual function to check if the contract has been initialized.
    * @return bool indicating whether the contract has been initialized.
    * @dev This function must be implemented in derived contracts to provide the initialization status.
    */
    function initialized() public view virtual returns (bool) {
        return _bool[initializedKey()];
    }

    /**
    * @dev Public function to initialize the contract.
    * @dev It can only be called once, ensuring that the contract has not been initialized before.
    */
    function initialize(address implementation) public virtual {
        _onlynotInitialized();
        _initialize(implementation);
    }

    /**
    * @dev Public function to set the implementation route for a specific sender.
    * @param sender The address of the sender for which to set the route.
    * @param implementation The address of the implementation to set for the specified sender.
    * @dev It requires the sender to have the "ROUTER_ROLE" and then sets the route using the internal function `_setRoute`.
    */
    function setRoute(address sender, address implementation) public virtual {
        requireRole(roleKey("ROUTER_ROLE"), msg.sender);
        _setRoute(sender, implementation);
    }

    /**
    * @dev Public function to upgrade the contract to a new implementation.
    * @param implementation The address of the new implementation to upgrade to.
    * @dev It requires the sender to have the "UPGRADER_ROLE" and then upgrades using the internal function `_upgrade`.
    */
    function upgrade(address implementation) public virtual {
        requireRole(roleKey(hash("UPGRADER_ROLE")), msg.sender);
        _upgrade(implementation);
    }

    /**
    * @dev Internal view function to check if the contract has not been initialized yet.
    * @dev If the contract has already been initialized, it reverts with the "AlreadyInitialized" error.
    */
    function _onlynotInitialized() internal view virtual {
        if (initialized()) {
            revert AlreadyInitialized();
        }
    }

    /**
    * @dev Internal virtual function to initialize the contract with a specific implementation.
    * @param implementation The address of the implementation to set as the current implementation.
    * @dev This function overrides the parent implementation and ensures that the base contracts are also initialized.
    */
    function _initialize(address implementation) internal virtual override(ProxyStateRouterV1, ProxyStateV1) {
        ProxyStateRouterV1._initialize(implementation);
        RoleStateV1._initialize();
        _bool[initializedKey()] = true;
    }

    /**
    * @dev Internal virtual function to upgrade the contract to a new implementation.
    * @param implementation The address of the new implementation to upgrade to.
    * @dev This function overrides the parent implementation and ensures that the base contract is upgraded.
    * @dev After upgrading the base contract, it logs the upgrade in history using the `_logUpgrade` function.
    */
    function _upgrade(address implementation) internal virtual override(ProxyStateHistoryV1, ProxyStateV1) {
        ProxyStateHistoryV1._upgrade(implementation);
    }

    /**
    * @dev Internal virtual function to handle the fallback function.
    * @dev If the sender has a specific route set, it delegates the call to that implementation.
    * @dev Otherwise, it calls the fallback function of the parent contract.
    */
    function _fallback() internal virtual override(ProxyStateRouterV1, ProxyStateV1) {}
}