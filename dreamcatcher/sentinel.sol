// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Book {
    mapping(address => bool) private isAdmin;

    address token_;
    address vault_;
    
    /** in $DREAM */
    struct PriceTo {
        uint256 createNewPool;
    }

    /** 
    all fees are in basis points 
    > fee > vault > buy & burn $DREAM
    */
    struct FeeTo {
        uint256 contributeToPool;
        uint256 withdrawFromPool;
        uint256 useOurAdapters;
        uint256 burn;
        uint256 bank;
    }

    struct Account {
        bool isMember;
        bool isBoard;
        bool isAdmin;
    }

    mapping(address => Account) private accounts;

    modifier onlyAdmins() {
        require(isAdmin[msg.sender]);
        _;
    }

    function accountOf(address _owner) public view (Account) {
        return accounts[_owner];
    } 

    function token() public view returns (address) {return token_;}
    function vault() public view returns (address) {return vault_;}

    function setToken(address _newContract) public onlyAdmins returns (bool) {
        token_ = _newContract;
    }

    function setVault(address _newContract) public onlyAdmins returns (bool) {
        vault_ = _newContract;
    }
}