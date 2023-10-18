// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/StorageLite.sol";

abstract contract Configurable is StorageLite {

    /**
    * @notice Emitted when the contract is configured.
    *         The `Configured` event signals that the contract has been successfully configured.
    * @dev This event provides information about the sender who triggered the configuration.
    * @param sender The address of the account that initiated the configuration process.
    * @dev It is recommended to listen for this event to track changes in the contract configuration
    *      and perform necessary actions accordingly.
    */
    event Configured(address indexed sender);

    /**
    * @notice Checks whether the contract is configured.
    * @dev This function returns a boolean indicating whether the contract has been configured.
    * @return True if the contract is configured, false otherwise.
    */
    function configured() public view virtual returns (bool) {
        return abi.decode(_bytes[____configured()], (bool));
    }

    /**
    * @dev Internal function to get the storage key for the configuration status.
    * @notice This function returns the keccak256 hash of the string "CONFIGURED".
    * @return The storage key for the configuration status.
    */
    function ____configured() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("CONFIGURED"));
    }

    /**
    * @dev Internal function to ensure that the contract is not already configured.
    * @notice This function checks if the contract is not configured and raises an error if it is.
    * @dev It is crucial to call this function before initiating the configuration process
    *      to prevent accidental reconfiguration.
    */
    function _mustNotBeConfigured() internal view virtual {
        require(!configured(), "ConfigurableLite: configured()");
    }

    /**
    * @dev Internal function to configure the contract.
    * @notice This function marks the contract as configured and emits the `Configured` event.
    * @dev It is recommended to call this function after successfully setting up the contract
    *      to indicate that it is ready for use.
    */
    function _configure() internal virtual {
        _mustNotBeConfigured();
        _bytes[____configured()] = abi.encode(true);
        emit Configured(msg.sender);
    }
}