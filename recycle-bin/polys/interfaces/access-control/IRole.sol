// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IRole {

    /**
    * @dev Emitted when the admin role of a role is changed.
    * @param role The role for which the admin role is changed.
    * @param oldAdminRole The previous admin role of the specified role.
    * @param newAdminRole The new admin role assigned to the specified role.
    */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed oldAdminRole, bytes32 indexed newAdminRole);

    /**
    * @dev Emitted when an account is granted a role.
    * @param role The role that is granted.
    * @param account The address that is granted the role.
    * @param sender The address initiating the role grant.
    */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
    * @dev Emitted when an account has a role revoked.
    * @param role The role that is revoked.
    * @param account The address that has the role revoked.
    * @param sender The address initiating the role revocation.
    */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
    * @dev Reverts with "Unauthorized" error if an account lacks the required role.
    * @param account The address that lacks the required role.
    * @param roleRequired The required role that is missing.
    */
    error Unauthorized(address account, bytes32 roleRequired);

    /**
    * @dev Public pure function to compute the keccak256 hash of a given string.
    * @param dat The input string to hash.
    * @return bytes32 representing the keccak256 hash of the input string.
    */
    function hash(string memory dat) external pure returns (bytes32);

    /**
    * @dev Public pure function to generate a unique key for the set of available roles.
    * @return bytes32 representing the unique key for the set of available roles.
    */
    function rolesKey() external pure returns (bytes32);

    /**
    * @dev Public pure function to generate a unique key for a role in the context of storing members.
    * @param role The role for which to generate the key.
    * @return bytes32 representing the unique key for the specified role in the context of storing members.
    */
    function roleKey(bytes32 role) external pure returns (bytes32);

    /**
    * @dev Public pure function to generate a unique key for the role admin of a specified role.
    * @param role The role for which to generate the role admin key.
    * @return bytes32 representing the unique key for the role admin of the specified role.
    */
    function roleAdminKey(bytes32 role) external pure returns (bytes32);

    /**
    * @dev Public pure virtual function to generate a unique key for the default admin role.
    * @return bytes32 representing the unique key for the default admin role.
    * @dev This function must be implemented in derived contracts to provide the default admin role key.
    */
    function defaultAdminRoleKey() external pure returns (bytes32);

    /**
    * @dev Public view function to check if an account has a specified role.
    * @param role The role for which to check.
    * @param account The address of the account to check for the specified role.
    * @return bool indicating whether the account has the specified role.
    */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
    * @dev Public view function to retrieve the list of members for a specified role.
    * @param role The role for which to retrieve the members.
    * @return address[] memory representing the array of addresses that have the specified role.
    * @dev This function returns the addresses that have the specified role in the order they were added.
    */
    function members(bytes32 role, uint256 id) external view returns (address);

    /**
    * @dev Public view virtual function to retrieve the number of members in a role.
    * @param role The role for which to retrieve the number of members.
    * @return uint256 representing the number of members in the specified role.
    */
    function membersLength(bytes32 role) external view returns (uint256);

    /**
    * @dev Public view function to retrieve the list of roles available.
    * @return bytes32[] memory representing the array of roles.
    * @dev This function returns the roles in the order they were added.
    */
    function roles(uint256 id) external view returns (bytes32);

    /**
    * @dev Public view virtual function to retrieve the number of roles.
    * @return uint256 representing the number of roles.
    */
    function rolesLength() external view returns (uint256);

    /**
    * @dev Public function to require that the calling account has a specified role.
    * @param role The role that the account must have.
    * @param account The address of the account to check for the specified role.
    * @dev If the account does not have the required role, it reverts with the "Unauthorized" error.
    */
    function requireRole(bytes32 role, address account) external view;

    /**
    * @dev Public view function to retrieve the admin role for a specified role.
    * @param role The role for which to retrieve the admin role.
    * @return bytes32 representing the admin role for the specified role.
    */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
    * @dev Public function to grant a role to a specified account.
    * @param role The role to be granted.
    * @param account The address of the account to which the role will be granted.
    * @dev This function can only be called by a role admin.
    * @dev It grants the specified role to the specified account and emits the RoleGranted event.
    */
    function grantRole(bytes32 role, address account) external;

    /**
    * @dev Public function to revoke a role from a specified account.
    * @param role The role to be revoked.
    * @param account The address of the account from which the role will be revoked.
    * @dev This function can only be called by a role admin.
    * @dev It revokes the specified role from the specified account and emits the RoleRevoked event.
    */
    function revokeRole(bytes32 role, address account) external;

    /**
    * @dev Public function to set a new role admin for a specified role.
    * @param role The role for which the admin is being set.
    * @param newRoleAdmin The new role admin address.
    * @dev This function can only be called by the default admin role.
    * @dev It sets the new role admin and emits the RoleAdminChanged event.
    */
    function setRoleAdmin(bytes32 role, bytes32 newRoleAdmin) external;
}