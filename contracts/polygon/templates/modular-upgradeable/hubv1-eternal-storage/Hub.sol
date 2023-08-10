// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC721/ERC721.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

enum DataType {
    NONE,
    STRING,
    BYTES,
    UINT,
    INT,
    ADDRESS,
    BOOL,
    BYTES32,
    STRING_ARRAY,
    BYTES_ARRAY,
    UINT_ARRAY,
    INT_ARRAY,
    ADDRESS_ARRAY,
    BOOL_ARRAY,
    BYTES32_ARRAY,
    ADDRESS_SET,
    UINT_SET,
    BYTES32_SET
}

enum KeyType {
    STANDARD,
    TIMED,
    CONSUMABLE
}

contract Database is Storage {}

/**

    #purpose
    1) manage roles
    2) manage access to individual functions
    3) act as a universal access to bypass validation
    4) timelock

 */

library Match {
    function isMatchingBytes(bytes memory bytesA, bytes memory bytesB)
    external pure
    returns (bool isMatch) {
        return keccak256(bytesA) ==keccak256(bytesB);
    }

    function isMatchingString(string memory stringA, string memory stringB)
    external pure
    returns (bool isMatch) {
        return keccak256(abi.encodePacked(stringA)) ==keccak256(abi.encodePacked(stringB));
    }
}



library Utils {
    function convertToWei(uint value)
    external pure
    returns (uint) {
        return value * (10**18);
    }

    function requireSuccess(bool success)
    external pure {
        require(success, "Utils: !success");
    }
}



library Encoder {
    function encode(string memory string_)
    external pure
    returns (bytes32 variable) {
        keccak256(abi.encode(string_));
    }

    function encodeKey(address contract_, string memory signature, KeyType keyType, uint startTimestamp, uint endTimestamp, uint balance)
    external pure
    returns (bytes memory key) {
        return abi.encode(contract_, signature, keyType, startTimestamp, endTimestamp, balance);
    }

    function decodeKey(bytes memory key)
    external pure
    returns (address contract_, string memory signature, KeyType keyType, uint startTimestamp, uint endTimestamp, uint balance) {
        return abi.decode(key, (address,string,KeyType,uint,uint,uint));
    }

    function encodeRequest(address[] memory targets, string[] memory signatures, bytes[] memory args, uint endTimelockTimestamp, uint endTimeoutTimestamp, bool approved, bool rejected, bool executed)
    external pure
    returns (bytes memory request) {
        return abi.encode(targets, signatures, args, endTimelockTimestamp, endTimeoutTimestamp, approved, rejected, executed);
    }

    function decodeRequest(bytes memory request)
    external pure
    returns (address[] memory targets, string[] memory signatures, bytes[] memory args, uint endTimelockTimestamp, uint endTimeoutTimestamp, bool approved, bool rejected, bool executed) {
        return abi.decode(request, (address[],string[],bytes[],uint,uint,bool,bool,bool));
    }

    function account(address account, string memory property)
    external pure
    returns (bytes32 variable) {
        return keccak256(abi.encode(account, property));
    }

    function role(string memory role, string memory property)
    external pure
    returns (bytes32 variable) {
        return keccak256(abi.encode(role, property));
    }
}



interface IStorage {
    // GET ADMIN & LOGIC

    function getAdmins() external view returns (address[] memory);
    function getLogics() external view returns (address[] memory);

    // GET BASIC

    function getString(bytes32 key) external view returns (string memory);
    function getBytes(bytes32 key) external view returns (bytes memory);
    function getUint(bytes32 key) external view returns (uint);
    function getInt(bytes32 key) external view returns (int);
    function getAddress(bytes32 key) external view returns (address);
    function getBool(bytes32 key) external view returns (bool);
    function getBytes32(bytes32 key) external view returns (bytes32);

    // GET ARRAYS

    function getStringArray(bytes32 key) external view returns (string[] memory);
    function getBytesArray(bytes32 key) external view returns (bytes[] memory);
    function getUintArray(bytes32 key) external view returns (uint[] memory);
    function getIntArray(bytes32 key) external view returns (int[] memory);
    function getAddressArray(bytes32 key) external view returns (address[] memory);
    function getBoolArray(bytes32 key) external view returns (bool[] memory);
    function getBytes32Array(bytes32 key) external view returns (bytes32[] memory);

    // GET INDEXED ARRAYS

    function indexStringArray(bytes32 key, uint index) external view returns (string memory);
    function indexBytesArray(bytes32 key, uint index) external view returns (bytes memory);
    function indexUintArray(bytes32 key, uint index) external view returns (uint);
    function indexIntArray(bytes32 key, uint index) external view returns (int);
    function indexAddressArray(bytes32 key, uint index) external view returns (address);
    function indexBoolArray(bytes32 key, uint index) external view returns (bool);
    function indexBytes32Array(bytes32 key, uint index) external view returns (bytes32);

    // GET SETS

    function getAddressSet(bytes32 key) external view returns (address[] memory);
    function getUintSet(bytes32 key) external view returns (uint[] memory);
    function getBytes32Set(bytes32 key) external view returns (bytes32[] memory);

    // GET INDEXED SETS

    function indexAddressSet(bytes32 key, uint index) external view returns (address);
    function indexUintSet(bytes32 key, uint index) external view returns (uint);
    function indexBytes32Set(bytes32 key, uint index) external view returns (bytes32);

    // CONTAINS SETS

    function containsAddressSet(bytes32 key, address value) external view returns (bool);
    function containsUintSet(bytes32 key, uint value) external view returns (bool);
    function containsBytes32Set(bytes32 key, bytes32 value) external view returns (bool);

    // SET ADMIN & LOGIC

    function addAdmin(address admin) external;
    function removeAdmin(address admin) external;
    function addLogic(address logic) external;
    function removeLogic(address logic) external;

    // SET BASIC

    function setString(bytes32 key, string memory value) external;
    function setBytes(bytes32 key, bytes memory value) external;
    function setUint(bytes32 key, uint value) external;
    function setInt(bytes32 key, int value) external;
    function setAddress(bytes32 key, address value) external;
    function setBool(bytes32 key, bool value) external;
    function setBytes32(bytes32 key, bytes32 value) external;

    // SET ARRAYS

