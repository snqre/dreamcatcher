// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

/**
 * @title Role
 * @dev Abstract contract for managing roles with state on the Polygon network.
 * @notice This contract provides functionalities for role management, including role granting, revocation, and role admin assignment.
 * @notice It utilizes the EnumerableSet library to manage sets of addresses efficiently.
 * @dev Roles are identified by unique keys, and each role has an associated admin role.
 * @dev The DEFAULT_ADMIN_ROLE has the highest privileges and is typically set during contract initialization.
 * @dev Admin roles can be changed, and additional roles can be created to grant specific permissions.
 * @dev The contract emits events for role admin changes, role granting, and role revocation.
 * @dev It also includes error codes for unauthorized access, existing role assignment, missing role, and attempts to set an existing role admin.
 */
abstract contract Role is Storage {

    /**
    * @dev Importing the EnumerableSet library for managing sets of addresses.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @dev Importing the EnumerableSet library for managing sets of bytes32 values.
    */
    using EnumerableSet for EnumerableSet.Bytes32Set;

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
    function hash(string memory dat) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(dat));
    }

    /**
    * @dev Public pure function to generate a unique key for the set of available roles.
    * @return bytes32 representing the unique key for the set of available roles.
    */
    function rolesKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("ROLES"));
    }

    /**
    * @dev Public pure function to generate a unique key for a role in the context of storing members.
    * @param role The role for which to generate the key.
    * @return bytes32 representing the unique key for the specified role in the context of storing members.
    */
    function roleKey(bytes32 role) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(role, "MEMBERS"));
    }

    /**
    * @dev Public pure function to generate a unique key for the role admin of a specified role.
    * @param role The role for which to generate the role admin key.
    * @return bytes32 representing the unique key for the role admin of the specified role.
    */
    function roleAdminKey(bytes32 role) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(role, "ROLE_ADMIN"));
    }

    /**
    * @dev Public pure virtual function to generate a unique key for the default admin role.
    * @return bytes32 representing the unique key for the default admin role.
    * @dev This function must be implemented in derived contracts to provide the default admin role key.
    */
    function defaultAdminRoleKey() public pure virtual returns (bytes32) {
        return 0xb4dd7b07910623c7c742febfbc4566bdec285f874faa2742c472acd10e26be29;
    }

    /**
    * @dev Public view function to check if an account has a specified role.
    * @param role The role for which to check.
    * @param account The address of the account to check for the specified role.
    * @return bool indicating whether the account has the specified role.
    */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _addressSet[roleKey(role)].contains(account);
    }

    /**
    * @dev Public view function to retrieve the list of members for a specified role.
    * @param role The role for which to retrieve the members.
    * @return address[] memory representing the array of addresses that have the specified role.
    * @dev This function returns the addresses that have the specified role in the order they were added.
    */
    function members(bytes32 role, uint256 id) public view virtual returns (address) {
        return _addressSet[roleKey(role)].at(id);
    }

    /**
    * @dev Public view virtual function to retrieve the number of members in a role.
    * @param role The role for which to retrieve the number of members.
    * @return uint256 representing the number of members in the specified role.
    */
    function membersLength(bytes32 role) public view virtual returns (uint256) {
        return _addressSet[roleKey(role)].length();
    }

    /**
    * @dev Public view function to retrieve the list of roles available.
    * @return bytes32[] memory representing the array of roles.
    * @dev This function returns the roles in the order they were added.
    */
    function roles(uint256 id) public view virtual returns (bytes32) {
        return _bytes32Set[rolesKey()].at(id);
    }

    /**
    * @dev Public view virtual function to retrieve the number of roles.
    * @return uint256 representing the number of roles.
    */
    function rolesLength() public view virtual returns (uint256) {
        return _bytes32Set[rolesKey()].length();
    }

    /**
    * @dev Public function to require that the calling account has a specified role.
    * @param role The role that the account must have.
    * @param account The address of the account to check for the specified role.
    * @dev If the account does not have the required role, it reverts with the "Unauthorized" error.
    */
    function requireRole(bytes32 role, address account) public view virtual {
        if (!hasRole(defaultAdminRoleKey(), msg.sender)) {
            if (!hasRole(role, account)) {
                revert Unauthorized(account, role);
            }
        }
    }

    /**
    * @dev Public view function to retrieve the admin role for a specified role.
    * @param role The role for which to retrieve the admin role.
    * @return bytes32 representing the admin role for the specified role.
    */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _bytes32[roleAdminKey(role)];
    }

    /**
    * @dev Public function to grant a role to a specified account.
    * @param role The role to be granted.
    * @param account The address of the account to which the role will be granted.
    * @dev This function can only be called by a role admin.
    * @dev It grants the specified role to the specified account and emits the RoleGranted event.
    */
    function grantRole(bytes32 role, address account) public virtual {
        _onlyRoleAdmin(role);
        _grantRole(role, account);
    }

    /**
    * @dev Public function to revoke a role from a specified account.
    * @param role The role to be revoked.
    * @param account The address of the account from which the role will be revoked.
    * @dev This function can only be called by a role admin.
    * @dev It revokes the specified role from the specified account and emits the RoleRevoked event.
    */
    function revokeRole(bytes32 role, address account) public virtual {
        _onlyRoleAdmin(role);
        _revokeRole(role, account);
    }

    /**
    * @dev Public function to set a new role admin for a specified role.
    * @param role The role for which the admin is being set.
    * @param newRoleAdmin The new role admin address.
    * @dev This function can only be called by the default admin role.
    * @dev It sets the new role admin and emits the RoleAdminChanged event.
    */
    function setRoleAdmin(bytes32 role, bytes32 newRoleAdmin) public virtual {
        _onlyDefaultAdminRole();
        _setRoleAdmin(role, newRoleAdmin);
    }

    /**
    * @dev Internal view function to check if the sender has the role admin privilege.
    * @param role The role for which the admin privilege is being checked.
    * @dev If the sender does not have the DEFAULT_ADMIN_ROLE, it checks if the sender has the role admin privilege.
    * @dev If the sender does not have the role admin privilege, it reverts with the IsNotRoleAdmin error.
    */
    function _onlyRoleAdmin(bytes32 role) internal view virtual {
        if (!hasRole(defaultAdminRoleKey(), msg.sender)) {
            require(hasRole(getRoleAdmin(role), msg.sender), "Role: !hasRole()");
        }
    }

    /**
    * @dev Internal view function to check if the sender has the DEFAULT_ADMIN_ROLE.
    * @dev If the sender does not have the DEFAULT_ADMIN_ROLE, it reverts with the Unauthorized error.
    */
    function _onlyDefaultAdminRole() internal view virtual {
        require(hasRole(defaultAdminRoleKey(), msg.sender), "Role: is not default admin");
    }

    /**
    * @dev Internal virtual function to grant DEFAULT_ADMIN_ROLE to the contract deployer during initialization.
    * 0xb4dd7b07910623c7c742febfbc4566bdec285f874faa2742c472acd10e26be29
    */
    function _initialize() internal virtual {
        _grantRole(roleKey(hash("DEFAULT_ADMIN_ROLE")), msg.sender);
    }

    /**
    * @dev Internal function to set a new role admin for the given role.
    * @param role The role for which to set a new admin.
    * @param newRoleAdmin The address of the new admin for the role.
    * @dev This function checks if the new admin is the same as the current one and reverts if so.
    * @dev It updates the role admin in storage and emits the `RoleAdminChanged` event.
    */
    function _setRoleAdmin(bytes32 role, bytes32 newRoleAdmin) internal virtual {
        require(getRoleAdmin(role) != newRoleAdmin, "Role: is already role admin");
        bytes32 oldAdminRole = _bytes32[roleAdminKey(role)];
        _bytes32[roleAdminKey(role)] = newRoleAdmin;
        emit RoleAdminChanged(role, oldAdminRole, newRoleAdmin);
    }

    /**
    * @dev Internal function to grant a role to an account.
    * @param role The role to grant.
    * @param account The address to grant the role to.
    * @dev This function checks if the account already has the role and reverts if so.
    * @dev It adds the account to the role set in storage and emits the `RoleGranted` event.
    */
    function _grantRole(bytes32 role, address account) internal virtual {
        require(!hasRole(role, account), "Role: already has role");
        _addressSet[roleKey(role)].add(account);
        _addRole(role);
        emit RoleGranted(role, account, msg.sender);
    }

    /**
    * @dev Internal function to revoke a role from an account.
    * @param role The role to revoke.
    * @param account The address to revoke the role from.
    * @dev This function checks if the account already has the role and reverts if not.
    * @dev It removes the account from the role set in storage and emits the `RoleRevoked` event.
    */
    function _revokeRole(bytes32 role, address account) internal virtual {
        require(hasRole(role, account), "Role: does not have role");
        _addressSet[roleKey(role)].remove(account);
        _subRole(role);
        emit RoleRevoked(role, account, msg.sender);
    }

    /**
    * @dev Internal function to add a new role to the list of available roles.
    * @param role The role to be added.
    * @dev This function checks if the role has at least one member and adds it to the roles set.
    */
    function _addRole(bytes32 role) internal virtual {
        if (membersLength(role) >= 1) {
            _bytes32Set[rolesKey()].add(role);
        }
    }

    /**
    * @dev Internal function to remove a role from the list of available roles.
    * @param role The role to be removed.
    * @dev This function checks if the role has no members and removes it from the roles set.
    */
    function _subRole(bytes32 role) internal virtual {
        if (membersLength(role) == 0) {
            _bytes32Set[rolesKey()].remove(role);
        }
    }
}