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
- `_grantRole(bytes32 role, address account)`
- `_revokeRole(bytes32 role, address account)`
- `addRole(string role)`
- `setRoleMin(string role, uint newMin)`
- `setRoleMax(string role, uint newMax)`
- `setRoleHasMinEnabled(string role, bool newSetting)`
- `setRoleHasMaxEnabled(string role, bool newSetting)`