    function setIndexStringArray(bytes32 key, uint index, string memory value) external;
    function setIndexBytesArray(bytes32 key, uint index, bytes memory value) external;
    function setIndexUintArray(bytes32 key, uint index, uint value) external;
    function setIndexIntArray(bytes32 key, uint index, int value) external;
    function setIndexAddressArray(bytes32 key, uint index, address value) external;
    function setIndexBoolArray(bytes32 key, uint index, bool value) external;
    function setIndexBytes32Array(bytes32 key, uint index, bytes32 value) external;

    // PUSH ARRAYS

    function pushStringArray(bytes32 key, string memory value) external;
    function pushBytesArray(bytes32 key, bytes memory value) external;
    function pushUintArray(bytes32 key, uint value) external;
    function pushIntArray(bytes32 key, int value) external;
    function pushAddressArray(bytes32 key, address value) external;
    function pushBoolArray(bytes32 key, bool value) external;
    function pushBytes32Array(bytes32 key, bytes32 value) external;

    // DELETE ARRAYS

    function deleteStringArray(bytes32 key) external;
    function deleteBytesArray(bytes32 key) external;
    function deleteUintArray(bytes32 key) external;
    function deleteIntArray(bytes32 key) external;
    function deleteAddressArray(bytes32 key) external;
    function deleteBoolArray(bytes32 key) external;
    function deleteBytes32Array(bytes32 key) external;

    // ADD SETS

    function addAddressSet(bytes32 key, address value) external;
    function addUintSet(bytes32 key, uint value) external;
    function addBytes32Set(bytes32 key, bytes32 value) external;

    // REMOVE SETS

    function removeAddressSet(bytes32 key, address value) external;
    function removeUintSet(bytes32 key, uint value) external;
    function removeBytes32Set(bytes32 key, bytes32 value) external;
}



