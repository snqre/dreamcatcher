# AccessControl
- `onlyRole(bytes32)`
- `supportsInterface(bytes4 interfaceId)`
- `hasRole(bytes32 role, address account)`
- `_checkRole(bytes32 role)`
- `_checkRole(bytes32 role, address account)`
- `getRoleAdmin(bytes32 role)`
- `grantRole(bytes32 role, address account)`
- `revokeRole(bytes32 role, address account)`
- `renounceRole(bytes32 role, address account)`
- `_setRoleAdmin(bytes32 role, bytes32 adminRole)`
- `_grantRole(bytes32 role, address account)`
- `_revokeRole(bytes32 role, address account)`

# AccessControlEnumerable
- `supportsInterface(bytes4 interfaceId)`
- `getRoleMember(bytes32 role, uint256 index)`
- `getRoleMemberCount(bytes32 role)`
- `_grantRole(bytes32 role, address account)`
- `_revokeRole(bytes32 role, address account)`

# Authenticator
- `_grantRole(bytes32 role, address account)` internal
- `_revokeRole(bytes32 role, address account)`: internal
- `addRole(string role)`: onlyRole(DEFAULT_ADMIN_ROLE)
- `setRoleMin(string role, uint newMin)`: onlyRole(DEFAULT_ADMIN_ROLE)
- `setRoleMax(string role, uint newMax)`: onlyRole(DEFAULT_ADMIN_ROLE)
- `setRoleHasMinEnabled(string role, bool newSetting)`: onlyRole(DEFAULT_ADMIN_ROLE)
- `setRoleHasMaxEnabled(string role, bool newSetting)`: onlyRole(DEFAULT_ADMIN_ROLE)