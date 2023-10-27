// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/utils/IConfigurableLite.sol";

interface IFoundation is IConfigurableLite {

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
    function implementation() external view returns (address);

    /**
    * @notice Retrieves the implementation address for a specific version.
    * @dev This function returns the implementation address associated with a given version index.
    * @param i The index of the version for which to retrieve the implementation address.
    * @return The address of the implementation contract for the specified version.
    * @dev Use this function to query the implementation address for a particular version.
    */
    function version(uint i) external view returns (address);

    /**
    * @notice Retrieves the total number of versions available.
    * @dev This function returns the total number of versions available for the contract.
    * @return The total number of versions available.
    * @dev Use this function to query the count of available versions.
    */
    function versionLength() external view returns (uint);

    /**
    * @notice Configures the contract with a new implementation address.
    * @dev This function allows the contract to be configured with a new implementation address.
    * @param implementation The address of the new implementation contract.
    * @dev Use this function to upgrade the contract to a new implementation.
    */
    function configure(address implementation) external;
}