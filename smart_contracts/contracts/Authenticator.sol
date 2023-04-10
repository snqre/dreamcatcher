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

    mapping(address => bool) private isAdmin; //
    mapping(address => bool) private isSyndicate; //

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
}
