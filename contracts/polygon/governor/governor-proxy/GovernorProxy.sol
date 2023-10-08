// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state-router/ProxyStateRouterV1.sol";
import "contracts/polygon/abstract/proxy/proxy-state-history/ProxyStateHistoryV1.sol";
import "contracts/polygon/abstract/access-control/role-state/RoleStateV1.sol";

/**
 * @dev GovernorProxy contract combines functionality from ProxyStateRouterV1, ProxyStateHistoryV1, and RoleStateV1.
 * It includes features for initialization tracking, setting implementation routes, and role-based access control.
 */
contract GovernorProxy is ProxyStateRouterV1, ProxyStateHistoryV1, RoleStateV1 {

    /**
    * @dev Emitted when a contract function is called.
    * @param target The address of the contract account.
    * @param signature The function signature.
    * @param args The function arguments.
    */
    event Called(address indexed target, string indexed signature, bytes indexed args);

    /**
    * @dev Error indicating that the contract has already been initialized.
    */
    error AlreadyInitialized();

    /**
    * @dev Error indicating that the contract has not been initialized yet.
    */
    error HasNotBeenInitializedYet();

    /**
    * @dev Error indicating that a low-level call to another contract has failed.
    *
    * Emits a {FailedCallTo} event with details about the failed call.
    *
    * Requirements:
    * - The call to the external contract must not be successful.
    */
    error FailedCallTo(address target, string signature, bytes args);

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
    * @dev Public function to call a function on a target contract.
    * @param target The address of the target contract.
    * @param signature The function signature.
    * @param args The function arguments.
    * @return bytes representing the result of the function call.
    */
    function call(address target, string memory signature, bytes memory args) public virtual returns (bytes memory) {
        return _call(target, signature, args);
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
    * @dev Internal function to call a specific function on a contract.
    * @param account The address of the contract to call.
    * @param signature The function signature.
    * @param args The function arguments.
    * @return bytes representing the result of the function call.
    * @dev It encodes the function signature and arguments, then calls the specified contract.
    * @dev If the call is not successful, it reverts with the "FailedCallTo" error.
    * @dev It emits a "Called" event after a successful call.
    */
    function _call(address target, string memory signature, bytes memory args) internal returns (bytes memory) {
        bytes4 selector = bytes4(keccak256(bytes(signature)));
        (bool success, bytes memory result) = target.call(abi.encodePacked(selector, args));
        if (!success) { revert FailedCallTo(target, signature, args); }
        emit Called(target, signature, args);
        return result;
    }

    /**
    * @dev Internal virtual function to handle the fallback function.
    * @dev If the sender has a specific route set, it delegates the call to that implementation.
    * @dev Otherwise, it calls the fallback function of the parent contract.
    */
    function _fallback() internal virtual override(ProxyStateRouterV1, ProxyStateV1) {}
}