// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

library __Validator {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    enum Class {
        DEFAULT,
        TIMED,
        STANDARD,
        CONSUMABLE
    }

    struct Data {
        Class class;
        uint32 startTimestamp;
        uint32 endTimestamp;
        uint8 balance;
    }

    struct Key {
        bytes32 id;
        Class class;
        uint32 startTimestamp;
        uint32 endTimestamp;
        uint8 balance;
    }

    function encode(string memory value)
        public pure 
        returns (bytes32) {
        return keccak256(abi.encode(value));
    }

    function isClass(Class class, Class requiredClass)
        public pure 
        returns (bool) {
        return class == requiredClass;
    }

    function isMatch(EnumerableSet.Bytes32Set storage keys, string memory key)
        public view 
        returns (bool) {
        return keys.contains(encode(key));
    }

    function onlyIfMatch(EnumerableSet.Bytes32Set storage keys, string memory key)
        public view {
        require(isMatch(keys, key), "__Validator: key match not found");
    }

    function onlyIfNotMatch(EnumerableSet.Bytes32Set storage keys, string memory key)
        public view {
        require(!isMatch(keys, key), "__Validator: key match was found");
    }

    function add(EnumerableSet.Bytes32Set storage keys, string memory key)
        public {
        keys.add(encode(key));
    }

    function remove(EnumerableSet.Bytes32Set storage keys, string memory key)
        public {
        keys.remove(encode(key));
    }

    function addKey(EnumerableSet.Bytes32Set storage keys, Data storage data, string memory key, Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance)
        public {
        add(keys, key);
        data.class = class;
        data.startTimestamp = startTimestamp;
        data.endTimestamp = endTimestamp;
        data.balance = balance;
    }

    function removeKey(EnumerableSet.Bytes32Set storage keys, Data storage data, string memory key)
        public {
        remove(keys, key);
        data.class = Class.DEFAULT;
        data.startTimestamp = 0;
        data.endTimestamp = 0;
        data.balance = 0;
    }

    function getKey(EnumerableSet.Bytes32Set storage keys, Data storage data, string memory key)
        public view
        returns (Key memory) {
        onlyIfMatch(keys, key);
        Key memory newKey = Key({
            id: encode(key),
            class: data.class,
            startTimestamp: data.startTimestamp,
            endTimestamp: data.endTimestamp,
            balance: data.balance
        });
        return newKey;
    }

    function getKeys(EnumerableSet.Bytes32Set storage keys, Data[] memory datas)
        public view
        returns (Key[] memory) {
        Key[] memory newKeys;
        bytes32[] memory values = keys.values();
        for (uint i = 0; i < values.length; i++) {
            newKeys[i] = Key({
                id: values[i],
                class: datas[i].class,
                startTimestamp: datas[i].startTimestamp,
                endTimestamp: datas[i].endTimestamp,
                balance: datas[i].balance
            });
        }
        return newKeys;
    }
}