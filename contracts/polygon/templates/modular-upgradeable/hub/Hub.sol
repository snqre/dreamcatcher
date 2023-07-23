// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/__Validator.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Link.sol";

interface IHub {
    function revoke(address from, address of_, string memory signature) external;
    function grant(address to, address of_, string memory signature, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance) external;
    function validate(address from, address of_, string memory signature) external;
    function getKey(address from, address of_, string memory signature) external view;
    function getKeys(address from) external view;
    function revokeKeyFromRole(string memory role, address of_, string memory signature) external;
    function grantKeyToRole(string memory role, address of_, string memory signature, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance) external;
    function grantRole(address to, string memory role) external;
    function revokeRole(address from, string memory role) external;
    function getRoleKey(string memory role, address of_, string memory signature) external view returns (bytes32, __Validator.Class, uint32, uint32, uint8);
    function getRoleMembers(string memory role) external view returns (address[] memory);
    function getRoleLength(string memory role) external view returns (uint);
    function getRoleKeys(string memory role) external view returns (bytes32[] memory, __Validator.Class[] memory, uint32[] memory, uint32[] memory, uint8[] memory);
    function connect(string memory signature, bytes memory args) external returns (bytes memory);
    function addTerminal(address terminal) external;
    function removeTerminal(address terminal) external;
    function addRouter(address terminal, address router) external;
    function removeRouter(address terminal, address router) external;
    function getTerminals() external view returns (address[] memory);
    function getRouters(address terminal) external view returns (address[] memory);
    function setTimelock(uint value) external;
    function setTimeout(uint value) external;
    function approveAll(uint value) external;
    function queue(address target, string memory signature, bytes memory args) external returns (uint);
    function queueBatch(address[] memory targets, string[] memory signatures, bytes[] memory args) external returns (uint);
    function approve(uint id) external;
    function reject(uint id) external;
    function execute(uint id) external returns (bytes memory);
    function executeBatch(uint id) external returns (bytes[] memory);
    function getRequest(uint id) external view returns (uint, uint, uint, uint, uint, address, bool, bool, bool, __Timelock.Class);
    function getPayload(uint id) external view returns (address, string memory, bytes memory args);
    function getBatchPayload(uint id) external view returns (address[] memory, string[] memory, bytes[] memory);
}

contract Hub is Link {
    constructor() 
    Role()
    Timelock() {
        /// ... Role: set maxKeyPerRole to 30
        /// ... Timelock: set timelock 604800 seconds
        /// ... Timelock: set timeout 604800 seconds
        /// ... Timelock: set enabledApproveAll = true
        
        /// grant roles to hub itself
        address to = address(this);
        _grant(to, address(this), "revoke", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "grant", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "revokeKeyFromRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "grantKeyToRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "grantRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "revokeRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "approve", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "reject", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "execute", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "executeBatch", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "addTerminal", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "removeTerminal", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "addRouter", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "removeRouter", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "queueBatch", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "queue", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "approveAll", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "setTimeout", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "setTimelock", __Validator.Class(2), 0, 0, 0);

        /// create hub role
        grantKeyToRole("hub", address(this), "revoke", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "grant", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "revokeKeyFromRole", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "grantKeyToRole", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "grantRole", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "revokeRole", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "approve", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "reject", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "execute", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "executeBatch", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "addTerminal", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "removeTerminal", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "addRouter", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "removeRouter", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "queueBatch", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "queue", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "approveAll", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "setTimeout", __Validator.Class(2), 0, 0, 0);
        grantKeyToRole("hub", address(this), "setTimelock", __Validator.Class(2), 0, 0, 0);

        /// for testing
        grantRole(msg.sender, "hub");
    }
}