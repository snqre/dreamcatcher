// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/__Validator.sol";

interface IValidator {
    event KeyRevoked(address indexed from, address of_, string signature);
    event KeyGranted(address indexed to, address of_, string signature, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance);
}

contract Validator is IValidator {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    mapping(address => EnumerableSet.Bytes32Set) private _keys;
    mapping(address => mapping(bytes32 => __Validator.Data)) private _datas;

    function revoke(address from, address of_, string memory signature)
        external {
        __Validator.removeKey(_keys[from], _datas[from][__Validator.encode(of_, signature)], of_, signature);
        emit KeyRevoked(from, of_, signature);
    }

    function grant(address to, address of_, string memory signature, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance)
        external 
        returns (__Validator.Key memory) {
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
        __Validator.addKey(_keys[to], _datas[to][__Validator.encode(of_, signature)], of_, signature, class, startTimestamp, endTimestamp, balance);
        emit KeyGranted(to, of_, signature, class, startTimestamp, endTimestamp, balance);
        return __Validator.Key({
            id: __Validator.encode(of_, signature),
            class: class,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            balance: balance
        });
    }

    function getKey(address from, address of_, string memory signature)
        public view
        returns (bytes32, __Validator.Class, uint32, uint32, uint8) {
        return __Validator.getKey(_keys[from], _datas[from][__Validator.encode(of_, signature)], of_, signature);
    }

    function getKeys(address from)
        external view
        returns (bytes32[] memory, __Validator.Class[] memory, uint32[] memory, uint32[] memory, uint8[] memory) {
        bytes32[] memory values = _keys[from].values();
        __Validator.Class[] memory classes = new __Validator.Class[](values.length);
        uint32[] memory startTimestamps = new uint32[](values.length);
        uint32[] memory endTimestamps = new uint32[](values.length);
        uint8[] memory balances = new uint8[](values.length);
        for (uint i = 0; i < values.length; i++) {
            __Validator.Data memory data = _datas[from][values[i]];
            classes[i] = data.class;
            startTimestamps[i] = data.startTimestamp;
            endTimestamps[i] = data.endTimestamp;
            balances[i] = data.balance;
        }
        return (values, classes, startTimestamps, endTimestamps, balances);
    }
}