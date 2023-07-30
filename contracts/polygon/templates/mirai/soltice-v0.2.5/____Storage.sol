// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

/**
* The Eternal Storage design pattern in Solidity aims to separate the state data 
* from the logic of a smart contract, enabling upgrades without data loss 
* by using an external contract to store the data permanently
 */

/// we are expanding on the eternal storage design pattern
/// here we add several new types of datatypes such as arrays
/// the scope of this storage is for solstice
contract ____Storage is Ownable {
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
    mapping(bytes32 => bool[]) private booleanArrayStorage;
    mapping(bytes32 => bytes32[]) private bytes32ArrayStorage;

    mapping(bytes32 => EnumerableSet.AddressSet) private addressSetStorage;
    mapping(bytes32 => EnumerableSet.UintSet) private uintSetStorage;
    mapping(bytes32 => EnumerableSet.Bytes32Set) private bytes32SetStorage;

    event SetLogic(address indexed newLogic);
    event SetStringStorage(bytes32 indexed key, string indexed value);
    event SetBytesStorage(bytes32 indexed key, bytes indexed value);
    event SetUintStorage(bytes32 indexed key, uint indexed value);
    event SetIntStorage(bytes32 indexed key, int indexed value);
    event SetAddressStorage(bytes32 indexed key, address indexed value);
    event SetBooleanStorage(bytes32 indexed key, bool indexed value);
    event SetBytes32Storage(bytes32 indexed key, bytes32 indexed value);
    event SetStringArrayStorage(bytes32 indexed key, string[] indexed value);
    event PushStringArrayStorage(bytes32 indexed key, string indexed value);
    event DeleteStringArrayStorage(bytes32 indexed key);
    event SetBytesArrayStorage(bytes32 indexed key, bytes[] indexed value);
    event PushBytesArrayStorage(bytes32 indexed key, bytes indexed value);
    event DeleteBytesArrayStorage(bytes32 indexed key);
    event SetUintArrayStorage(bytes32 indexed key, uint[] indexed value);
    event PushUintArrayStorage(bytes32 indexed key, uint indexed value);
    event DeleteUintArrayStorage(bytes32 indexed key);
    event SetIntArrayStorage(bytes32 indexed key, int[] indexed value);
    event PushIntArrayStorage(bytes32 indexed key, int indexed value);
    event DeleteIntArrayStorage(bytes32 indexed key);
    event SetAddressArrayStorage(bytes32 indexed key, address[] indexed value);
    event PushAddressArrayStorage(bytes32 indexed key, address indexed value);
    event DeleteAddressArrayStorage(bytes32 indexed key);
    event SetBooleanArrayStorage(bytes32 indexed key, bool[] indexed value);
    event PushBooleanArrayStorage(bytes32 indexed key, bool indexed value);
    event DeleteBooleanArrayStorage(bytes32 indexed key);
    event SetBytes32ArrayStorage(bytes32 indexed key, bytes32[] indexed value);
    event PushBytes32ArrayStorage(bytes32 indexed key, bytes32 indexed value);
    event DeleteBytes32ArrayStorage(bytes32 indexed key);
    event AddAddressSetStorage(bytes32 indexed key, address indexed value);
    event RemoveAddressSetStorage(bytes32 indexed key, address indexed value);
    event AddUintSetStorage(bytes32 indexed key, uint indexed value);
    event RemoveUintSetStorage(bytes32 indexed key, uint indexed value);
    event AddBytes32SetStorage(bytes32 indexed key, bytes32 indexed value);
    event RemoveBytes32SetStorage(bytes32 indexed key, bytes32 indexed value);

    constructor() 
        Ownable(msg.sender) {
        
    }

    function encode(string memory value)
        public view
        returns (bytes32) {
        return keccak256(value);
    }

    function setLogic(address newLogic)
        public 
        onlyOwner {
        logic = newLogic;
        _transferOwnership(newlogic);
        emit SetLogic(newLogic);
    }

    function getLogic()
        public view
        returns (address) {
        return logic;
    }

    function setStringStorage(bytes32 key, string memory value)
        public 
        onlyOwner {
        stringStorage[key] = value;
        emit SetStringStorage(key, value);
    }

    function getStringStorage(bytes32 key)
        public view
        returns (string memory) {
        return stringStorage[key];
    }

    function setBytesStorage(bytes32 key, bytes memory value)
        public 
        onlyOwner {
        bytesStorage[key] = value;
        emit SetBytesStorage(key, value);
    }

    function getBytesStorage(bytes32 key)
        public view
        returns (bytes memory) {
        return bytesStorage[key];
    }

    function setUintStorage(bytes32 key, uint value)
        public 
        onlyOwner {
        uintStorage[key] = value;
        emit SetUintStorage(key, value);
    }

    function getUintStorage(bytes32 key)
        public view 
        returns (uint) {
        return uintStorage[key];
    }

    function setIntStorage(bytes32 key, int value)
        public 
        onlyOwner {
        intStorage[key] = value;
        emit SetIntStorage(key, value);
    }

    function getIntStorage(bytes32 key)
        public view
        returns (int) {
        return intStorage[key];
    }

    function setAddressStorage(bytes32 key, address value)
        public 
        onlyOwner {
        addressStorage[key] = value;
        emit SetAddressStorage(key, value);
    }

    function getAddressStorage(bytes32 key)
        public view
        returns (address) {
        return addressStorage[key];
    }

    function setBooleanStorage(bytes32 key, bool value)
        public 
        onlyOwner {
        booleanStorage[key] = value;
        emit SetBooleanStorage(key, value);
    }

    function getBooleanStorage(bytes32 key)
        public view
        returns (bool) {
        return booleanStorage[key];
    }

    function setBytes32Storage(bytes32 key, bytes32 value)
        public 
        onlyOwner {
        bytes32Storage[key] = value;
        emit SetBytes32Storage(key, value);
    }

    function getBytes32Storage(bytes32 key)
        public view
        returns (bytes32) {
        return bytes32Storage[key];
    }

    function setStringArrayStorage(bytes32 key, string[] memory value)
        public 
        onlyOwner {
        stringArrayStorage[key] = value;
        emit SetStringArrayStorage(key, value);
    }

    function pushStringArrayStorage(bytes32 key, string memory value)
        public 
        onlyOwner {
        stringArrayStorage[key].push(value);
        emit PushStringArrayStorage(key, value);
    }

    function deleteStringArrayStorage(bytes32 key) 
        public 
        onlyOwner {
        delete stringArrayStorage[key];
        emit DeleteStringArrayStorage(key);
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

    function lengthStringArrayStorage(bytes32 key)
        public view
        returns (uint) {
        return stringArrayStorage[key].length;
    }

    function setBytesArrayStorage(bytes32 key, bytes[] memory value)
        public 
        onlyOwner {
        bytesArrayStorage[key] = value;
        emit SetBytesArrayStorage(key, value);
    }

    function pushBytesArrayStorage(bytes32 key, bytes memory value)
        public 
        onlyOwner {
        bytesArrayStorage[key].push(value);
        emit PushBytesArrayStorage(key, value);
    }

    function deleteBytesArrayStorage(bytes32 key)
        public 
        onlyOwner {
        delete bytesArrayStorage[key];
        emit DeleteBytesArrayStorage(key);
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

    function lengthBytesArrayStorage(bytes32 key)
        public view
        returns (uint) {
        return bytesArrayStorage[key].length;
    }

    function setUintArrayStorage(bytes32 key, uint[] memory value)
        public 
        onlyOwner {
        uintArrayStorage[key] = value;
        emit SetUintArrayStorage(key, value);
    }

    function pushUintArrayStorage(bytes32 key, uint value)
        public 
        onlyOwner {
        uintArrayStorage[key].push(value);
        emit PushUintArrayStorage(key, value);
    }

    function deleteUintArrayStorage(bytes32 key)
        public 
        onlyOwner {
        delete uintArrayStorage[key];
        emit DeleteUintArrayStorage(key);
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

    function lengthUintArrayStorage(bytes32 key)
        public view
        returns (uint) {
        return uintArrayStorage[key].length;
    }

    function setIntArrayStorage(bytes32 key, int[] memory value)
        public 
        onlyOwner {
        intArrayStorage[key] = value;
        emit SetIntArrayStorage(key, value);
    }

    function pushIntArrayStorage(bytes32 key, int value)
        public 
        onlyOwner {
        intArrayStorage[key].push(value);
        emit PushIntArrayStorage(key, value);
    }

    function deleteIntArrayStorage(bytes32 key)
        public 
        onlyOwner {
        delete intArrayStorage[key];
        emit DeleteBytesArrayStorage(key);
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

    function lengthIntArrayStorage(bytes32 key)
        public view
        returns (uint) {
        return intArrayStorage[key].length;
    }

    function setAddressArrayStorage(bytes32 key, address[] memory value)
        public 
        onlyOwner {
        addressArrayStorage[key] = value;
        emit SetAddressArrayStorage(key, value);
    }

    function pushAddressArrayStorage(bytes32 key, address value)
        public 
        onlyOwner {
        addressArrayStorage[key].push(value);
        emit PushAddressArrayStorage(key, value);
    }

    function deleteAddressArrayStorage(bytes32 key)
        public 
        onlyOwner {
        delete addressArrayStorage[key];
        emit DeleteAddressArrayStorage(key);
    }

    function getAddressArrayStorage(bytes32 key)
        public view
        returns (address[] memory) {
        return addressArrayStorage[key];
    }

    function indexAddressArrayStorage(bytes32 key, uint index)
        public view
        returns (address) {
        return addressArrayStorage[key][index];
    }

    function lengthAddressArrayStorage(bytes32 key)
        public view
        returns (uint) {
        return addressArrayStorage[key].length;
    }

    function setBooleanArrayStorage(bytes32 key, bool[] memory value)
        public 
        onlyOwner {
        booleanArrayStorage[key] = value;
        emit SetBooleanArrayStorage(key, value);
    }

    function pushBooleanArrayStorage(bytes32 key, bool value)
        public 
        onlyOwner {
        booleanArrayStorage[key].push(value);
        emit PushBooleanArrayStorage(key, value);
    }

    function deleteBooleanArrayStorage(bytes32 key)
        public 
        onlyOwner {
        delete booleanArrayStorage[key];
        emit DeleteBooleanArrayStorage(key);
    }

    function getBooleanArrayStorage(bytes32 key)
        public view
        returns (bool[] memory) {
        return booleanArrayStorage[key];
    }

    function indexBooleanArrayStorage(bytes32 key, uint index)
        public view
        returns (bool) {
        return booleanArrayStorage[key][index];
    }

    function lengthBooleanArrayStorage(bytes32 key)
        public view
        returns (uint) {
        return booleanArrayStorage[key].length;
    }

    function setBytes32ArrayStorage(bytes32 key, bytes32[] memory value)
        public 
        onlyOwner {
        bytes32ArrayStorage[key] = value;
        emit SetBytes32ArrayStorage(key, value);
    }

    function pushBytes32ArrayStorage(bytes32 key, bytes32 value)
        public 
        onlyOwner {
        bytes32ArrayStorage[key].push(value);
        emit PushBytes32ArrayStorage(key, value);
    }

    function deleteBytes32ArrayStorage(bytes32 key)
        public 
        onlyOwner {
        delete bytes32ArrayStorage[key];
        emit DeleteBytes32ArrayStorage(key);
    }

    function getBytes32ArrayStorage(bytes32 key)
        public view
        returns (bytes32[] memory) {
        return bytes32ArrayStorage[key];
    }

    function indexBytes32ArrayStorage(bytes32 key, uint index)
        public view
        returns (bytes32) {
        return bytes32ArrayStorage[key][index];
    }

    function lengthBytes32ArrayStorage(bytes32 key)
        public view
        returns (uint) {
        return bytes32ArrayStorage[key].length;
    }

    function addAddressSetStorage(bytes32 key, address value)
        public 
        onlyOwner {
        addressSetStorage[key].add(value);
        emit AddAddressSetStorage(key, value);
    }

    function removeAddressSetStorage(bytes32 key, address value)
        public 
        onlyOwner {
        addressSetStorage[key].remove(value);
        emit RemoveAddressSetStorage(key, value);
    }

    function containsAddressSetStorage(bytes32 key, address value)
        public view
        returns (bool) {
        return addressSetStorage[key].contains(value);
    }

    function indexAddressSetStorage(bytes32 key, uint index)
        public view
        returns (address) {
        return addressSetStorage[key].at(index);
    }

    function valuesAddressSetStorage(bytes32 key)
        public view
        returns (address[] memory) {
        return addressSetStorage[key].values();
    }

    function lengthAddressSetStorage(bytes32 key)
        public view
        returns (uint) {
        return addressSetStorage[key].length();
    }

    function addUintSetStorage(bytes32 key, uint value)
        public 
        onlyOwner {
        uintSetStorage[key].add(value);
        emit AddUintSetStorage(key, value);
    }

    function removeUintSetStorage(bytes32 key, uint value)
        public 
        onlyOwner {
        uintSetStorage[key].remove(value);
        emit RemoveUintSetStorage(key, value);
    }

    function containsUintSetStorage(bytes32 key, uint value)
        public view
        returns (bool) {
        return uintSetStorage[key].contains(value);
    }

    function indexUintSetStorage(bytes32 key, uint index)
        public view
        returns (uint) {
        return uintSetStorage[key].at(index);
    }

    function valuesUintSetStorage(bytes32 key)
        public view
        returns (uint[] memory) {
        return uintSetStorage[key].values();
    }

    function lengthUintSetStorage(bytes32 key)
        public view
        returns (uint) {
        return uintSetStorage[key].length();
    }

    function addBytes32SetStorage(bytes32 key, bytes32 value)
        public 
        onlyOwner {
        bytes32SetStorage[key].add(value);
        emit AddBytes32SetStorage(key, value);
    }

    function removeBytes32SetStorage(bytes32 key, bytes32 value)
        public 
        onlyOwner {
        bytes32SetStorage[key].remove(value);
        emit RemoveBytes32SetStorage(key, value);
    }

    function containsBytes32SetStorage(bytes32 key, bytes32 value)
        public view
        returns (bool) {
        return bytes32SetStorage[key].contains(value);
    }

    function indexBytes32SetStorage(bytes32 key, uint index)
        public view
        returns (bytes32) {
        return bytes32SetStorage[key].at(index);
    }

    function valuesBytes32SetStorage(bytes32 key)
        public view
        returns (bytes32[] memory) {
        return bytes32SetStorage[key].values();
    }

    function lengthBytes32SetStorage(bytes32 key)
        public view
        returns (uint) {
        return bytes32SetStorage[key].length();
    }
}