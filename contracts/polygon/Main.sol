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
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

/** storage usage
    <how the bytes32 variable is encoded> <storage access used>
    address > _bytes
 */

// KEYS
enum KeyClass {
    SOURCE,
    STANDARD,
    CONSUMABLE,
    TIMED
}

struct Key {
    address logic;
    string signature;
    uint granted;
    uint expiration;
    bool transferable;
    bool clonable;
    KeyClass class;
    uint balance;
    bytes data;
}

// REQUESTS
enum RequestStage {
    PENDING,
    APPROVED,
    REJECTED,
    EXECUTED
}

struct Request {
    string message;
    address[] targets;
    string[] signatures;
    bytes[] args;
    uint created;
    uint endTimelock;
    uint endTimeout;
    address creator;
    RequestStage stage;
}

// PROPOSALS
enum ProposalSide {
    ABSTAIN,
    AGAINST,
    SUPPORT
}

enum ProposalStage {
    PENDING,
    APPROVED,
    REJECTED,
    EXECUTED
}

struct Proposal {
    string message;
    uint snapshot;
    address creator;
    address[] targets;
    string[] signatures;
    bytes[] args;
    uint abstain;
    uint against;
    uint support;
    uint endTimeout;
    uint quorum;
    uint requiredQuorum;
    uint requiredThreshold;
    ProposalStage stage;
    EnumerableSet.AddressSet voters;
}

// MULTI SIG PROPOSALS
struct MSigProposal {
    string message;
    address creator;
    address[] targets;
    string[] signatures;
    bytes[] args;
    uint endTimeout;
    uint quorum;
    uint requiredQuorum;
    ProposalStage stage;
    EnumerableSet.AddressSet signers;
    EnumerableSet.AddressSet signatures_;
}

library Match {
    function isMatchingBytes(bytes memory bytesA, bytes memory bytesB)
    external pure
    returns (bool) {
        return keccak256(bytesA) == keccak256(bytesB);
    }

    function isMatchingString(string memory stringA, string memory stringB)
    external pure
    returns (bool) {
        return keccak256(abi.encodePacked(stringA)) == keccak256(abi.encodePacked(stringB));
    }
}

library Utils {
    function convertToWei(uint value)
    external pure
    returns (uint) {
        return value * (10**18);
    }

    function convertToWeiDecimal(uint value, uint decimals)
    external pure
    returns (uint) {
        return value * (10**decimals);
    }
}

library CustomMatch {
    /// send amount of value to receibe shares from pool > reference: https://docs.google.com/spreadsheets/d/1wqqXCuHfu9PvRrel3CzLKnsElOFI48IRBMXtoRT-u-8/edit?usp=sharing
    function amountToMint(uint value, uint supply, uint balance)
    external pure
    returns (uint) {
        require(value >= 1, "CustomMath: value must not be zero");
        require(supply >= 1, "CustomMath: supply must not be zero");
        require(balance >= 1, "CustomMath: balance must not be zero");
        return (value * supply) / balance;
    }

    /// burn amount of shares to receive value from pool > reference: https://docs.google.com/spreadsheets/d/1wqqXCuHfu9PvRrel3CzLKnsElOFI48IRBMXtoRT-u-8/edit?usp=sharing
    function valueToReturn(uint amount, uint supply, uint balance)
    external pure
    returns (uint) {
        require(amount >= 1, "CustomMath: amount must not be zero");
        require(supply >= 1, "CustomMath: supply must not be zero");
        require(balance >= 1, "CustomMath: balance must not be zero");
        require(amount <= supply, "CustomMath: amount cannot be greater than supply");
        return (amount * balance) / supply;
    }
}

interface IEternalStorage {
    function getAdmins() external view returns (address[] memory);
    function getLogics() external view returns (address[] memory);
    function getString(bytes32 variable) external view returns (string memory);
    function getBytes(bytes32 variable) external view returns (bytes memory);
    function getUint(bytes32 variable) external view returns (uint);
    function getInt(bytes32 variable) external view returns (int);
    function getAddress(bytes32 variable) external view returns (address);
    function getBool(bytes32 variable) external view returns (bool);
    function getBytes32(bytes32 variable) external view returns (bytes32);

    function getStringArray(bytes32 variable) external view returns (string[] memory);
    function getBytesArray(bytes32 variable) external view returns (bytes[] memory);
    function getUintArray(bytes32 variable) external view returns (uint[] memory);
    function getIntArray(bytes32 variable) external view returns (int[] memory);
    function getAddressArray(bytes32 variable) external view returns (address[] memory);
    function getBoolArray(bytes32 variable) external view returns (bool[] memory);
    function getBytes32Array(bytes32 variable) external view returns (bytes32[] memory);

    function indexStringArray(bytes32 variable, uint index) external view returns (string memory);
    function indexBytesArray(bytes32 variable, uint index) external view returns (bytes memory);
    function indexUintArray(bytes32 variable, uint index) external view returns (uint);
    function indexIntArray(bytes32 variable, uint index) external view returns (int);
    function indexAddressArray(bytes32 variable, uint index) external view returns (address);
    function indexBoolArray(bytes32 variable, uint index) external view returns (bool);
    function indexBytes32Array(bytes32 variable, uint index) external view returns (bytes32);

    function lengthStringArray(bytes32 variable) external view returns (uint);
    function lengthBytesArray(bytes32 variable) external view returns (uint);
    function lengthUintArray(bytes32 variable) external view returns (uint);
    function lengthIntArray(bytes32 variable) external view returns (uint);
    function lengthAddressArray(bytes32 variable) external view returns (uint);
    function lengthBoolArray(bytes32 variable) external view returns (uint);
    function lengthBytes32Array(bytes32 variable) external view returns (uint);

    function getAddressSet(bytes32 variable) external view returns (address[] memory);
    function getUintSet(bytes32 variable) external view returns (uint[] memory);
    function getBytes32Set(bytes32 variable) external view returns (bytes32[] memory);

    function indexAddressSet(bytes32 variable, uint index) external view returns (address);
    function indexUintSet(bytes32 variable, uint index) external view returns (uint);
    function indexBytes32Set(bytes32 variable, uint index) external view returns (bytes32);

