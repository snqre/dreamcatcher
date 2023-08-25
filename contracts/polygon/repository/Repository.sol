// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/repository/IRepository.sol";

contract Repository is IRepository {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.AddressSet private _admins;
    EnumerableSet.AddressSet private _logics;

    mapping(bytes32 => string)       private _string;
    mapping(bytes32 => bytes)        private _bytes;
    mapping(bytes32 => uint)         private _uint;
    mapping(bytes32 => int)          private _int;
    mapping(bytes32 => address)      private _address;
    mapping(bytes32 => bool)         private _bool;
    mapping(bytes32 => bytes32)      private _bytes32;
    mapping(bytes32 => string[])     private _stringArray;
    mapping(bytes32 => bytes[])      private _bytesArray;
    mapping(bytes32 => uint[])       private _uintArray;
    mapping(bytes32 => int[])        private _intArray;
    mapping(bytes32 => address[])    private _addressArray;
    mapping(bytes32 => bool[])       private _boolArray;
    mapping(bytes32 => bytes32[])    private _bytes32Array;

    mapping(bytes32 => EnumerableSet.AddressSet) private _addressSet;
    mapping(bytes32 => EnumerableSet.UintSet)    private _uintSet;
    mapping(bytes32 => EnumerableSet.Bytes32Set) private _bytes32Set;

    event AdminAdded(address indexed account);
    event LogicAdded(address indexed account);

    event AdminRemoved(address indexed account);
    event LogicRemoved(address indexed account);

    event StringUpdated(bytes32 indexed key, string indexed value);
    event BytesUpdated(bytes32 indexed key, bytes indexed value);
    event UintUpdated(bytes32 indexed key, uint indexed value);
    event IntUpdated(bytes32 indexed key, int indexed value);
    event AddressUpdated(bytes32 indexed key, address indexed value);
    event BoolUpdated(bytes32 indexed key, bool indexed value);
    event Bytes32Updated(bytes32 indexed key, bytes32 indexed value);

    event StringArrayUpdated(bytes32 indexed key, uint indexed index, string indexed value);
    event BytesArrayUpdated(bytes32 indexed key, uint indexed index, bytes indexed value);
    event UintArrayUpdated(bytes32 indexed key, uint indexed index, uint indexed value);
    event IntArrayUpdated(bytes32 indexed key, uint indexed index, int indexed value);
    event AddressArrayUpdated(bytes32 indexed key, uint indexed index, address indexed value);
    event BoolArrayUpdated(bytes32 indexed key, uint indexed index, bool indexed value);
    event Bytes32ArrayUpdated(bytes32 indexed key, uint indexed index, bytes32 indexed value);

    event StringArrayPushed(bytes32 indexed key, string indexed value);
    event BytesArrayPushed(bytes32 indexed key, bytes indexed value);
    event UintArrayPushed(bytes32 indexed key, uint indexed value);
    event IntArrayPushed(bytes32 indexed key, int indexed value);
    event AddressArrayPushed(bytes32 indexed key, address indexed value);
    event BoolArrayPushed(bytes32 indexed key, bool indexed value);
    event Bytes32ArrayPushed(bytes32 indexed key, bytes32 indexed value);

    event StringArrayDeleted(bytes32 indexed key);
    event BytesArrayDeleted(bytes32 indexed key);
    event UintArrayDeleted(bytes32 indexed key);
    event IntArrayDeleted(bytes32 indexed key);
    event AddressArrayDeleted(bytes32 indexed key);
    event BoolArrayDeleted(bytes32 indexed key);
    event Bytes32ArrayDeleted(bytes32 indexed key);

    event AddressSetValueAdded(bytes32 indexed key, address indexed value);
    event UintSetValueAdded(bytes32 indexed key, uint indexed value);
    event Bytes32SetValueAdded(bytes32 indexed key, bytes32 indexed value);

    event AddressSetValueRemoved(bytes32 indexed key, address indexed value);
    event UintSetValueRemoved(bytes32 indexed key, uint indexed value);
    event Bytes32SetValueRemoved(bytes32 indexed key, bytes32 indexed value);

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    modifier onlyLogic() {
        _onlyLogic();
        _;
    }

    constructor() {
        _admins.add(msg.sender);
    }

    function getAdmins()
    external view
    returns (address[] memory) {
        return _admins.values();
    }

    function getLogics()
    external view
    returns (address[] memory) {
        return _logics.values();
    }

    function getString(bytes32 key)
    external view
    returns (string memory) {
        return _string[key];
    }

    function getBytes(bytes32 key)
    external view
    returns (bytes memory) {
        return _bytes[key];
    }

    function getUint(bytes32 key)
    external view
    returns (uint) {
        return _uint[key];
    }

    function getInt(bytes32 key)
    external view
    returns (int) {
        return _int[key];
    }

    function getAddress(bytes32 key)
    external view
    returns (address) {
        return _address[key];
    }

    function getBool(bytes32 key)
    external view
    returns (bool) {
        return _bool[key];
    }

    function getBytes32(bytes32 key)
    external view
    returns (bytes32) {
        return _bytes32[key];
    }

    function getStringArray(bytes32 key)
    external view
    returns (string[] memory) {
        return _stringArray[key];
    }

    function getBytesArray(bytes32 key)
    external view
    returns (bytes[] memory) {
        return _bytesArray[key];
    }

    function getUintArray(bytes32 key)
    external view
    returns (uint[] memory) {
        return _uintArray[key];
    }

    function getIntArray(bytes32 key)
    external view
    returns (int[] memory) {
        return _intArray[key];
    }

    function getAddressArray(bytes32 key)
    external view
    returns (address[] memory) {
        return _addressArray[key];
    }

    function getBoolArray(bytes32 key)
    external view
    returns (bool[] memory) {
        return _boolArray[key];
    }

    function getBytes32Array(bytes32 key)
    external view
    returns (bytes32[] memory) {
        return _bytes32Array[key];
    }

    function getIndexedStringArray(bytes32 key, uint index)
    external view
    returns (string memory) {
        return _stringArray[key][index];
    }

    function getIndexedBytesArray(bytes32 key, uint index)
    external view
    returns (bytes memory) {
        return _bytesArray[key][index];
    }

    function getIndexedUintArray(bytes32 key, uint index)
    external view
    returns (uint) {
        return _uintArray[key][index];
    }

    function getIndexedIntArray(bytes32 key, uint index)
    external view
    returns (int) {
        return _intArray[key][index];
    }

    function getIndexedAddressArray(bytes32 key, uint index)
    external view
    returns (address) {
        return _addressArray[key][index];
    }

    function getIndexedBoolArray(bytes32 key, uint index)
    external view
    returns (bool) {
        return _boolArray[key][index];
    }

    function getIndexedBytes32Array(bytes32 key, uint index)
    external view
    returns (bytes32) {
        return _bytes32Array[key][index];
    }

    function getLengthStringArray(bytes32 key)
    external view
    returns (uint) {
        return _stringArray[key].length;
    }

    function getLengthBytesArray(bytes32 key)
    external view
    returns (uint) {
        return _bytesArray[key].length;
    }

    function getLengthUintArray(bytes32 key)
    external view
    returns (uint) {
        return _uintArray[key].length;
    }

    function getLengthIntArray(bytes32 key)
    external view
    returns (uint) {
        return _intArray[key].length;
    }

    function getLengthAddressArray(bytes32 key)
    external view
    returns (uint) {
        return _addressArray[key].length;
    }

    function getLengthBoolArray(bytes32 key)
    external view
    returns (uint) {
        return _boolArray[key].length;
    }

    function getLengthBytes32Array(bytes32 key)
    external view
    returns (uint) {
        return _bytes32Array[key].length;
    }

    function getAddressSet(bytes32 key)
    external view
    returns (address[] memory) {
        return _addressSet[key].values();
    }

    function getUintSet(bytes32 key)
    external view
    returns (uint[] memory) {
        return _uintSet[key].values();
    }

    function getBytes32Set(bytes32 key)
    external view
    returns (bytes32[] memory) {
        return _bytes32Set[key].values();
    }

    function getIndexedAddressSet(bytes32 key, uint index)
    external view
    returns (address) {
        return _addressSet[key].at(index);
    }

    function getIndexedUintSet(bytes32 key, uint index)
    external view
    returns (uint) {
        return _uintSet[key].at(index);
    }

    function getIndexedBytes32Set(bytes32 key, uint index)
    external view
    returns (bytes32) {
        return _bytes32Set[key].at(index);
    }

    function getLengthAddressSet(bytes32 key)
    external view
    returns (uint) {
        return _addressSet[key].length();
    }

    function getLengthUintSet(bytes32 key)
    external view
    returns (uint) {
        return _uintSet[key].length();
    }

    function getLengthBytes32Set(bytes32 key)
    external view
    returns (uint) {
        return _bytes32Set[key].length();
    }

    function addressSetContains(bytes32 key, address value)
    external view
    returns (bool) {
        return _addressSet[key].contains(value);
    }

    function uintSetContains(bytes32 key, uint value)
    external view
    returns (bool) {
        return _uintSet[key].contains(value);
    }

    function bytes32SetContains(bytes32 key, bytes32 value)
    external view
    returns (bool) {
        return _bytes32Set[key].contains(value);
    }

    function addAdmin(address account)
    external 
    onlyAdmin {
        require(account != address(0), "Repository: cannot add admin because account is address zero");
        require(!_admins.contains(account), "Repository: cannot add admin because account is already admin");
        require(!_logics.contains(account), "Repository: cannot add admin because account is logic");
        _admins.add(account);
        emit AdminAdded(account);
    }

    function addLogic(address account)
    external
    onlyAdmin {
        require(account != address(0), "Repository: cannot add logic because account is address zero");
        require(!_logics.contains(account), "Repository: cannot add logic because account is already logic");
        require(!_admins.contains(account), "Repository: cannot add logic because account is admin");
        _logics.add(account);
        emit LogicAdded(account);
    }

    function removeAdmin(address account)
    external
    onlyAdmin {
        require(_admins.contains(account), "Repository: cannot remove admin because account is not admin");
        _admins.remove(account);
        emit AdminRemoved(account);
    }

    function removeLogic(address account)
    external
    onlyAdmin {
        require(_logics.contains(account), "Repository: cannot remove logic because account is not logic");
        _logics.remove(account);
        emit LogicRemoved(account);
    }

    function setString(bytes32 key, string memory value)
    external
    onlyLogic {
        _string[key] = value;
        emit StringUpdated(key, value);
    }

    function setBytes(bytes32 key, bytes memory value)
    external
    onlyLogic {
        _bytes[key] = value;
        emit BytesUpdated(key, value);
    }

    function setUint(bytes32 key, uint value)
    external
    onlyLogic {
        _uint[key] = value;
        emit UintUpdated(key, value);
    }

    function setInt(bytes32 key, int value)
    external
    onlyLogic {
        _int[key] = value;
        emit IntUpdated(key, value);
    }

    function setAddress(bytes32 key, address value)
    external
    onlyLogic {
        _address[key] = value;
        emit AddressUpdated(key, value);
    }

    function setBool(bytes32 key, bool value)
    external
    onlyLogic {
        _bool[key] = value;
        emit BoolUpdated(key, value);
    }

    function setBytes32(bytes32 key, bytes32 value)
    external
    onlyLogic {
        _bytes32[key] = value;
        emit Bytes32Updated(key, value);
    }

    function setStringArray(bytes32 key, uint index, string memory value)
    external
    onlyLogic {
        _stringArray[key][index] = value;
        emit StringArrayUpdated(key, index, value);
    }

    function setBytesArray(bytes32 key, uint index, bytes memory value)
    external
    onlyLogic {
        _bytesArray[key][index] = value;
        emit BytesArrayUpdated(key, index, value);
    }

    function setUintArray(bytes32 key, uint index, uint value)
    external
    onlyLogic {
        _uintArray[key][index] = value;
        emit UintArrayUpdated(key, index, value);
    }

    function setIntArray(bytes32 key, uint index, int value)
    external
    onlyLogic {
        _intArray[key][index] = value;
        emit IntArrayUpdated(key, index, value);
    }

    function setAddressArray(bytes32 key, uint index, address value)
    external
    onlyLogic {
        _addressArray[key][index] = value;
        emit AddressArrayUpdated(key, index, value);
    }

    function setBoolArray(bytes32 key, uint index, bool value)
    external
    onlyLogic {
        _boolArray[key][index] = value;
        emit BoolArrayUpdated(key, index, value);
    }

    function setBytes32Array(bytes32 key, uint index, bytes32 value)
    external
    onlyLogic {
        _bytes32Array[key][index] = value;
        emit Bytes32ArrayUpdated(key, index, value);
    }

    function pushStringArray(bytes32 key, string memory value)
    external
    onlyLogic {
        _stringArray[key].push(value);
        emit StringArrayPushed(key, value);
    }

    function pushBytesArray(bytes32 key, bytes memory value)
    external
    onlyLogic {
        _bytesArray[key].push(value);
        emit BytesArrayPushed(key, value);
    }

    function pushUintArray(bytes32 key, uint value)
    external
    onlyLogic {
        _uintArray[key].push(value);
        emit UintArrayPushed(key, value);
    }

    function pushIntArray(bytes32 key, int value)
    external
    onlyLogic {
        _intArray[key].push(value);
        emit IntArrayPushed(key, value);
    }

    function pushAddressArray(bytes32 key, address value)
    external
    onlyLogic {
        _addressArray[key].push(value);
        emit AddressArrayPushed(key, value);
    }

    function pushBoolArray(bytes32 key, bool value)
    external
    onlyLogic {
        _boolArray[key].push(value);
        emit BoolArrayPushed(key, value);
    }

    function pushBytes32Array(bytes32 key, bytes32 value)
    external
    onlyLogic {
        _bytes32Array[key].push(value);
        emit Bytes32ArrayPushed(key, value);
    }

    function deleteStringArray(bytes32 key)
    external
    onlyLogic {
        delete _stringArray[key];
        emit StringArrayDeleted(key);
    }

    function deleteBytesArray(bytes32 key)
    external
    onlyLogic {
        delete _bytesArray[key];
        emit BytesArrayDeleted(key);
    }

    function deleteUintArray(bytes32 key)
    external
    onlyLogic {
        delete _uintArray[key];
        emit UintArrayDeleted(key);
    }

    function deleteIntArray(bytes32 key)
    external
    onlyLogic {
        delete _intArray[key];
        emit IntArrayDeleted(key);
    }

    function deleteAddressArray(bytes32 key)
    external
    onlyLogic {
        delete _addressArray[key];
        emit AddressArrayDeleted(key);
    }

    function deleteBoolArray(bytes32 key)
    external
    onlyLogic {
        delete _boolArray[key];
        emit BoolArrayDeleted(key);
    }

    function deleteBytes32Array(bytes32 key)
    external
    onlyLogic {
        delete _bytes32Array[key];
        emit Bytes32ArrayDeleted(key);
    }

    function addAddressSet(bytes32 key, address value)
    external 
    onlyLogic {
        _addressSet[key].add(value);
        emit AddressSetValueAdded(key, value);
    }

    function addUintSet(bytes32 key, uint value)
    external 
    onlyLogic {
        _uintSet[key].add(value);
        emit UintSetValueAdded(key, value);
    }

    function addBytes32Set(bytes32 key, bytes32 value)
    external
    onlyLogic {
        _bytes32Set[key].add(value);
        emit Bytes32SetValueAdded(key, value);
    }

    function removeAddressSet(bytes32 key, address value)
    external 
    onlyLogic {
        _addressSet[key].remove(value);
        emit AddressSetValueRemoved(key, value);
    }

    function removeUintSet(bytes32 key, uint value)
    external
    onlyLogic {
        _uintSet[key].remove(value);
        emit UintSetValueRemoved(key, value);
    }

    function removeBytes32Set(bytes32 key, bytes32 value)
    external 
    onlyLogic {
        _bytes32Set[key].remove(value);
        emit Bytes32SetValueRemoved(key, value);
    }

    function _onlyAdmin()
    internal view {
        require(_admins.contains(msg.sender), "Repository: msg.sender != admin");
    }

    function _onlyLogic()
    internal view {
        require(_logics.contains(msg.sender), "Repository: msg.sender != logic");
    }
}