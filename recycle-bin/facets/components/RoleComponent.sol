// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

/// access control
library RoleComponent {
    using EnumerableSet for EnumerableSet.AddressSet;

    error Unauthorized(address caller);

    struct Role {
        EnumerableSet.AddressSet _members;
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

    function isMember(Role storage role, address account) internal view returns (bool) {
        return role._members.contains(account);
    }

    function authenticate(Role storage role) internal view {
        if (isMember({role: role, account: msg.sender})) {
            revert Unauthorized({caller: msg.sender});
        }
    }

    function tryAuthenticate(Role storage role) internal view {
        if (membersLength(role) != 0) {
            authenticate(role);
        }
    }

    function addMember(Role storage role, address account) internal {
        role._members.add(account);
    }

    function removeMemeber(Role storage role, address account) internal {
        role._members.remove(account);
    }
}