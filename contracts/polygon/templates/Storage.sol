// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

/**

    The provided Solidity contract is named "Storage" and is intended to serve 
    as a data storage and management smart contract. It includes a series of functions 
    to store and retrieve various types of data, such as strings, bytes, integers, 
    addresses, booleans, and bytes32, as well as arrays of these types. 
    The contract implements an interface called "IStorage," which defines the functions 
    that can be interacted with externally.

    The contract allows setting and getting data for each data type using specific keys (bytes32 values). 
    Additionally, it supports various operations on arrays like pushing, deleting, 
    and fetching elements by index. 
    
    The contract also incorporates the OpenZeppelin library's EnumerableSet to manage 
    sets of addresses, uints, and bytes32 values. It provides functions to add, remove, 
    and check the existence of elements within these sets.

    Whilt this complicated our syntax it allows us to keep storage within one single contract
    making our contracts even more transparent

 */

interface IStorage {
    function addAdmin(address admin) external;
    function removeAdmin(address admin) external;
    function getAdmins() external view returns (address[] memory);

    function addImplementation(address implementation) external;
    function removeImplementation(address implementation) external;
    function getImplementations() external view returns (address[] memory);

    function setString(bytes32 key, string memory value) external;
    function getString(bytes32 key) external view returns (string memory);

    function setBytes(bytes32 key, bytes memory value) external;
    function getBytes(bytes32 key) external view returns (bytes memory);

    function setUint(bytes32 key, uint value) external;
    function getUint(bytes32 key) external view returns (uint);

    function setInt(bytes32 key, int value) external;
    function getInt(bytes32 key) external view returns (int);

    function setAddress(bytes32 key, address value) external;
    function getAddress(bytes32 key) external view returns (address);

    function setBool(bytes32 key, bool value) external;
    function getBool(bytes32 key) external view returns (bool);

    function setBytes32(bytes32 key, bytes32 value) external;
    function getBytes32(bytes32 key) external view returns (bytes32);

    function setStringArray(bytes32 key, string[] memory value) external;
    function setIndexStringArray(bytes32 key, uint index, string memory value) external;
    function pushStringArray(bytes32 key, string memory value) external;
    function deleteStringArray(bytes32 key) external;
    function getStringArray(bytes32 key) external view returns (string[] memory);
    function indexStringArray(bytes32 key, uint index) external view returns (string memory);
    function lengthStringArray(bytes32 key) external view returns (uint);

    function setBytesArray(bytes32 key, bytes[] memory value) external;
    function setIndexBytesArray(bytes32 key, uint index, bytes memory value) external;
    function pushBytesArray(bytes32 key, bytes memory value) external;
    function deleteBytesArray(bytes32 key) external;
    function getBytesArray(bytes32 key) external view returns (bytes[] memory);
    function indexBytesArray(bytes32 key, uint index) external view returns (bytes memory);
    function lengthBytesArray(bytes32 key) external view returns (uint);

    function setUintArray(bytes32 key, uint[] memory value) external;
    function setIndexUintArray(bytes32 key, uint index, uint value) external;
    function pushUintArray(bytes32 key, uint value) external;
    function deleteUintArray(bytes32 key) external;
    function getUintArray(bytes32 key) external view returns (uint[] memory);
    function indexUintArray(bytes32 key, uint index) external view returns (uint);
    function lengthUintArray(bytes32 key) external view returns (uint);

    function setIntArray(bytes32 key, int[] memory value) external;
    function setIndexIntArray(bytes32 key, uint index, int value) external;
    function pushIntArray(bytes32 key, int value) external;
    function deleteIntArray(bytes32 key) external;
    function getIntArray(bytes32 key) external view returns (int[] memory);
    function indexIntArray(bytes32 key, uint index) external view returns (int);
    function lengthIntArray(bytes32 key) external view returns (uint);

