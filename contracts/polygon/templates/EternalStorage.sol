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
    string[] signatures_;
    bytes[] args;
    uint endTimeout;
    uint quorum;
    uint requiredQuorum;
    ProposalStage stage;
    EnumerableSet.AddressSet signers;
    EnumerableSet.AddressSet signatures;
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
    }

    function downgrade(string memory module, uint version)
    external 
    onlyOwner {
        bytes32 variable = keccak256(abi.encode("router", module));
        address logic = eternalStorage.indexAddressSet(variable, version);
        eternalStorage.removeAddressSet(variable, logic);
        eternalStorage.addAddressSet(variable, logic);
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

interface ISentinel {
    function decodeKey(bytes memory encodedKey) external pure returns (address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data);
    function getKeys(address account) external view returns (bytes[] memory);
    function mintSource(string memory signature) external;
    function burn(address logic, string memory signature) external;
    function transfer(address to, address logic, string memory signature) external;
    function transferCopy(address to, address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data) external;
    function verify(address account, address logic, string memory signature) external;
}

contract Sentinel is ISentinel, Ownable, Pausable, ReentrancyGuard {
    IEternalStorage eternalStorage;

    constructor(address eternalStorage_)
    Ownable(msg.sender) {
        eternalStorage = IEternalStorage(eternalStorage_);
    }

    function decodeKey(bytes memory encodedKey)
    external pure
    returns (address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data) {
        Key memory key = abi.decode(encodedKey, (Key));
        
        return (
            key.logic, 
            key.signature, 
            key.granted, 
            key.expiration, 
            key.transferable, 
            key.clonable, 
            key.class, 
            key.balance, 
            key.data
        );
    }

    function getKeys(address account)
    external view 
    returns (bytes[] memory) {
        bytes32 variable = keccak256(abi.encode(account, "keys"));
        return eternalStorage.getBytesArray(variable);
    }

    function mintSource(string memory signature)
    external
    nonReentrant 
    whenNotPaused {
        bytes32 variable = keccak256(abi.encode(msg.sender, "keys"));
        _mintSource(variable, signature);
    }

    /// @dev source keys can also be deleted by contracts
    function burn(address logic, string memory signature)
    external
    nonReentrant 
    whenNotPaused {
        bytes32 variable = keccak256(abi.encode(msg.sender, "keys"));
        _burn(variable, logic, signature);
    }

    function transfer(address to, address logic, string memory signature)
    external
    nonReentrant 
    whenNotPaused {
        _transfer(msg.sender, to, logic, signature);
    }

    function transferCopy(address to, address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data)
    external
    nonReentrant 
    whenNotPaused {
        _transferCopy(msg.sender, to, logic, signature, granted, expiration, transferable, clonable, class, balance, data);
    }

    function verify(address account, address logic, string memory signature)
    external
    nonReentrant 
    whenNotPaused {
        bytes32 variable = keccak256(abi.encode(account, "keys"));
        _verify(variable, logic, signature);
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

    function _verifyKeyArgs(Key memory key)
    internal view {
        require(key.logic != address(0), "Sentinel: logic must not be address zero");

        if (key.class == KeyClass.SOURCE) {
            require(key.granted == 0, "Sentinel: class is source but granted is not zero");
            require(key.expiration == 0, "Sentinel: class is source but expiration is not zero");
            require(key.balance == 0, "Sentinel: class is source but balance is not zero");
            require(key.transferable, "Sentinel: class is source but key is not transferable");
            require(key.clonable, "Sentinel: class is source but key is not clonable");
        }

        else if (key.class == KeyClass.STANDARD) {
            require(key.granted == 0, "Sentinel: class is standard but granted is not zero");
            require(key.expiration == 0, "Sentinel: class is standard but expiration is not zero");
            require(key.balance == 0, "Sentinel: class is standard but balance is not zero");
        }

        else if (key.class == KeyClass.TIMED) {
            require(block.timestamp >= key.granted, "Sentinel: class is timed but granted in the past");
            require(key.granted < key.expiration, "Sentinel: class is timed but expires before granted");
            require(key.balance == 0, "Sentinel: class is timed but balance is not zero");
        }

        else if (key.class == KeyClass.CONSUMABLE) {
            require(key.granted == 0, "Sentinel: class is consumable but granted is not zero");
            require(key.expiration == 0, "Sentinel: class is consumable but expiration is not zero");
            require(key.balance >= 1, "Sentinel: class is consumable but balance is zero");
        }

        else {
            revert("Sentinel: unrecognized class");
        }
    }

    function _getIndexEmptyBytes(bytes32 variable)
    internal view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes[] memory keys = eternalStorage.getBytesArray(variable);
        for (uint i = 0; i < keys.length; i++) {

            if (Match.isMatchingBytes(keys[i], emptyBytes)) {
                index = i;
                success = true;
                break;
            }
        }

        return (success, index);
    }

    function _getIndexLogSig(bytes32 variable, address logic, string memory signature)
    internal view
    returns (bool success, uint index, Key memory key) {
        bytes memory emptyBytes;
        bytes[] memory keys = eternalStorage.getBytesArray(variable);
        for (uint i = 0; i < keys.length; i++) {
            key = abi.decode(keys[i], (Key));
            if (!Match.isMatchingBytes(keys[i], emptyBytes) && key.logic == logic && Match.isMatchingString(key.signature, signature)) {
                index = i;
                success = true;
                break;
            }
        }

        return (success, index, key);
    }

    function _mint(bytes32 variable, address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data)
    internal {
        (bool success, uint index,) = _getIndexLogSig(variable, logic, signature);
        require(!success, "Sentinel: cannot mint key because the bytes array already has a key with the given logic and signature");
        (success, index) = _getIndexEmptyBytes(variable);
        Key memory key = Key({
            logic: logic,
            signature: signature,
            granted: granted,
            expiration: expiration,
            transferable: transferable,
            clonable: clonable,
            class: class,
            balance: balance,
            data: data
        });

        if (success) {
            eternalStorage.setIndexBytesArray(variable, index, abi.encode(key));
        }

        else {
            eternalStorage.pushBytesArray(variable, abi.encode(key));
        }
    }

    function _mintSource(bytes32 variable, string memory signature)
    internal {
        bytes memory emptyBytes;
        _mint(variable, msg.sender, signature, 0, 0, true, true, KeyClass.SOURCE, 0, emptyBytes);
    }

    function _burn(bytes32 variable, address logic, string memory signature)
    internal {
        (bool success, uint index,) = _getIndexLogSig(variable, logic, signature);
        require(success, "Sentinel: cannot burn key because the bytes array does not contain any key with the given logic and signature");
        bytes memory emptyBytes;
        eternalStorage.setIndexBytesArray(variable, index, emptyBytes);
    }

    function _transfer(address from, address to, address logic, string memory signature)
    internal {
        // burn key of sender, and mint key to recipient unlike tokens recipient cannot have multiple of the same key so transfer will fail if they already have a copy regardless of class or difference
        bytes32 variableFrom = keccak256(abi.encode(from, "keys"));
        bytes32 variableTo = keccak256(abi.encode(to, "keys"));
        (bool success, uint index,) = _getIndexLogSig(variableFrom, logic, signature);
        require(success, "Sentinel: cannot transfer because sender does not have a key with the given logic and signature");
        Key memory key = abi.decode(eternalStorage.indexBytesArray(variableFrom, index), (Key));
        require(key.transferable, "Sentinel: cannot transfer because key is not transferable");
        if (!key.clonable) {
            _burn(variableFrom, logic, signature); 
        }

        _mint(
            variableTo,
            key.logic,
            key.signature,
            key.granted,
            key.expiration,
            key.transferable,
            key.clonable,
            key.class,
            key.balance,
            key.data
        );
    }

    function _transferCopy(address from, address to, address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data)
    internal {
        require(class != KeyClass.SOURCE, "Sentinel: cannot transfer copy because transfered version is a source");
        bytes32 variableFrom = keccak256(abi.encode(from, "keys"));
        bytes32 variableTo = keccak256(abi.encode(to, "keys"));
        (bool success, uint index,) = _getIndexLogSig(variableFrom, logic, signature);
        require(success, "Sentinel: cannot transfer copy because sender does not have a key with the given logic and signature");
        Key memory key = abi.decode(eternalStorage.indexBytesArray(variableFrom, index), (Key));
        require(key.class == KeyClass.SOURCE, "Sentinel: cannot transfer copy because the transfered key is not a source");

        _verifyKeyArgs(Key({
            logic: key.logic,
            signature: key.signature,
            granted: granted,
            expiration: expiration,
            transferable: transferable,
            clonable: clonable,
            class: class,
            balance: balance,
            data: data
        }));

        _mint(
            variableTo,
            key.logic,
            key.signature,
            granted,
            expiration,
            transferable,
            clonable,
            class,
            balance,
            data
        );
    }

    function _verify(bytes32 variable, address logic, string memory signature)
    internal {
        (bool success, uint index,) = _getIndexLogSig(variable, logic, signature);
        require(success, "Sentinel: unauthorized because bytes array does not contain any key with the given logic and signature");
        Key memory key = abi.decode(eternalStorage.indexBytesArray(variable, index), (Key));
        success = false;
        if (key.class == KeyClass.SOURCE) {
            success = true;
        }

        else if (key.class == KeyClass.STANDARD) {
            success = true;
        }

        else if (key.class == KeyClass.CONSUMABLE) {
            require(key.balance >= 1, "Sentinel: unauthorized because key is depleted");
            key.balance -= 1;
            eternalStorage.setIndexBytesArray(variable, index, key);
            success = true;
        }

        else if (key.class == KeyClass.TIMED) {
            require(block.timestamp >= key.granted, "Sentinel: unauthorized because key has not been granted yet");
            require(block.timestamp < key.expiration, "Sentinel: unauthorized because key has expired");
            success = true;
        }

        else {
            revert("Sentinel: cannot verify because class is unrecognized");
        }
    }
}

contract Curator is Ownable, Pausable, ReentrancyGuard {
    IEternalStorage eternalStorage;

    constructor(address eternalStorage_)
    Ownable(msg.sender) {
        eternalStorage = IEternalStorage(eternalStorage_);
    }

    function _getIndexEmptyBytes(bytes32 variable)
    internal view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes[] memory roles = eternalStorage.getBytesArray(variable);
        for (uint i = 0; i < roles.length; i++) {

            if (Match.isMatchingBytes(roles[i], emptyBytes)) {
                index = i;
                success = true;
                break;
            }
        }

        return (success, index);
    }

    function _getIndexRole(bytes32 variable, string role)
    internal view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes[] memory roles = eternalStorage.getBytesArray(variable);
        for (uint i = 0; i < roles.length; i++) {

            if (!Match.isMatchingBytes(roles[i], emptyBytes) && Match.isMatchingString(role, abi.decode(roles[i], (string)))) {
                index = i;
                success = true;
                break;
            }
        }

        return (success, index);
    }

    function _grant(address to, string memory role)
    internal {
        bytes32 variable = keccak256(abi.encode(to, "roles"));
        
    }

    function _mint(bytes32 variable, string memory role)
    internal {
        
    }
    
}