contract Storage {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.AddressSet internal _admins;
    EnumerableSet.AddressSet internal _implementations;

    mapping(bytes32 => DataType) internal _usedKeys;

    mapping(bytes32 => string) internal _string;
    mapping(bytes32 => bytes) internal _bytes;
    mapping(bytes32 => uint) internal _uint;
    mapping(bytes32 => int) internal _int;
    mapping(bytes32 => address) internal _address;
    mapping(bytes32 => bool) internal _bool;
    mapping(bytes32 => bytes32) internal _bytes32;

    mapping(bytes32 => string[]) internal _stringArray;
    mapping(bytes32 => bytes[]) internal _bytesArray;
    mapping(bytes32 => uint[]) internal _uintArray;
    mapping(bytes32 => int[]) internal _intArray;
    mapping(bytes32 => address[]) internal _addressArray;
    mapping(bytes32 => bool[]) internal _boolArray;
    mapping(bytes32 => bytes32[]) private _bytes32Array;

    mapping(bytes32 => EnumerableSet.AddressSet) internal _addressSet;
    mapping(bytes32 => EnumerableSet.UintSet) internal _uintSet;
    mapping(bytes32 => EnumerableSet.Bytes32Set) internal _bytes32Set;

    // ADMIN & LOGIC EVENTS

    event AddAdmin(address indexed admin);
    event RemoveAdmin(address indexed admin);

    event AddLogic(address indexed logic);
    event RemoveLogic(address indexed logic);

    // BASIC EVENTS

    event SetString(bytes32 indexed key, string indexed value);
    event SetBytes(bytes32 indexed key, bytes indexed value);
    event SetUint(bytes32 indexed key, uint indexed value);
    event SetInt(bytes32 indexed key, int indexed value);
    event SetAddress(bytes32 indexed key, address indexed value);
    event SetBool(bytes32 indexed key, bool indexed value);
    event SetBytes32(bytes32 indexed key, bytes32 indexed value);

    // ARRAY EVENTS

    event SetIndexStringArray(bytes32 indexed key, uint indexed index, string indexed value);
    event SetIndexBytesArray(bytes32 indexed key, uint indexed index, bytes indexed value);
    event SetIndexUintArray(bytes32 indexed key, uint indexed index, uint indexed value);
    event SetIndexIntArray(bytes32 indexed key, uint indexed index, int indexed value);
    event SetIndexAddressArray(bytes32 indexed key, uint indexed index, address indexed value);
    event SetIndexBoolArray(bytes32 indexed key, uint indexed index, bool indexed value);
    event SetIndexBytes32Array(bytes32 indexed key, uint indexed index, bytes32 indexed value);

    event PushStringArray(bytes32 indexed key, string indexed value);
    event PushBytesArray(bytes32 indexed key, bytes indexed value);
    event PushUintArray(bytes32 indexed key, uint indexed value);
    event PushIntArray(bytes32 indexed key, int indexed value);
    event PushAddressArray(bytes32 indexed key, address indexed value);
    event PushBoolArray(bytes32 indexed key, bool indexed value);
    event PushBytes32Array(bytes32 indexed key, bytes32 indexed value);
    
    event DeleteStringArray(bytes32 indexed key);
    event DeleteBytesArray(bytes32 indexed key);
    event DeleteUintArray(bytes32 indexed key);
    event DeleteIntArray(bytes32 indexed key);
    event DeleteAddressArray(bytes32 indexed key);
    event DeleteBoolArray(bytes32 indexed key);
    event DeleteBytes32Array(bytes32 indexed key);

    // SET EVENTS

    event AddAddressSet(bytes32 indexed key, address indexed value);
    event AddUintSet(bytes32 indexed key, uint indexed value);
    event AddBytes32Set(bytes32 indexed key, bytes32 indexed value);

    event RemoveAddressSet(bytes32 indexed key, address indexed value);
    event RemoveUintSet(bytes32 indexed key, uint indexed value);
    event RemoveBytes32Set(bytes32 indexed key, bytes32 indexed value);

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    modifier onlyLogic() {
        _onlyLogic();
        _;
    }

    modifier onlyDataType(bytes32 key, DataType dataType) {
        _onlyDataTypeCheck({key: key, dataType: dataType});
        _;
        _afterCheckDataTypeSet({key: key, dataType: dataType});
    }

    modifier onlyDataTypeCheck(bytes32 key, DataType dataType) {
        _onlyDataTypeCheck({key: key, dataType: dataType});
        _;
    }

    modifier onlyNotEmptyKey(bytes32 key) {
        _onlyNotEmptyKey({key: key});
        _;
    }

    constructor() {
        _admins.add(msg.sender);
    }

    // GET ADMIN & LOGIC

    function getAdmins()
    external view
    returns (address[] memory) {
        return _admins.values();
    }

    function getLogics()
    external view
    returns (address[] memory) {
        return _implementations.values();
    }

    // GET BASIC

    function getString(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.STRING)
    returns (string memory) {
        return _string[key];
    }

    function getBytes(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.BYTES)
    returns (bytes memory) {
        return _bytes[key];
    }

    function getUint(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.UINT)
    returns (uint) {
        return _uint[key];
    }

    function getInt(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.INT)
    returns (int) {
        return _int[key];
    }

    function getAddress(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.ADDRESS)
    returns (address) {
        return _address[key];
    }

    function getBool(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.BOOL)
    returns (bool) {
        return _bool[key];
    }

    function getBytes32(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.BYTES32)
    returns (bytes32) {
        return _bytes32[key];
    }

    // GET ARRAYS

    function getStringArray(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.STRING_ARRAY) 
    returns (string[] memory) {
        return _stringArray[key];
    }

    function getBytesArray(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.BYTES_ARRAY)
    returns (bytes[] memory) {
        return _bytesArray[key];
    }

    function getUintArray(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.UINT_ARRAY)
    returns (uint[] memory) {
        return _uintArray[key];
    }

    function getIntArray(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.INT_ARRAY)
    returns (int[] memory) {
        return _intArray[key];
    }

    function getAddressArray(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.ADDRESS_ARRAY)
    returns (address[] memory) {
        return _addressArray[key];
    }

    function getBoolArray(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.BOOL_ARRAY)
    returns (bool[] memory) {
        return _boolArray[key];
    }

    function getBytes32Array(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.BYTES32_ARRAY)
    returns (bytes32[] memory) {
        return _bytes32Array[key];
    }

    // GET INDEXED ARRAYS

    function indexStringArray(bytes32 key, uint index)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.STRING_ARRAY)
    returns (string memory) {
        require(index <_stringArray[key].length, "Storage: index not found");
        return _stringArray[key][index];
    }

    function indexBytesArray(bytes32 key, uint index)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.BYTES_ARRAY)
    returns (bytes memory) {
        require(index <_bytesArray[key].length, "Storage: index not found");
        return _bytesArray[key][index];
    }

    function indexUintArray(bytes32 key, uint index)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.UINT_ARRAY)
    returns (uint) {
        require(index <_uintArray[key].length, "Storage: index not found");
        return _uintArray[key][index];
    }

    function indexIntArray(bytes32 key, uint index)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.INT_ARRAY)
    returns (int) {
        require(index <_intArray[key].length, "Storage: index not found");
        return _intArray[key][index];
    }

    function indexAddressArray(bytes32 key, uint index)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.ADDRESS_ARRAY)
    returns (address) {
        require(index <_addressArray[key].length, "Storage: index not found");
        return _addressArray[key][index];
    }

    function indexBoolArray(bytes32 key, uint index)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.BOOL_ARRAY)
    returns (bool) {
        require(index <_boolArray[key].length, "Storage: index not found");
        return _boolArray[key][index];
    }

    function indexBytes32Array(bytes32 key, uint index)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.BYTES32_ARRAY)
    returns (bytes32) {
        require(index <_bytes32Array[key].length, "Storage: index not found");
        return _bytes32Array[key][index];
    }

    // GET SETS

    function getAddressSet(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.ADDRESS_SET)
    returns (address[] memory) {
        return _addressSet[key].values();
    }

    function getUintSet(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.UINT_SET)
    returns (uint[] memory) {
        return _uintSet[key].values();
    }

    function getBytes32Set(bytes32 key)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.BYTES32_SET)
    returns (bytes32[] memory) {
        return _bytes32Set[key].values();
    }

    // GET INDEXED SETS

    function indexAddressSet(bytes32 key, uint index)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.ADDRESS_SET)
    returns (address) {
        return _addressSet[key].at(index);
    }

    function indexUintSet(bytes32 key, uint index)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.UINT_SET)
    returns (uint) {
        return _uintSet[key].at(index);
    }

    function indexBytes32Set(bytes32 key, uint index)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.BYTES32_SET)
    returns (bytes32) {
        return _bytes32Set[key].at(index);
    }

    // CONTAINS SETS

    function containsAddressSet(bytes32 key, address value)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.ADDRESS_SET)
    returns (bool) {
        return _addressSet[key].contains(value);
    }

    function containsUintSet(bytes32 key, uint value)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCheck(key, DataType.UINT_SET)
    returns (bool) {
        return _uintSet[key].contains(value);
    }

    function containsBytes32Set(bytes32 key, bytes32 value)
    external view
    onlyNotEmptyKey(key)
    onlyDataTypeCehck(key, DataType.BYTES32_SET)
    returns (bool) {
        return _bytes32Set[key].contains(value);
    }

    // SET ADMIN & LOGIC

    function addAdmin(address admin)
    external
    onlyAdmin {
        require(admin !=address(0), "Storage: admin is address zero");
        require(!_implementations.contains(admin), "Storage: admin is logic");
        require(!_admins.contains(admin), "Storage: duplicate assignment");
        _admins.add(admin);
        emit AddAdmin({admin: admin});
    }

    function removeAdmin(address admin)
    external
    onlyAdmin {
        require(admin !=address(0), "Storage: admin is address zero");
        require(!_implementations.contains(admin), "Storage: admin is logic");
        require(_admins.contains(admin), "Storage: admin not found");
        _admins.remove(admin);
        emit RemoveAdmin({admin: admin});
    }

    function addLogic(address logic)
    external
    onlyAdmin {
        require(logic !=address(0), "Storage: logic is address zero");
        require(!_admins.contains(logic), "Storage: logic is admin");
        require(!_implementations.contains(logic), "Storage: duplicate assignment");
        _implementations.add(logic);
        emit AddLogic({logic: logic});
    }

    function removeLogic(address logic)
    external
    onlyAdmin {
        require(logic !=address(0), "Storage: logic is address zero");
        require(!_admins.contains(logic), "Storage: logic is admin");
        require(_implementations.contains(logic), "Storage: logic not found");
        _implementations.remove(logic);
        emit RemoveLogic({logic: logic});
    }

    // SET BASIC

    function setString(bytes32 key, string memory value)
    external
    onlyLogic 
    onlyNotEmptyKey(key) 
    onlyDataType(key, DataType.STRING) {
        _string[key] =value;
        if (_usedKeys[key] ==DataType.NULL)
        emit SetString({key: key, value: value});
    }
    
    function setBytes(bytes32 key, bytes memory value)
    external
    onlyLogic 
    onlyNotEmptyKey(key) 
    onlyDataType(key, DataType.BYTES) {
        _bytes[key] =value;
        emit SetBytes({key: key, value: value});
    }

    function setUint(bytes32 key, uint value)
    external
    onlyLogic 
    onlyNotEmptyKey(key) 
    onlyDataType(key, DataType.UINT) {
        _uint[key] =value;
        emit SetUint({key: key, value: value});
    }

    function setInt(bytes32 key, int value)
    external
    onlyLogic
    onlyNotEmptyKey(key) 
    onlyDataType(key, DataType.INT) {
        _int[key] =value;
        emit SetInt({key: key, value: value});
    }

    function setAddress(bytes32 key, address value)
    external
    onlyLogic
    onlyNotEmptyKey(key) 
    onlyDataType(key, DataType.ADDRESS) {
        _address[key] =value;
        emit SetAddress({key: key, value: value});
    }

    function setBool(bytes32 key, bool value)
    external
    onlyLogic
    onlyNotEmptyKey(key) 
    onlyDataType(key, DataType.BOOL) {
        _bool[key] =value;
        emit SetBool({key: key, value: value});
    }

    function setBytes32(bytes32 key, bytes32 value)
    external
    onlyLogic 
    onlyNotEmptyKey(key) 
    onlyDataType(key, DataType.BYTES32) {
        _bytes32[key] =value;
        emit SetBytes32({key: key, value: value});
    }

    // SET ARRAYS

    function setIndexStringArray(bytes32 key, uint index, string memory value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.STRING_ARRAY) {
        _stringArray[key][index] =value;
        emit SetIndexStringArray({key: key, index: index, value: value});
    }

    function setIndexBytesArray(bytes32 key, uint index, bytes memory value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BYTES_ARRAY) {
        _bytesArray[key][index] =value;
        emit SetIndexBytesArray({key: key, index: index, value: value});
    }

    function setIndexUintArray(bytes32 key, uint index, uint value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.UINT_ARRAY) {
        _uintArray[key][index] =value;
        emit SetIndexUintArray({key: key, index: index, value: value});
    }

    function setIndexIntArray(bytes32 key, uint index, int value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.INT_ARRAY) {
        _intArray[key][index] =value;
        emit SetIndexIntArray({key: key, index: index, value: value});
    }

    function setIndexAddressArray(bytes32 key, uint index, address value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.ADDRESS_ARRAY) {
        _addressArray[key][index] =value;
        emit SetIndexAddressArray({key: key, index: index, value: value});
    }

    function setIndexBoolArray(bytes32 key, uint index, bool value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BOOL_ARRAY) {
        _boolArray[key][index] =value;
        emit SetIndexBoolArray({key: key, index: index, value: value});
    }

    function setIndexBytes32Array(bytes32 key, uint index, bytes32 value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BYTES32_ARRAY) {
        _bytes32Array[key][index] =value;
        emit SetIndexBytes32Array({key: key, index: index, value: value});
    }

    // PUSH ARRAYS

    function pushStringArray(bytes32 key, string memory value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.STRING_ARRAY) {
        _stringArray.push(value);
        emit PushStringArray({key: key, value: value});
    }

    function pushBytesArray(bytes32 key, bytes memory value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BYTES_ARRAY) {
        _bytesArray.push(value);
        emit PushBytesArray({key: key, value: value});
    }

    function pushUintArray(bytes32 key, uint value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.UINT_ARRAY) {
        _uintArray.push(value);
        emit PushUintArray({key: key, value: value});
    }

    function pushIntArray(bytes32 key, int value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.INT_ARRAY) {
        _intArray.push(value);
        emit PushIntArray({key: key, value: value});
    }

    function pushAddressArray(bytes32 key, address value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.ADDRESS_ARRAY) {
        _addressArray.push(value);
        emit PushAddressArray({key: key, value: value});
    }

    function pushBoolArray(bytes32 key, bool value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BOOL_ARRAY) {
        _boolArray.push(value);
        emit PushBoolArray({key: key, value: value});
    }

    function pushBytes32Array(bytes32 key, bytes32 value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BYTES32_ARRAY) {
        _bytes32Array.push(value);
        emit PushBytes32Array({key: key, value: value});
    }

    // DELETE ARRAYS

    function deleteStringArray(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.STRING_ARRAY) {
        require(_stringArray[key].length >0, "Storage: array is empty");
        delete _stringArray[key];
        emit DeleteStringArray({key: key});
    }

    function deleteBytesArray(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BYTES_ARRAY) {
        require(_bytesArray[key].length >0, "Storage: array is empty");
        delete _bytesArray[key];
        emit DeleteBytesArray({key: key});
    }

    function deleteUintArray(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.UINT_ARRAY) {
        require(_uintArray[key].length >0, "Storage: array is empty");
        delete _uintArray[key];
        emit DeleteUintArray({key: key});
    }

    function deleteIntArray(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.INT_ARRAY) {
        require(_intArray[key].length >0, "Storage: array is empty");
        delete _intArray[key];
        emit DeleteIntArray({key: key});
    }

    function deleteAddressArray(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.ADDRESS_ARRAY) {
        require(_addressArray[key].length >0, "Storage: array is empty");
        delete _addressArray[key];
        emit DeleteAddressArray({key: key});
    }

    function deleteBoolArray(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BOOL_ARRAY) {
        require(_boolArray[key].length >0, "Storage: array is empty");
        delete _boolArray[key];
        emit DeleteBoolArray({key: key});
    }

    function deleteBytes32Array(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BYTES32_ARRAY) {
        require(_bytes32Array[key].length >0, "Storage: array is empty");
        delete _bytes32Array[key];
        emit DeleteBytes32Array({key: key});
    }

    // ADD SETS

    function addAddressSet(bytes32 key, address value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.ADDRESS_SET) {
        require(!_addressSet[key].contains(value), "Storage: set already contains value");
        _addressSet[key].add(value);
        emit AddAddressSet({key: key, value: value});
    }

    function addUintSet(bytes32 key, uint value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.UINT_SET) {
        require(!_uintSet[key].contains(value), "Storage: set already contains value");
        _uintSet[key].add(value);
        emit AddUintSet({key: key, value: value});
    }

    function addBytes32Set(bytes32 key, bytes32 value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BYTES32_SET) {
        require(!_bytes32Set[key].contains(value), "Storage: set already contains value");
        _bytes32Set[key].add(value);
        emit AddBytes32Set({key: key, value: value});
    }

    // REMOVE SETS

    function removeAddressSet(bytes32 key, address value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.ADDRESS_SET) {
        require(_addressSet[key].contains(value), "Storage: value not found");
        _addressSet[key].remove(value);
        emit RemoveAddressSet({key: key, value: value});
    }

    function removeUintSet(bytes32 key, uint value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.UINT_SET) {
        require(_uintSet[key].contains(value), "Storage: value not found");
        _uintSet[key].remove(value);
        emit RemoveUintSet({key: key, value: value});
    }

    function removeBytes32Set(bytes32 key, bytes32 value)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BYTES32_SET) {
        require(_bytes32Set[key].contains(value), "Storage: value not found");
        _bytes32Set[key].remove(value);
        emit RemoveBytes32Set({key: key, value: value});
    }

    // MODIFIERS
    
    function _onlyAdmin()
    internal view {
        require(_admins.contains(msg.sender), "Storage: !admin");
    }

    function _onlyLogic()
    internal view {
        require(_implementations.contains(msg.sender), "Storage: !logic");
    }

    function _onlyNotEmptyKey(bytes32 key)
    internal view {
        bytes32 emptyBytes32;
        require(key !=emptyBytes32, "Storage: empty key was given");
    }

    function _onlyDataTypeCheck(bytes32 key, DataType dataType)
    internal view {
        require(
            _usedKeys[key] ==DataType.NONE || _usedKeys[key] ==dataType,
            "Storage: key is already being assigned to a different datatype"
        );
    }

    function _afterCheckDataTypeSet(bytes32 key, DataType dataType)
    internal {
        if (_usedKeys[key] ==DataType.NULL) { _usedKeys[key] =dataType; }
    }
}



