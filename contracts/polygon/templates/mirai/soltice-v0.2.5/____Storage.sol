// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

/**
* The Eternal Storage design pattern in Solidity aims to separate the state data 
* from the logic of a smart contract, enabling upgrades without data loss 
* by using an external contract to store the data permanently
 */

/// we are expanding on the eternal storage design pattern
/// here we add several new types of datatypes such as arrays
/// the scope of this storage is for solstice
contract ____Storage {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    address private logic;

    mapping(bytes32 => string) private stringStorage;
    mapping(bytes32 => bytes) private bytesStorage;
    mapping(bytes32 => uint) private uintStorage;
    mapping(bytes32 => int) private intStorage;
    mapping(bytes32 => address) private addressStorage;
    mapping(bytes32 => bool) private booleanStorage;
    mapping(bytes32 => bytes32) private bytes32Storage;

    mapping(bytes32 => string[]) private stringArrayStorage;
    mapping(bytes32 => bytes[]) private bytesArrayStorage;
    mapping(bytes32 => uint[]) private uintArrayStorage;
    mapping(bytes32 => int[]) private intArrayStorage;
    mapping(bytes32 => address[]) private addressArrayStorage;
    mapping(bytes32 => bool[]) private boolArrayStorage;
    mapping(bytes32 => bytes32[]) private bytes32ArrayStorage;

    mapping(bytes32 => EnumerableSet.AddressSet) private addressSetStorage;
    mapping(bytes32 => EnumerableSet.UintSet) private uintSetStorage;
    mapping(bytes32 => EnumerableSet.Bytes32Set) private bytes32SetStorage;

    constructor(address firstLogic) {
        logic = firstLogic;
    }

    function setLogic(address newLogic)
        public {
        logic = newLogic;
    }

    function getLogic()
        public view
        returns (address) {
        return logic;
    }

    function setStringStorage(bytes32 key, string memory value)
        public {
        stringStorage[key] = value;
    }

    function getStringStorage(bytes32 key)
        public view
        returns (string memory) {
        return stringStorage[key];
    }

    function setBytesStorage(bytes32 key, bytes memory value)
        public {
        bytesStorage[key] = value;
    }

    function getBytesStorage(bytes32 key)
        public view
        returns (bytes memory) {
        return bytesStorage[key];
    }

    function setUintStorage(bytes32 key, uint value)
        public {
        uintStorage[key] = value;
    }

    function getUintStorage(bytes32 key)
        public view 
        returns (uint) {
        return uintStorage[key];
    }

    function setIntStorage(bytes32 key, int value)
        public {
        intStorage[key] = value;
    }

    function getIntStorage(bytes32 key)
        public view
        returns (int) {
        return intStorage[key];
    }

    function setAddressStorage(bytes32 key, address value)
        public {
        addressStorage[key] = value;
    }

    function getAddressStorage(bytes32 key)
        public view
        returns (address) {
        return addressStorage[key];
    }

    function setBooleanStorage(bytes32 key, bool value)
        public {
        booleanStorage[key] = value;
    }

    function getBooleanStorage(bytes32 key)
        public view
        returns (bool) {
        return booleanStorage[key];
    }

    function setBytes32Storage(bytes32 key, bytes32 value)
        public {
        bytes32Storage[key] = value;
    }

    function getBytes32Storage(bytes32 key)
        public view
        returns (bytes32) {
        return bytes32Storage[key];
    }

    function setStringArrayStorage(bytes32 key, string[] memory value)
        public {
        stringArrayStorage[key] = value;
    }

    function pushStringArrayStorage(bytes32 key, string memory value)
        public {
        stringArrayStorage[key].push(value);
    }

    function deleteStringArrayStorage(bytes32 key) 
        public {
        delete stringArrayStorage[key];
    }

    function getStringArrayStorage(bytes32 key)
        public view
        returns (string[] memory) { 
        return stringArrayStorage[key];
    }

    function indexStringArrayStorage(bytes32 key, uint index)
        public view
        returns (string memory) {
        return stringArrayStorage[key][index];
    }

    function setBytesArrayStorage(bytes32 key, bytes[] memory value)
        public {
        bytesArrayStorage[key] = value;
    }

    function pushBytesArrayStorage(bytes32 key, bytes memory value)
        public {
        bytesArrayStorage[key].push(value);
    }

    function deleteBytesArrayStorage(bytes32 key)
        public {
        delete bytesArrayStorage[key];
    }

    function getBytesArrayStorage(bytes32 key)
        public view
        returns (bytes[] memory) {
        return bytesArrayStorage[key];
    }

    function indexBytesArrayStorage(bytes32 key, uint index)
        public view
        returns (bytes memory) {
        return bytesArrayStorage[key][index];
    }

    function setUintArrayStorage(bytes32 key, uint[] memory value)
        public {
        uintArrayStorage[key] = value;
    }

    function pushUintArrayStorage(bytes32 key, uint value)
        public {
        uintArrayStorage[key].push(value);
    }

    function deleteUintArrayStorage(bytes32 key)
        public {
        delete uintArrayStorage[key];
    }

    function getUintArrayStorage(bytes32 key)
        public view
        returns (uint[] memory) {
        return uintArrayStorage[key];
    }

    function indexUintArrayStorage(bytes32 key, uint index)
        public view
        returns (uint) {
        return uintArrayStorage[key][index];
    }

    function setIntArrayStorage(bytes32 key, int[] memory value)
        public {
        intArrayStorage[key] = value;
    }

    function pushIntArrayStorage(bytes32 key, int value)
        public {
        intArrayStorage[key].push(value);
    }

    function deleteIntArrayStorage(bytes32 key)
        public {
        delete intArrayStorage[key];
    }

    function getIntArrayStorage(bytes32 key)
        public view
        returns (int[] memory) {
        return intArrayStorage[key];
    }

    function indexIntArrayStorage(bytes32 key, uint index)
        public view
        returns (int) {
        return intArrayStorage[key][index];
    }

}