    function setAddressArray(bytes32 key, address[] memory value) external;
    function setIndexAddressArray(bytes32 key, uint index, address value) external;
    function pushAddressArray(bytes32 key, address value) external;
    function deleteAddressArray(bytes32 key) external;
    function getAddressArray(bytes32 key) external view returns (address[] memory);
    function indexAddressArray(bytes32 key, uint index) external view returns (address);
    function lengthAddressArray(bytes32 key) external view returns (uint);

    function setBoolArray(bytes32 key, bool[] memory value) external;
    function setIndexBoolArray(bytes32 key, uint index, bool value) external;
    function pushBoolArray(bytes32 key, bool value) external;
    function deleteBoolArray(bytes32 key) external;
    function getBoolArray(bytes32 key) external view returns (bool[] memory);
    function indexBoolArray(bytes32 key, uint index) external view returns (bool);
    function lengthBoolArray(bytes32 key) external view returns (uint);

    function setBytes32Array(bytes32 key, bytes32[] memory value) external;
    function setIndexBytes32Array(bytes32 key, uint index, bytes32 value) external;
    function pushBytes32Array(bytes32 key, bytes32 value) external;
    function deleteBytes32Array(bytes32 key) external;
    function getBytes32Array(bytes32 key) external view returns (bytes32[] memory);
    function indexBytes32Array(bytes32 key, uint index) external view returns (bytes32);
    function lengthBytes32Array(bytes32 key) external view returns (uint);
    
    function addAddressSet(bytes32 key, address value) external;
    function removeAddressSet(bytes32 key, address value) external;
    function containsAddressSet(bytes32 key, address value) external view returns (bool);
    function indexAddressSet(bytes32 key, uint index) external view returns (address);
    function valuesAddressSet(bytes32 key) external view returns (address[] memory);
    function lengthAddressSet(bytes32 key) external view returns (uint);
    function addUintSet(bytes32 key, uint value) external;
    function removeUintSet(bytes32 key, uint value) external;
    function containsUintSet(bytes32 key, uint value) external view returns (bool);
    function indexUintSet(bytes32 key, uint index) external view returns (uint);
    function valuesUintSet(bytes32 key) external view returns (uint[] memory);
    function lengthUintSet(bytes32 key) external view returns (uint);
    function addBytes32Set(bytes32 key, bytes32 value) external;
    function removeBytes32Set(bytes32 key, bytes32 value) external;
    function containsBytes32Set(bytes32 key, bytes32 value) external view returns (bool);
    function indexBytes32Set(bytes32 key, uint index) external view returns (bytes32);
    function valuesBytes32Set(bytes32 key) external view returns (bytes32[] memory);
    function lengthBytes32Set(bytes32 key) external view returns (uint);
}

