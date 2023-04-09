// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Authenticator {
    event RoleGranted(address indexed _account, string _role);
    event RoleRevoked(address indexed _account, string _role);

    mapping(address => bool) internal isSyndicate;
    mapping(address => bool) internal isCustodian;
    mapping(address => bool) internal isMember;

    // security
    bool private locked;
    modifier reentrancyLock() {
        require(!locked, "Anti-Reentrancy Lock");
        locked = true;
        _;
        locked = false;
    }

    modifier onlySyndicates(address _accountToCheck) {
        require(isSyndicate[_accountToCheck]);
        _;
    }

    // syndicates
    function giveSyndicate(address _account)
        internal
        reentrancyLock
        returns (bool)
    {
        require(
            isSyndicate[_account] != true,
            "Address is already a syndicate"
        );
        isSyndicate[_account] = true;
        RoleGranted(_account, "Syndicate");
        return true;
    }

    function takeSyndicate(address _account)
        internal
        reentrancyLock
        returns (bool)
    {
        require(
            isSyndicate[_account] != false,
            "Address is already not a syndicate"
        );
        isSyndicate[_account] = false;
        RoleRevoked(_account, "Syndicate");
        return true;
    }

    modifier onlyCustodians(address _accountToCheck) {
        require(isCustodian[_accountToCheck]);
        _;
    }

    // custodians
    function giveCustodian(address _account)
        internal
        reentrancyLock
        returns (bool)
    {
        require(
            isCustodian[_account] != true,
            "Address is already a custodian"
        );
        isCustodian[_account] = true;
        RoleGranted(_account, "Custodian");
        return true;
    }

    function takeCustodian(address _account)
        internal
        reentrancyLock
        returns (bool)
    {
        require(
            isCustodian[_account] != false,
            "Address is already not a custodian"
        );
        isCustodian[_account] = false;
        RoleRevoked(_account, "Custodian");
        return true;
    }

    // members
    modifier onlyMembers(address _accountToCheck) {
        require(isMember[_accountToCheck]);
        _;
    }

    function giveMembership(address _account)
        internal
        reentrancyLock
        returns (bool)
    {
        require(isMember[_account] != true, "Address is already a member");
        isMember[_account] = true;
        RoleGranted(_account, "Member");
        return true;
    }

    function takeMembership(address _account)
        internal
        reentrancyLock
        returns (bool)
    {
        require(isMember[_account] != false, "Address is already not a member");
        isMember[_account] = false;
        RoleRevoked(_account, "Member");
        return true;
    }
}