    function lengthAddressSet(bytes32 variable) external view returns (uint);
    function lengthUintSet(bytes32 variable) external view returns (uint);
    function lengthBytes32Set(bytes32 variable) external view returns (uint);

    function containsAddressSet(bytes32 variable, address data) external view returns (bool);
    function containsUintSet(bytes32 variable, uint data) external view returns (bool);
    function containsBytes32Set(bytes32 variable, bytes32 data) external view returns (bool);

    function addAdmin(address admin) external;
    function addLogic(address logic) external;
    function removeAdmin(address admin) external;
    function removeLogic(address logic) external;

    function setString(bytes32 variable, string memory data) external;
    function setBytes(bytes32 variable, bytes memory data) external;
    function setUint(bytes32 variable, uint data) external;
    function setInt(bytes32 variable, int data) external;
    function setAddress(bytes32 variable, address data) external;
    function setBool(bytes32 variable, bool data) external;
    function setBytes32(bytes32 variable, bytes32 data) external;

    function setIndexStringArray(bytes32 variable, uint index, string memory data) external;
    function setIndexBytesArray(bytes32 variable, uint index, bytes memory data) external;
    function setIndexUintArray(bytes32 variable, uint index, uint data) external;
    function setIndexIntArray(bytes32 variable, uint index, int data) external;
    function setIndexAddressArray(bytes32 variable, uint index, address data) external;
    function setIndexBoolArray(bytes32 variable, uint index, bool data) external;
    function setIndexBytes32Array(bytes32 variable, uint index, bytes32 data) external;

    function pushStringArray(bytes32 variable, string memory data) external;
    function pushBytesArray(bytes32 variable, bytes memory data) external;
    function pushUintArray(bytes32 variable, uint data) external;
    function pushIntArray(bytes32 variable, int data) external;
    function pushAddressArray(bytes32 variable, address data) external;
    function pushBoolArray(bytes32 variable, bool data) external;
    function pushBytes32Array(bytes32 variable, bytes32 data) external;

    function deleteStringArray(bytes32 variable) external;
    function deleteBytesArray(bytes32 variable) external;
    function deleteUintArray(bytes32 variable) external;
    function deleteIntArray(bytes32 variable) external;
    function deleteAddressArray(bytes32 variable) external;
    function deleteBoolArray(bytes32 variable) external;
    function deleteBytes32Array(bytes32 variable) external;

    function addAddressSet(bytes32 variable, address data) external;
    function addUintSet(bytes32 variable, uint data) external;
    function addBytes32Set(bytes32 variable, bytes32 data) external;
    
    function removeAddressSet(bytes32 variable, address data) external;
    function removeUintSet(bytes32 variable, uint data) external;
    function removeBytes32Set(bytes32 variable, bytes32 data) external;
}

