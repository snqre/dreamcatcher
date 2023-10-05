// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/libraries/__Shared.sol";
import "contracts/polygon/ProxyStateOwnableContract.sol";

contract RoleV1 is ProxyStateOwnableContract {
    using EnumerableSet for EnumerableSet.AddressSet;

    modifier onlyWhenInitializedRoleV1() {
        _onlyWhenInitializedRoleV1();
        _;
    }

    modifier onlynotInitializedRoleV1() {
        _onlynotInitializedRoleV1();
        _;
    }

    /**
    * @notice Retrieves the members associated with a specific role.
    * @dev This function allows you to get the addresses of members assigned to a particular role.
    * @param role The role identifier (usually obtained through keccak256) for which to retrieve the members.
    * @return An array of addresses representing the members of the specified role.
    * @dev The returned array provides the addresses of all members assigned to the given role.
    * @dev It uses an internal mapping `_addressSet` to store AddressSet instances associated with each role.
    * @dev The members are retrieved using the `values()` method of the AddressSet.
    * @dev The `values()` method returns an array of addresses stored in the set.
    * @dev If no members are assigned to the role, an empty array will be returned.
    * @dev Ensure that the role identifier is generated consistently using keccak256 for accurate retrieval.
    * @dev Example usage: `members(keccak256("ADMIN_ROLE"))`.
    */
    function members(bytes32 role) public view returns (address[] memory) {
        EnumerableSet.AddressSet memory members
        = _addressSet[keccak256(abi.encode("role", role))];
        return members.values();
    }

    /**
    * @notice Retrieves the number of members associated with a specific role.
    * @dev This function allows you to get the count of members assigned to a particular role.
    * @param role The role identifier (usually obtained through keccak256) for which to retrieve the member count.
    * @return An unsigned integer representing the number of members assigned to the specified role.
    * @dev The member count is obtained by querying the length of the AddressSet associated with the given role.
    * @dev The `length()` method of the AddressSet returns the count of unique addresses stored in the set.
    * @dev If no members are assigned to the role, the function returns 0.
    * @dev Ensure that the role identifier is generated consistently using keccak256 for accurate retrieval.
    * @dev Example usage: `roleLength(keccak256("ADMIN_ROLE"))`.
    */
    function roleLength(bytes32 role) public view returns (uint256) {
        EnumerableSet.AddressSet memory members
        = _addressSet[keccak256(abi.encode("role", role))];
        return members.length();
    }

    /**
    * @notice Checks if an account is assigned to a specific role.
    * @dev This function allows you to determine whether a given account is assigned to a particular role.
    * @param account The Ethereum address of the account to check for role assignment.
    * @param role The role identifier (usually obtained through keccak256) for which to check the account assignment.
    * @return A boolean indicating whether the specified account is assigned to the given role.
    * @dev The account assignment is checked by verifying if the AddressSet associated with the role contains the account.
    * @dev Ensure that the role identifier is generated consistently using keccak256 for accurate verification.
    * @dev Example usage: `isRole(msg.sender, keccak256("ADMIN_ROLE"))`.
    */
    function isRole(address account, bytes32 role) public view returns (bool) {
        EnumerableSet.AddressSet memory members
        = _addressSet[keccak256(abi.encode("role", role))];
        return members.contains(account);
    }
    
    function canGrantRole(bytes32 role, bytes32 grantableRole) public view returns (bool) {
        EnumerableSet.AddressSet memory grantableRoles
        = _addressSet[keccak256(abi.encode("role", role))];
        return grantableRoles.contains(grantableRole);
    }

    /**
    * @notice Modifier to restrict access to a function based on the presence of a specified role.
    * @dev Use this modifier to ensure that only accounts with the specified role can execute the function.
    * @param account The address of the account whose possession of the specified role is checked.
    * @param role The role identifier (usually obtained through keccak256) that grants access to the function.
    * @dev Reverts if the specified account does not possess the required role.
    * @dev Ensure that the role identifier is generated consistently using keccak256 for accurate verification.
    * @dev Example usage: `onlyRole(msg.sender, keccak256("MODERATOR_ROLE"))`.
    */
    function onlyRole(address account, bytes32 role) public view {
        require(isRole(account, role), "RoleV1: account !isRole()");
    }

    /**
    * @notice Modifier to restrict access to a function based on the absence of a specified role.
    * @dev Use this modifier to ensure that only accounts without the specified role can execute the function.
    * @param account The address of the account whose lack of possession of the specified role is checked.
    * @param role The role identifier (usually obtained through keccak256) that should be absent for access to the function.
    * @dev Reverts if the specified account possesses the required role.
    * @dev Ensure that the role identifier is generated consistently using keccak256 for accurate verification.
    * @dev Example usage: `onlynotRole(msg.sender, keccak256("BANNED_ROLE"))`.
    */
    function onlynotRole(address account, bytes32 role) public view {
        require(!isRole(account, role), "RoleV1: account isRole()");
    }

    /**
    * @notice View function to check the initialization status of RoleV1 contract.
    * @dev Use this function to query whether the RoleV1 contract has been initialized.
    * @return A boolean indicating the initialization status. `true` if initialized, `false` otherwise.
    * @dev Example usage: `bool isInitialized = initializedRoleV1();`.
    */
    function initializedRoleV1() public view returns (bool) {
        return _bool[keccak256(abi.encode("initializedRoleV1"))];
    }

    function initializeRoleV1() public onlynotInitializedRoleV1() {
        _grant(address(this), keccak256(abi.encode("admin")));
        _bool[keccak256(abi.encode("initializedRoleV1"))] = true;
    }

    function allowGrantRole(bytes32 role, bytes32 role) public onlyWhenInitializedRoleV1() {

    }

    function disallowGrantRole(bytes32 role, bytes32 role) public onlyWhenInitializedRoleV1() {

    }

    function _onlyWhenInitializedRoleV1() internal view {
        require(initializedRoleV1(), "RoleV1: !initializedRoleV1()");
    }

    function _onlynotInitializedRoleV1() internal view {
        require(!initializedRoleV1(), "RoleV1: initializedRoleV1()");
    }

    /** Internal. */

    function _grant(address account, bytes32 role) internal {
        
        require(!isRole(account, role), "RoleV1: account already isRole()");
        EnumerableSet.AddressSet memory members
        = _addressSet[keccak256(abi.encode("role", role))];
        members.add(account);
    }

    function _revoke(address account, bytes32 role) internal {
        require(isRole(account, role), "RoleV1: account already !isRole()");
        EnumerableSet.AddressSet memory members
        = _addressSet[keccak256(abi.encode("role", role))];
        members.remove(account);
    }
}