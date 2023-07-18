// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/__Validator.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Validator.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/__Role.sol";

interface IRole {
    event KeyRevokedFromRole(string indexed role, address indexed of_, string indexed signature);
    event KeyGrantedToRole(string indexed role, address indexed of_, string indexed signature, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance);
    event RoleGranted(address indexed to, string indexed role);
    event RoleRevoked(address indexed from, string indexed role);

    //function revokeKeyFromRole(string memory role, address of_, string memory signature) external;
    //function grantKeyToRole(string memory role, address of_, string memory signature, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance) external;
    //function getKey(string memory role, address of_, string memory signature) external view returns (bytes32, __Validator.Class, uint32, uint32, uint8);
    //function getKeys(string memory role) external view returns (bytes32[] memory, __Validator.Class[] memory, uint32[] memory, uint32[] memory, uint8[] memory);
}

contract Role is IRole, Validator {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    uint public maxKeysPerRole;

    mapping(string => EnumerableSet.AddressSet) internal _roles;
    mapping(string => EnumerableSet.Bytes32Set) internal _rolesKeys;
    mapping(string => mapping(bytes32 => __Validator.Data)) internal _rolesDatas;

    constructor() {
        /// 30 approaches about 3million gas in execution to grant
        maxKeysPerRole = 30;
    }

    function revokeKeyFromRole(string memory role, address of_, string memory signature)
        public {
        validate(msg.sender, address(this), "revokeKeyFromRole");
        __Validator.removeKey(_rolesKeys[role], _rolesDatas[role][__Validator.encode(of_, signature)], of_, signature);
        emit KeyRevokedFromRole(role, of_, signature);
    }

    /// @dev is repeat logic and is similar to the one in validator
    /// terribly inneficient but ... it works

    function grantKeyToRole(string memory role, address of_, string memory signature, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance)
        public {
        validate(msg.sender, address(this), "grantKeyToRole");
        require(_rolesKeys[role].length() <= maxKeysPerRole, "Role: maximum amount of keys per role reached");
        require(
            !__Validator.isClass(class, __Validator.Class.DEFAULT),
            "Validator: class cannot default"
        );
        if (__Validator.isClass(class, __Validator.Class.STANDARD)) {
            startTimestamp = 0;
            endTimestamp = 0;
            balance = 0;
        }
        else if (__Validator.isClass(class, __Validator.Class.TIMED)) {
            balance = 0;
            require(
                endTimestamp > startTimestamp,
                "Validator: timed keys cannot expire before they are granted"
            );
        }
        else if (__Validator.isClass(class, __Validator.Class.CONSUMABLE)) {
            startTimestamp = 0;
            endTimestamp = 0;
        }
        __Validator.addKey(_rolesKeys[role], _rolesDatas[role][__Validator.encode(of_, signature)], of_, signature, class, startTimestamp, endTimestamp, balance);
        emit KeyGrantedToRole(role, of_, signature, class, startTimestamp, endTimestamp, balance);
    }

    /// terrible way of implementing this but its good enough for the moment
    /// maximum and optimal amount of numbers seams to be 30 due to gas limits

    function grantRole(address to, string memory role)
        public {
        validate(msg.sender, address(this), "grantRole");
        (bytes32[] memory values, __Validator.Class[] memory classes, uint32[] memory startTimestamps, uint32[] memory endTimestamps, uint8[] memory balances) = getRoleKeys(role);
        for (uint i = 0; i < values.length; i++) {
            __Role.addKey(_keys[to], _datas[to][values[i]], values[i], classes[i], startTimestamps[i], endTimestamps[i], balances[i]);
        }
        _roles[role].add(to);
        emit RoleGranted(to, role);
    }

    /// revoking a role will remove all related keys even if they were not granted by the role

    function revokeRole(address from, string memory role)
        public {
        validate(msg.sender, address(this), "revokeRole(address,string)");
        (bytes32[] memory values, , , ,) = getRoleKeys(role);
        for (uint i = 0; i < values.length; i++) {
            __Role.removeKey(_keys[from], _datas[from][values[i]], values[i]);
        }
        _roles[role].remove(from);
        emit RoleRevoked(from, role);
    }

    function getRoleKey(string memory role, address of_, string memory signature)
        public view
        returns (bytes32, __Validator.Class, uint32, uint32, uint8) {
        return __Validator.getKey(_rolesKeys[role], _rolesDatas[role][__Validator.encode(of_, signature)], of_, signature);
    }

    function getRoleMembers(string memory role)
        public view
        returns (address[] memory) {
        return _roles[role].values();
    }

    function getRoleLength(string memory role)
        public view
        returns (uint) {
        return _roles[role].length();
    }

    function getRoleKeys(string memory role)
        public view
        returns (bytes32[] memory, __Validator.Class[] memory, uint32[] memory, uint32[] memory, uint8[] memory) {
        bytes32[] memory values = _rolesKeys[role].values();
        __Validator.Class[] memory classes = new __Validator.Class[](values.length);
        uint32[] memory startTimestamps = new uint32[](values.length);
        uint32[] memory endTimestamps = new uint32[](values.length);
        uint8[] memory balances = new uint8[](values.length);
        for (uint i = 0; i < values.length; i++) {
            __Validator.Data memory data = _rolesDatas[role][values[i]];
            classes[i] = data.class;
            startTimestamps[i] = data.startTimestamp;
            endTimestamps[i] = data.endTimestamp;
            balances[i] = data.balance;
        }
        return (values, classes, startTimestamps, endTimestamps, balances);
    }
}