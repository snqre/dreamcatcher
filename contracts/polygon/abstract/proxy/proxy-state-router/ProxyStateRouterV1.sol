// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state/ProxyStateV1.sol";

/**
 * @title ProxyStateRouterV1
 * @dev Abstract contract for a stateful proxy with routing capabilities.
 * @dev It extends ProxyStateV1 and allows setting different implementations for specific senders.
 */
abstract contract ProxyStateRouterV1 is ProxyStateV1 {

    /**
    * @dev Emitted when the route for a sender is set to a specific implementation.
    * @param sender The address for which the route is set.
    * @param implementation The address of the implementation to which the route is set.
    */
    event SenderRouteSetTo(address indexed sender, address implementation);

    /**
    * @dev Error indicating that the route for a sender is already set to a specific implementation.
    * @param sender The address for which the route is already set.
    * @param implementation The address of the implementation to which the route is already set.
    */
    error SenderRouteAlreadySetTo(address sender, address implementation);

    /**
    * @dev Public pure function to generate a unique key for routing information associated with a sender.
    * @param sender The address of the sender for which to generate the route key.
    * @return bytes32 representing the unique key for the routing information of the specified sender.
    * @dev The function uses keccak256 hashing to create a unique key based on the sender's address and the "ROUTE" identifier.
    */
    function routeKey(address sender) public pure returns (bytes32) {
        return keccak256(abi.encode(sender, "ROUTE"));
    }

    /**
    * @dev Public view function to retrieve the routing information for a specified sender.
    * @param sender The address of the sender for which to retrieve the route.
    * @return address representing the routing information for the specified sender.
    * @dev The function looks up the routing information stored in the contract state using the generated route key.
    */
    function route(address sender) public view returns (address) {
        return _address[routeKey(sender)];
    }

    /**
    * @dev Internal virtual function to initialize the contract with a specific implementation.
    * @param implementation The address of the implementation to set as the current implementation.
    * @dev This function overrides the parent implementation and ensures that the base contract is also initialized.
    */
    function _initialize(address implementation) internal virtual override {
        super._initialize(implementation);
    }

    /**
    * @dev Internal virtual function to set the implementation address for a specific sender.
    * @param sender The address of the sender for which to set the implementation.
    * @param implementation The address of the implementation to set for the specified sender.
    * @dev It checks if the current implementation is already set to the provided one and reverts if so.
    * @dev It updates the implementation address in storage and emits the `SenderRouteSetTo` event.
    */
    function _setRoute(address sender, address implementation) internal virtual {
        if (route(sender) == implementation) {
            revert SenderRouteAlreadySetTo(sender, implementation);
        }
        _address[routeKey(sender)] = implementation;
        emit SenderRouteSetTo(sender, implementation);
    }

    /**
    * @dev Internal virtual function to handle the fallback function.
    * @dev If the sender has a specific route set, it delegates the call to that implementation.
    * @dev Otherwise, it calls the fallback function of the parent contract.
    */
    function _fallback() internal virtual override {
        if (route(msg.sender) != address(0)) {
            _delegate(route(msg.sender));
        }
        else {
            super._fallback();
        }
    }
}