contract Storage is IStorage {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.AddressSet private _admins;
    EnumerableSet.AddressSet private _implementations;

    mapping(bytes32 => string) private _string;
    mapping(bytes32 => bytes) private _bytes;
    mapping(bytes32 => uint) private _uint;
    mapping(bytes32 => int) private _int;
    mapping(bytes32 => address) private _address;
    mapping(bytes32 => bool) private _bool;
    mapping(bytes32 => bytes32) private _bytes32;

    mapping(bytes32 => string[]) private _stringArray;
    mapping(bytes32 => bytes[]) private _bytesArray;
    mapping(bytes32 => uint[]) private _uintArray;
    mapping(bytes32 => int[]) private _intArray;
    mapping(bytes32 => address[]) private _addressArray;
    mapping(bytes32 => bool[]) private _boolArray;
    mapping(bytes32 => bytes32[]) private _bytes32Array;

    mapping(bytes32 => EnumerableSet.AddressSet) private _addressSet;
    mapping(bytes32 => EnumerableSet.UintSet) private _uintSet;
    mapping(bytes32 => EnumerableSet.Bytes32Set) private _bytes32Set;

    event AddAdmin(address admin);
    event RemoveAdmin(address admin);
    event AddImplementation(address indexed implementation);
    event RemoveImplementation(address indexed implementation);
    event SetString(bytes32 indexed key, string indexed value);
    event SetBytes(bytes32 indexed key, bytes indexed value);
    event SetUint(bytes32 indexed key, uint indexed value);
    event SetInt(bytes32 indexed key, int indexed value);
    event SetAddress(bytes32 indexed key, address indexed value);
    event SetBool(bytes32 indexed key, bool indexed value);
    event SetBytes32(bytes32 indexed key, bytes32 indexed value);
    event SetStringArray(bytes32 indexed key, string[] indexed value);
    event PushStringArray(bytes32 indexed key, string indexed value);
    event DeleteStringArray(bytes32 indexed key);
    event SetBytesArray(bytes32 indexed key, bytes[] indexed value);
    event PushBytesArray(bytes32 indexed key, bytes indexed value);
    event DeleteBytesArray(bytes32 indexed key);
    event SetUintArray(bytes32 indexed key, uint[] indexed value);
    event PushUintArray(bytes32 indexed key, uint indexed value);
    event DeleteUintArray(bytes32 indexed key);
    event SetIntArray(bytes32 indexed key, int[] indexed value);
    event PushIntArray(bytes32 indexed key, int indexed value);
    event DeleteIntArray(bytes32 indexed key);
    event SetAddressArray(bytes32 indexed key, address[] indexed value);
    event PushAddressArray(bytes32 indexed key, address indexed value);
    event DeleteAddressArray(bytes32 indexed key);
    event SetBoolArray(bytes32 indexed key, bool[] indexed value);
    event PushBoolArray(bytes32 indexed key, bool indexed value);
    event DeleteBoolArray(bytes32 indexed key);
    event SetBytes32Array(bytes32 indexed key, bytes32[] indexed value);
    event PushBytes32Array(bytes32 indexed key, bytes32 indexed value);
    event DeleteBytes32Array(bytes32 indexed key);
    event AddAddressSet(bytes32 indexed key, address indexed value);
    event RemoveAddressSet(bytes32 indexed key, address indexed value);
    event AddUintSet(bytes32 indexed key, uint indexed value);
    event RemoveUintSet(bytes32 indexed key, uint indexed value);
    event AddBytes32Set(bytes32 indexed key, bytes32 indexed value);
    event RemoveBytes32Set(bytes32 indexed key, bytes32 indexed value);
    event SetIndexStringArray(bytes32 indexed key, uint indexed index, string indexed value);
    event SetIndexBytesArray(bytes32 indexed key, uint indexed index, bytes indexed value);
    event SetIndexUintArray(bytes32 indexed key, uint indexed index, uint indexed value);
    event SetIndexIntArray(bytes32 indexed key, uint indexed index, int indexed value);
    event SetIndexAddressArray(bytes32 indexed key, uint indexed index, address indexed value);
    event SetIndexBoolArray(bytes32 indexed key, uint indexed index, bool indexed value);
    event SetIndexBytes32Array(bytes32 indexed key, uint indexed index, bytes32 indexed value);

    // only implementations are owners and can actually set and modify data
    modifier onlyOwner() {
        require(_implementations.contains(msg.sender), "Storage: caller is not an assigned implementation");
        _;
    }

    // admins can add and remove implementations
    modifier onlyAdmin() {
        require(_admins.contains(msg.sender), "Storage: caller is not an admin");
        _;
    }

    constructor() { // adds msg.sender as admin
        _admins.add(msg.sender);
    }

    function addAdmin(address admin)
        public
        onlyAdmin {
        _admins.add(admin);
        emit AddAdmin(admin);
    }

    function removeAdmin(address admin)
        public
        onlyAdmin {
        _admins.remove(admin);
        emit RemoveAdmin(admin);
    }

    function getAdmins()
        public view
        returns (address[] memory) {
        return _admins.values();
    }

    function addImplementation(address implementation)
        public
        onlyAdmin {
        _implementations.add(implementation);
        emit AddImplementation(implementation);
    }

    function removeImplementation(address implementation)
        public
        onlyAdmin {
        _implementations.remove(implementation);
        emit RemoveImplementation(implementation);
    }

    function getImplementations()
        public view
        returns (address[] memory) {
        return _implementations.values();
    }

    function setString(bytes32 key, string memory value)
        public
        onlyOwner {
        _string[key] = value;
        emit SetString(key, value);
    }

    function getString(bytes32 key)
        public view
        returns (string memory) {
        return _string[key];
    }

    function setBytes(bytes32 key, bytes memory value)
        public 
        onlyOwner {
        _bytes[key] = value;
        emit SetBytes(key, value);
    }

    function getBytes(bytes32 key)
        public view
        returns (bytes memory) {
        return _bytes[key];
    }

    function setUint(bytes32 key, uint value)
        public 
        onlyOwner {
        _uint[key] = value;
        emit SetUint(key, value);
    }

    function getUint(bytes32 key)
        public view 
        returns (uint) {
        return _uint[key];
    }

    function setInt(bytes32 key, int value)
        public 
        onlyOwner {
        _int[key] = value;
        emit SetInt(key, value);
    }

    function getInt(bytes32 key)
        public view
        returns (int) {
        return _int[key];
    }

    function setAddress(bytes32 key, address value)
        public 
        onlyOwner {
        _address[key] = value;
        emit SetAddress(key, value);
    }

    function getAddress(bytes32 key)
        public view
        returns (address) {
        return _address[key];
    }

    function setBool(bytes32 key, bool value)
        public 
        onlyOwner {
        _bool[key] = value;
        emit SetBool(key, value);
    }

    function getBool(bytes32 key)
        public view
        returns (bool) {
        return _bool[key];
    }

    function setBytes32(bytes32 key, bytes32 value)
        public 
        onlyOwner {
        _bytes32[key] = value;
        emit SetBytes32(key, value);
    }

    function getBytes32(bytes32 key)
        public view
        returns (bytes32) {
        return _bytes32[key];
    }

    function setStringArray(bytes32 key, string[] memory value)
        public 
        onlyOwner {
        _stringArray[key] = value;
        emit SetStringArray(key, value);
    }

    function setIndexStringArray(bytes32 key, uint index, string memory value)
        public
        onlyOwner {
        _stringArray[key][index] = value;
        emit SetIndexStringArray(key, index, value);
    }

    function pushStringArray(bytes32 key, string memory value)
        public 
        onlyOwner {
        _stringArray[key].push(value);
        emit PushStringArray(key, value);
    }

    function deleteStringArray(bytes32 key) 
        public 
        onlyOwner {
        delete _stringArray[key];
        emit DeleteStringArray(key);
    }

    function getStringArray(bytes32 key)
        public view
        returns (string[] memory) { 
        return _stringArray[key];
    }

    function indexStringArray(bytes32 key, uint index)
        public view
        returns (string memory) {
        return _stringArray[key][index];
    }

    function lengthStringArray(bytes32 key)
        public view
        returns (uint) {
        return _stringArray[key].length;
    }

    function setBytesArray(bytes32 key, bytes[] memory value)
        public 
        onlyOwner {
        _bytesArray[key] = value;
        emit SetBytesArray(key, value);
    }

    function setIndexBytesArray(bytes32 key, uint index, bytes memory value)
        public
        onlyOwner {
        _bytesArray[key][index] = value;
        emit SetIndexBytesArray(key, index, value);
    }

    function pushBytesArray(bytes32 key, bytes memory value)
        public 
        onlyOwner {
        _bytesArray[key].push(value);
        emit PushBytesArray(key, value);
    }

    function deleteBytesArray(bytes32 key)
        public 
        onlyOwner {
        delete _bytesArray[key];
        emit DeleteBytesArray(key);
    }

    function getBytesArray(bytes32 key)
        public view
        returns (bytes[] memory) {
        return _bytesArray[key];
    }

    function indexBytesArray(bytes32 key, uint index)
        public view
        returns (bytes memory) {
        return _bytesArray[key][index];
    }

    function lengthBytesArray(bytes32 key)
        public view
        returns (uint) {
        return _bytesArray[key].length;
    }

    function setUintArray(bytes32 key, uint[] memory value)
        public 
        onlyOwner {
        _uintArray[key] = value;
        emit SetUintArray(key, value);
    }

    function setIndexUintArray(bytes32 key, uint index, uint value)
        public
        onlyOwner {
        _uintArray[key][index] = value;
        emit SetIndexUintArray(key, index, value);
    }

    function pushUintArray(bytes32 key, uint value)
        public 
        onlyOwner {
        _uintArray[key].push(value);
        emit PushUintArray(key, value);
    }

    function deleteUintArray(bytes32 key)
        public 
        onlyOwner {
        delete _uintArray[key];
        emit DeleteUintArray(key);
    }

    function getUintArray(bytes32 key)
        public view
        returns (uint[] memory) {
        return _uintArray[key];
    }

    function indexUintArray(bytes32 key, uint index)
        public view
        returns (uint) {
        return _uintArray[key][index];
    }

    function lengthUintArray(bytes32 key)
        public view
        returns (uint) {
        return _uintArray[key].length;
    }

    function setIntArray(bytes32 key, int[] memory value)
        public 
        onlyOwner {
        _intArray[key] = value;
        emit SetIntArray(key, value);
    }

    function setIndexIntArray(bytes32 key, uint index, int value)
        public
        onlyOwner {
        _intArray[key][index] = value;
        emit SetIndexIntArray(key, index, value);
    }

    function pushIntArray(bytes32 key, int value)
        public 
        onlyOwner {
        _intArray[key].push(value);
        emit PushIntArray(key, value);
    }

    function deleteIntArray(bytes32 key)
        public 
        onlyOwner {
        delete _intArray[key];
        emit DeleteBytesArray(key);
    }

    function getIntArray(bytes32 key)
        public view
        returns (int[] memory) {
        return _intArray[key];
    }

    function indexIntArray(bytes32 key, uint index)
        public view
        returns (int) {
        return _intArray[key][index];
    }

    function lengthIntArray(bytes32 key)
        public view
        returns (uint) {
        return _intArray[key].length;
    }

    function setAddressArray(bytes32 key, address[] memory value)
        public 
        onlyOwner {
        _addressArray[key] = value;
        emit SetAddressArray(key, value);
    }

    function setIndexAddressArray(bytes32 key, uint index, address value)
        public
        onlyOwner {
        _addressArray[key][index] = value;
        emit SetIndexAddressArray(key, index, value);
    }

    function pushAddressArray(bytes32 key, address value)
        public 
        onlyOwner {
        _addressArray[key].push(value);
        emit PushAddressArray(key, value);
    }

    function deleteAddressArray(bytes32 key)
        public 
        onlyOwner {
        delete _addressArray[key];
        emit DeleteAddressArray(key);
    }

    function getAddressArray(bytes32 key)
        public view
        returns (address[] memory) {
        return _addressArray[key];
    }

    function indexAddressArray(bytes32 key, uint index)
        public view
        returns (address) {
        return _addressArray[key][index];
    }

    function lengthAddressArray(bytes32 key)
        public view
        returns (uint) {
        return _addressArray[key].length;
    }

    function setBoolArray(bytes32 key, bool[] memory value)
        public 
        onlyOwner {
        _boolArray[key] = value;
        emit SetBoolArray(key, value);
    }

    function setIndexBoolArray(bytes32 key, uint index, bool value)
        public
        onlyOwner {
        _boolArray[key][index] = value;
        emit SetIndexBoolArray(key, index, value);
    }

    function pushBoolArray(bytes32 key, bool value)
        public 
        onlyOwner {
        _boolArray[key].push(value);
        emit PushBoolArray(key, value);
    }

    function deleteBoolArray(bytes32 key)
        public 
        onlyOwner {
        delete _boolArray[key];
        emit DeleteBoolArray(key);
    }

    function getBoolArray(bytes32 key)
        public view
        returns (bool[] memory) {
        return _boolArray[key];
    }

    function indexBoolArray(bytes32 key, uint index)
        public view
        returns (bool) {
        return _boolArray[key][index];
    }

    function lengthBoolArray(bytes32 key)
        public view
        returns (uint) {
        return _boolArray[key].length;
    }

    function setBytes32Array(bytes32 key, bytes32[] memory value)
        public 
        onlyOwner {
        _bytes32Array[key] = value;
        emit SetBytes32Array(key, value);
    }

    function setIndexBytes32Array(bytes32 key, uint index, bytes32 value)
        public
        onlyOwner {
        _bytes32Array[key][index] = value;
        emit SetIndexBytes32Array(key, index, value);
    }

    function pushBytes32Array(bytes32 key, bytes32 value)
        public 
        onlyOwner {
        _bytes32Array[key].push(value);
        emit PushBytes32Array(key, value);
    }

    function deleteBytes32Array(bytes32 key)
        public 
        onlyOwner {
        delete _bytes32Array[key];
        emit DeleteBytes32Array(key);
    }

    function getBytes32Array(bytes32 key)
        public view
        returns (bytes32[] memory) {
        return _bytes32Array[key];
    }

    function indexBytes32Array(bytes32 key, uint index)
        public view
        returns (bytes32) {
        return _bytes32Array[key][index];
    }

    function lengthBytes32Array(bytes32 key)
        public view
        returns (uint) {
        return _bytes32Array[key].length;
    }

    function addAddressSet(bytes32 key, address value)
        public 
        onlyOwner {
        _addressSet[key].add(value);
        emit AddAddressSet(key, value);
    }

    function removeAddressSet(bytes32 key, address value)
        public 
        onlyOwner {
        _addressSet[key].remove(value);
        emit RemoveAddressSet(key, value);
    }

    function containsAddressSet(bytes32 key, address value)
        public view
        returns (bool) {
        return _addressSet[key].contains(value);
    }

    function indexAddressSet(bytes32 key, uint index)
        public view
        returns (address) {
        return _addressSet[key].at(index);
    }

    function valuesAddressSet(bytes32 key)
        public view
        returns (address[] memory) {
        return _addressSet[key].values();
    }

    function lengthAddressSet(bytes32 key)
        public view
        returns (uint) {
        return _addressSet[key].length();
    }

    function addUintSet(bytes32 key, uint value)
        public 
        onlyOwner {
        _uintSet[key].add(value);
        emit AddUintSet(key, value);
    }

    function removeUintSet(bytes32 key, uint value)
        public 
        onlyOwner {
        _uintSet[key].remove(value);
        emit RemoveUintSet(key, value);
    }

    function containsUintSet(bytes32 key, uint value)
        public view
        returns (bool) {
        return _uintSet[key].contains(value);
    }

    function indexUintSet(bytes32 key, uint index)
        public view
        returns (uint) {
        return _uintSet[key].at(index);
    }

    function valuesUintSet(bytes32 key)
        public view
        returns (uint[] memory) {
        return _uintSet[key].values();
    }

    function lengthUintSet(bytes32 key)
        public view
        returns (uint) {
        return _uintSet[key].length();
    }

    function addBytes32Set(bytes32 key, bytes32 value)
        public 
        onlyOwner {
        _bytes32Set[key].add(value);
        emit AddBytes32Set(key, value);
    }

    function removeBytes32Set(bytes32 key, bytes32 value)
        public 
        onlyOwner {
        _bytes32Set[key].remove(value);
        emit RemoveBytes32Set(key, value);
    }

    function containsBytes32Set(bytes32 key, bytes32 value)
        public view
        returns (bool) {
        return _bytes32Set[key].contains(value);
    }

    function indexBytes32Set(bytes32 key, uint index)
        public view
        returns (bytes32) {
        return _bytes32Set[key].at(index);
    }

    function valuesBytes32Set(bytes32 key)
        public view
        returns (bytes32[] memory) {
        return _bytes32Set[key].values();
    }

    function lengthBytes32Set(bytes32 key)
        public view
        returns (uint) {
        return _bytes32Set[key].length();
    }
}