library ValidatorMatch {
    /// @dev Checks if an access key meta data has the same address and if two string signatures match
    /// @param contractA The address of the first contract
    /// @param contractB The address of the second contract
    /// @param signatureA The first string signature
    /// @param signatureB The second string signature
    /// @return isMatch True if both contracts are the same and signatures match, false otherwise
    function isMatchingKeyContractAndSignature(address contractA, address contractB, string memory signatureA, string memory signatureB)
    external pure
    returns (bool isMatch) {
        bool sameContract =contractA ==contractB;
        bool sameString =Match.isMatchingString({stringA: signatureA, stringB: signatureB});
        return sameContract && sameString;
    }
}



library ValidatorToolkit {
    /// @dev Retrieves the index of a key by comparing contract address and signature in a given storage variable
    /// @param storage_ The storage contract where the keys are stored
    /// @param variable The variable containing the keys in the storage
    /// @param contract_ The contract address to compare against
    /// @param signature The signature string to compare against
    /// @return success True if a matching key is found, false otherwise
    /// @return index The index of the matching key, if found, otherwise 0
    function getKeyIndexByContractAndSignature(IStorage storage_, bytes32 variable, address contract_, string memory signature)
    external view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes[] memory bytesArray =storage_.getBytesArray({key: variable});
        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory key =bytesArray[i];
            if (!Match.isMatchingBytes({bytesA: key, bytesB: emptyBytes})) {
                (address dContract, string memory dSignature, , , ,) =Encoder.decodeKey({key: key});
                if (ValidatorMatch.isMatchingKeyContractAndSignature({contractA: contract_, contractB: dContract, signatureA: signature, signatureB: dSignature})) {
                    index =i;
                    success =true;
                    break;
                }
            }
        }
        return (success, index);
    }

    /// @dev Retrieves the index of a key containing empty bytes in a given storage variable
    /// @param storage_ The storage contract where the keys are stored
    /// @param variable The variable containing the keys in the storage
    /// @return success True if a key with empty bytes is found, false otherwise
    /// @return index The index of the key with empty bytes, if found, otherwise 0
    function getKeyIndexByEmptyBytes(IStorage storage_, bytes32 variable)
    external view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes[] memory bytesArray =storage_.getBytesArray({key: variable});
        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory key =bytesArray[i];
            if (Match.isMatchingBytes({bytesA: key, bytesB: emptyBytes})) {
                success =true;
                index =i;
                break;
            }
        }
        return (success, index);
    }

    /// @dev Validates the input parameters based on the specified key type
    /// @param keyType The type of the key (STANDARD, TIMED, CONSUMABLE)
    /// @param startTimestamp The start timestamp for the key
    /// @param endTimestamp The end timestamp for the key
    /// @param balance The balance associated with the key
    function requireCorrectInput(KeyType keyType, uint startTimestamp, uint endTimestamp, uint balance)
    external view {
        if (keyType ==KeyType.STANDARD) {
            require(startTimestamp ==0, "ValidatorToolkit: startTimestamp must be zero");
            require(endTimestamp ==0, "ValidatorToolkit: endTimestamp must be zero");
            require(balance ==0, "ValidatorToolkit: balance must be zero");
        } else if (keyType ==KeyType.TIMED) {
            require(block.timestamp <=startTimestamp, "ValidatorToolkit: cannot grant in the past");
            require(endTimestamp >=startTimestamp, "ValidatorToolkit: cannot expire before granted");
            require(balance ==0, "Validator: balance must be zero");
        } else if (keyType ==KeyType.CONSUMABLE) {
            require(startTimestamp ==0, "ValidatorToolkit: startTimestamp must be zero");
            require(endTimestamp ==0, "ValidatorToolkit: endTimestamp must be zero");
            require(balance >= 1, "ValidatorToolkit: balance is less than one");
        }
        else {
            revert("ValidatorToolkit: invalid keyType");
        }
    }
}



