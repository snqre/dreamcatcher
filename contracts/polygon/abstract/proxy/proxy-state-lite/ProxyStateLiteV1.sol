// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";
import "contracts/polygon/abstract/storage/state-lite/StateLiteV1.sol";

/**
 * @title ProxyStateLiteV1
 * @dev A proxy contract with lightweight state and upgrade functionality.
 */
abstract contract ProxyStateLiteV1 is StateLiteV1, Proxy {

    /**
    * @dev Upgraded Event
    * @dev Emitted when the contract undergoes an upgrade to a new implementation.
    *
    * This event is typically used in the context of proxy contracts to notify external observers
    * when the contract's implementation is upgraded to a new address. The `implementation` parameter
    * is indexed for efficient event filtering.
    *
    * @param implementation The address of the newly upgraded implementation contract.
    */
    event Upgraded(address indexed implementation);

    /**
    * @dev Implementation Address Is Zero Error
    * @dev Custom error indicating that the implementation address is set to zero during contract execution.
    *
    * This error is typically used in the context of proxy contracts to signal that the implementation address
    * is not set before attempting to delegate to the implementation contract. It helps developers identify and
    * handle scenarios where the implementation address is unexpectedly zero.
    */
    error ImplementationAddressIsZero();

    /**
    * @dev Fallback Function
    * @dev Executed when the contract receives Ether without a specific function call.
    * @dev Calls the _fallback() function, which can be overridden by inheriting contracts.
    *
    * This function allows the contract to handle incoming Ether transactions in a customizable way.
    * Developers can override the _fallback() function in their contracts to implement specific logic
    * when Ether is sent to the contract without a specific function call.
    *
    * @notice Ensure that inheriting contracts implement the _fallback() function as needed.
    */
    fallback() external payable virtual override {
        _fallback();
    }

    /**
    * @dev Receive Function
    * @dev Automatically called when the contract receives Ether.
    * @dev Calls the _fallback() function, which can be overridden by inheriting contracts.
    *
    * This function is invoked when the contract receives Ether, providing a way to handle incoming transactions.
    * Developers can customize the behavior by implementing the _fallback() function in their contracts.
    *
    * @notice Ensure that inheriting contracts implement the _fallback() function as needed.
    */
    receive() external payable virtual override {
        _fallback();
    }

    /**
    * @dev Implementation Key Function
    * @dev Generates a unique key for identifying the implementation contract.
    *
    * This function returns the keccak256 hash of the string "IMPLEMENTATION", providing a unique identifier
    * (key) commonly used in the context of proxy contracts to associate an implementation contract with a key.
    *
    * @return A bytes32 key representing the implementation contract.
    */
    function implementationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("IMPLEMENTATION"));
    }

    /**
    * @dev Implementation Function
    * @dev Retrieves the address of the current implementation contract.
    * @dev Calls the _implementation() function, which can be overridden by inheriting contracts.
    *
    * This function is often used in the context of proxy contracts to obtain the address of the underlying
    * implementation contract. Developers can override the _implementation() function in their contracts to
    * dynamically specify the implementation address.
    *
    * @return The address of the current implementation contract.
    */
    function implementation() public view virtual returns (address) {
        return _implementation();
    }

    /**
    * @dev Implementation Address Retrieval
    * @dev Retrieves the address of the current implementation contract stored as bytes.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This function is often used in the context of proxy contracts to obtain the address of the underlying
    * implementation contract. Developers can override this function in their contracts to dynamically specify
    * the implementation address. The implementation address is stored as bytes and decoded using `abi.decode`.
    *
    * @return The address of the current implementation contract.
    */
    function _implementation() internal view virtual override returns (address) {
        return abi.decode(_bytes[implementationKey()], (address));
    }

    /**
    * @dev Internal virtual function to perform the initial upgrade of the contract to the provided implementation.
    * @param implementation The address of the new implementation contract.
    */
    function _initialize(address implementation) internal virtual {
        _upgrade(implementation);
    }

    /**
    * @dev Upgrade Implementation
    * @dev Updates the implementation address and emits an Upgraded event.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This function is typically used in the context of proxy contracts to upgrade the implementation address.
    * It updates the `_bytes` mapping with the new implementation by encoding it using `abi.encode`.
    * Developers can override this function in their contracts to implement custom upgrade logic.
    *
    * @param implementation The new address of the upgraded implementation contract.
    */
    function _upgrade(address implementation) internal virtual {
        _bytes[implementationKey()] = abi.encode(implementation);
        emit Upgraded(implementation);
    }

    /**
    * @dev Delegate Function
    * @dev Delegates to the specified implementation address using the parent contract's _delegate function.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This function is often used in the context of proxy contracts to delegate to a specific implementation.
    * It internally calls the _delegate function from the parent contract, providing a way to customize delegation logic
    * in inheriting contracts.
    *
    * @param implementation The address of the implementation contract to which the delegation occurs.
    */
    function _delegate(address implementation) internal virtual override {
        super._delegate(implementation);
    }

    /**
    * @dev Fallback Function Override
    * @dev Customizes the behavior of the fallback function and ensures the implementation address is not zero.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This function is typically used in the context of proxy contracts to customize the behavior of the fallback function.
    * It checks whether the implementation address is set and reverts if it's zero. If the check passes, it delegates to
    * the parent contract's fallback logic using super._fallback().
    *
    * @notice Ensure that the implementation address is set before calling this function to avoid reversion.
    * @notice Developers can override this function in their contracts to implement custom fallback logic.
    */
    function _fallback() internal virtual override {
        if (implementation() == address(0)) {
            revert ImplementationAddressIsZero();
        }
        super._fallback();
    }

    /**
    * @dev Before Fallback Hook
    * @dev Executes logic before the fallback function is delegated to the implementation contract.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This hook is designed for customization in the context of proxy contracts. It allows developers to
    * execute additional logic before the fallback function is delegated to the implementation contract.
    *
    * @notice Developers can override this function in their contracts to implement custom logic
    * that should be executed before the fallback function.
    */
    function _beforeFallback() internal virtual override {
        super._beforeFallback();
    }
}