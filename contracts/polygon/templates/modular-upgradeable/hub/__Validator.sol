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
        returns (bytes32, Class, uint32, uint32, uint8) {
        onlyIfMatch(keys, key);
        return (encode(key), data.class, data.startTimestamp, data.endTimestamp, data.balance);
    }
}