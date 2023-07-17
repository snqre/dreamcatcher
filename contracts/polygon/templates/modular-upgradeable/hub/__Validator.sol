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

    function encode(address of_, string memory signature)
        public pure 
        returns (bytes32) {
        return keccak256(abi.encode(of_, signature));
    }

    function isClass(Class class, Class requiredClass)
        public pure 
        returns (bool) {
        return class == requiredClass;
    }

    function isMatch(EnumerableSet.Bytes32Set storage keys, address of_, string memory signature)
        public view 
        returns (bool) {
        return keys.contains(encode(of_, signature));
    }

    function onlyIfMatch(EnumerableSet.Bytes32Set storage keys, address of_, string memory signature)
        public view {
        require(isMatch(keys, of_, signature), "__Validator: key match not found");
    }

    function onlyIfNotMatch(EnumerableSet.Bytes32Set storage keys, address of_, string memory signature)
        public view {
        require(!isMatch(keys, of_, signature), "__Validator: key match was found");
    }

    function add(EnumerableSet.Bytes32Set storage keys, address of_, string memory signature)
        public {
        keys.add(encode(of_, signature));
    }

    function remove(EnumerableSet.Bytes32Set storage keys, address of_, string memory signature)
        public {
        keys.remove(encode(of_, signature));
    }

    function addKey(EnumerableSet.Bytes32Set storage keys, Data storage data, address of_, string memory signature, Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance)
        public {
        add(keys, of_, signature);
        data.class = class;
        data.startTimestamp = startTimestamp;
        data.endTimestamp = endTimestamp;
        data.balance = balance;
    }

    function removeKey(EnumerableSet.Bytes32Set storage keys, Data storage data, address of_, string memory signature)
        public {
        remove(keys, of_, signature);
        data.class = Class.DEFAULT;
        data.startTimestamp = 0;
        data.endTimestamp = 0;
        data.balance = 0;
    }

    function getKey(EnumerableSet.Bytes32Set storage keys, Data storage data, address of_, string memory signature)
        public view
        returns (bytes32, Class, uint32, uint32, uint8) {
        onlyIfMatch(keys, of_, signature);
        return (encode(of_, signature), data.class, data.startTimestamp, data.endTimestamp, data.balance);
    }
}