contract EternalStorage is IEternalStorage, Pausable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.AddressSet private _admins;
    EnumerableSet.AddressSet private _logics;

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

    event AddAdmin(address indexed admin);
    event AddLogic(address indexed logic);
    
    event RemoveAdmin(address indexed admin);
    event RemoveLogic(address indexed logic);

    event SetString(bytes32 indexed variable, string indexed data);
    event SetBytes(bytes32 indexed variable, bytes indexed data);
    event SetUint(bytes32 indexed variable, uint indexed data);
    event SetInt(bytes32 indexed variable, int indexed data);
    event SetAddress(bytes32 indexed variable, address indexed data);
    event SetBool(bytes32 indexed variable, bool indexed data);
    event SetBytes32(bytes32 indexed variable, bytes32 indexed data);

    event SetIndexStringArray(bytes32 indexed variable, uint indexed index, string indexed data);
    event SetIndexBytesArray(bytes32 indexed variable, uint indexed index, bytes indexed data);
    event SetIndexUintArray(bytes32 indexed variable, uint indexed index, uint indexed data);
    event SetIndexIntArray(bytes32 indexed variable, uint indexed index, int indexed data);
    event SetIndexAddressArray(bytes32 indexed variable, uint indexed index, address indexed data);
    event SetIndexBoolArray(bytes32 indexed variable, uint indexed index, bool indexed data);
    event SetIndexBytes32Array(bytes32 indexed variable, uint indexed index, bytes32 indexed data);

    event PushStringArray(bytes32 indexed variable, string indexed data);
    event PushBytesArray(bytes32 indexed variable, bytes indexed data);
    event PushUintArray(bytes32 indexed variable, uint indexed data);
    event PushIntArray(bytes32 indexed variable, int indexed data);
    event PushAddressArray(bytes32 indexed variable, address indexed data);
    event PushBoolArray(bytes32 indexed variable, bool indexed data);
    event PushBytes32Array(bytes32 indexed variable, bytes32 indexed data);

    event DeleteStringArray(bytes32 indexed variable);
    event DeleteBytesArray(bytes32 indexed variable);
    event DeleteUintArray(bytes32 indexed variable);
    event DeleteIntArray(bytes32 indexed variable);
    event DeleteAddressArray(bytes32 indexed variable);
    event DeleteBoolArray(bytes32 indexed variable);
    event DeleteBytes32Array(bytes32 indexed variable);

    event AddAddressSet(bytes32 indexed variable, address indexed data);
    event AddUintSet(bytes32 indexed variable, uint indexed data);
    event AddBytes32Set(bytes32 indexed variable, bytes32 indexed data);

    event RemoveAddressSet(bytes32 indexed variable, address indexed data);
    event RemoveUintSet(bytes32 indexed variable, uint indexed data);
    event RemoveBytes32Set(bytes32 indexed variable, bytes32 indexed data);

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    modifier onlyLogic() {
        _onlyLogic();
        _;
    }

    constructor() { _admins.add(msg.sender); }

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

    function getString(bytes32 variable) 
    external view 
    returns (string memory) { 
        return _string[variable]; 
    }

    function getBytes(bytes32 variable) 
    external view 
    returns (bytes memory) { 
        return _bytes[variable]; 
    }

    function getUint(bytes32 variable) 
    external view 
    returns (uint) { 
        return _uint[variable]; 
    }

    function getInt(bytes32 variable) 
    external view 
    returns (int) { 
        return _int[variable]; 
    }

    function getAddress(bytes32 variable) 
    external view 
    returns (address) { 
        return _address[variable]; 
    }

    function getBool(bytes32 variable) 
    external view 
    returns (bool) { 
        return _bool[variable]; 
    }

    function getBytes32(bytes32 variable) 
    external view 
    returns (bytes32) { 
        return _bytes32[variable]; 
    }

    function getStringArray(bytes32 variable) 
    external view 
    returns (string[] memory) { 
        return _stringArray[variable]; 
    }

    function getBytesArray(bytes32 variable) 
    external view 
    returns (bytes[] memory) { 
        return _bytesArray[variable]; 
    }

    function getUintArray(bytes32 variable) 
    external view 
    returns (uint[] memory) { 
        return _uintArray[variable]; 
    }

    function getIntArray(bytes32 variable) 
    external view 
    returns (int[] memory) { 
        return _intArray[variable]; 
    }

    function getAddressArray(bytes32 variable) 
    external view 
    returns (address[] memory) { 
        return _addressArray[variable]; 
    }

    function getBoolArray(bytes32 variable) 
    external view 
    returns (bool[] memory) { 
        return _boolArray[variable]; 
    }

    function getBytes32Array(bytes32 variable) 
    external view 
    returns (bytes32[] memory) { 
        return _bytes32Array[variable]; 
    }

    function indexStringArray(bytes32 variable, uint index) 
    external view 
    returns (string memory) { 
        return _stringArray[variable][index]; 
    }

    function indexBytesArray(bytes32 variable, uint index) 
    external view 
    returns (bytes memory) { 
        return _bytesArray[variable][index]; 
    }

    function indexUintArray(bytes32 variable, uint index) 
    external view 
    returns (uint) { 
        return _uintArray[variable][index]; 
    }

    function indexIntArray(bytes32 variable, uint index) 
    external view 
    returns (int) { 
        return _intArray[variable][index]; 
    }

    function indexAddressArray(bytes32 variable, uint index) 
    external view 
    returns (address) { 
        return _addressArray[variable][index]; 
    }

    function indexBoolArray(bytes32 variable, uint index) 
    external view 
    returns (bool) { 
        return _boolArray[variable][index]; 
    }

    function indexBytes32Array(bytes32 variable, uint index) 
    external view 
    returns (bytes32) { 
        return _bytes32Array[variable][index]; 
    }

    function lengthStringArray(bytes32 variable) 
    external view 
    returns (uint) { 
        return _stringArray[variable].length; 
    }

    function lengthBytesArray(bytes32 variable) 
    external view 
    returns (uint) { 
        return _bytesArray[variable].length; 
    }

    function lengthUintArray(bytes32 variable) 
    external view 
    returns (uint) { 
        return _uintArray[variable].length; 
    }

    function lengthIntArray(bytes32 variable) 
    external view 
    returns (uint) { 
        return _intArray[variable].length; 
    }

    function lengthAddressArray(bytes32 variable) 
    external view 
    returns (uint) { 
        return _addressArray[variable].length; 
    }

    function lengthBoolArray(bytes32 variable) 
    external view 
    returns (uint) { 
        return _boolArray[variable].length; 
    }

    function lengthBytes32Array(bytes32 variable) 
    external view 
    returns (uint) { 
        return _bytes32Array[variable].length; 
    }

    function getAddressSet(bytes32 variable) 
    external view 
    returns (address[] memory) { 
        return _addressSet[variable].values(); 
    }

    function getUintSet(bytes32 variable) 
    external view 
    returns (uint[] memory) { 
        return _uintSet[variable].values(); 
    }

    function getBytes32Set(bytes32 variable) 
    external view 
    returns (bytes32[] memory) { 
        return _bytes32Set[variable].values(); 
    }

    function indexAddressSet(bytes32 variable, uint index) 
    external view 
    returns (address) { 
        return _addressSet[variable].at(index); 
    }

    function indexUintSet(bytes32 variable, uint index) 
    external view 
    returns (uint) { 
        return _uintSet[variable].at(index); 
    }

    function indexBytes32Set(bytes32 variable, uint index) 
    external view 
    returns (bytes32) { 
        return _bytes32Set[variable].at(index); 
    }

    function lengthAddressSet(bytes32 variable) 
    external view 
    returns (uint) { 
        return _addressSet[variable].length(); 
    }

    function lengthUintSet(bytes32 variable) 
    external view 
    returns (uint) { 
        return _uintSet[variable].length(); 
    }

    function lengthBytes32Set(bytes32 variable) 
    external view 
    returns (uint) { 
        return _bytes32Set[variable].length(); 
    }

    function containsAddressSet(bytes32 variable, address data) 
    external view 
    returns (bool) { 
        return _addressSet[variable].contains(data); 
    }
    
    function containsUintSet(bytes32 variable, uint data) 
    external view
    returns (bool) { 
        return _uintSet[variable].contains(data); 
    }

    function containsBytes32Set(bytes32 variable, bytes32 data) 
    external view
    returns (bool) { 
        return _bytes32Set[variable].contains(data); 
    }

    function addAdmin(address admin) 
    external 
    onlyAdmin 
    nonReentrant 
    whenNotPaused {
        require(admin != address(0), "Storage: admin is address zero");
        require(!_logics.contains(admin), "Storage: admin is logic");
        require(!_admins.contains(admin), "Storage: already admin");
        _admins.add(admin);
        emit AddAdmin(admin);
    }

    function addLogic(address logic) 
    external 
    onlyAdmin 
    nonReentrant 
    whenNotPaused {
        require(logic != address(0), "Storage: logic is address zero");
        require(!_admins.contains(logic), "Storage: logic is admin");
        require(!_logics.contains(logic), "Storage: already logic");
        _logics.add(logic);
        emit AddLogic(logic);
    }

    function removeAdmin(address admin) 
    external 
    onlyAdmin 
    nonReentrant 
    whenNotPaused {
        require(admin != address(0), "Storage: admin is address zero");
        require(!_logics.contains(admin), "Storage: admin is logic");
        require(_admins.contains(admin), "Storage: not admin");
        _admins.remove(admin);
        emit RemoveAdmin(admin);
    }

    function removeLogic(address logic) 
    external 
    onlyAdmin 
    nonReentrant 
    whenNotPaused {
        require(logic != address(0), "Storage: logic is address zero");
        require(!_admins.contains(logic), "Storage: logic is admin");
        require(_logics.contains(logic), "Storage: not logic");
        _logics.remove(logic);
        emit RemoveLogic(logic);
    }

    function setString(bytes32 variable, string memory data) 
    external 
    onlyLogic 
    nonReentrant 
    whenNotPaused {
        _string[variable] = data;
        emit SetString(variable, data);
    }

    function setBytes(bytes32 variable, bytes memory data) 
    external 
    onlyLogic 
    nonReentrant 
    whenNotPaused {
        _bytes[variable] = data;
        emit SetBytes(variable, data);
    }

    function setUint(bytes32 variable, uint data) 
    external 
    onlyLogic 
    nonReentrant 
    whenNotPaused {
        _uint[variable] = data;
        emit SetUint(variable, data);
    }

    function setInt(bytes32 variable, int data) 
    external 
    onlyLogic 
    nonReentrant 
    whenNotPaused {
        _int[variable] = data;
        emit SetInt(variable, data);
    }

    function setAddress(bytes32 variable, address data) 
    external 
    onlyLogic 
    nonReentrant 
    whenNotPaused {
        _address[variable] = data;
        emit SetAddress(variable, data);
    }

    function setBool(bytes32 variable, bool data) 
    external 
    onlyLogic 
    nonReentrant 
    whenNotPaused {
        _bool[variable] = data;
        emit SetBool(variable, data);
    }

    function setBytes32(bytes32 variable, bytes32 data) 
    external 
    onlyLogic 
    nonReentrant 
    whenNotPaused {
        _bytes32[variable] = data;
        emit SetBytes32(variable, data);
    }

    function setIndexStringArray(bytes32 variable, uint index, string memory data) 
    external 
    onlyLogic 
    nonReentrant 
    whenNotPaused {
        _stringArray[variable][index] = data;
        emit SetIndexStringArray(variable, index, data);
    }

    function setIndexBytesArray(bytes32 variable, uint index, bytes memory data) 
    external 
    onlyLogic 
    nonReentrant 
    whenNotPaused {
        _bytesArray[variable][index] = data;
        emit SetIndexBytesArray(variable, index, data);
    }

    function setIndexUintArray(bytes32 variable, uint index, uint data) 
    external 
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _uintArray[variable][index] = data;
        emit SetIndexUintArray(variable, index, data);
    }

    function setIndexIntArray(bytes32 variable, uint index, int data) 
    external 
    onlyLogic 
    nonReentrant 
    whenNotPaused {
        _intArray[variable][index] = data;
        emit SetIndexIntArray(variable, index, data);
    }

    function setIndexAddressArray(bytes32 variable, uint index, address data) 
    external 
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _addressArray[variable][index] = data;
        emit SetIndexAddressArray(variable, index, data);
    }

    function setIndexBoolArray(bytes32 variable, uint index, bool data) 
    external 
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _boolArray[variable][index] = data;
        emit SetIndexBoolArray(variable, index, data);
    }

    function setIndexBytes32Array(bytes32 variable, uint index, bytes32 data) 
    external 
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _bytes32Array[variable][index] = data;
        emit SetIndexBytes32Array(variable, index, data);
    }

    function pushStringArray(bytes32 variable, string memory data) 
    external 
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _stringArray[variable].push(data);
        emit PushStringArray(variable, data);
    }

    function pushBytesArray(bytes32 variable, bytes memory data) 
    external 
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _bytesArray[variable].push(data);
        emit PushBytesArray(variable, data);
    }

    function pushUintArray(bytes32 variable, uint data) 
    external 
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _uintArray[variable].push(data);
        emit PushUintArray(variable, data);
    }

    function pushIntArray(bytes32 variable, int data) 
    external 
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _intArray[variable].push(data);
        emit PushIntArray(variable, data);
    }

    function pushAddressArray(bytes32 variable, address data) 
    external 
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _addressArray[variable].push(data);
        emit PushAddressArray(variable, data);
    }

    function pushBoolArray(bytes32 variable, bool data) 
    external 
    onlyLogic 
    nonReentrant 
    whenNotPaused{
        _boolArray[variable].push(data);
        emit PushBoolArray(variable, data);
    }

    function pushBytes32Array(bytes32 variable, bytes32 data) 
    external 
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _bytes32Array[variable].push(data);
        emit PushBytes32Array(variable, data);
    }

    function deleteStringArray(bytes32 variable)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        delete _stringArray[variable];
        emit DeleteStringArray(variable);
    }

    function deleteBytesArray(bytes32 variable)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        delete _bytesArray[variable];
        emit DeleteBytesArray(variable);
    }

    function deleteUintArray(bytes32 variable)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        delete _uintArray[variable];
        emit DeleteUintArray(variable);
    }

    function deleteIntArray(bytes32 variable)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        delete _intArray[variable];
        emit DeleteIntArray(variable);
    }

    function deleteAddressArray(bytes32 variable)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        delete _addressArray[variable];
        emit DeleteAddressArray(variable);
    }

    function deleteBoolArray(bytes32 variable)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        delete _boolArray[variable];
        emit DeleteBoolArray(variable);
    }

    function deleteBytes32Array(bytes32 variable)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        delete _bytes32Array[variable];
        emit DeleteBytes32Array(variable);
    }

    function addAddressSet(bytes32 variable, address data)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _addressSet[variable].add(data);
        emit AddAddressSet(variable, data);
    }

    function addUintSet(bytes32 variable, uint data)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _uintSet[variable].add(data);
        emit AddUintSet(variable, data);
    }

    function addBytes32Set(bytes32 variable, bytes32 data)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _bytes32Set[variable].add(data);
        emit AddBytes32Set(variable, data);
    }

    function removeAddressSet(bytes32 variable, address data)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _addressSet[variable].remove(data);
        emit RemoveAddressSet(variable, data);
    }

    function removeUintSet(bytes32 variable, uint data)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _uintSet[variable].remove(data);
        emit RemoveUintSet(variable, data);
    }

    function removeBytes32Set(bytes32 variable, bytes32 data)
    external
    onlyLogic
    nonReentrant 
    whenNotPaused {
        _bytes32Set[variable].remove(data);
        emit RemoveBytes32Set(variable, data);
    }

    function _onlyAdmin() 
    private view {
        require(_admins.contains(msg.sender), "Storage: msg.sender !=admin");
    }

    function _onlyLogic() 
    private view {
        require(_logics.contains(msg.sender), "Storage: msg.sender !=logic");
    }
}

