// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

/// reusable for multiple roles
library RoleComponent {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// name of the role should be set on deployment to help identify them
    event RoleNameSet(string oldName, string newName);
    event RoleMemberAdded(string name, address account);
    event RoleMemberRemoved(string name, address account);
    event RoleMinLengthEnabled(string name);
    event RoleMinLengthDisabled(string name);
    event RoleMinLengthSet(string name, uint oldMinLength, uint newMinLength);
    event RoleMaxLengthEnabled(string name);
    event RoleMaxLengthDisabled(string name);
    event RoleMaxLengthSet(string name, uint oldMaxLength, uint newMaxLength);

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
        _setName(role, name);
        emit RoleNameSet(oldName, name);
        return true;
    }

    function addMember(Role storage role, address account) internal returns (bool) {
        _addMember(role, account);
        emit RoleMemberAdded(name(role), account);
        return true;
    }

    function removeMember(Role storage role, address account) internal returns (bool) {
        _removeMember(role, account);
        emit RoleMemberRemoved(name(role), account);
        return true;
    }

    function enableMinLength(Role storage role) internal returns (bool) {
        _enableMinLength(role, account);
        emit RoleMinLengthEnabled(name(role));
        return true;
    }

    function disableMinLength(Role storage role) internal returns (bool) {
        _disableMinLength(role, account);
        emit RoleMinLengthDisabled(name(role));
        return true;
    }

    function setMinLength(Role storage role, uint minLength) internal returns (bool) {
        uint oldMinLength = minLength(role);
        _setMinLength(role, minLength);
        emit RoleMinLengthSet(name(role), oldMinLength, minLength);
        return true;
    }

    function enableMaxLength(Role storage role) internal returns (bool) {
        _enableMaxLength(role, account);
        emit RoleMaxLengthEnabled(name(role));
        return true;
    }

    function disableMaxLength(Role storage role) internal returns (bool) {
        _disableMaxLength(role, account);
        emit RoleMaxLengthDisabled(name(role));
        return true;
    }

    function setMaxLength(Role storage role, uint maxLength) internal returns (bool) {
        uint oldMaxLength = maxLength(role);
        _setMaxLength(role, maxLength);
        emit RoleMaxLengthSet(name(role), oldMaxLength, maxLength);
        return true;
    }

    function _setName(Role storage role, string memory name) private returns (bool) {
        role._name = name;
        return true;
    }

    function _addMember(Role storage role, address account) private returns (bool) {
        role._members.add(account);
        if (hasMaxLength(role)) {
            require(membersLength(role) <= maxLength(role), "RoleComponent: max length exceeded");
        }
        return true;
    }

    function _removeMember(Role storage role, address account) private returns (bool) {
        role._members.remove(account);
        if (hasMinLength(role)) {
            require(membersLength(role) <= minLength(role), "RoleComponent: min length exceeded");
        }
        return true;
    }

    function _enableMinLength(Role storage role) private returns (bool) {
        role._hasMinLength = true;
        return true;
    }

    function _disableMinLength(Role storage role) private returns (bool) {
        role._hasMinLength = false;
        return true;
    }

    function _setMinLength(Role storage role, uint minLength) private returns (bool) {
        role._minLength = minLength;
        return true;
    }

    function _enableMaxLength(Role storage role) private returns (bool) {
        role._hasMaxLength = true;
        return true;
    }
    
    function _disableMaxLength(Role storage role) private returns (bool) {
        role._hasMaxLength = false;
        return true;
    }

    function _setMaxLength(Role storage role, uint maxLength) private returns (bool) {
        role._maxLength = maxLength;
        return true;
    }
}