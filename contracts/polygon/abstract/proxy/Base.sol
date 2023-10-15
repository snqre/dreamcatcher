// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";
import "contracts/polygon/abstract/storage/Storage.sol";

/**
* NOTE: https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies
 */
abstract contract Base is Storage, Proxy {

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

    event OwnershipTransffered(address indexed oldOwner, address indexed newOwner);

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
    * @notice Checks whether the contract has been initialized.
    * @dev Returns the boolean value indicating the initialization status.
    * @return bool The initialization status of the contract.
    */
    function initialized() public view virtual returns (bool) {
        return _bool[_keyInitialized()];
    }

    /**
    * @notice Retrieves the implementation address at the specified index in the implementation history.
    * @dev Returns the implementation address based on the provided implementationId.
    * @param implementationId The index of the implementation in the implementation history.
    * @return address The address of the implementation contract at the specified index.
    */
    function implementations(uint256 implementationId) public view virtual returns (address) {
        return _addressArray[_keyHistory()][implementationId];
    }

    /**
    * @notice Retrieves the number of implementations in the implementation history.
    * @dev Returns the length of the implementation history array.
    * @return uint The number of implementations in the history.
    */
    function implementationLength() public view virtual returns (uint) {
        return _addressArray[_keyHistory()].length;
    }

    /**
    * @notice Sets the initial implementation for the ProxyWithStorage contract.
    * @dev Sets the initial implementation for the ProxyWithStorage contract if it has not been initialized.
    * @param implementation The address of the initial implementation contract.
    * @throws If the contract has already been initialized.
    */
    function setInitialImplementation(address implementation) public {
        require(!initialized(), "initialized");
        _upgrade(implementation);
        _bool[_keyInitialized()] = true;
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
    function _keyImplementation() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("implementation"));
    }

    /**
    * @dev Returns the keccak256 hash of the string "initialized".
    * @return bytes32 The keccak256 hash value.
    */
    function _keyInitialized() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("initialized"));
    }

    /**
    * @notice Generates the key for accessing the implementation history.
    * @dev Returns the keccak256 hash of the string "history".
    * @return bytes32 The key for accessing the implementation history.
    */
    function _keyHistory() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("history"));
    }

    function _ownerKey() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("ownerKey()"));
    }

    /**
    * @dev Implementation Address Retrieval
    * @dev Retrieves the address of the current implementation contract.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This function is often used in the context of proxy contracts to obtain the address of the underlying
    * implementation contract. Developers can override this function in their contracts to dynamically specify
    * the implementation address.
    *
    * @return The address of the current implementation contract.
    */
    function _implementation() internal view virtual override returns (address) {
        return _address[_keyImplementation()];
    }

    /**
    * @dev Upgrade Function
    * @dev Updates the implementation address and emits an Upgraded event.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This function is typically used in the context of proxy contracts to upgrade the implementation address.
    * It updates the `_address` mapping with the new implementation using the generated key from `implementationKey()`.
    * Developers can override this function in their contracts to implement custom upgrade logic.
    *
    * @param implementation The new address of the upgraded implementation contract.
    */
    function _upgrade(address implementation) internal virtual {
        _address[_keyImplementation()] = implementation;
        _logUpgrade(implementation);
        emit Upgraded(implementation);
    }

    /**
    * @dev Logs the upgrade by adding the new implementation address to the contract's upgrade history.
    * @param implementation The address of the new implementation contract.
    */
    function _logUpgrade(address implementation) internal virtual {
        _addressArray[_keyHistory()].push(implementation);
    }

}