interface IRouter {
    function getLatestLogic(string memory module) external view returns (address);
    function getLogic(string memory module, uint version) external view returns (address);
    function getLogics(string memory module) external view returns (address[] memory);
    function getLatestVersion(string memory module) external view returns (uint);
    function requireLatestLogic(string memory module, address logic) external view;
    function upgrade(string memory module, address logic) external;
    function downgrade(string memory module, uint version) external;
    function pause() external;
    function unpause() external;
}

contract Router is IRouter, Ownable, Pausable, ReentrancyGuard {
    IEternalStorage eternalStorage;

    event LogicUpgraded(string indexed module, address indexed logic);

    constructor(address eternalStorage_) 
    Ownable(msg.sender) {
        eternalStorage = IEternalStorage(eternalStorage_);
    }

    function getLatestLogic(string memory module)
    external view
    returns (address) {
        bytes32 variable = keccak256(abi.encode("router", module));
        uint index = eternalStorage.lengthAddressSet(variable) - 1;
        return eternalStorage.indexAddressSet(variable, index);
    }

    function getLogic(string memory module, uint version)
    external view
    returns (address) {
        bytes32 variable = keccak256(abi.encode("router", module));
        return eternalStorage.indexAddressSet(variable, version);
    }

    function getLogics(string memory module)
    external view
    returns (address[] memory) {
        bytes32 variable = keccak256(abi.encode("router", module));
        return eternalStorage.getAddressSet(variable);
    }

    function getLatestVersion(string memory module)
    external view
    returns (uint) {
        bytes32 variable = keccak256(abi.encode("router", module));
        return eternalStorage.lengthAddressSet(variable);
    }

    /// useful for contracts to pause or unpause if they are the latest implementation or not
    function requireLatestLogic(string memory module, address logic)
    external view {
        bytes32 variable = keccak256(abi.encode("router", module));
        uint index = eternalStorage.lengthAddressSet(variable) - 1;
        address latestLogic = eternalStorage.indexAddressSet(variable, index);
        require(logic == latestLogic, "Router: logic is not latest logic");
    }

    function upgrade(string memory module, address logic)
    external 
    onlyOwner {
        bytes32 variable = keccak256(abi.encode("router", module));
        eternalStorage.addAddressSet(variable, logic);
        emit LogicUpgraded(module, logic);
    }

    function downgrade(string memory module, uint version)
    external 
    onlyOwner {
        bytes32 variable = keccak256(abi.encode("router", module));
        address logic = eternalStorage.indexAddressSet(variable, version);
        eternalStorage.removeAddressSet(variable, logic);
        eternalStorage.addAddressSet(variable, logic);
        emit LogicUpgraded(module, logic);
    }

    function pause()
    external
    onlyOwner {
        _pause();
    }

    function unpause()
    external
    onlyOwner {
        _unpause();
    }
}

