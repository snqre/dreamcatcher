// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/ProxyStateOwnableContract.sol";
import "contracts/polygon/interfaces/IProxyStateOwnable.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

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
contract TerminalV2 is ProxyStateOwnableContract {

    /**
    * @dev Import the functionality of the EnumerableSet library for managing unique sets of addresses.
    * This allows convenient use of EnumerableSet functions directly on instances of AddressSet.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @dev Modifier that ensures the function is only callable by authorized addresses.
    * Reverts if the message sender is not authorized.
    */
    modifier onlyAuthorized() {
        _onlyAuthorized();
        _;
    }

    /**
    * @dev Emitted when the proxy contract is deployed and associated with this proposal.
    * 
    * @param account The Ethereum address of the deployed proxy contract.
    */
    event ProxyDeployedTo(address indexed account);

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
    function deployed() public view returns (address[] memory) {
        return _addressSet[keccak256(abi.encode("proxies"))].values();
    }

    /**
    * @dev Get the total number of deployed proxy contracts.
    * 
    * @return The length of the array containing the addresses of all deployed proxy contracts.
    */
    function deployedLength() public view returns (uint256) {
        return _addressSet[keccak256(abi.encode("proxies"))].length();
    }

    /**
    * @dev Check if a proxy contract is deployed.
    * 
    * @param account The address of the proxy contract to check for deployment status.
    * @return A boolean indicating whether the given proxy contract is deployed.
    */
    function isDeployed(address account) public view returns (bool) {
        return _addressSet[keccak256(abi.encode("proxies"))].contains(account);
    }

    /**
    * @dev Get the array of addresses representing active elements stored in the AddressSet.
    * 
    * @return An array containing the addresses of active elements.
    */
    function active() public view returns (address[] memory) {
        return _addressSet[keccak256(abi.encode("active"))].values();
    }

    /**
    * @dev Get the number of active elements in the AddressSet.
    * 
    * @return The length of the array containing the addresses of active elements.
    */
    function activeLength() public view returns (uint256) {
        return _addressSet[keccak256(abi.encode("active"))].length();
    }

    /**
    * @dev Check if a specific address is included in the set of active elements.
    * 
    * @param account The address to check for activity.
    * @return `true` if the address is active, otherwise `false`.
    */
    function isActive(address account) public view returns (bool) {
        return _addressSet[keccak256(abi.encode("active"))].contains(account);
    }

    /**
    * @dev Get the array of historical implementations associated with a specific proxy contract.
    * 
    * @param account The address of the proxy contract to query implementations for.
    * @return An array containing the addresses of historical implementations for the given proxy contract.
    */
    function implementations(address account) public view returns (address[] memory) {
        return _addressSet[keccak256(abi.encode("implementations", account))].values();
    }

    /**
    * @dev Get the version count (number of historical implementations) associated with a specific proxy contract.
    * 
    * @param account The address of the proxy contract to query versions for.
    * @return The number of historical implementations associated with the given proxy contract.
    */
    function version(address account) public view returns (uint256) {
        return _addressSet[keccak256(abi.encode("implementations", account))].length();
    }

    /**
    * @notice Retrieves the list of addresses that are currently authorized to perform privileged actions.
    * @return An array containing the addresses of authorized accounts.
    */
    function authorized() public view returns (address[] memory) {
        return _addressSet[keccak256(abi.encode("authorized"))].values();
    }

    /**
    * @notice Retrieves the total number of addresses currently authorized to perform privileged actions.
    * @return The length of the array containing the addresses of authorized accounts.
    */
    function authorizedLength() public view returns (uint256) {
        return _addressSet[keccak256(abi.encode("authorized"))].length();
    }

    /**
    * @notice Checks whether a specific address is currently authorized to perform privileged actions.
    * @param account The address to check for authorization.
    * @return `true` if the address is authorized, otherwise `false`.
    */
    function isAuthorized(address account) public view returns (bool) {
        return _addressSet[keccak256(abi.encode("authorized"))].contains(account);
    }

    /**
    * @notice Updates the contract by granting owner permissions and reinitializing deployed proxies.
    * Only the contract owner can trigger this update, and it can only be executed once.
    * This function is typically used for contract upgrades or important updates.
    * @dev It grants owner permissions, reinitializes deployed proxies, and sets the update status to true.
    * Reverts if the update has already been executed.
    */
    function update() public onlyOwner whenNotPaused() {
        if (_bool[keccak256(abi.encode("updated"))]) { revert AlreadyReinitialized(); }
        _grant(owner());
        EnumerableSet.AddressSet storage oldDeployedProxies = _addressSet[keccak256(abi.encode("proxies", "deployed"))];
        for (uint i = 0; i < oldDeployedProxies.length(); i++) {
            _deploy(oldDeployedProxies.at(i));
        }
        _bool[keccak256(abi.encode("updated"))] = true;
        
        emit Reinitialized();
    }
    
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
    function upgradeV2(address implementation) public onlyAuthorized() whenNotPaused() {
        _upgrade(implementation);
        _upgradeTo(address(this), implementation);
    }

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
    function upgradeTo(address account, address implementation) public onlyAuthorized() whenNotPaused() {
        IProxyStateOwnable deployedInterface = IProxyStateOwnable(account);
        if (!deployedInterface.paused()) {
            deactivate(account);
            deployedInterface.upgrade(implementation);
            activate(account);
        }
        else {
            deployedInterface.upgrade(implementation);
        }
        _upgradeTo(account, implementation);
    }

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
    function upgradeBatchTo(address[] memory accounts, address[] memory implementations) public onlyAuthorized() whenNotPaused() {
        for (uint256 i = 0; i < accounts.length; i++) {
            IProxyStateOwnable deployedInterface = IProxyStateOwnable(accounts[i]);
            if (!deployedInterface.paused()) {
                deactivate(accounts[i]);
                deployedInterface.upgrade(implementations[i]);
                activate(accounts[i]);
            }
            else {
                deployedInterface.upgrade(implementations[i]);
            }
            _upgradeTo(accounts[i], implementations[i]);
        }
    }

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
    function deploy() public onlyAuthorized() whenNotPaused() {
        address deployed = address(new ProxyStateOwnableContract());
        IProxyStateOwnable deployedInterface = IProxyStateOwnable(deployed);
        deployedInterface.initialize();
        _deploy(deployed);
        if (!deployedInterface.paused()) { _activate(deployed); }
    }

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
    function retire(address account) public onlyAuthorized() whenNotPaused() {
        deactivate(account);
        _retire(account);
    }

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
    function activate(address account) public onlyAuthorized() whenNotPaused() {
        IProxyStateOwnable deployedInterface = IProxyStateOwnable(account);
        deployedInterface.unpause();
        _activate(account);
    }

    /**
    * @notice Grants authorization to an address, allowing it to perform certain privileged actions.
    * @dev This function can only be called by the owner of the contract.
    * @param account The address to be granted authorization.
    * @dev Emits a {PermissionGranted} event upon successful authorization.
    */
    function grant(address account) public onlyOwner() whenNotPaused() {
        _grant(account);
    }

    /**
    * @notice Revokes authorization from an address, removing its ability to perform certain privileged actions.
    * @dev This function can only be called by the owner of the contract.
    * @param account The address to have its authorization revoked.
    * @dev Emits a {PermissionRevoked} event upon successful revocation.
    */
    function revokeFrom(address account) public onlyOwner() {
        _revoke(account);
    }

    /**
    * @notice Revokes the sender's own authorization, removing its ability to perform certain privileged actions.
    * @dev Emits a {PermissionRevoked} event upon successful revocation.
    */
    function renounce() public whenNotPaused() {
        _revoke(msg.sender);
    }

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
    function deactivate(address account) public onlyAuthorized() whenNotPaused() {
        IProxyStateOwnable deployedInterface = IProxyStateOwnable(account);
        deployedInterface.pause();
        _deactivate(account);
    }

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
    function call(address account, string memory signature, bytes memory args) public onlyAuthorized() whenNotPaused() returns (bytes memory) {
        return _call(account, signature, args);
    }

    /** Flags. */
    
    /**
    * @dev Modifier that restricts function execution to authorized users.
    * 
    * Requirements:
    * - The sender must be an authorized user; otherwise, it reverts with an "Unauthorized" error message,
    *   including the address of the unauthorized sender.
    */
    function _onlyAuthorized() internal view {
        if (!isAuthorized(msg.sender)) { revert Unauthorized(msg.sender); }
    }

    /**
    * @dev Deploys a new proxy contract and adds it to the list of deployed proxies.
    * 
    * @param account The address of the newly deployed proxy contract.
    * 
    * Emits a {ProxyDeployedTo} event upon successful deployment.
    * 
    * Reverts if an attempt is made to deploy a proxy contract that is already deployed.
    */
    function _deploy(address account) internal {
        if (isDeployed(account)) { revert DuplicateDeployment(account); }
        _addressSet[keccak256(abi.encode("proxies"))].add(account);
        emit ProxyDeployedTo(account);
    }

    /**
    * @dev Retires a deployed proxy contract by removing it from the list of deployed proxies.
    * 
    * @param account The address of the proxy contract to be retired.
    * 
    * Emits a {ProxyRetired} event upon successful retirement.
    * 
    * Reverts if an attempt is made to retire a proxy contract that is not deployed.
    */
    function _retire(address account) internal {
        if (!isDeployed(account)) { revert Undeployed(account); }
        _addressSet[keccak256(abi.encode("proxies"))].remove(account);
        emit ProxyRetired(account);   
    }

    /**
    * @dev Activates a deployed proxy contract by adding it to the list of active proxies.
    * 
    * @param account The address of the proxy contract to be activated.
    * 
    * Emits a {ProxyActivated} event upon successful activation.
    * 
    * Reverts if an attempt is made to activate a proxy contract that is already active.
    */
    function _activate(address account) internal {
        if (!isDeployed(account)) { revert DuplicateDeployment(account); }
        if (isActive(account)) { revert DuplicateActive(account); }
        _addressSet[keccak256(abi.encode("proxies"))].add(account);
        emit ProxyActivated(account);
    }

    /**
    * @dev Deactivates an active proxy contract by removing it from the list of active proxies.
    * 
    * @param account The address of the proxy contract to be deactivated.
    * 
    * Emits a {ProxyDisactivated} event upon successful deactivation.
    * 
    * Reverts if an attempt is made to deactivate a proxy contract that is already inactive.
    */
    function _deactivate(address account) internal {
        if (!isDeployed(account)) { revert DuplicateDeployment(account); }
        if (!isActive(account)) { revert Inactive(account); }
        _addressSet[keccak256(abi.encode("proxies"))].remove(account);
        emit ProxyDeactivated(account);
    }

    /**
    * @dev Upgrades the implementation address of a deployed proxy contract by adding the new implementation
    * to the list of implementations associated with the proxy.
    * 
    * @param account The address of the proxy contract to be upgraded.
    * @param implementation The address of the new implementation contract.
    * 
    * Emits a {ProxyUpgradedTo} event upon successful upgrade.
    */
    function _upgradeTo(address account, address implementation) internal {
        if (!isDeployed(account)) { revert DuplicateDeployment(account); }
        _addressSet[keccak256(abi.encode("implementations", account))].add(implementation);
        emit ProxyUpgradedTo(account, implementation);
    }

    /**
    * @notice Adds an address to the set of authorized addresses.
    * @dev This function checks for duplicate authorization and emits an event upon successful addition.
    * @param account The address to be granted authorization.
    * @dev Reverts if the provided address is already authorized.
    */
    function _grant(address account) internal {
        if (isAuthorized(account)) { revert DuplicatePermission(account); }
        _addressSet[keccak256(abi.encode("authorized"))].add(account);
        emit PermissionGranted(account);
    }

    /**
    * @notice Removes an address from the set of authorized addresses.
    * @dev This function checks for existing authorization and emits an event upon successful removal.
    * @param account The address to be revoked of authorization.
    * @dev Reverts if the provided address is not already authorized.
    */
    function _revoke(address account) internal {
        if (!isAuthorized(account)) { revert NoPermission(account); }
        _addressSet[keccak256(abi.encode("authorized"))].remove(account);
        emit PermissionRevoked(account);
    }

    /**
    * @dev Executes a low-level call to a target contract.
    * @param account The address of the target contract.
    * @param signature The function signature.
    * @param args The encoded arguments for the function call.
    * @return The result of the contract call.
    * 
    * Requirements:
    * - The call must succeed; otherwise, it reverts with an error message.
    * 
    * Emits a {CallTo} event after a successful call.
    */
    function _call(address account, string memory signature, bytes memory args) internal returns (bytes memory) {
        bytes4 selector = bytes4(keccak256(bytes(signature)));
        (bool success, bytes memory result) = account.call(abi.encodePacked(selector, args));
        if (!success) { revert FailedCallTo(account, signature, args); }
        emit CallTo(account, signature, args);
        return result;
    }
}