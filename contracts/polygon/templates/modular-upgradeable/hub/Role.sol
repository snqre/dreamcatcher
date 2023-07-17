// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/__Validator.sol";

interface IRole {
    event KeyRevokedFromRole(string indexed role, address indexed of_, string indexed signature);
    event KeyGrantedToRole(string indexed role, address indexed of_, string indexed signature, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance);

    function revokeKeyFromRole(string memory role, address of_, string memory signature) external;
    function grantKeyToRole(string memory role, address of_, string memory signature, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance) external;
}

contract Role is IRole {
    using EnumerableSet for EnumerableSet.AddressSet;
    // chef, 
    mapping(string => EnumerableSet.AddressSet) private _roles;
    mapping(string => EnumerableSet.Bytes32Set) private _rolesKeys;
    mapping(string => mapping(bytes32 => __Validator.Data)) private _datas;

    function revokeKeyFromRole(string memory role, address of_, string memory signature)
        public {
        __Validator.removeKey(_rolesKeys[role], _datas[role][__Validator.encode(of_, signature)], of_, signature);
        emit KeyRevokedFromRole(role, of_, signature);
    }

    function grantKeyToRole(string memory role, address of_, string memory signature, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance)
        public {
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
        __Validator.addKey(_rolesKeys[role], _datas[role][__Validator.encode(of_, signature)], of_, signature, class, startTimestamp, endTimestamp, balance);
        emit KeyGrantedToRole(role, of_, signature, class, startTimestamp, endTimestamp, balance);
    }

    function getKey(string memory role, address of_, string memory signature)
        public view
        returns (bytes32, __Validator.Class, uint32, uint32, uint8) {
        return __Validator.getKey(_rolesKeys[role], _datas[role][__Validator.encode(of_, signature)], of_, signature);
    }

    function getKeys(string memory role)
        public view
        returns (bytes32[] memory, __Validator.Class[] memory, uint32[] memory, uint32[] memory, uint8[] memory) {
        bytes32[] memory values = _rolesKeys[role].values();
        __Validator.Class[] memory classes = new __Validator.Class[](values.length);
        uint32[] memory startTimestamps = new uint32[](values.length);
        uint32[] memory endTimestamps = new uint32[](values.length);
        
    }
}