// TODO test contract
contract Sentinel is Ownable, Pausable, ReentrancyGuard {
    IEternalStorage eternalStorage;

    event Transfer(address indexed from, address indexed to, address logic, string signature, uint granted, uint expiration, bool transferable, bool clonable, uint class, uint balance, bytes data);

    constructor(address eternalStorage_)
    Ownable(msg.sender) {
        eternalStorage = IEternalStorage(eternalStorage_);
    }

    function decodeKey(bytes memory encodedKey)
    external pure
    returns (address, string memory, uint, uint, bool, bool, KeyClass, uint, bytes memory) {
        Key memory key = abi.decode(encodedKey, (Key));
        return (key.logic, key.signature, key.granted, key.expiration, key.transferable, key.clonable, key.class, key.balance, key.data);
    }

    function getKey(address account, uint index)
    external view
    returns (address, string memory, uint, uint, bool, bool, KeyClass, uint, bytes memory) {
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        bytes memory encodedKey = eternalStorage.indexBytesArray(varAccountKeys, index);
        Key memory key = abi.decode(encodedKey, (Key));
        return (key.logic, key.signature, key.granted, key.expiration, key.transferable, key.clonable, key.class, key.balance, key.data);
    }

    function getKeys(address account)
    external view
    returns (bytes[] memory) {
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        return eternalStorage.getBytesArray(varAccountKeys);
    }

    function mint(string memory signature)
    external 
    nonReentrant
    whenNotPaused {
        bytes memory emptyBytes;
        _mint(msg.sender, msg.sender, signature, 0, 0, true, true, KeyClass.SOURCE, 0, emptyBytes);
    }

    function burn(address logic, string memory signature)
    external 
    nonReentrant 
    whenNotPaused {
        _burn(msg.sender, logic, signature);
    }

    function transfer(address to, address logic, string memory signature)
    external
    nonReentrant
    whenNotPaused {
        _transfer(msg.sender, to, logic, signature);
    }

    function grant(address to, address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data)
    external 
    nonReentrant
    whenNotPaused {
        _grant(msg.sender, to, logic, signature, granted, expiration, transferable, clonable, class, balance, data);
    }

    function pause()
    external 
    onlyOwner {
        _pause();
    }

    function unpause()
    external 
    onlyOwner {
        _unpause();
    }

    function verify(address account, address logic, string memory signature)
    external {
        _verify(account, logic, signature);
    }

    function _getIndexEmptyBytes(address account)
    internal view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        bytes[] memory encodedKeys = eternalStorage.getBytesArray(varAccountKeys);
        for (uint i = 0; i < encodedKeys.length; i++) {
            if (Match.isMatchingBytes(encodedKeys[i], emptyBytes)) {
                success = true;
                index = i;
                break;
            }
        }
        return (success, index);
    }

    function _getIndexLogSig(address account, address logic, string memory signature)
    internal view
    returns (bool success, uint index, Key memory key) {
        bytes memory emptyBytes;
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        bytes[] memory encodedKeys = eternalStorage.getBytesArray(varAccountKeys);
        for (uint i = 0; i < encodedKeys.length; i++) {
            key = abi.decode(encodedKeys[i], (Key));
            if (!Match.isMatchingBytes(encodedKeys[i], emptyBytes) && Match.isMatchingString(signature, key.signature) && logic == key.logic) {
                success = true;
                index = i;
                break;
            }
        }
        return (success, index, key);
    }

    function _pushKey(address account, Key memory key)
    internal {
        (bool success, uint index,) = _getIndexLogSig(account, key.logic, key.signature);
        require(!success, "Sentinel: cannot push because account already has a key with the given logic and signature");
        (success, index) = _getIndexEmptyBytes(account);
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        if (success) {
            eternalStorage.setIndexBytesArray(varAccountKeys, index, abi.encode(key));
        } else {
            eternalStorage.pushBytesArray(varAccountKeys, abi.encode(key));
        }
    }

    function _pullKey(address account, address logic, string memory signature)
    internal {
        (bool success, uint index,) = _getIndexLogSig(account, logic, signature);
        require(success, "Sentinel: cannot pull because account does not have a key with the given logic and signature");
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        bytes memory emptyBytes;
        eternalStorage.setIndexBytesArray(varAccountKeys, index, emptyBytes);
    }

    function _mint(address account, address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data)
    internal {
        require(msg.sender != address(0), "Sentinel: cannot mint because caller is address zero");
        require(account != address(0), "Sentinel: cannot mint because account is address zero");
        require(logic != address(0), "Sentinel: cannot mint because logic is address zero");
        Key memory key = Key({logic: logic, signature: signature, granted: granted, expiration: expiration, transferable: transferable, clonable: clonable, class: class, balance: balance, data: data});
        _pushKey(account, key);
        emit Transfer(address(0), account, logic, signature, granted, expiration, transferable, clonable, uint(class), balance, data);
    }

    function _burn(address account, address logic, string memory signature)
    internal {
        require(msg.sender != address(0), "Sentinel: cannot mint because caller is address zero");
        require(account != address(0), "Sentinel: cannot mint because account is address zero");
        require(logic != address(0), "Sentinel: cannot mint because logic is address zero");
        _pullKey(account, logic, signature);
        (, , Key memory key) = _getIndexLogSig(account, logic, signature);
        emit Transfer(account, address(0), key.logic, key.signature, key.granted, key.expiration, key.transferable, key.clonable, uint(key.class), key.balance, key.data);
    }

    function _transfer(address from, address to, address logic, string memory signature)
    internal {
        require(from != address(0), "Sentinel: cannot transfer because sender is address zero");
        require(to != address(0), "Sentinel: cannot transfer because recipient is address zero");
        require(logic != address(0), "Sentinel: cannot transfer because logic is address zero");
        require(from != to, "Sentinel: cannot transfer because sender and recipient address is recursive");
        (, , Key memory key) = _getIndexLogSig(from, logic, signature);
        require(key.transferable, "Sentinel: cannot transfer because key is not transferable");
        _pullKey(from, key.logic, key.signature);
        _pushKey(to, key);
        if (key.clonable) {
            _pushKey(from, key);
        }
        emit Transfer(from, to, key.logic, key.signature, key.granted, key.expiration, key.transferable, key.clonable, uint(key.class), key.balance, key.data);
    }
    
    function _grant(address from, address to, address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data)
    internal {
        require(from != address(0), "Sentinel: cannot grant because sender is address zero");
        require(to != address(0), "Sentinel: cannot grant because recipient is address zero");
        require(logic != address(0), "Sentinel: cannot grant because logic is address zero");
        require(from != to, "Sentinel: cannot grant because sender and recipient address is recursive");
        (, , Key memory sourceKey) = _getIndexLogSig(from, logic, signature);
        require(sourceKey.class == KeyClass.SOURCE, "Sentinel: cannot grant because grantor does not have source");
        require(class != KeyClass.SOURCE, "Sentinel: cannot grant because granted version is a source **use transfer for source class");
        Key memory key = Key({logic: logic, signature: signature, granted: granted, expiration: expiration, transferable: transferable, clonable: clonable, class: class, balance: balance, data: data});
        _pushKey(to, key);
        emit Transfer(from, to, key.logic, key.signature, key.granted, key.expiration, key.transferable, key.clonable, uint(key.class), key.balance, key.data);
    }

    function _verify(address account, address logic, string memory signature)
    internal {
        (bool success, uint index, Key memory key) = _getIndexLogSig(account, logic, signature);
        require(success, "Sentinel: unauthorized because account does not have a key with the given logic and signature");
        if (key.class == KeyClass.CONSUMABLE) {
            require(key.balance >= 1, "Sentinel: unauthorized because consumable is depleted");
            key.balance--;
            bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
            eternalStorage.setIndexBytesArray(varAccountKeys, index, abi.encode(key));
        } else if (key.class == KeyClass.TIMED) {
            require(block.timestamp >= key.granted, "Sentinel: unauthorized because timed has not been granted yet");
            require(block.timestamp < key.expiration, "Sentinel: unauthorized because key has expired");
        } else if (key.class != KeyClass.SOURCE && key.class != KeyClass.STANDARD && key.class != KeyClass.CONSUMABLE && key.class != Key.TIMED) {
            revert("Sentinel: cannot verify because class is unrecognized");
        }
    }
}

