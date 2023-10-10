// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/IProxyStateOwnable.sol";

/**
* version 1.0.0
*
* deprecated =>
*   address "map" string/name
*   stringArray "proxies" "names"
*   addressSet "proxies" "deployed"
*   addressSet "proxies" "supported"
*   addressSet "history" string/name
*
* addressSet "proxies"
* addressSet "active"
* addressSet "implementations" address/account
* addressSet "authorized"
 */
interface ITerminalV2 is IProxyStateOwnable {

    /**
    * @dev Emitted when the proxy contract is deployed and associated with this proposal.
    * 
    * @param account The Ethereum address of the deployed proxy contract.
    */
    event PrxoyDeployedTo(address indexed account);

    /**
    * @dev Emitted when the proxy contract associated with this proposal is successfully upgraded to a new implementation.
    * 
    * @param account The Ethereum address of the upgraded proxy contract.
    * @param implementation The Ethereum address of the new implementation contract.
    */
    event ProxyUpgradedTo(address indexed account, address indexed implementation);

    /**
    * @dev Emitted when a proxy contract is retired, indicating that it is no longer active.
    * 
    * @param account The address of the retired proxy contract.
    */
    event ProxyRetired(address indexed account);

    /**
    * @dev Emitted when a proxy contract is activated, indicating that it is now active.
    * 
    * @param account The address of the activated proxy contract.
    */
    event ProxyActivated(address indexed account);

    /**
    * @dev Emitted when a proxy contract is deactivated, indicating that it is no longer active.
    * 
    * @param account The address of the deactivated proxy contract.
    */
    event ProxyDeactivated(address indexed account);

    /**
    * @dev Emitted when permission is granted to an account.
    *
    * @param account The Ethereum address to which permission is granted.
    */
    event PermissionGranted(address indexed account);

    /**
    * @dev Emitted when permission is revoked from an account.
    *
    * @param account The Ethereum address from which permission is revoked.
    */
    event PermissionRevoked(address indexed account);

    /**
    * @dev Emitted when the contract is reinitialized.
    *
    * This event is emitted when the `update` function is called to reinitialize the contract.
    * It indicates that the contract has been successfully reinitialized.
    */
    event Reinitialized();

    /**
    * @dev Emitted when a low-level call is made to another contract.
    *
    * This event is emitted when the `_call` function is invoked, indicating that a call has been made
    * to the specified contract address with a given function signature and arguments.
    *
    * @param account The address of the target contract that received the call.
    * @param signature The function signature of the call.
    * @param args The arguments passed to the called function.
    */
    event CallTo(address indexed account, string indexed signature, bytes indexed args);

    /**
    * @dev Reverts if an attempt is made to deploy a proxy contract that has already been deployed.
    * 
    * @param account The address of the proxy contract attempting a duplicate deployment.
    */
    error DuplicateDeployment(address account);

    /**
    * @dev Reverts if an operation requires interaction with a proxy contract that has not been deployed.
    * 
    * @param account The address of the undeployed proxy contract.
    */
    error Undeployed(address account);

    /**
    * @dev Reverts if an attempt is made to mark a proxy contract as active when it is already marked as active.
    * 
    * @param account The address of the proxy contract attempting a duplicate activation.
    */
    error DuplicateActive(address account);

    /**
    * @dev Reverts if an operation requires interaction with a proxy contract that is not marked as active.
    * 
    * @param account The address of the inactive proxy contract.
    */
    error Inactive(address account);

    /**
    * @dev Error indicating that the caller is not authorized to perform a certain action.
    * 
    * Parameters:
    * - `account`: The address of the unauthorized caller.
    */
    error Unauthorized(address account);

    /**
    * @dev Error indicating an attempt to grant a permission that has already been granted.
    * 
    * Parameters:
    * - `account`: The address for which the permission duplication is detected.
    */
    error DuplicatePermission(address account);

    /**
    * @dev Error indicating an attempt to revoke a permission that has not been granted.
    * 
    * Parameters:
    * - `account`: The address for which the absence of permission is detected.
    */
    error NoPermission(address account);

    /**
    * @dev Error indicating an attempt to reinitialize a contract that has already been updated.
    */
    error AlreadyReinitialized();

