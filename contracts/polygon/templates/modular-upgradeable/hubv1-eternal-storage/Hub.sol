// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
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

    function encodeKey(address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external pure
    returns (bytes memory key) {
        return abi.encode(contract_, signature, type_, startTimestamp, endTimestamp, balance);
    }

    function decodeKey(bytes memory key)
    external pure
    returns (address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) {
        return abi.decode(key, (address,string,uint,uint,uint,uint));
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

    function encodeUsedBytes32Key(bytes32 usedBytes32Key, DataType dataType)
    external pure
    returns (bytes memory) {
        return abi.encode(usedBytes32Key, dataType);
    }

    function decodeUsedBytes32Key(bytes memory usedBytes32Key)
    external pure
    returns (bytes32, DataType) {
        return abi.decode(usedBytes32Key, (bytes32, DataType));
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

    event addAddressSet(bytes32 indexed key, address indexed value);
    event addUintSet(bytes32 indexed key, uint indexed value);
    event addBytes32Set(bytes32 indexed key, bytes32 indexed value);

    event removeAddressSet(bytes32 indexed key, address indexed value);
    event removeUintSet(bytes32 indexed key, uint indexed value);
    event removeBytes32Set(bytes32 indexed key, bytes32 indexed value);

    modifier onlyAdmin() {
        require(_admins.contain(msg.sender), "Storage: !admin");
        _;
    }

    modifier onlyLogic() {
        require(_implementations.contains(msg.sender), "Storage: !logic");
        _;
    }

    modifier onlyDataType(bytes32 key, DataType dataType) {
        require(
            _usedKeys[key] ==DataType.NONE || _usedKeys[key] ==dataType,
            "Storage: key is already being assigned to a different datatype"
        );
        _;
        if (_usedKeys[key] ==DataType.NULL) { _usedKeys[key] =dataType; }
    }

    modifier onlyDataTypeCheck(bytes32 key, DataType dataType) {
        require(
            _usedKeys[key] ==DataType.NONE || _usedKeys[key] ==dataType,
            "Storage: key is already being assigned to a different datatype"
        );
        _;
    }

    modifier onlyNotEmptyKey(bytes32 key) {
        bytes32 emptyBytes32;
        require(key !=emptyBytes32, "Storage: empty key was given");
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
        delete _stringArray[key];
        emit DeleteStringArray({key: key});
    }

    function deleteBytesArray(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BYTES_ARRAY) {
        delete _bytesArray[key];
        emit DeleteBytesArray({key: key});
    }

    function deleteUintArray(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.UINT_ARRAY) {
        delete _uintArray[key];
        emit DeleteUintArray({key: key});
    }

    function deleteIntArray(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.INT_ARRAY) {
        delete _intArray[key];
        emit DeleteIntArray({key: key});
    }

    function deleteAddressArray(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.ADDRESS_ARRAY) {
        delete _addressArray[key];
        emit DeleteAddressArray({key: key});
    }

    function deleteBoolArray(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BOOL_ARRAY) {
        delete _boolArray[key];
        emit DeleteBoolArray({key: key});
    }

    function deleteBytes32Array(bytes32 key)
    external
    onlyLogic
    onlyNotEmptyKey(key)
    onlyDataType(key, DataType.BYTES32_ARRAY) {
        delete _bytes32Array[key];
        emit DeleteBytes32Array({key: key});
    }

}



library ValidatorMatch {
    function isMatchingKeyContractAndSignature(address contractA, address contractB, string memory signatureA, string memory signatureB)
    external pure
    returns (bool isMatch) {
        bool sameContract =contractA ==contractB;
        bool sameString =Match.isMatchingString({stringA: signatureA, stringB: signatureB});
        return sameContract && sameString;
    }
}



library ValidatorToolkit {
    function getKeyIndexByContractAndSignature(IStorage db, bytes32 array, address contract_, string memory signature)
    external view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes[] memory bytesArray =db.getBytesArray({key: array});
        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory key =bytesArray[i];
            if (!Match.isMatchingBytes({bytesA: key, bytesB: emptyBytes})) {
                (address contract_B, string memory signatureB, , , ,) = Encoder.decodeKey({key: key});
                if (ValidatorMatch.isMatchingKeyContractAndSignature({contractA: contract_, contractB: contract_B, signatureA: signature, signatureB: signatureB})) {
                    index =i;
                    success =true;
                    break;
                }
            }
        }
        return (success, index);
    }

    function getKeyIndexByEmptyBytes(IStorage db, bytes32 array)
    external view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes[] memory bytesArray =db.getBytesArray({key: array});
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

    function requireInput(uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external view {
        if (type_ ==0) {
            require(startTimestamp ==0, "ValidatorToolkit: startTimestamp must be zero");
            require(endTimestamp ==0, "ValidatorToolkit: endTimestamp must be zero");
            require(balance ==0, "ValidatorToolkit: balance must be zero");
        } else if (type_ ==1) {
            require(block.timestamp <=startTimestamp, "ValidatorToolkit: cannot grant in the past");
            require(endTimestamp >=startTimestamp, "ValidatorToolkit: cannot expire before granted");
            require(balance ==0, "Validator: balance must be zero");
        } else if (type_ ==2) {
            require(startTimestamp ==0, "ValidatorToolkit: startTimestamp must be zero");
            require(endTimestamp ==0, "ValidatorToolkit: endTimestamp must be zero");
            require(balance >= 1, "ValidatorToolkit: balance is less than one");
        }
    }
}



library Validator {
    function getKeys(IStorage db, address account)
    external view
    returns (bytes[] memory) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 keys =Encoder.account({account: account, property: "keys"});
        return db.getBytesArray({key: keys});
    }

    function getRoleKeys(IStorage db, string memory role)
    external view
    returns (bytes[] memory) {
        bytes32 keys =Encoder.role({role: role, property: "keys"});
        return db.getBytesArray({key: keys});
    }

    function getRoleMembers(IStorage db, string memory role)
    external view
    returns (address[] memory) {
        bytes32 members =Encoder.role({role: role, property: "members"});
        return db.valuesAddressSet({key: members});
    }

    function getRoleSize(IStorage db, string memory role)
    external view
    returns (uint) {
        bytes32 members =Encoder.role({role: role, property: "members"});
        return db.lengthAddressSet({key: members});
    }

    function grantKey(IStorage db, address account, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external
    returns (bool success, uint index) {
        ValidatorToolkit.requireInput({type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        require(account !=address(0), "Validator: account is address zero");
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes memory key =Encoder.encodeKey({contract_: contract_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        bytes32 keys =Encoder.account({account: account, property: "keys"});
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