interface IOverseer {
    function getMembers(string memory role) external view returns (address[] memory);
    function getSize(string memory role) external view returns (uint);
    function requireRole(address account, string memory role) external view;
    function grant(address to, string memory role) external;
    function revoke(address from, string memory role) external;
    function pause() external;
    function unpause() external;
}

contract Overseer is IOverseer, Ownable, Pausable, ReentrancyGuard {
    IEternalStorage eternalStorage;

    event RoleGranted(address indexed to, string indexed role);
    event RoleRevoked(address indexed from, string indexed role);

    constructor(address eternalStorage_)
    Ownable(msg.sender) {
        eternalStorage = IEternalStorage(eternalStorage_);
    }

    function getMembers(string memory role)
    external view
    returns (address[] memory) {
        bytes32 variable = keccak256(abi.encode(role, "members"));
        return eternalStorage.getAddressSet(variable);
    }

    function getSize(string memory role)
    external view
    returns (uint) {
        bytes32 variable = keccak256(abi.encode(role, "members"));
        return eternalStorage.lengthAddressSet(variable);
    }

    function requireRole(address account, string memory role)
    external view {
        bytes32 variable = keccak256(abi.encode(role, "members"));
        require(eternalStorage.containsAddressSet(variable, account), "Overseer: unauthorized because account does not have required role");
    }

    function grant(address to, string memory role)
    external 
    onlyOwner
    nonReentrant
    whenNotPaused {
        _grant(to, role);
        emit RoleGranted(to, role);
    }

    function revoke(address from, string memory role)
    external 
    onlyOwner
    nonReentrant
    whenNotPaused {
        _revoke(from, role);
        emit RoleRevoked(from, role);
    }

    function pause()
    external
    onlyOwner {
        _pause();
    }

    function unpause()
    external
    onlyOwner {
        _unpause();
    }

    function _grant(address to, string memory role)
    internal {
        bytes32 variable = keccak256(abi.encode(role, "members"));
        eternalStorage.addAddressSet(variable, to);
    }

    function _revoke(address from, string memory role)
    internal {
        bytes32 variable = keccak256(abi.encode(role, "members"));
        eternalStorage.removeAddressSet(variable, from);
    }
}