/** STORAGE VARS USABLE
    <addr/account>  "keys"       _bytesArray
    <str/role>      "keys"       _bytesArray
    <str/role>      "members"    _addressSet
 */
library Validator {
    /// @dev Retrieves the keys associated with a specific account from the provided storage
    /// @param storage_ The storage contract where the keys are stored
    /// @param account The address of the account to retrieve keys for
    /// @return keys An array containing the keys associated with the specified account
    function getKeys(IStorage storage_, address account)
    external view
    returns (bytes[] memory keys) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 varAccountKeys =Encoder.account({account: account, property: "keys"});
        return storage_.getBytesArray({key: varAccountKeys});
    }

    /// @dev Retrieves the keys associated with a specific role from the provided storage
    /// @param storage_ The storage contract where the keys are stored
    /// @param role The name of the role to retrieve keys for
    /// @return keys An array containing the keys associated with the specified role
    function getRoleKeys(IStorage storage_, string memory role)
    external view
    returns (bytes[] memory keys) {
        bytes32 varRoleKeys =Encoder.role({role: role, property: "keys"});
        return storage_.getBytesArray({key: varRoleKeys});
    }

    /// @dev Retrieves the members associated with a specific role from the provided storage
    /// @param storage_ The storage contract where the members are stored
    /// @param role The name of the role to retrieve members for
    /// @return members An array containing the addresses of members associated with the specified role
    function getRoleMembers(IStorage storage_, string memory role)
    external view
    returns (address[] memory members) {
        bytes32 varRoleMembers =Encoder.role({role: role, property: "members"});
        return storage_.getAddressSet({key: varRoleMembers});
    }

    /// @dev Retrieves the number of members associated with a specific role from the provided storage
    /// @param storage_ The storage contract where the members are stored
    /// @param role The name of the role to retrieve the size for
    /// @return size The number of members associated with the specified role
    function getRoleSize(IStorage storage_, string memory role)
    external view
    returns (uint size) {
        bytes32 varRoleMembers =Encoder.role({role: role, property: "members"});
        address[] memory addressArray =storage_.getAddressSet({key: varRoleMembers});
        return addressArray.length;
    }

    /// @dev Grants a key to an account with the specified parameters
    /// @param storage_ The storage contract where the key will be stored
    /// @param account The address of the account to which the key will be granted
    /// @param contract_ The address of the contract associated with the key
    /// @param signature The signature string for the key
    /// @param keyType The type of the key (STANDARD, TIMED, CONSUMABLE)
    /// @param startTimestamp The start timestamp for the key
    /// @param endTimestamp The end timestamp for the key
    /// @param balance The balance associated with the key
    /// @return success True if the key granting was successful, false otherwise
    /// @return index The index of the granted key in the account's key list
    function grantKey(IStorage storage_, address account, address contract_, string memory signature, KeyType keyType, uint startTimestamp, uint endTimestamp, uint balance)
    external
    returns (bool success, uint index) {
        ValidatorToolkit.requireCorrectInput({keyType: keyType, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        require(account !=address(0), "Validator: account is address zero");
        require(contract_ !=address(0), "Validator: contract is address zero");
        bytes memory key =Encoder.account({contract_: contract_, signature: signature, keyType: keyType, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        bytes32 varAccountKeys =Encoder.account({account: account, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({storage_: storage_, variable: varAccountKeys, contract_: contract_, signature: signature});
        require(!success, "Validator: matching existing key: contract and address");
        (success, index) =ValidatorToolkit.getKeyIndexByEmptyBytes({storage_: storage_, variable: varAccountKeys});
        if (success) { storage_.setindexBytesArray({key: varAccountKeys, index: index, value: key}); }
        else {
            storage_.pushBytesArray({key: varAccountKeys, value: key});
            bytes[] memory bytesArray =storage_.getBytesArray({key: varAccountKeys});
            index =bytesArray.length -1;
            success =true;
        }
        Utils.requireSuccess({success: success});
        return (success, index);
    }



    function revokeKey(IStorage db, address account, address contract_, string memory signature)
    external
    returns (bool success, uint index) {
        require(account !=address(0), "Validator: account is address zero");
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes32 keys =Encoder.account({account: account, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({db: db, array: keys, contract_: contract_, signature: signature});
        require(success, "Validator: unable to find matching contract and address");
        bytes memory emptyBytes;
        db.setIndexBytesArray({key: keys, index: index, value: emptyBytes});
        success =true;
        return (success, index);
    }

    function resetKeys(IStorage db, address account)
    external
    returns (bool success) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 keys =Encoder.account({account: account, property: "keys"});
        db.deleteBytesArray({key: keys});
        success =true;
        return success;
    }

    function verify(IStorage db, address account, address contract_, string memory signature)
    external
    returns (bool success, uint index) {
        require(account !=address(0), "Validator: account is address zero");
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes32 keys =Encoder.account({account: account, property: "keys"});
        bytes[] memory bytesArray =db.getBytesArray({key: keys});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({db: db, array: keys, contract_: contract_, signature: signature});
        require(success, "Validator: unable to find matching contract and address");
        bytes memory key =db.indexBytesArray({key: keys, index: index});
        (address contract_B, string memory signatureB, uint type_, uint startTimestamp, uint endTimestamp, uint balance) =Encoder.decodeKey({key: key});
        if (type_ ==0) { success =true; }
        else if (type_ ==1) {
            require(block.timestamp >=startTimestamp, "Validator: cannot use key before granted");
            require(block.timestamp <=endTimestamp, "Validator: expired");
            success =true;
        }
        else if (type_ ==2) {
            require(balance >=1, "Validator: insufficient balance");
            balance--;
            bytes memory keyB =Encoder.encodeKey({contract_: contract_B, signature: signatureB, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
            db.setIndexBytesArray({key: keys, index: index, value: keyB});
            success =true;
        }
        Utils.requireSuccess({success: success});
        return (success, index);
    }

    function grantKeyToRole(IStorage db, string memory role, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external
    returns (bool success, uint index) {
        ValidatorToolkit.requireInput({type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes memory key =Encoder.encodeKey({contract_: contract_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        bytes32 keys =Encoder.role({role: role, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({db: db, array: keys, contract_: contract_, signature: signature});
        require(!success, "Validator: matching contract and address");
        (success, index) =ValidatorToolkit.getKeyIndexByEmptyBytes({db: db, array: keys});
        if (success) { db.setIndexBytesArray({key: keys, index: index, value: key}); }
        else {
            db.pushBytesArray({key: keys, value: key});
            index =db.lengthBytesArray({key: keys}) -1;
            success =true;
        }
        Utils.requireSuccess({success: success});
        return (success, index);
    }

    function revokeKeyFromRole(IStorage db, string memory role, address contract_, string memory signature)
    external
    returns (bool success, uint index) {
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes32 keys =Encoder.role({role: role, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({db: db, array: keys, contract_: contract_, signature: signature});
        require(success, "Validator: unable to find matching contract and address");
        bytes memory emptyBytes;
        db.setIndexBytesArray({key: keys, index: index, value: emptyBytes});
        success =true;
        return (success, index);
    }

    function resetRoleKeys(IStorage db, string memory role)
    external
    returns (bool success) {
        bytes32 keys =Encoder.role({role: role, property: "keys"});
        db.deleteBytesArray({key: keys});
        success =true;
        return success;
    }

    function grantRole(IStorage db, address account, string memory role)
    external
    returns (bool success) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 keysA =Encoder.role({role: role, property: "keys"});
        bytes32 keysB =Encoder.account({account: account, property: "keys"});
        db.deleteBytesArray({key: keysB});
        bytes[] memory roleKeysArray =db.getBytesArray({key: keysA});
        for (uint i =0; i <roleKeysArray.length; i++) {
            success =false;
            (address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) =Encoder.decodeKey({key: roleKeysArray[i]});
            ValidatorToolkit.requireInput(type_, startTimestamp, endTimestamp, balance);
            db.pushBytesArray({key: keysB, value: roleKeysArray[i]});
        }
        bytes32 members =Encoder.role({role: role, property: "members"});
        db.addAddressSet({key: members, value: account});
        success =true;
        return success;
    }

    function revokeRole(IStorage db, address account, string memory role)
    external
    returns (bool success, uint index) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 keys =Encoder.role({role: role, property: "keys"});
        bytes32 keysB =Encoder.account({account: account, property: "keys"});
        bytes[] memory roleKeysArray =db.getBytesArray({key: keys});
        bytes memory emptyBytes;
        for (uint i =0; i <roleKeysArray.length; i++) {
            (address contract_, string memory signature, , , ,) =Encoder.decodeKey({key: roleKeysArray[i]});
            success =false;
            index =0;
            (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({db: db, array: keys, contract_: contract_, signature: signature});
            if (success) { db.setIndexBytesArray({key: keysB, index: index, value: emptyBytes}); }
        }
        success =true;
        return (success, index);
    }
}



library Network {
    function setUpAccount(IStorage db, address account, string memory username)
    external {
        bytes32 meta =Encoder.account({account: account, property: "meta"});
        
    }

    
}



interface ISentinel {
    function init() external;
    function getKeys(address account) external view returns (bytes[] memory);
    function getRoleKeys(string memory role) external view returns (bytes[] memory);
    function getRoleMembers(string memory role) external view returns (address[] memory);
    function getRoleSize(string memory role) external view returns (uint);
    function verify(address account, address contract_, string memory signature) external;
    function grantKey(address account, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) external;
    function revokeKey(address account, address contract_, string memory signature) external;
    function resetKeys(address account) external;
    function grantKeyToRole(string memory role, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) external;
    function revokeKeyFromRole(string memory role, address contract_, string memory signature) external;
    function resetRoleKeys(string memory role) external;
    function grantRole(address account, string memory role) external;
    function revokeRole(address account, string memory role) external;
}



contract Sentinel is Pausable, ReentrancyGuard {
    bool internal _init;
    address internal _deployer;
    IStorage db;

    modifier verify_(string memory signature) {
        Validator.verify({db: db, account: msg.sender, contract_: address(this), signature: signature});
        _;
    }

    constructor(address database) {
        _deployer =msg.sender;
        db =IStorage(database);
    }

    function init()
    external {
        require(msg.sender ==_deployer, "Terminal: only _deployer can call");
        require(!_init, "Sentienl: _init");
        bool isImplementation;
        address[] memory implementations =db.getImplementations();
        for (uint i =0; i <implementations.length; i++) {
            if (msg.sender ==implementations[i]) { isImplementation =true; }
        }
        require(isImplementation, "Sentinel: cannot init without setting as implementation first");
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "grantKey(address,address,string,uint256,uint256,uint256,uint256)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "revokeKey(address,address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "resetKeys(address)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "grantKeyToRole(string,address,string,uint256,uint256,uint256,uint256)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "revokeKeyFromRole(string,address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "resetRoleKeys(string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "grantRole(address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "revokeRole(address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantRole({db: db, account: msg.sender, role: "validator"});
        _init =true;
    }

    function getKeys(address account)
    external view
    returns (bytes[] memory) {
        return Validator.getKeys({db: db, account: account});
    }

    function getRoleKeys(string memory role)
    external view
    returns (bytes[] memory) {
        return Validator.getRoleKeys({db: db, role: role});
    }

    function getRoleMembers(string memory role)
    external view
    returns (address[] memory) {
        return Validator.getRoleMembers({db: db, role: role});
    }

    function getRoleSize(string memory role)
    external view
    returns (uint) {
        return Validator.getRoleSize({db: db, role: role});
    }

    function verify(address account, address contract_, string memory signature)
    external 
    nonReentrant {
        Validator.verify({db: db, account: account, contract_: contract_, signature: signature});
    }

    function grantKey(address account, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("grantKey(address,address,string,uint256,uint256,uint256,uint256)") {
        Validator.grantKey({db: db, account: account, contract_: contract_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
    }

    function revokeKey(address account, address contract_, string memory signature)
    external
    nonReentrant
    whenNotPaused 
    verify_("revokeKey(address,address,string)") {
        Validator.revokeKey({db: db, account: account, contract_: contract_, signature: signature});
    }

    function resetKeys(address account)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("resetKeys(address)") {
        Validator.resetKeys({db: db, account: account});
    }

    function grantKeyToRole(string memory role, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external 
    nonReentrant
    whenNotPaused
    verify_("grantKeyToRole(string,address,string,uint256,uint256,uint256,uint256)") {
        Validator.grantKeyToRole({db: db, role: role, contract_: contract_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
    }

    function revokeKeyFromRole(string memory role, address contract_, string memory signature)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("revokeKeyFromRole(string,address,string)") {
        Validator.revokeKeyFromRole({db: db, role: role, contract_: contract_, signature: signature});
    }

    function resetRoleKeys(string memory role)
    external 
    nonReentrant
    whenNotPaused
    verify_("resetRoleKeys(string)") {
        Validator.resetRoleKeys({db: db, role: role});
    }

    function grantRole(address account, string memory role)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("grantRole(address,string)") {
        Validator.grantRole({db: db, account: account, role: role});
    }

    function revokeRole(address account, string memory role)
    external 
    nonReentrant
    whenNotPaused
    verify_("revokeRole(address,string)") {
        Validator.revokeRole({db: db, account: account, role: role});
    }
}



library Timelock {
    function queueRequest(address[] memory targets, string[] memory signatures, bytes[] memory args)
    external {
        uint now_ =block.timestamp;
        uint durationTimelock =db.getUint({key: Encoder.encode({string_: "durationTimelock"})});
        uint durationTimeout =db.getUint({key: Encoder.encode({string_: "durationTimeout"})});
        bytes memory request =Encoder.encodeRequest({targets: targets, signatures: signatures, args: args, endTimelockTimestamp: now_ +durationTimelock, endTimeoutTimestamp: now_ +durationTimeout, approved: false, rejected: false, executed: false});
        db.pushBytesArray({key: Encoder.encode({string_: "requests"}), value: request});
    }
}



contract Key {

}



contract Achievements is ERC721 {
    IStorage db;
    ISentinel sn;

    constructor(address database, address sentinel)
    ERC721("DreamRewards", "DRMR") {
        db =IStorage(database);
        sn =ISentinel(sentinel);
    }

    function createCollectible(address account, string memory tokenURI)
    external
    returns (uint) {
        sn.verify({account: msg.sender, contract_: address(this), signature: "createCollectibe(address,string)"});
        bytes32 numAchievements =Encoder.encode({string_: "numAchievements"});
        uint newItemId =db.getUint({key: numAchievements});
        _safeMint({to: account, tokenId: newItemId});
        _setTokenURI({tokenId: newItemId, tokenURI: tokenURI});
        db.setUint({key: numAchievements, value: newItemId +=1});
        return newItemId;
    }
}



interface IDreamToken {
    function maxSupply() external view returns (uint);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function getCurrentSnapshotId() external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function snapshot() external returns (uint);
    function burn(uint amount) external;
    function burnFrom(address account, uint amount) external;
}



contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    uint public cap;
    IStorage db;
    ISentinel sn;

    modifier verify(string memory signature) {
        sn.verify({account: msg.sender, contract_: address(this), signature: signature});
        _;
    }

    constructor(address database, address sentinel)
    ERC20("DreamToken", "DREAM")
    ERC20Permit("DreamToken") {
        cap =Utils.convertToWei({value: 200000000});
        _mint({account: msg.sender, amount: cap});
        db =IStorage(database);
        sn =ISentinel(sentinel);
    }

    function maxSupply()
    external view
    returns (uint) {
        return cap;
    }

    function getCurrentSnapshotId()
    external view
    returns (uint) {
        return _getCurrentSnapshotId();
    }

    function allowance(address owner, address spender) 
    public view override 
    returns (uint) {
        return super.allowance({owner: owner, spender: spender});
    }

    function snapshot()
    external
    verify("snapshot()")
    returns (uint) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function _beforeTokenTransfer(address from, address to, uint amount)
    internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer({from: from, to: to, amount: amount});
    }

    function _afterTokenTransfer(address from, address to, uint amount)
    internal override {
        bytes32 balanceA =Encoder.account({account: to, property: "dreamTokenBalance"});
        bytes32 balanceB =Encoder.account({account: from, property: "dreamTokenBalance"});
        uint balanceTo =db.getUint({key: balanceA});
        uint balanceFrom =db.getUint({key: balanceB});
        if (from !=address(0)) { balanceFrom -=amount; }
        if (to !=address(0)) { balanceTo +=amount; }
        db.setUint({key: balanceA, value: balanceTo});
        db.setUint({key: balanceB, value: balanceFrom});
        super._afterTokenTransfer({from: from, to: to, amount: amount});
    }

    function _mint(address account, uint amount)
    internal override {
        super._mint({account: account, amount: amount});
    }

    function _burn(address account, uint amount)
    internal override {
        cap -= amount;
        super._burn({account: account, amount: amount});
    }
}



interface IEmberToken {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function getCurrentSnapshotId() external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function mint(address to, uint amount) external;
    function snapshot() external returns (uint);
    function burn(uint amount) external;
    function burnFrom(address account, uint amount) external;
}



contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    IStorage db;
    ISentinel sn;

    constructor(address database, address sentinel)
    ERC20("EmberToken", "EMBER")
    ERC20Permit("EmberToken") {
        db =IStorage(database);
        sn =ISentinel(sentinel);
    }

    function getCurrentSnapshotId()
    external view
    returns (uint) {
        return _getCurrentSnapshotId();
    }

    function mint(address account, uint amount)
    external
    onlyOwner {
        _mint({account: account, amount: amount});
    }

    function snapshot()
    external
    onlyOwner
    returns (uint) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function _beforeTokenTransfer(address from, address to, uint amount)
    internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer({from: from, to: to, amount: amount});
    }

    function _afterTokenTransfer(address from, address to, uint amount)
    internal override {
        bytes32 balanceA =Encoder.account({account: to, property: "emberTokenBalance"});
        bytes32 balanceB =Encoder.account({account: from, property: "emberTokenBalance"});
        uint balanceTo =db.getUint({key: balanceA});
        uint balanceFrom =db.getUint({key: balanceB});
        if (from !=address(0)) { balanceFrom -=amount; }
        if (to !=address(0)) { balanceTo +=amount; }
        db.setUint({key: balanceA, value: balanceTo});
        db.setUint({key: balanceB, value: balanceFrom});
        super._afterTokenTransfer({from: from, to: to, amount: amount});
    }

    function _transfer(address from, address to, uint amount)
    internal override {
        revert("EmberToken: transfer disabled by design");
    }

    function _mint(address account, uint amount)
    internal override {
        super._mint({account: account, amount: amount});
    }

    function _burn(address account, uint amount)
    internal override {
        super._burn({account: account, amount: amount});
    }
}