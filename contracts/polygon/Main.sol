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

    base 1 wei or 2 wei
    extend 5000 equal 1 wei + 200%, 3 or 6 wei

    _uint:          "gas", "base"
    _uint:          "gas", "extendCreateSolsticePool"
    _uint:          "gas", "extendCreateEnigmaPool"

    _addressSet:    "router", <string module>, "implementations"

    _addressSet:    "overseer", <string role>, "members"

    _string:        "requests", <uint index>, "message"
    _addressArray:  "requests", <uint index>, "targets"
    _stringArray:   "requests", <uint index>, "signatures"
    _bytesArray:    "requests", <uint index>, "args"
    _uint:          "requests", <uint index>, "start"
    _uint:          "requests", <uint index>, "timelock"
    _uint:          "requests", <uint index>, "timeout"
    _address:       "requests", <uint index>, "creator"
    _bool:          "requests", <uint index>, "executed"
    _uint:          "requests", "count"

    _uint:          "dreamToken", <address account, "balance"
    _uint:          "emberToken", <address account, "balance"


    _uint:          "mSigProposalsCount"

    _string:        "pools", <uint index>, "name"
    _string:        "pools", <uint index>, "description"  
    _addressSet:    "pools", <uint index>, "managers"  
    _addressSet:    "pools", <uint index>, "admins"   
    _addressSet:    "pools", <uint index>, "contributors"
    _addressSet:    "pools", <uint index>, "whitelist"
    _bool:          "pools", <uint index>, "isWhitelisted"
    _uint:          "pools", <uint index>, <address account>, "contribution"
    _address:       "pools", <uint index>, "token"
    _string:        "pools", <uint index>, "tokenName"
    _string:        "pools", <uint index>, "tokenSymbol"
    _uint:          "poolsCount"

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

// MANAGED POOL
enum PoolState {
    PENDING,
    TRADING,
    PAUSED
}

struct Pool {
    string name;
    string description;
    address[] managers;
    address[] admins;
    address[] contributors;
    uint[] contributions;
    uint start;
    PoolState state;
    address[] tokens;
    uint[] amounts;
    uint balance;
    bytes data;
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
    function getLatestImplementation(string memory module, uint index) external view returns (address);
    function getLatestVersion(string memory module) external view returns (uint);
    function getImplementation(string memory module, uint index) external view returns (address);
    function requireLatestImplementation(string memory module, address implementation) external view;
    function upgrade(string memory module, address implementation) external;
    function pause() external;
    function unpause() external;
}

