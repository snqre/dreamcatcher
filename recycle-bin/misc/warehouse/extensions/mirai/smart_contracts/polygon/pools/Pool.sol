// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/security/Pausable.sol";
import "extensions/mirai/smart_contracts/polygon/tokens/standard_token/StandardToken.sol";

library State {
    using EnumerableSet for EnumerableSet.AddressSet;
    struct Schedule {
        uint startTimestamp;
        uint endTimestamp;
        uint duration;
        uint required;
        bool isWhitelisted;
        EnumerableSet.AddressSet whitelist;
    }

    struct Vault {
        EnumerableSet.AddressSet contracts;
        EnumerableSet.UintSet amounts;
        uint balance;
    }
}

interface IPool {
    error CallerIsNotManager(address caller);
    error CallerIsNotAdmin(address caller);
}

contract Pool is Ownable, Pausable {
    using EnumerableSet for EnumerableSet.AddressSet;

    string public name;
    string public description;
    address public creator;

    State.Schedule public schedule;
    State.Vault public vault;

    mapping(address => bool) public isManager;
    mapping(address => bool) public isAdmin;

    modifier onlyManager() {
        if (!isManager[msg.sender]) {
            revert CallerIsNotManager(msg.sender);
        }
        _;
    }

    modifier onlyAdmin() {
        if (!isAdmin[msg.sender]) {
            revert CallerIsNotAdmin(msg.sender);
        }
        _;
    }
    
    constructor() Ownable() {
        _transferOwnership(msg.sender);

    }

    function contribute()
    external payable
    returns (bool) {

    }


    
}