    /**
    * @dev Error indicating that a low-level call to another contract has failed.
    *
    * Emits a {FailedCallTo} event with details about the failed call.
    *
    * Requirements:
    * - The call to the external contract must not be successful.
    */
    error FailedCallTo(address account, string signature, bytes args);

    /**
    * @dev Get the array of deployed proxy contract addresses stored in the AddressSet.
    * 
    * @return An array containing the addresses of deployed proxy contracts.
    */
    function deployed() external view returns (address[] memory);

    /**
    * @dev Get the total number of deployed proxy contracts.
    * 
    * @return The length of the array containing the addresses of all deployed proxy contracts.
    */
    function deployedLength() external view returns (uint256);

   /**
    * @dev Check if a proxy contract is deployed.
    * 
    * @param account The address of the proxy contract to check for deployment status.
    * @return A boolean indicating whether the given proxy contract is deployed.
    */
    function isDeployed(address account) external view returns (bool);

    /**
    * @dev Get the array of addresses representing active elements stored in the AddressSet.
    * 
    * @return An array containing the addresses of active elements.
    */
    function active() external view returns (address[] memory);

    /**
    * @dev Get the number of active elements in the AddressSet.
    * 
    * @return The length of the array containing the addresses of active elements.
    */
    function activeLength() external view returns (uint256);

    /**
    * @dev Check if a specific address is included in the set of active elements.
    * 
    * @param account The address to check for activity.
    * @return `true` if the address is active, otherwise `false`.
    */
    function isActive(address account) external view returns (bool);

    /**
    * @dev Get the array of historical implementations associated with a specific proxy contract.
    * 
    * @param account The address of the proxy contract to query implementations for.
    * @return An array containing the addresses of historical implementations for the given proxy contract.
    */
    function implementations(address account) external view returns (address[] memory);

    /**
    * @dev Get the version count (number of historical implementations) associated with a specific proxy contract.
    * 
    * @param account The address of the proxy contract to query versions for.
    * @return The number of historical implementations associated with the given proxy contract.
    */
    function version(address account) external view returns (uint256);

    /**
    * @notice Retrieves the list of addresses that are currently authorized to perform privileged actions.
    * @return An array containing the addresses of authorized accounts.
    */
    function authorized() external view returns (address[] memory);

    /**
    * @notice Retrieves the total number of addresses currently authorized to perform privileged actions.
    * @return The length of the array containing the addresses of authorized accounts.
    */
    function authorizedLength() external view returns (uint256);

    /**
    * @notice Checks whether a specific address is currently authorized to perform privileged actions.
    * @param account The address to check for authorization.
    * @return `true` if the address is authorized, otherwise `false`.
    */
    function isAuthorized(address account) external view returns (bool);

    /**
    * @notice Updates the contract by granting owner permissions and reinitializing deployed proxies.
    * Only the contract owner can trigger this update, and it can only be executed once.
    * This function is typically used for contract upgrades or important updates.
    * @dev It grants owner permissions, reinitializes deployed proxies, and sets the update status to true.
    * Reverts if the update has already been executed.
    */
    function update() external;

    /**
    * @dev Upgrades the implementation address of the current contract to a new implementation.
    *
    * It checks for authorization, ensures that the contract is not paused, and then invokes the
    * `upgrade` function from the parent contract to perform the upgrade. After the upgrade, it
    * updates the implementation associated with the current contract in the address set of
    * implementations.
    *
    * Emits a {ProxyUpgradedTo} event upon a successful upgrade.
    *
    * @param implementation The address of the new implementation contract.
    *
    * NOTE Here we use upgradeV2 instead of an override because the ProxyStateOwnable should
    *      not be modified or changed. So we settle for multiple ways of executing this function.
    */
    function upgradeV2(address implementation) external;

    /**
    * @dev Upgrades the implementation of an existing proxy contract to a new implementation.
    * 
    * It first checks if the proxy is currently active. If active, it is temporarily deactivated,
    * then the upgrade is performed through the `upgrade` function of the `IProxyStateOwnable` interface.
    * After the upgrade, the proxy is activated again. If the proxy was originally paused, it remains paused.
    * 
    * Emits a {ProxyUpgradedTo} event upon successful upgrade.
    * 
    * @param account The address of the proxy contract to be upgraded.
    * @param implementation The address of the new implementation contract.
    */
    function upgradeTo(address account, address implementation) external;

