// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

import "deps/openzeppelin/access/AccessControlEnumerable.sol";
import "smart_contracts/utils/Utils.sol";

contract Authenticator is AccessControlEnumerable {
    mapping(string => bytes32) public roles;
    mapping(string => uint) public rolesMin;
    mapping(string => uint) public rolesMax;
    mapping(string => bool) public rolesHasMinEnabled;
    mapping(string => bool) public rolesHasMaxEnabled;

    /** if max enabled then will not grant the role if at max */
    function _grantRole(bytes32 role, address account) internal virtual override {
        if (rolesHasMaxEnabled[Utils.byteToStr(role)]) {
            require(getRoleMemberCount(role) < rolesMax[Utils.byteToStr(role)], "must maintain max amount for this role");
        }

        AccessControlEnumerable._grantRole(role, account);
    }

    /** if min enabled then will not revoke the role if at min */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        if (rolesHasMinEnabled[Utils.byteToStr(role)]) {
            require(getRoleMemberCount(role) > rolesMin[Utils.byteToStr(role)], "must maintain min amount for this role");
        }

        AccessControlEnumerable._revokeRole(role, account);
    }

    /** eg. onlyRole(roles["manager"]) */
    function addRole(string memory role) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 roleRef = keccak256(bytes(role));
        roles[role] = roleRef;
    }

    function setRoleMin(string memory role, uint newMin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newMin <= rolesMax[role], "newMin cannot be larger than max");
        rolesMin[role] = newMin;
    }

    function setRoleMax(string memory role, uint newMax) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newMax >= rolesMin[role], "newMax cannot be smaller than min");
        rolesMax[role] = newMax;
    }

    function setRoleHasMinEnabled(string memory role, bool newSetting) public onlyRole(DEFAULT_ADMIN_ROLE) {
        rolesHasMinEnabled[role] = newSetting;
    }

    function setRoleHasMaxEnabled(string memory role, bool newSetting) public onlyRole(DEFAULT_ADMIN_ROLE) {
        rolesHasMaxEnabled[role] = newSetting;
    }
}