// TODO finish up timelock interface
interface ITimelock {
    function init(uint timelock, uint timeout) external;
}

contract Timelock is ITimelock, Pausable, ReentrancyGuard {
    IEternalStorage eternalStorage;
    ISentinel sentinel;
    address private _deployer;
    bool private _init;
    address me;
    
    constructor(address eternalStorage_, address sentinel_) {
        eternalStorage = IEternalStorage(eternalStorage_);
        sentinel = ISentinel(sentinel_);
        _deployer = msg.sender;
        me = address(this);
        sentinel.mint("queue");
        sentinel.mint("execute");
        sentinel.mint("pause");
        sentinel.mint("unpause");
        bytes memory emptyBytes;
        sentinel.grant(msg.sender, me, "queue", 0, 0, false, false, KeyClass.STANDARD, 0, emptyBytes);
        sentinel.grant(msg.sender, me, "execute", 0, 0, false, false, KeyClass.STANDARD, 0, emptyBytes);
        sentinel.grant(msg.sender, me, "pause", 0, 0, false, false, KeyClass.STANDARD, 0, emptyBytes);
        sentinel.grant(msg.sender, me, "unpause", 0, 0, false, false, KeyClass.STANDARD, 0, emptyBytes);
    }

    function decodeRequest(bytes memory encodedRequest)
    external pure
    returns (string memory message, address[] memory targets, string[] memory signatures, bytes[] memory args, uint created, uint endTimelock, uint endTimeout, address creator, RequestStage stage) {
        Request memory request = abi.decode(encodedRequest, (Request));
        return (
            request.message,
            request.targets,
            request.signatures,
            request.args,
            request.created,
            request.endTimelock,
            request.endTimeout,
            request.creator,
            request.stage
        );
    }

    function getRequests()
    external view
    returns (bytes[] memory) {
        bytes32 requests = keccak256(abi.encode("requests"));
        return eternalStorage.getBytesArray(requests);
    }

    function getActiveRequests()
    external view
    returns (bytes[] memory activeRequests) {
        uint count;
        bytes32 requests = keccak256(abi.encode("requests"));
        bytes[] memory encodedRequests = eternalStorage.getBytesArray(requests);
        for (uint i = 0; i < encodedRequests.length; i++) {
            Request memory request = abi.decode(encodedRequests[i], (Request));
            if (block.timestamp >= request.created && block.timestamp <= request.endTimeout) {
                activeRequests[count] = encodedRequests[i];
                count++;
            }
        }

        return activeRequests;
    }

    function init(uint timelock, uint timeout)
    external {
        require(msg.sender == _deployer, "Timelock: cannot initialize because caller is not deployer");
        require(!_init, "Timelock: cannot initialize because already been initialized");
        bytes32 durationTimelock = keccak256(abi.encode("durationTimelock"));
        bytes32 durationTimeout = keccak256(abi.encode("durationTimeout"));
        eternalStorage.setUint(durationTimelock, timelock);
        eternalStorage.setUint(durationTimeout, timeout);
        _init = true;
    }

    function queue(string memory message, address[] memory targets, string[] memory signatures, bytes[] memory args)
    external 
    nonReentrant
    whenNotPaused {
        sentinel.verify(msg.sender, me, "queue");
        _queue(message, targets, signatures, args);
    }

    function execute(uint index)
    external 
    nonReentrant
    whenNotPaused {
        sentinel.verify(msg.sender, me, "execute");
        _execute(index);
    }

    function pause()
    external {
        sentinel.verify(msg.sender, me, "pause");
        _pause();
    }

    function unpause()
    external {
        sentinel.verify(msg.sender, me, "unpause");
        _unpause();
    }

    function _queue(string memory message, address[] memory targets, string[] memory signatures, bytes[] memory args)
    internal {
        bytes32 requests = keccak256(abi.encode("requests"));
        bytes32 durationTimelock = keccak256(abi.encode("durationTimelock"));
        bytes32 durationTimeout = keccak256(abi.encode("durationTimeout"));
        eternalStorage.pushBytesArray(
            requests,
            abi.encode(
                Request({
                    message: message,
                    targets: targets,
                    signatures: signatures,
                    args: args,
                    created: block.timestamp,
                    endTimelock: block.timestamp + eternalStorage.getUint(durationTimelock),
                    endTimeout: block.timestamp + eternalStorage.getUint(durationTimeout),
                    creator: msg.sender,
                    stage: RequestStage.PENDING
                })
            )
        );
    }

    /// TODO solve issue where not executing when it should be
    function _execute(uint index)
    internal
    returns (bool[] memory successes, bytes[] memory responses) {
        bytes32 requests = keccak256(abi.encode("requests"));
        Request memory request = abi.decode(eternalStorage.indexBytesArray(requests, index), (Request));
        require(block.timestamp > request.endTimelock, "Timelock: cannot execute request because timelock has not ended yet");
        require(block.timestamp < request.endTimeout, "Timelock: cannot execute request because request has timed out");
        require(request.stage != RequestStage.EXECUTED, "Timelock: cannot execute request because request has already been executed");
        request.stage = RequestStage.EXECUTED;
        eternalStorage.setIndexBytesArray(requests, index, abi.encode(request));
        for (uint i = 0; i < request.targets.length; i++) {
            (successes[i], responses[i]) = request.targets[i].call(abi.encodeWithSignature(request.signatures[i], request.args[i]));
        }

        return (successes, responses);
    }
}

