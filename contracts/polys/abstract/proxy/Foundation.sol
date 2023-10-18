// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";
import "contracts/polygon/abstract/storage/StorageLite.sol";
import "contracts/polygon/abstract/utils/Configurable.sol";

contract Foundation is StorageLite, Configurable, Proxy {

    /**
    * @notice Emitted when the contract is upgraded to a new implementation.
    *         The `Upgraded` event signals that the contract has been successfully upgraded.
    * @dev This event provides information about the sender who triggered the upgrade and the new implementation address.
    * @param sender The address of the account that initiated the upgrade.
    * @param implementation The address of the new implementation contract.
    * @dev It is recommended to listen for this event to track upgrades and perform necessary actions accordingly.
    */
    event Upgraded(address indexed sender, address indexed implementation);

    /**
    * @notice Retrieves the current implementation address.
    * @dev This function returns the address of the current implementation contract.
    * @return The address of the current implementation contract.
    * @dev Use this function to query the current implementation address.
    */
    function implementation() public view virtual returns (address) {
        return _implementation();
    }

    /**
    * @notice Retrieves the implementation address for a specific version.
    * @dev This function returns the implementation address associated with a given version index.
    * @param i The index of the version for which to retrieve the implementation address.
    * @return The address of the implementation contract for the specified version.
    * @dev Use this function to query the implementation address for a particular version.
    */
    function version(uint i) public view virtual returns (address) {
        return abi.decode(_bytes[____version(i)], (address));
    }

    /**
    * @notice Retrieves the total number of versions available.
    * @dev This function returns the total number of versions available for the contract.
    * @return The total number of versions available.
    * @dev Use this function to query the count of available versions.
    */
    function versionLength() public view virtual returns (uint) {
        return abi.decode(_bytes[____versionCount()], (uint));
    }

    /**
    * @notice Configures the contract with a new implementation address.
    * @dev This function allows the contract to be configured with a new implementation address.
    * @param implementation The address of the new implementation contract.
    * @dev Use this function to upgrade the contract to a new implementation.
    */
    function configure(address implementation) public virtual {
        _configure(implementation);
    }

    /**
    * @notice Returns the storage key for the implementation address.
    * @dev This internal pure function returns the storage key for the implementation address.
    * @return The storage key for the implementation address.
    * @dev Use this function internally to get the storage key for the implementation address.
    */
    function ____implementation() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("IMPLEMENTATION"));
    }

    /**
    * @notice Returns the storage key for a specific version.
    * @dev This internal pure function returns the storage key for a specific version based on the index.
    * @param i The index of the version.
    * @return The storage key for the specified version.
    * @dev Use this function internally to get the storage key for a specific version.
    */
    function ____version(uint i) internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("VERSION", i));
    }

    /**
    * @notice Returns the storage key for the version count.
    * @dev This internal pure function returns the storage key for the version count.
    * @return The storage key for the version count.
    * @dev Use this function internally to get the storage key for the version count.
    */
    function ____versionCount() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("VERSION_COUNT"));
    }

    /**
    * @notice Returns the implementation address.
    * @dev This internal view function returns the implementation address by decoding it from storage.
    * @return The implementation address.
    * @dev Use this function internally to get the implementation address.
    */
    function _implementation() internal view virtual override returns (address) {
        return abi.decode(_bytes[____implementation()], (address));
    }

    /**
    * @notice Configures the contract with the provided implementation address.
    * @dev This internal virtual function configures the contract by upgrading to the new implementation address.
    * @param implementation The address of the new implementation.
    * @dev Use this function internally to configure the contract with a new implementation address.
    */
    function _configure(address implementation) internal virtual {
        ConfigurableLite._configure();
        _upgrade(implementation);
    }

    /**
    * @notice Upgrades the contract to the provided implementation address.
    * @dev This internal virtual function performs the upgrade to the new implementation address.
    * @param implementation The address of the new implementation.
    * @dev Use this function internally to upgrade the contract to a new implementation address.
    */
    function _upgrade(address implementation) internal virtual {
        _bytes[____implementation()] = abi.encode(implementation);
        _logUpgrade(implementation);
        emit Upgraded(msg.sender, implementation);
    }

    /**
    * @notice Logs the upgrade by recording the new implementation address in the version history.
    * @dev This internal virtual function records the new implementation address in the version history.
    * @param implementation The address of the new implementation.
    * @dev Use this function internally to log the upgrade in the version history.
    */
    function _logUpgrade(address implementation) internal virtual {
        uint i = _raiseVersion();
        _bytes[____version(i)] = abi.encode(implementation);
    }

    /**
    * @notice Increases the version count and returns the new version number.
    * @dev This internal virtual function increments the version count and returns the new version number.
    * @return The new version number after incrementing.
    * @dev Use this function internally when raising the version during an upgrade.
    */
    function _raiseVersion() internal virtual returns (uint) {
        uint i = abi.decode(_bytes[____versionCount()], (uint));
        i++;
        _bytes[____versionCount()] = abi.encode(i);
        return i;
    }
}