contract Router is IRouter, Ownable, Pausable {
    IEternalStorage eternalStorage;

    constructor(address eternalStorage_)
    Ownable(msg.sender) {
        eternalStorage = IEternalStorage(eternalStorage_);
    }

    function getLatestImplementation(string memory module, uint index)
    external view
    whenNotPaused
    returns (address) {
        return _getLatestImplementation(module);
    }

    function getLatestVersion(string memory module)
    external view
    whenNotPaused
    returns (uint) {
        return _getLatestVersion(module);
    }

    function getImplementation(string memory module, uint index)
    external view
    whenNotPaused
    returns (address) {
        return _getImplementation(module, index);
    }

    function requireLatestImplementation(string memory module, address implementation)
    external view 
    whenNotPaused {
        return _requireLatestImplementation(module, implementation);
    }

    function upgrade(string memory module, address implementation)
    external
    onlyOwner 
    whenNotPaused {
        _upgrade(module, implementation);
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

    function _implementations(string memory module)
    internal view
    returns (bytes32) {
        return keccak256(abi.encode("router", module, "logics"));
    }

    function _getLatestImplementation(string memory module)
    internal view
    returns (address) {
        return eternalStorage.indexAddressSet(_implementations(module), _getLatestVersion(module));
    }

    function _getLatestVersion(string memory module)
    internal view
    returns (uint) {
        return eternalStorage.lengthAddressSet(_implementations(module)) - 1;
    }

    function _getImplementation(string memory module, uint index)
    internal view 
    returns (address) {
        return eternalStorage.indexAddressSet(_implementations(module), index);
    }

    function _requireLatestImplementation(string memory module, address implementation)
    internal view {
        address latestImplementation = eternalStorage.indexAddressSet(_implementations(module), _getLatestVersion(module));
        require(implementation == latestImplementation, "Router: implementation is not latest implementation");
    }

    function _upgrade(string memory module, address implementation)
    internal {
        eternalStorage.removeAddressSet(_implementations(module), implementation);
        eternalStorage.addAddressSet(_implementations(module), implementation);
    }
}

interface IOverseer {
    function getMembers(string memory role) external view returns (address[] memory);
    function getSize(string memory role) external view returns (uint);
    function requireRole(address account, string memory role) external view;
    function grant(address account, string memory role) external;
    function revoke(address account, string memory role) external;
    function pause() external;
    function unpause() external;
}

contract Overseer is IOverseer, Ownable, Pausable {
    IEternalStorage eternalStorage;

    constructor(address eternalStorage_)
    Ownable(msg.sender) {
        eternalStorage = IEternalStorage(eternalStorage_);
    }

    function getMembers(string memory role)
    external view
    whenNotPaused
    returns (address[] memory) {
        return _getMembers(role);
    }

    function getSize(string memory role)
    external view
    whenNotPaused
    returns (uint) {
        return _getSize(role);
    }

    function requireRole(address account, string memory role)
    external view 
    whenNotPaused {
        _requireRole(account, role);
    }

    function grant(address account, string memory role)
    external
    onlyOwner 
    whenNotPaused {
        _grant(account, role);
    }

    function revoke(address account, string memory role)
    external 
    onlyOwner
    whenNotPaused {
        _revoke(account, role);
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

    function _role(string memory role)
    internal view 
    returns (bytes32) {
        return keccak256(abi.encode("overseer", role, "members"));
    }

    function _getMembers(string memory role)
    internal view
    returns (address[] memory) {
        return eternalStorage.getAddressSet(_role(role));
    }

    function _getSize(string memory role)
    internal view
    returns (uint) {
        return eternalStorage.lengthAddressSet(_role(role));
    }

    function _requireRole(address account, string memory role)
    internal view {
        require(eternalStorage.containsAddressSet(_role(role), account), "Overseer: unauthorized because account does not have required role");
    }

    function _grant(address account, string memory role)
    internal {
        eternalStorage.addAddressSet(_role(role), account);
    }

    function _revoke(address account, string memory role)
    internal {
        eternalStorage.removeAddressSet(_role(role), account);
    }
}

library TimelockToolkit {
    function getMessage(IEternalStorage eternalStorage, uint index)
    external view
    returns (string memory) {
        bytes32 message = keccak256(abi.encode("requests", index, "message"));
        return eternalStorage.getString(message);
    }

    function getTargets(IEternalStorage eternalStorage, uint index)
    external view
    returns (address[] memory) {
        bytes32 targets = keccak256(abi.encode("requests", index, "targets"));
        return eternalStorage.getAddressArray(targets);
    }

    function getSignatures(IEternalStorage eternalStorage, uint index)
    external view
    returns (string[] memory) {
        bytes32 signatures = keccak256(abi.encode("requests", index, "signatures"));
        return eternalStorage.getStringArray(signatures);
    }

    function getArgs(IEternalStorage eternalStorage, uint index)
    external view
    returns (bytes[] memory) {
        bytes32 args = keccak256(abi.encode("requests", index, "args"));
        return eternalStorage.getBytesArray(args);
    }

    function getStart(IEternalStorage eternalStorage, uint index)
    external view
    returns (uint) {
        bytes32 start = keccak256(abi.encode("requests", index, "start"));
        return eternalStorage.getUint(start);
    }

    function getTimelock(IEternalStorage eternalStorage, uint index)
    external view
    returns (uint) {
        bytes32 timelock = keccak256(abi.encode("requests", index, "timelock"));
        return eternalStorage.getUint(timelock);
    }

    function getTimeout(IEternalStorage eternalStorage, uint index)
    external view
    returns (uint) {
        bytes32 timeout = keccak256(abi.encode("requests", index, "timeout"));
        return eternalStorage.getUint(timeout);
    }

    function getCreator(IEternalStorage eternalStorage, uint index)
    external view
    returns (address) {
        bytes32 creator = keccak256(abi.encode("requests", index, "creator"));
        return eternalStorage.getAddress(creator);
    }

    function isExecuted(IEternalStorage eternalStorage, uint index)
    external view
    returns (bool) {
        bytes executed = keccak256(abi.encode("requests", index, "executed"));
        return eternalStorage.getBool(executed);
    }

    function setMessage(IEternalStorage eternalStorage, uint index, string memory newMessage)
    external {
        bytes32 message = keccak256(abi.encode("requests", index, "message"));
        eternalStorage.setString(message, newMessage);
    }

    function pushTarget(IEternalStorage eternalStorage, uint index, address target)
    external {
        bytes32 targets = keccak256(abi.encode("requests", index, "targets"));
        eternalStorage.pushAddressArray(targets, target);
    }

    function pushSignature(IEternalStorage eternalStorage, uint index, string memory signature)
    external {
        bytes32 signatures = keccak256(abi.encode("requests", index, "signatures"));
        eternalStorage.pushStringArray(signatures, signature);
    }

    function pushArg(IEternalStorage eternalStorage, uint index, bytes memory arg)
    external {
        bytes32 args = keccak256(abi.encode("requests", index, "args"));
        eternalStorage.pushBytesArray(args, arg);
    }

    function setStart(IEternalStorage eternalStorage, uint index, uint timestamp)
    external {
        bytes32 start = keccak256(abi.encode("requests", index, "start"));
        eternalStorage.setUint(start, timestamp);
    }

    function setTimelock(IEternalStorage eternalStorage, uint index, uint timestamp)
    external {
        bytes32 timelock = keccak256(abi.encode("requests", index, "timelock"));
        eternalStorage.setUint(timelock, timestamp);
    }

    function setTimeout(IEternalStorage eternalStorage, uint index, uint timestamp)
    external {
        bytes32 timeout = keccak256(abi.encode("requests", index, "timeout"));
        eternalStorage.setUint(timeout, timestamp);
    }

    function setCreator(IEternalStorage eternalStorage, uint index, address newCreator)
    external {
        bytes32 creator = keccak256(abi.encode("requests", index, "creator"));
        eternalStorage.setAddress(creator, newCreator);
    }

    function setExecuted(IEternalStorage eternalStorage, uint index, bool value)
    external {
        bytes32 executed = keccak256(abi.encode("requests", index, "executed"));
        eternalStorage.setBool(executed, value);
    }

    function incrementCount(IEternalStorage eternalStorage)
    external 
    returns (uint) {
        bytes32 requestsCount = keccak256(abi.encode("requests", "count"));
        uint count = eternalStorage.getUint(requestsCount) + 1;
        eternalStorage.setUint(requestsCount, count);
        return count;
    }
}

contract Timelock is Ownable, Pausable {
    IEternalStorage eternalStorage;
    address internal _deployer;
    bool internal _init;
    
    constructor(address eternalStorage_) 
    Ownable(msg.sender) {
        eternalStorage = IEternalStorage(eternalStorage_);
    }

    function _init()
    internal {
        
    }

    function _queue(string memory message, address[] memory targets)
    internal {
        uint index = TimelockToolkit.incrementCount(eternalStorage);
        TimelockToolkit.setMessage(eternalStorage, index, newMessage);
        for (uint i = 0; i < targets.length; i++) {
            TimelockToolkit.pushTarget(eternalStorage, index, targets[i]);
        }

        
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

contract Proposals {

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

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    uint cap;
    IEternalStorage eternalStorage;
    ISentinel sentinel;
    
    constructor(address eternalStorage_, address sentinel_)
    ERC20("DreamToken", "DREAM")
    ERC20Permit("DreamToken") {
        cap = Utils.convertToWei(200000000);
        _mint(msg.sender, cap);
        eternalStorage = IEternalStorage(eternalStorage);
        sentinel = ISentinel(sentinel_);
    }

    function _setAccountDreamTokenBalance(address account, uint amount)
    internal override {
        bytes32 varAccountDreamTokenBalance = keccak256(abi.encode(account, "dreamTokenBalance"));
        eternalStorage.setUint(varAccountDreamTokenBalance, amount);
    }
}

contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {

}

interface IPoolToken is IERC20 {
    function getCurrentSnapshotId() external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function snapshot() external returns (uint index);
    function mint(address account, uint amount) external;
}

contract PoolToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    IEternalStorage eternalStorage;
    
    constructor(address eternalStorage_, uint index, string memory name, string memory symbol)
    ERC20(name, symbol)
    ERC20Permit(name) {
        eternalStorage = IEternalStorage(eternalStorage_);
        
    }

    function getCurrentSnapshotId()
    external view
    returns (uint) {
        return _getCurrentSnapshotId();
    }

    function allowance(address owner, address spender)
    external view override
    returns (uint) {
        return super.allowance(owner, spender);
    }

    function snapshot()
    external
    returns (uint index) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function mint(address account, uint amount)
    external {
        _mint(account, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint amount)
    internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint amount)
    internal override {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint amount)
    internal override {
        super._mint(account, amount);
    }

    function _burn(address account, uint amount)
    internal override {
        super._burn(account, amount);
    }
}

contract Vault {
    
}

library ResonanceToolkit {
    function isManager(IEternalStorage eternalStorage, uint index, address account)
    external view
    returns (bool) {
        bytes32 managers = keccak256(abi.encode("pools", index, "managers"));
        return eternalStorage.containsAddressSet(managers, account);
    }

    function isAdmin(IEternalStorage eternalStorage, uint index, address account)
    external view
    returns (bool) {
        bytes32 admins = keccak256(abi.encode("pools", index, "admins"));
        return eternalStorage.containsAddressSet(admins, account);
    }

    function isContributor(IEternalStorage eternalStorage, uint index, address account)
    external view
    returns (bool) {
        bytes32 contributors = keccak256(abi.encode("pools", index, "contributors"));
        return eternalStorage.containsAddressSet(contributors, account);
    }

    function getManagers(IEternalStorage eternalStorage, uint index)
    external view
    returns (address[] memory) {
        bytes32 managers = keccak256(abi.encode("pools", index, "managers"));
        return eternalStorage.getAddressSet(managers);
    }

    function getAdmins(IEternalStorage eternalStorage, uint index)
    external view
    returns (address[] memory) {
        bytes32 admins = keccak256(abi.encode("pools", index, "admins"));
        return eternalStorage.getAddressSet(admins);
    }

    function getContributors(IEternalStorage eternalStorage, uint index)
    external view
    returns (address[] memory) {
        bytes32 contributors = keccak256(abi.encode("pools", index, "contributors"));
        return eternalStorage.getAddressSet(contributors);
    }

    function getName(IEternalStorage eternalStorage, uint index)
    external view
    returns (string memory) {
        bytes32 name = keccak256(abi.encode("pools", index, "name"));
        return eternalStorage.getString(name);
    }

    function getDescription(IEternalStorage eternalStorage, uint index)
    external view
    returns (string memory) {
        bytes32 description = keccak256(abi.encode("pools", index, "description"));
        return eternalStorage.getString(description);
    }

    function getContribution(IEternalStorage eternalStorage, uint index, address account)
    external view
    returns (uint) {
        bytes32 contribution = keccak256(abi.encode("pools", index, account, "contribution"));
        return eternalStorage.getUint(contribution);
    }

    function isWhitelisted(IEternalStorage eternalStorage, uint index)
    external view
    returns (bool) {
        bytes isWhitelisted = keccak256(abi.encode("pools", index, "isWhitelisted"));
        return eternalStorage.getBool(isWhitelisted);
    }

    function addManager(IEternalStorage eternalStorage, uint index, address account)
    external {
        bytes32 managers = keccak256(abi.encode("pools", index, "managers"));
        eternalStorage.addAddressSet(managers, account);
    }

    function addAdmin(IEternalStorage eternalStorage, uint index, address account)
    external {
        bytes32 admins = keccak256(abi.encode("pools", index, "admins"));
        eternalStorage.addAddressSet(admins, account);
    }

    function removeManager(IEternalStorage eternalStorage, uint index, address account)
    external {
        bytes32 managers = keccak256(abi.encode("pools", index, "managers"));
        eternalStorage.removeAddressSet(managers, account);
    }

    function removeAdmin(IEternalStorage eternalStorage, uint index, address account)
    external {
        bytes32 admins = keccak256(abi.encode("pools", index, "admins"));
        eternalStorage.removeAddressSet(admins, account);
    }

    function setName(IEternalStorage eternalStorage, uint index, string memory newName)
    external {
        bytes32 name = keccak256(abi.encode("pools", index, "name"));
        eternalStorage.setString(name, newName);
    }

    function setDescription(IEternalStorage eternalStorage, uint index, string memory newDescription)
    external {
        bytes32 description = keccak256(abi.encode("pools", index, "description"));
        eternalStorage.setString(description, newDescription);
    }

    function setContributor(IEternalStorage eternalStorage, uint index, address account, uint newContribution)
    external {
        bytes32 contributors = keccak256(abi.encode("pools", index, "contributors"));
        bytes32 contributions = keccak256(abi.encode("pools", index, account, "contribution"));
        if (newContribution >= 1) {
            eternalStorage.addAddressSet(contributors, account);
        } else {
            eternalStorage.removeAddressSet(contributors, account);
        }
        eternalStorage.setUint(contributions, newContribution);
    }

    function setIsWhitelisted(IEternalStorage eternalStorage, uint index, bool value)
    external {
        bytes32 isWhitelisted = keccak256(abi.encode("pools", index, "isWhitelisted"));
        eternalStorage.setBool(isWhitelisted, value);
    }

    function incrementCount(IEternalStorage eternalStorage)
    external
    returns (uint count) {
        bytes32 poolsCount = keccak256(abi.encode("poolsCount"));
        count = eternalStorage.getUint(poolsCount) + 1;
        eternalStorage.setUint(poolsCount, count);
        return count;
    }
}

contract Resonance is Pausable, ReentrancyGuard {
    IEternalStorage eternalStorage;
    IOverseer overseer;
    ISentinel sentinel;

    modifier gas(uint amount) {
        _;
    }

    constructor(address eternalStorage_, address overseer_, address sentinel_) {
        eternalStorage = IEternalStorage(eternalStorage_);
        overseer = IOverseer(overseer_);
        sentinel = ISentinel(sentinel_);
    }

    function _create(string memory name, string memory description, address[] memory managers, address[] memory admins)
    internal payable 
    returns (uint index) {
        require(msg.value >= poolCreateMinPayable, "Resonance: cannot create pool because not enough value was sent");
        index = ResonanceToolkit.incrementCount(eternalStorage);
        ResonanceToolkit.setName(eternalStorage, index, name);
        ResonanceToolkit.setDescription(eternalStorage, index, description);
        for (uint i = 0; i < managers.length; i++) { ResonanceToolkit.addManager(eternalStorage, index, managers[i]); } 
        for (uint i = 0; i < admins.length; i++) { ResonanceToolkit.addAdmin(eternalStorage, index, admins[i]); }
        new PoolToken(address(eternalStorage), index, name, symbol);
        // TODO create new erc20 for new pool and mint initial to caller
    }

    function _contribute(uint index)
    internal payable {
        
        CustomMatch.amountToMint(value, supply, balance);
    }

    function _gas(uint amount)
    internal {
        // TODO monetize
    }
}