    /**
    * @dev Upgrades the implementation of multiple existing proxy contracts to new implementations in batch.
    * 
    * For each proxy contract in the given array, it checks if the proxy is currently active. If active,
    * it is temporarily deactivated, then the upgrade is performed through the `upgrade` function
    * of the `IProxyStateOwnable` interface. After the upgrade, the proxy is activated again.
    * If the proxy was originally paused, it remains paused.
    * 
    * Emits a {ProxyUpgradedTo} event for each successful upgrade.
    * 
    * @param accounts An array of addresses representing the proxy contracts to be upgraded.
    * @param implementations An address representing the new implementation contract for all proxies in the batch.
    */
    function upgradeBatchTo(address[] memory accounts, address[] memory implementations) external;

    /**
    * @dev Deploys a new instance of a proxy contract implementing the `IProxyStateOwnable` interface.
    * 
    * It creates a new instance of the proxy contract, initializes it by calling the `initialize` function
    * through the `IProxyStateOwnable` interface, deploys the proxy by adding it to the list of deployed proxies,
    * and activates the proxy if it's not paused by adding it to the list of active proxies.
    * 
    * Emits a {ProxyDeployedTo} event upon successful deployment.
    * Emits a {ProxyActivated} event upon successful activation.
    */
    function deploy() external;

    /**
    * @dev Pauses and retires a deployed proxy contract, removing it from the list of active and deployed proxies.
    * 
    * It first calls the `pause` function on the proxy contract using the `IProxyStateOwnable` interface
    * to pause its functionality, then disactivates the proxy by removing it from the list of active proxies
    * and finally retires the proxy by removing it from the list of deployed proxies.
    * 
    * @param account The address of the proxy contract to be retired.
    * 
    * Emits a {ProxyDisactivated} event upon successful disactivation.
    * Emits a {ProxyRetired} event upon successful retirement.
    */
    function retire(address account) external;

    /**
    * @dev Resumes the functionality of a deployed proxy contract and marks it as active.
    * 
    * It first calls the `unpause` function on the proxy contract using the `IProxyStateOwnable` interface
    * and then activates the proxy by adding it to the list of active proxies.
    * 
    * @param account The address of the proxy contract to be activated.
    * 
    * Emits a {ProxyActivated} event upon successful activation.
    */
    function activate(address account) external;

    /**
    * @notice Grants authorization to an address, allowing it to perform certain privileged actions.
    * @dev This function can only be called by the owner of the contract.
    * @param account The address to be granted authorization.
    * @dev Emits a {PermissionGranted} event upon successful authorization.
    */
    function grant(address account) external;

    /**
    * @notice Revokes authorization from an address, removing its ability to perform certain privileged actions.
    * @dev This function can only be called by the owner of the contract.
    * @param account The address to have its authorization revoked.
    * @dev Emits a {PermissionRevoked} event upon successful revocation.
    */
    function revokeFrom(address account) external;

    /**
    * @notice Revokes the sender's own authorization, removing its ability to perform certain privileged actions.
    * @dev Emits a {PermissionRevoked} event upon successful revocation.
    */
    function renounce() external;

    /**
    * @dev Pauses the functionality of a deployed proxy contract and marks it as inactive.
    * 
    * It first calls the `pause` function on the proxy contract using the `IProxyStateOwnable` interface
    * and then disactivates the proxy by removing it from the list of active proxies.
    * 
    * @param account The address of the proxy contract to be disactivated.
    * 
    * Emits a {ProxyDisactivated} event upon successful disactivation.
    */
    function deactivate(address account) external;

    /**
    * @dev Executes a function on a target contract using a low-level call.
    * @param account The address of the target contract.
    * @param signature The function signature.
    * @param args The encoded arguments for the function call.
    * 
    * Requirements:
    * - The caller must be authorized to execute calls.
    * - The contract must not be paused.
    */
    function call(address account, string memory signature, bytes memory args) external returns (bytes memory);
}