contract MSigProposals {
    using EnumerableSet for EnumerableSet.AddressSet;

    IEternalStorage eternalStorage;
    ISentinel sentinel;
    IOverseer overseer;
    ITimelock timelock;
    bytes32 varMSigProposals;
    uint durationTimeout;
    uint requiredQuorum;

    modifier onlySigner() {
        _onlySigner();
        _;
    }

    modifier onlySigned(uint index) {
        _onlySigned(index);
        _;
    }

    modifier onlyNotSigned(uint index) {
        _onlyNotSigned(index);
        _;
    }

    modifier onlyPending(uint index) {
        _onlyPending(index);
        _;
    }

    modifier onlyApproved(uint index) {
        _onlyApproved(index);
        _;
    }

    modifier onlyRejected(uint index) {
        _onlyRejected(index);
        _;
    }

    modifier onlyExecuted(uint index) {
        _onlyExecuted(index);
        _;
    }

    modifier onlyNotExecuted(uint index) {
        _onlyNotExecuted(index);
        _;
    }

    constructor(address eternalStorage_, address sentinel_, address overseer_, address timelock_) {
        eternalStorage = IEternalStorage(eternalStorage_);
        sentinel = ISentinel(sentinel_);
        overseer = IOverseer(overseer_);
        timelock = ITimelock(timelock_);
        varMSigProposals = keccak256(abi.encode("mSigProposals"));
    }

    function _onlySigner()
    internal view {
        overseer.requireRole(msg.sender, "council");
    }

    function _onlySigned(uint index)
    internal view {
        MSigProposal memory proposal = _getProposal(index);
        require(proposal.signatures_.contains(msg.sender));
    }

    function _onlyNotSigned(uint index) 
    internal view {
        MSigProposal memory proposal = _getProposal(index);
        require(!proposal.signatures_.contains(msg.sender));
    }

    function _onlyPending(uint index)
    internal view {
        MSigProposal memory proposal = _getProposal(index);
        require(proposal.stage == ProposalStage.PENDING, "MSigProposals: multi sig proposal is not pending");
    }

    function _onlyApproved(uint index)
    internal view {
        MSigProposal memory proposal = _getProposal(index);
        require(proposal.stage == ProposalStage.APPROVED, "MSigProposals: multi sig proposal is not approved");
    }

    function _onlyRejected(uint index)
    internal view {
        MSigProposal memory proposal = _getProposal(index);
        require(proposal.stage == ProposalStage.REJECTED, "MSigProposals: multi sig proposal is not rejected");
    }

    function _onlyExecuted(uint index)
    internal view {
        MSigProposal memory proposal = _getProposal(index);
        require(proposal.stage == ProposalStage.EXECUTED, "MSigProposals: multi sig proposal is not executed");
    }

    function _onlyNotExecuted(uint index)
    internal view {
        MSigProposal memory proposa = _getProposal(index);
        require(proposal.stage != ProposalStage.EXECUTED, "MSigProposals: multi sig proposal is executed");
    }

    function _getProposal(uint index)
    internal view
    returns (MSigProposal memory) {
        bytes memory encodedProposal = eternalStorage.indexBytesArray(varMSigProposals, index);
        return abi.decode(encodedProposal, (MSigProposal));
    }

    function _queue(string memory message, address[] memory targets, string[] memory signatures, bytes[] memory args, uint endTimeout, uint quorum, uint requiredQuorum, ProposalStage stage)
    internal 
    onlySigner
    returns (uint) {
        MSigProposal memory newProposal = MSigProposal({message: message, creator: msg.sender, targets: targets, signatures: signatures, args: args, endTimeout: endTimeout, quorum: quorum, requiredQuorum: requiredQuorum, stage: stage, signers: overseer.getMembers("council"), signatures_: []});
        eternalStorage.pushBytesArray(varMSigProposals, abi.encode(newProposal));
        return eternalStorage.lengthBytesArray(varMSigProposals) - 1;
    }

    function _sign(uint index)
    internal 
    onlySigner 
    onlyNotSigned(index) 
    onlyPending(index) {
        MSigProposal memory proposal = _getProposal(index);
        proposal.signatures_.add(msg.sender);
        _update(index);
    }

    function _unsign(uint index)
    internal
    onlySigner
    onlySigned(index)
    onlyPending(index) {
        MSigProposal memory proposal = _getProposal(index);
        proposa.signatures_.remove(msg.sender);
        _update(index);
    }

    function _escalate(uint index)
    internal
    onlySigner
    onlyNotExecuted(index) {
        // TODO escalte call public proposal
    }

    function _update(uint index)
    internal {
        MSigProposal memory proposal = _getProposal(index);
        if (proposal.quorum >= requiredQuorum) {
            proposal.stage = ProposalStage.APPROVED;
        }
    }
}

