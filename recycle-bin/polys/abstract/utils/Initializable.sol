// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/StorageLite.sol";

abstract contract Initializable is StorageLite {

    /**
    * @notice Emitted when the contract is initialized by a sender.
    *         The `Initialized` event signals that the contract has been successfully initialized
    *         and can now perform its intended functions.
    * @dev This event provides information about the sender who triggered the initialization.
    *      It is recommended to perform necessary setup and configuration tasks in response
    *      to this event, as the contract is now ready for operation.
    * @param sender The address of the account that initiated the initialization process.
    * @dev It is crucial to pay attention to the `sender` parameter to track the origin of
    *      the initialization.
    */
    event Initialized(address indexed sender);

    /**
    * @notice Checks whether the contract has been initialized.
    * @dev This function returns a boolean indicating whether the contract has been initialized.
    * @return True if the contract is initialized, false otherwise.
    */
    function initialized() public view virtual returns (bool) {
        return abi.decode(_bytes[____initialized()], (bool));
    }

    /**
    * @notice Internal function to get the storage key for the initialization status.
    * @dev This function returns the keccak256 hash of the string "INITIALIZED".
    * @return The storage key for the initialization status.
    */
    function ____initialized() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("INITIALIZED"));
    }

    /**
    * @dev Internal function to ensure that the contract is not already initialized.
    * @notice This function checks if the contract is not already initialized. If the contract
    *         is already initialized, it will revert the transaction with an error message.
    */
    function _mustNotBeInitialized() internal view virtual {
        require(!initialized(), "InitializableLite: initialized()");
    }

    /**
    * @dev Internal function to initialize the contract.
    * @notice This function initializes the contract, setting the initialization status to true.
    *         It emits the `Initialized` event to signal that the contract has been successfully initialized.
    * @dev It is crucial to call `_mustNotBeInitialized()` before calling this function to ensure
    *      that the contract is not already initialized.
    */
    function _initialize() internal virtual {
        _mustNotBeInitialized();
        _bytes[____initialized()] = abi.encode(true);
        emit Initialized(msg.sender);
    }
}