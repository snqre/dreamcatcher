// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/__Validator.sol";

interface IValidator {
    event KeyRevoked(address indexed from, string indexed key);
    event KeyGranted(address indexed to, string indexed key, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance);
}

contract Validator is IValidator {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    mapping(address => EnumerableSet.Bytes32Set) private _keys;
    mapping(address => mapping(bytes32 => __Validator.Data)) private _datas;

    function revoke(address from, string memory key)
        external {
        __Validator.removeKey(_keys[from], _datas[from][__Validator.encode(key)], key);
        emit KeyRevoked(from, key);
    }

    function grant(address to, string memory key, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance)
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
        __Validator.addKey(_keys[to], _datas[to][__Validator.encode(key)], key, class, startTimestamp, endTimestamp, balance);
        emit KeyGranted(to, key, class, startTimestamp, endTimestamp, balance);
        return __Validator.Key({
            id: __Validator.encode(key),
            class: class,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            balance: balance
        });
    }

    function getKey(address from, string memory key)
        external view
        returns (__Validator.Key memory) {
        return __Validator.getKey(_keys[from], _datas[from][__Validator.encode(key)], key);
    }

    function getKeys(address from)
        external view
        returns (__Validator.Key[] memory) {
        __Validator.Data[] memory newDatas;
        for (uint i = 0; i < _keys[from].length(); i++) {
            __Validator.Data storage data = _datas[from][_keys[from].at(i)];
            newDatas[i].class = data.class;
            newDatas[i].startTimestamp = data.startTimestamp;
            newDatas[i].endTimestamp = data.endTimestamp;
            newDatas[i].balance = data.balance;
        }
        return __Validator.getKeys(_keys[from], newDatas);
    }
}