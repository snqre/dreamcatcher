// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Authenticator {
    /*
    admin: 
    syndicate: 
    custodian:
    member:
     */

    event RoleGranted(address indexed _account, string _role);
    event RoleRevoked(address indexed _account, string _role);

    mapping(address => bool) private isAdmin;
    mapping(address => bool) private isSyndicate;
    mapping(address => bool) private isCustodian;
    mapping(address => bool) private isMember;

    bool private locked;
    modifier reentrancyLock() {
        require(!locked, "Anti-Reentrancy Lock");
        locked = true;
        _;
        locked = false;
    }

    // admins
    modifier onlyAdmins(address _accountToCheck) {
        require(isAdmin[_accountToCheck]);
        _;
    }

    function giveAdmin(address _account) internal returns (bool) {
        require(isAdmin[_account] != true, "Address is already an admin");
        isAdmin[_account] = true;
        emit RoleGranted(_account, "Admin");
        return true;
    }

    function takeAdmin(address _account) internal returns (bool) {
        require(isAdmin[_account] != false, "Address is already not an admin");
        isAdmin[_account] = false;
        emit RoleRevoked(_account, "Admin");
        return true;
    }

    modifier onlySyndicates(address _accountToCheck) {
        require(isSyndicate[_accountToCheck]);
        _;
    }

    // syndicates
    function giveSyndicate(address _account) internal returns (bool) {
        require(
            isSyndicate[_account] != true,
            "Address is already a syndicate"
        );
        isSyndicate[_account] = true;
        emit RoleGranted(_account, "Syndicate");
        return true;
    }

    function takeSyndicate(address _account) internal returns (bool) {
        require(
            isSyndicate[_account] != false,
            "Address is already not a syndicate"
        );
        isSyndicate[_account] = false;
        emit RoleRevoked(_account, "Syndicate");
        return true;
    }

    modifier onlyCustodians(address _accountToCheck) {
        require(isCustodian[_accountToCheck]);
        _;
    }

    // custodians
    function giveCustodian(address _account) internal returns (bool) {
        require(
            isCustodian[_account] != true,
            "Address is already a custodian"
        );
        isCustodian[_account] = true;
        emit RoleGranted(_account, "Custodian");
        return true;
    }

    function takeCustodian(address _account) internal returns (bool) {
        require(
            isCustodian[_account] != false,
            "Address is already not a custodian"
        );
        isCustodian[_account] = false;
        emit RoleRevoked(_account, "Custodian");
        return true;
    }

    // members
    modifier onlyMembers(address _accountToCheck) {
        require(isMember[_accountToCheck]);
        _;
    }

    function giveMembership(address _account) internal returns (bool) {
        require(isMember[_account] != true, "Address is already a member");
        isMember[_account] = true;
        emit RoleGranted(_account, "Member");
        return true;
    }

    function takeMembership(address _account) internal returns (bool) {
        require(isMember[_account] != false, "Address is already not a member");
        isMember[_account] = false;
        emit RoleRevoked(_account, "Member");
        return true;
    }
}
