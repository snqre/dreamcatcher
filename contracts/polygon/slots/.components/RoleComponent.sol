// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

library RoleComponent {
    using EnumerableSet for EnumerableSet.AddressSet;

    event RoleNameAssigned(string oldName, string newName);
    event RoleMemberAdded(string name, address account);
    event RoleMemberRemoved(string name, address account);

    struct Role {
        string _name;
        EnumerableSet.AddressSet _members;
        bool _hasMinLength;
        bool _hasMaxLength;
        uint _minLength;
        uint _maxLength;
    }

    function name(Role storage role) internal view returns (string memory) {
        return role._name;
    }

    function members(Role storage role, uint i) internal view returns (address) {
        return role._members.at(i);
    }

    function members(Role storage role) internal view returns (address[] memory) {
        return role._members.values();
    }

    function membersLength(Role storage role) internal view returns (uint) {
        return role._members.length();
    }

    function membersContains(Role storage role, address account) internal view returns (bool) {
        return role._members.contains(account);
    }

    function hasMinLength(Role storage role) internal view returns (bool) {
        return role._hasMin;
    }

    function hasMaxLength(Role storage role) internal view returns (bool) {
        return role._hasMax;
    }

    function minLength(Role storage role) internal view returns (uint) {
        return role._minLength;
    }

    function maxLength(Role storage role) internal view returns (uint) {
        return role._maxLength;
    }

    function tryAuthenticate(Role storage role) internal view returns (bool) {
        if (role._members.length != 0) { 
            authenticate(role); 
        }
        return true;
    }

    function authenticate(Role storage role) internal view returns (bool) {
        require(role._members.contains(msg.sender), "RoleComponent: unauthorized");
        return true;
    }

    function setName(Role storage role, string memory name) internal returns (bool) {
        string memory oldName = name(role);
        role._name = name;
        emit RoleNameAssigned(oldName, name);
        return true;
    }

    function addMember(Role storage role, address account) internal returns (bool) {
        role._members.add(account);
        if (hasMaxLength(role)) {
            require(membersLength(role) <= maxLength(role), "RoleComponent: max length exceeded");
        }
        emit RoleMemberAdded(name(role), account);
        return true;
    }

    function removeMember(Role storage role, address account) internal returns (bool) {
        role._members.remove(account);
        if (hasMinLength(role)) {
            require(membersLength(role) >= minLength(role), "RoleComponent: min length exceeded");
        }
        emit RoleMemberRemoved(name(role), account);
        return true;
    }
}