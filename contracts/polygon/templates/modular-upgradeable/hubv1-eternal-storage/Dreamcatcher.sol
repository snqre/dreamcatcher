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

/** storage usage
    bytes32 -> address,"keys" -> _bytesArray
    bytes32 -> "governor" -> _address
 */

enum Class {
    STANDARD,
    CONSUMABLE,
    TIMED
}

struct Timestamp {
    uint32 granted;
    uint32 expiration;
}

struct Settings {
    bool isTransferable;
    bool isFungible;
    bool isClonable;
}

struct Key {
    address logic;
    string signature;
    Timestamp timestamp;
    Class class;
    Settings settings;
    uint balance;
    bytes data;
}

interface IStorage {
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
}

/**
 * @title Storage
 * @dev This contract provides storage and management of various data types, arrays, and sets.
 */
contract Storage is IStorage {
    /**
    * @dev Importing the EnumerableSet library for AddressSet, UintSet, and Bytes32Set data structures.
    * This allows efficient management and manipulation of sets of addresses, uints, and bytes32 values.
    */
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /**
    * @dev EnumerableSet mappings to store sets of addresses representing administrators and logic contracts.
    */
    EnumerableSet.AddressSet private _admins;
    EnumerableSet.AddressSet private _logics;

    /**
    * @dev Mappings to store data of different types associated with specific bytes32 variables.
    * Each mapping corresponds to a different data type: strings, bytes, uints, integers, addresses, booleans, and bytes32 values.
    */
    mapping(bytes32 => string) private _string;
    mapping(bytes32 => bytes) private _bytes;
    mapping(bytes32 => uint) private _uint;
    mapping(bytes32 => int) private _int;
    mapping(bytes32 => address) private _address;
    mapping(bytes32 => bool) private _bool;
    mapping(bytes32 => bytes32) private _bytes32;

    /**
    * @dev Mappings to store arrays of different data types associated with specific bytes32 variables.
    * Each mapping corresponds to a different data type: strings, bytes, uints, integers, addresses, booleans, and bytes32 values.
    */
    mapping(bytes32 => string[]) private _stringArray;
    mapping(bytes32 => bytes[]) private _bytesArray;
    mapping(bytes32 => uint[]) private _uintArray;
    mapping(bytes32 => int[]) private _intArray;
    mapping(bytes32 => address[]) private _addressArray;
    mapping(bytes32 => bool[]) private _boolArray;
    mapping(bytes32 => bytes32[]) private _bytes32Array;

    /**
    * @dev Mappings to store sets of data associated with specific bytes32 variables.
    * Each mapping corresponds to a different data type: addresses, uints, and bytes32 values.
    */
    mapping(bytes32 => EnumerableSet.AddressSet) private _addressSet;
    mapping(bytes32 => EnumerableSet.UintSet) private _uintSet;
    mapping(bytes32 => EnumerableSet.Bytes32Set) private _bytes32Set;

    /**
    * @dev Modifier to restrict access to only administrators.
    * @notice Reverts if the sender is not an administrator.
    */
    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    /**
    * @dev Modifier to restrict access to only logic contracts.
    * @notice Reverts if the sender is not a logic contract.
    */
    modifier onlyLogic() {
        _onlyLogic();
        _;
    }

    /**
    * @dev Contract constructor.
    * @notice Initializes the contract by adding the deployer's address as an administrator.
    */
    constructor() { _admins.add(msg.sender); }

    function getAdmins() external view returns (address[] memory) { return _admins.values(); }
    function getLogics() external view returns (address[] memory) { return _logics.values(); }
    function getString(bytes32 variable) external view returns (string memory) { return _string[variable]; }
    function getBytes(bytes32 variable) external view returns (bytes memory) { return _bytes[variable]; }
    function getUint(bytes32 variable) external view returns (uint) { return _uint[variable]; }
    function getInt(bytes32 variable) external view returns (int) { return _int[variable]; }
    function getAddress(bytes32 variable) external view returns (address) { return _address[variable]; }
    function getBool(bytes32 variable) external view returns (bool) { return _bool[variable]; }
    function getBytes32(bytes32 variable) external view returns (bytes32) { return _bytes32[variable]; }

    /**
    * @dev Getter function to retrieve an array of stored data from the contract's storage.
    * @param variable The identifier of the data array variable to retrieve.
    * @return An array of the specified data type.
    */
    function getStringArray(bytes32 variable) external view returns (string[] memory) { return _stringArray[variable]; }
    function getBytesArray(bytes32 variable) external view returns (bytes[] memory) { return _bytesArray[variable]; }
    function getUintArray(bytes32 variable) external view returns (uint[] memory) { return _uintArray[variable]; }
    function getIntArray(bytes32 variable) external view returns (int[] memory) { return _intArray[variable]; }
    function getAddressArray(bytes32 variable) external view returns (address[] memory) { return _addressArray[variable]; }
    function getBoolArray(bytes32 variable) external view returns (bool[] memory) { return _boolArray[variable]; }
    function getBytes32Array(bytes32 variable) external view returns (bytes32[] memory) { return _bytes32Array[variable]; }

    /**
    * @dev Getter function to retrieve an element from a stored array.
    * @param variable The identifier of the array variable.
    * @param index The index of the element to retrieve.
    * @return The value of the element.
    */
    function indexStringArray(bytes32 variable, uint index) external view returns (string memory) { return _stringArray[variable][index]; }
    function indexBytesArray(bytes32 variable, uint index) external view returns (bytes memory) { return _bytesArray[variable][index]; }
    function indexUintArray(bytes32 variable, uint index) external view returns (uint) { return _uintArray[variable][index]; }
    function indexIntArray(bytes32 variable, uint index) external view returns (int) { return _intArray[variable][index]; }
    function indexAddressArray(bytes32 variable, uint index) external view returns (address) { return _addressArray[variable][index]; }
    function indexBoolArray(bytes32 variable, uint index) external view returns (bool) { return _boolArray[variable][index]; }
    function indexBytes32Array(bytes32 variable, uint index) external view returns (bytes32) { return _bytes32Array[variable][index]; }

    /**
    * @dev Getter function to retrieve the length of a stored array.
    * @param variable The identifier of the array variable.
    * @return The length of the array.
    */
    function lengthStringArray(bytes32 variable) external view returns (uint) { return _stringArray[variable].length; }
    function lengthBytesArray(bytes32 variable) external view returns (uint) { return _bytesArray[variable].length; }
    function lengthUintArray(bytes32 variable) external view returns (uint) { return _uintArray[variable].length; }
    function lengthIntArray(bytes32 variable) external view returns (uint) { return _intArray[variable].length; }
    function lengthAddressArray(bytes32 variable) external view returns (uint) { return _addressArray[variable].length; }
    function lengthBoolArray(bytes32 variable) external view returns (uint) { return _boolArray[variable].length; }
    function lengthBytes32Array(bytes32 variable) external view returns (uint) { return _bytes32Array[variable].length; }

    /**
    * @dev Getter function to retrieve the values of a stored set.
    * @param variable The identifier of the set variable.
    * @return An array of values representing the elements in the set.
    */
    function getAddressSet(bytes32 variable) external view returns (address[] memory) { return _addressSet[variable].values(); }
    function getUintSet(bytes32 variable) external view returns (uint[] memory) { return _uintSet[variable].values(); }
    function getBytes32Set(bytes32 variable) external view returns (bytes32[] memory) { return _bytes32Set[variable].values(); }
    
    /**
    * @dev Getter function to retrieve an element from a stored set at a specific index.
    * @param variable The identifier of the set variable.
    * @param index The index of the element to retrieve.
    * @return The value of the element at the specified index.
    */
    function indexAddressSet(bytes32 variable, uint index) external view returns (address) { return _addressSet[variable].at(index); }
    function indexUintSet(bytes32 variable, uint index) external view returns (uint) { return _uintSet[variable].at(index); }
    function indexBytes32Set(bytes32 variable, uint index) external view returns (bytes32) { return _bytes32Set[variable].at(index); }

    /**
    * @dev Getter function to retrieve the length of a stored set.
    * @param variable The identifier of the set variable.
    * @return The length of the set.
    */
    function lengthAddressSet(bytes32 variable) external view returns (uint) { return _addressSet[variable].length(); }
    function lengthUintSet(bytes32 variable) external view returns (uint) { return _uintSet[variable].length(); }
    function lengthBytes32Set(bytes32 variable) external view returns (uint) { return _bytes32Set[variable].length(); }

    /**
    * @dev Checks if a specific element exists in a stored set.
    * @param variable The identifier of the set variable.
    * @param data The element to check for existence in the set.
    * @return True if the element exists in the set, false otherwise.
    */
    function containsAddressSet(bytes32 variable, address data) external view returns (bool) { return _addressSet[variable].contains(data); }
    function containsUintSet(bytes32 variable, uint data) external view returns (bool) { return _uintSet[variable].contains(data); }
    function containsBytes32Set(bytes32 variable, bytes32 data) external view returns (bool) { return _bytes32Set[variable].contains(data); }

    /**
    * @dev Adds an administrator to the list of authorized administrators.
    * @param admin The address of the administrator to be added.
    * Requirements:
    * - The specified admin address must not be the zero address.
    * - The admin address must not be an existing logic address.
    * - The admin address must not be an existing admin address.
    * Emits an {AddAdmin} event.
    */
    function addAdmin(address admin) 
    external 
    onlyAdmin {
        require(admin != address(0), "Storage: admin is address zero");
        require(!_logics.contains(admin), "Storage: admin is logic");
        require(!_admins.contains(admin), "Storage: already admin");
        _admins.add(admin);
        emit AddAdmin(admin);
    }

    /**
    * @dev Adds a logic contract address to the list of authorized logic contracts.
    * @param logic The address of the logic contract to be added.
    * Requirements:
    * - The specified logic address must not be the zero address.
    * - The logic address must not be an existing admin address.
    * - The logic address must not be an existing logic address.
    * Emits an {AddLogic} event.
    */
    function addLogic(address logic) 
    external 
    onlyAdmin {
        require(logic != address(0), "Storage: logic is address zero");
        require(!_admins.contains(logic), "Storage: logic is admin");
        require(!_logics.contains(logic), "Storage: already logic");
        _logics.add(logic);
        emit AddLogic(logic);
    }

    /**
    * @dev Removes an administrator from the list of authorized administrators.
    * @param admin The address of the administrator to be removed.
    * Requirements:
    * - The specified admin address must not be the zero address.
    * - The admin address must not be an existing logic address.
    * - The admin address must be an existing admin address.
    * Emits a {RemoveAdmin} event.
    */
    function removeAdmin(address admin) 
    external 
    onlyAdmin {
        require(admin != address(0), "Storage: admin is address zero");
        require(!_logics.contains(admin), "Storage: admin is logic");
        require(_admins.contains(admin), "Storage: not admin");
        _admins.remove(admin);
        emit RemoveAdmin(admin);
    }

    /**
    * @dev Removes a logic contract address from the list of authorized logic contracts.
    * @param logic The address of the logic contract to be removed.
    * Requirements:
    * - The specified logic address must not be the zero address.
    * - The logic address must not be an existing admin address.
    * - The logic address must be an existing logic address.
    * Emits a {RemoveLogic} event.
    */
    function removeLogic(address logic) 
    external 
    onlyAdmin {
        require(logic != address(0), "Storage: logic is address zero");
        require(!_admins.contains(logic), "Storage: logic is admin");
        require(_logics.contains(logic), "Storage: not logic");
        _logics.remove(logic);
        emit RemoveLogic(logic);
    }

    /**
    * @dev Sets a string value in the contract storage.
    * @param variable The identifier of the string variable.
    * @param data The string data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetString} event.
    */
    function setString(bytes32 variable, string memory data) 
    external 
    onlyLogic {
        _string[variable] = data;
        emit SetString(variable, data);
    }

    /**
    * @dev Sets a bytes value in the contract storage.
    * @param variable The identifier of the bytes variable.
    * @param data The bytes data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetBytes} event.
    */
    function setBytes(bytes32 variable, bytes memory data) 
    external 
    onlyLogic {
        _bytes[variable] = data;
        emit SetBytes(variable, data);
    }

    /**
    * @dev Sets a uint value in the contract storage.
    * @param variable The identifier of the uint variable.
    * @param data The uint data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetUint} event.
    */
    function setUint(bytes32 variable, uint data) 
    external 
    onlyLogic {
        _uint[variable] = data;
        emit SetUint(variable, data);
    }

    /**
    * @dev Sets an int value in the contract storage.
    * @param variable The identifier of the int variable.
    * @param data The int data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetInt} event.
    */
    function setInt(bytes32 variable, int data) 
    external 
    onlyLogic {
        _int[variable] = data;
        emit SetInt(variable, data);
    }

    /**
    * @dev Sets an address value in the contract storage.
    * @param variable The identifier of the address variable.
    * @param data The address data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetAddress} event.
    */
    function setAddress(bytes32 variable, address data) 
    external 
    onlyLogic {
        _address[variable] = data;
        emit SetAddress(variable, data);
    }

    /**
    * @dev Sets a boolean value in the contract storage.
    * @param variable The identifier of the boolean variable.
    * @param data The boolean data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetBool} event.
    */
    function setBool(bytes32 variable, bool data) 
    external 
    onlyLogic {
        _bool[variable] = data;
        emit SetBool(variable, data);
    }

    /**
    * @dev Sets a bytes32 value in the contract storage.
    * @param variable The identifier of the bytes32 variable.
    * @param data The bytes32 data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetBytes32} event.
    */
    function setBytes32(bytes32 variable, bytes32 data) 
    external 
    onlyLogic {
        _bytes32[variable] = data;
        emit SetBytes32(variable, data);
    }

    /**
    * @dev Sets the value at a specific index in a string array stored in the contract storage.
    * @param variable The identifier of the string array variable.
    * @param index The index where the value should be set.
    * @param data The string data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetIndexStringArray} event.
    */
    function setIndexStringArray(bytes32 variable, uint index, string memory data) 
    external 
    onlyLogic {
        _stringArray[variable][index] = data;
        emit SetIndexStringArray(variable, index, data);
    }

    /**
    * @dev Sets the value at a specific index in a bytes array stored in the contract storage.
    * @param variable The identifier of the bytes array variable.
    * @param index The index where the value should be set.
    * @param data The bytes data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetIndexBytesArray} event.
    */
    function setIndexBytesArray(bytes32 variable, uint index, bytes memory data) 
    external 
    onlyLogic {
        _bytesArray[variable][index] = data;
        emit SetIndexBytesArray(variable, index, data);
    }

    /**
    * @dev Sets the value at a specific index in a uint array stored in the contract storage.
    * @param variable The identifier of the uint array variable.
    * @param index The index where the value should be set.
    * @param data The uint data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetIndexUintArray} event.
    */
    function setIndexUintArray(bytes32 variable, uint index, uint data) 
    external 
    onlyLogic {
        _uintArray[variable][index] = data;
        emit SetIndexUintArray(variable, index, data);
    }

    /**
    * @dev Sets the value at a specific index in an int array stored in the contract storage.
    * @param variable The identifier of the int array variable.
    * @param index The index where the value should be set.
    * @param data The int data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetIndexIntArray} event.
    */
    function setIndexIntArray(bytes32 variable, uint index, int data) 
    external 
    onlyLogic {
        _intArray[variable][index] = data;
        emit SetIndexIntArray(variable, index, data);
    }

    /**
    * @dev Sets the value at a specific index in an address array stored in the contract storage.
    * @param variable The identifier of the address array variable.
    * @param index The index where the value should be set.
    * @param data The address data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetIndexAddressArray} event.
    */
    function setIndexAddressArray(bytes32 variable, uint index, address data) 
    external 
    onlyLogic {
        _addressArray[variable][index] = data;
        emit SetIndexAddressArray(variable, index, data);
    }

    /**
    * @dev Sets the value at a specific index in a bool array stored in the contract storage.
    * @param variable The identifier of the bool array variable.
    * @param index The index where the value should be set.
    * @param data The bool data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetIndexBoolArray} event.
    */
    function setIndexBoolArray(bytes32 variable, uint index, bool data) 
    external 
    onlyLogic {
        _boolArray[variable][index] = data;
        emit SetIndexBoolArray(variable, index, data);
    }

    /**
    * @dev Sets the value at a specific index in a bytes32 array stored in the contract storage.
    * @param variable The identifier of the bytes32 array variable.
    * @param index The index where the value should be set.
    * @param data The bytes32 data to be stored.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {SetIndexBytes32Array} event.
    */
    function setIndexBytes32Array(bytes32 variable, uint index, bytes32 data) 
    external 
    onlyLogic {
        _bytes32Array[variable][index] = data;
        emit SetIndexBytes32Array(variable, index, data);
    }

    /**
    * @dev Appends a new value to the end of a string array stored in the contract storage.
    * @param variable The identifier of the string array variable.
    * @param data The string data to be added.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {PushStringArray} event.
    */
    function pushStringArray(bytes32 variable, string memory data) 
    external 
    onlyLogic {
        _stringArray[variable].push(data);
        emit PushStringArray(variable, data);
    }

    /**
    * @dev Appends a new bytes element to the end of a bytes array stored in the contract storage.
    * @param variable The identifier of the bytes array variable.
    * @param data The bytes data to be added.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {PushBytesArray} event.
    */
    function pushBytesArray(bytes32 variable, bytes memory data) 
    external 
    onlyLogic {
        _bytesArray[variable].push(data);
        emit PushBytesArray(variable, data);
    }

    /**
    * @dev Appends a new uint element to the end of a uint array stored in the contract storage.
    * @param variable The identifier of the uint array variable.
    * @param data The uint data to be added.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {PushUintArray} event.
    */
    function pushUintArray(bytes32 variable, uint data) 
    external 
    onlyLogic {
        _uintArray[variable].push(data);
        emit PushUintArray(variable, data);
    }

    /**
    * @dev Appends a new int element to the end of an int array stored in the contract storage.
    * @param variable The identifier of the int array variable.
    * @param data The int data to be added.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {PushIntArray} event.
    */
    function pushIntArray(bytes32 variable, int data) 
    external 
    onlyLogic {
        _intArray[variable].push(data);
        emit PushIntArray(variable, data);
    }

    /**
    * @dev Appends a new address element to the end of an address array stored in the contract storage.
    * @param variable The identifier of the address array variable.
    * @param data The address data to be added.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {PushAddressArray} event.
    */
    function pushAddressArray(bytes32 variable, address data) 
    external 
    onlyLogic {
        _addressArray[variable].push(data);
        emit PushAddressArray(variable, data);
    }

    /**
    * @dev Appends a new bool element to the end of a bool array stored in the contract storage.
    * @param variable The identifier of the bool array variable.
    * @param data The bool data to be added.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {PushBoolArray} event.
    */
    function pushBoolArray(bytes32 variable, bool data) 
    external 
    onlyLogic {
        _boolArray[variable].push(data);
        emit PushBoolArray(variable, data);
    }

    /**
    * @dev Appends a new bytes32 element to the end of a bytes32 array stored in the contract storage.
    * @param variable The identifier of the bytes32 array variable.
    * @param data The bytes32 data to be added.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {PushBytes32Array} event.
    */
    function pushBytes32Array(bytes32 variable, bytes32 data) 
    external 
    onlyLogic {
        _bytes32Array[variable].push(data);
        emit PushBytes32Array(variable, data);
    }

    /**
    * @dev Deletes an entire string array stored in the contract storage.
    * @param variable The identifier of the string array variable to be deleted.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {DeleteStringArray} event.
    */
    function deleteStringArray(bytes32 variable)
    external
    onlyLogic {
        delete _stringArray[variable];
        emit DeleteStringArray(variable);
    }

    /**
    * @dev Deletes an entire bytes array stored in the contract storage.
    * @param variable The identifier of the bytes array variable to be deleted.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {DeleteBytesArray} event.
    */
    function deleteBytesArray(bytes32 variable)
    external
    onlyLogic {
        delete _bytesArray[variable];
        emit DeleteBytesArray(variable);
    }

    /**
    * @dev Deletes an entire uint array stored in the contract storage.
    * @param variable The identifier of the uint array variable to be deleted.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {DeleteUintArray} event.
    */
    function deleteUintArray(bytes32 variable)
    external
    onlyLogic {
        delete _uintArray[variable];
        emit DeleteUintArray(variable);
    }

    /**
    * @dev Deletes an entire int array stored in the contract storage.
    * @param variable The identifier of the int array variable to be deleted.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {DeleteIntArray} event.
    */
    function deleteIntArray(bytes32 variable)
    external
    onlyLogic {
        delete _intArray[variable];
        emit DeleteIntArray(variable);
    }

    /**
    * @dev Deletes an entire address array stored in the contract storage.
    * @param variable The identifier of the address array variable to be deleted.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {DeleteAddressArray} event.
    */
    function deleteAddressArray(bytes32 variable)
    external
    onlyLogic {
        delete _addressArray[variable];
        emit DeleteAddressArray(variable);
    }

    /**
    * @dev Deletes an entire bool array stored in the contract storage.
    * @param variable The identifier of the bool array variable to be deleted.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {DeleteBoolArray} event.
    */
    function deleteBoolArray(bytes32 variable)
    external
    onlyLogic {
        delete _boolArray[variable];
        emit DeleteBoolArray(variable);
    }

    /**
    * @dev Deletes an entire bytes32 array stored in the contract storage.
    * @param variable The identifier of the bytes32 array variable to be deleted.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {DeleteBytes32Array} event.
    */
    function deleteBytes32Array(bytes32 variable)
    external
    onlyLogic {
        delete _bytes32Array[variable];
        emit DeleteBytes32Array(variable);
    }

    /**
    * @dev Adds an address to a set stored in the contract storage.
    * @param variable The identifier of the address set variable.
    * @param data The address to be added to the set.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits an {AddAddressSet} event.
    */
    function addAddressSet(bytes32 variable, address data)
    external
    onlyLogic {
        _addressSet[variable].add(data);
        emit AddAddressSet(variable, data);
    }

    /**
    * @dev Adds a uint value to a set stored in the contract storage.
    * @param variable The identifier of the uint set variable.
    * @param data The uint value to be added to the set.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits an {AddUintSet} event.
    */
    function addUintSet(bytes32 variable, uint data)
    external
    onlyLogic {
        _uintSet[variable].add(data);
        emit AddUintSet(variable, data);
    }

    /**
    * @dev Adds a bytes32 value to a set stored in the contract storage.
    * @param variable The identifier of the bytes32 set variable.
    * @param data The bytes32 value to be added to the set.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits an {AddBytes32Set} event.
    */
    function addBytes32Set(bytes32 variable, bytes32 data)
    external
    onlyLogic {
        _bytes32Set[variable].add(data);
        emit AddBytes32Set(variable, data);
    }

    /**
    * @dev Removes an address value from a set stored in the contract storage.
    * @param variable The identifier of the address set variable.
    * @param data The address value to be removed from the set.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {RemoveAddressSet} event.
    */
    function removeAddressSet(bytes32 variable, address data)
    external
    onlyLogic {
        _addressSet[variable].remove(data);
        emit RemoveAddressSet(variable, data);
    }

    /**
    * @dev Removes a uint value from a set stored in the contract storage.
    * @param variable The identifier of the uint set variable.
    * @param data The uint value to be removed from the set.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {RemoveUintSet} event.
    */
    function removeUintSet(bytes32 variable, uint data)
    external
    onlyLogic {
        _uintSet[variable].remove(data);
        emit RemoveUintSet(variable, data);
    }

    /**
    * @dev Removes a bytes32 value from a set stored in the contract storage.
    * @param variable The identifier of the bytes32 set variable.
    * @param data The bytes32 value to be removed from the set.
    * Requirements:
    * - The function caller must be an authorized logic contract.
    * Emits a {RemoveBytes32Set} event.
    */
    function removeBytes32Set(bytes32 variable, bytes32 data)
    external
    onlyLogic {
        _bytes32Set[variable].remove(data);
        emit RemoveBytes32Set(variable, data);
    }

    /**
    * @dev Internal function to check if the message sender is an admin.
    * @notice Reverts if the message sender is not an admin.
    * Requirements:
    * - The message sender must be an admin.
    */
    function _onlyAdmin() 
    private view {
        require(_admins.contains(msg.sender), "Storage: msg.sender !=admin");
    }

    /**
    * @dev Internal function to check if the message sender is a logic contract.
    * @notice Reverts if the message sender is not a logic contract.
    * Requirements:
    * - The message sender must be a logic contract.
    */
    function _onlyLogic() 
    private view {
        require(_logics.contains(msg.sender), "Storage: msg.sender !=logic");
    }
}

interface IRepository is IStorage {
    function name() external view returns (string memory);
    function description() external view returns (string memory);
    function launched() external view returns (uint32);
    function updateData(string memory name, string memory description) external;
}

/**
 * @title Repository Contract
 * @dev Manages essential information about a data entity.
 */
contract Repository is Storage {
    struct Data {
        string name;
        string description;
        uint launched;
    }
    
    /**
    * @dev This private storage variable holds the core data structure for the contract.
    * It stores essential information about the data entity being managed.
    * @notice Access to this data is restricted to internal and derived contracts.
    */
    Data private _data;

    /**
    * @dev Constructs a new instance of the `Storage` contract, initializing the core data structure.
    * @param name The name associated with the data being stored.
    * @param description The description providing additional details about the stored data.
    */
    constructor(string memory name, string memory description) 
    Storage() {
        _data = Data({name: name, description: description, launched: block.timestamp});
    }

    /**
    * @dev Retrieves the name associated with the stored data.
    * @return The name of the stored data entity.
    */
    function name() 
    external view 
    returns (string memory) { 
        return _data.name; 
    }

    /**
    * @dev Retrieves the description associated with the stored data.
    * @return The description of the stored data entity.
    */
    function description() 
    external view 
    returns (string memory) { 
        return _data.description; 
    }

    /**
    * @dev Retrieves the timestamp when the stored data was launched or created.
    * @return The timestamp representing the launch time of the stored data entity.
    */
    function launched() 
    external view 
    returns (uint) { 
        return _data.launched; 
    }

    /**
    * @dev Updates the name and description associated with the stored data.
    * @param name The new name to be associated with the stored data entity.
    * @param description The new description to provide additional details about the stored data.
    * @notice This function allows the contract owner to update the name and description of the stored data.
    */    
    function updateData(string memory name, string memory description)
    external {
        _data.name = name;
        _data.description = description;
    }
}

library __Match {
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

library __SentinelToolkit {
    function verifyKeyInput(Key memory key)
    external view {
        require(key.logic != address(0), "__SentinelToolkit: key.logic == address(0)");
        if (key.class == Class.STANDARD) {
            require(key.timestamp.granted == 0, "__SentinelToolkit: key.timestamp.granted != 0");
            require(key.timestamp.expiration == 0, "__SentinelToolkit: key.timestamp.expiration != 0");
            require(key.balance == 0, "__SentinelToolkit: key.balance != 0");
        } else if (key.class == Class.TIMED) {
            require(block.timestamp <= key.timestamp.granted, "__SentinelToolkit: key.timestamp.granted > block.timestamp");
            require(key.timestamp.expiration > key.timestamp.granted, "__SentinelToolkit: key.timestamp.expiration <= key.timestamp.granted");
            require(key.balance == 0, "__SentinelToolkit: key.balance != 0");
        } else if (key.class == Class.CONSUMABLE) {
            require(key.timestamp.granted == 0, "__SentinelToolkit: key.timestamp.granted != 0");
            require(key.timestamp.expiration == 0, "__SentinelToolkit: key.timestamp.expiration != 0");
            require(key.balance >= 1, "__SentinelToolkit: key.balance < 1");
        } else {
            revert("__SentinelToolkit: unrecognized class");
        }
    }

    function getKeyIndexByLogSigFromBytesArray(IRepository repository, bytes32 variable, address logic, string memory signature)
    external view
    returns (bool, uint, Key memory) {
        uint index;
        bool success;
        Key memory key;
        bytes memory emptyBytes;
        bytes[] memory keys = repository.getBytesArray(variable);
        for (uint i = 0; i < keys.length; i++) {
            if (!__Match.isMatchingBytes(keys[i], emptyBytes)) {
                key = abi.decode(keys[i], (Key));
                if (logic == key.logic && __Match.isMatchingString(signature, key.signature)) {
                    index = i;
                    success = true;
                    break;
                }
                
            }
        }
        return (success, index, key);
    }

    function getKeyIndexByEmptyBytesFromBytesArray(IRepository repository, bytes32 variable)
    external view
    returns (bool, uint) {
        uint index;
        bool success;
        bytes memory emptyBytes;
        bytes[] memory keys = repository.getBytesArray(variable);
        for (uint i = 0; i < keys.length; i++) {
            if (__Match.isMatchingBytes(keys[i], emptyBytes)) {
                success = true;
                index = i;
                break;
            }
        }
        return (success, index);
    }

    function verifyKey(IRepository repository, address account, uint index, Key memory key)
    external {
        bool success;
        if (key.class == Class.STANDARD) { success = true; }
        else if (key.class == Class.TIMED) {
            require(block.timestamp >= key.timestamp.granted, "__SentinelToolkit: block.timestamp < key.timestamp.granted");
            require(block.timestamp < key.timestamp.expiration, "__SentinelToolkit: block.timestamp >= key.timestamp.expiration");
            success = true;
        } else if (key.class == Class.CONSUMABLE) {
            require(key.balance >= 1, "__SentinelToolkit: insufficient balance");
            key.balance -= 1;
            repository.setIndexBytesArray(keccak256(abi.encode(account, "keys")), index, abi.encode(key));
            success =true;
        } else {
            revert("__SentinelToolkit: unrecognized key.class");
        }
        require(success, "__SentinelToolkit: verification failed");
    }
}

library __Sentinel {
    function encodeAndPushKeyToBytesArray(IRepository repository, bytes32 variable, Key memory key)
    external {
        __SentinelToolkit.verifyKeyInput(key);
        uint index;
        bool success;
        bytes[] memory keys = repository.getBytesArray(variable);
        (success, ,) = __SentinelToolkit.getKeyIndexByLogSigFromBytesArray(repository, variable, key.logic, key.signature);
        require(!success, "__Sentinel: key with given logic & signature was found");
        (success, index) = __SentinelToolkit.getKeyIndexByEmptyBytesFromBytesArray(repository, variable);
        if (success) { repository.setIndexBytesArray(variable, index, abi.encode(key)); }
        else { repository.pushBytesArray(variable, abi.encode(key)); }
    }

    function decodeAndPullKeyFromBytesArray(IRepository repository, bytes32 variable, address logic, string memory signature)
    external {
        uint index;
        bool success;
        bytes[] memory keys = repository.getBytesArray(variable);
        (success, index,) = __SentinelToolkit.getKeyIndexByLogSigFromBytesArray(repository, variable, logic, signature);
        require(success, "__Sentinel: key with given logic & signature was not found");
        bytes memory emptyBytes;
        repository.setIndexBytesArray(variable, index, emptyBytes);
    }

    function require_(IRepository repository, address account, address logic, string memory signature)
    external {
        if (account != repository.getAddress(keccak256(abi.encode("governor")))) {
            uint index;
            bool success;
            Key memory key;
            (success, index, key) = __SentinelToolkit.getKeyIndexByLogSigFromBytesArray(repository, keccak256(abi.encode(account, "keys")), logic, signature);
            require(success, "__Sentinel: key with given logic & signature was not found");
            __SentinelToolkit.verifyKey(repository, account, index, key);
        } else {
            require(repository.getAddress(keccak256(abi.encode("governor"))) != address(0), "__Sentinel: governor is address zero");
        }
    }
}

contract Sentinel {
    IRepository repository;

    constructor(address repository_) {
        repository = IRepository(repository_);
    }

    function getKeys(address account)
    external view
    returns (bytes[] memory) {
        return repository.getBytesArray(keccak256(abi.encode(account, "keys")));
    }

    function require_(address account, address logic, string memory signature)
    external {
        __Sentinel.require_(repository, account, logic, signature);
    }

    function _grantKey(address to, address logic, string memory signature, uint32 granted, uint32 expiration, Class class, bool isTransferable, bool isFungible, bool isClonable, uint balance, bytes memory data)
    external {
        __Sentinel.encodeAndPushKeyToBytesArray(
            repository, 
            keccak256(
                abi.encode(to, "keys")), 
                Key({
                    logic: logic,
                    signature: signature,
                    timestamp: Timestamp({
                        granted: granted,
                        expiration: expiration
                    }),
                    class: class,
                    settings: Settings({
                        isTransferable: isTransferable,
                        isFungible: isFungible,
                        isClonable: isClonable
                    }),
                    balance: balance,
                    data: data
                })
            );
    }

    function _revokeKey(address from, address logic, string memory signature)
    external {
        __Sentinel.decodeAndPullKeyFromBytesArray(repository, keccak256(abi.encode(from, "keys")), logic, signature);
    }




}

/** STORAGE VARS USAGE
    "durationTimelock"           _uint
    "durationTimeout"            _uint
    "requests"                   _bytesArray
    "selfApprove"                _bool

    | o ---------- lock
    | o ------------------------ out
    | o           -------------- window of execution
    
    **request is pending during lock period
    **request can be executed after lock but before timeout
    **request cannot be executed after timeout
    **request can only be executed once
    **timelock can never be less than 3600 seconds
    **timeout can never be less than timelock + 3600 seconds
    **d stands for decoded ie. dArgs is decoded args

    pending -> approved -> executed
    pending -> rejected

    **request can only be executed if approved
    **request cannot be executed if rejected
    **request cannot be approved from rejected or vice versa
    **request cannot go backwards within the logic tree must always start from pending
    **request can only be approved or rejected during timelock
    **if self approve is true then all requests are automatically approved
 */


/** STORAGE VARS USAGE


    **community earns anima by achieving goals within the ecosystem
    **represent achievements from the community
    **conditions for earning rewards are checked from storage
    **some anima have byte code which when checked by contract can "do certain things"
    **community can create new anima conditions for any achievement with costum code
 */

/**
contract Achievements is ERC721 {
    IStorage storage_;
    ISentinel sentinel;

    constructor(address storage__, address sentinel_)
    ERC721("AnimaRewards", "ANIMA") {
        storage_ =IStorage(storage__);
        sentinel =ISentinel(sentinel_);
    }

    function createCollectible(address account, string memory tokenURI)
    external
    returns (uint) {
        sentinel.verify({account: msg.sender, contract_: address(this), signature: "createCollectibe(address,string)"});
        bytes32 numAchievements =Encoder.encode({string_: "numAchievements"});
        uint newItemId =storage_.getUint({key: numAchievements});
        _safeMint({to: account, tokenId: newItemId});
        //_setTokenURI({tokenId: newItemId, tokenURI: tokenURI});
        storage_.setUint({key: numAchievements, value: newItemId +=1});
        return newItemId;
    }
}
*/


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


/** STORAGE VARS USAGE
    <ddr/account>   "dreamTokenBalance"     _uint

 */
/*
contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    uint public cap;
    IStorage storage_;
    ISentinel sentinel;

    modifier verify(string memory signature) {
        _verify({account: msg.sender, contract_: address(this), signature: signature});
        _;
    }

    constructor(address storage__, address sentinel_)
    ERC20("DreamToken", "DREAM")
    ERC20Permit("DreamToken") {
        cap =Utils.convertToWei({value: 200000000});
        _mint({account: msg.sender, amount: cap});
        storage_ =IStorage(storage__);
        sentinel =ISentinel(sentinel_);
    }

    function maxSupply()
    external view
    returns (uint) {
        return cap;
    }

    function getCurrentSnapshotId()
    external view
    returns (uint index) {
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
    returns (uint index) {
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
        uint balanceTo =storage_.getUint({key: balanceA});
        uint balanceFrom =storage_.getUint({key: balanceB});
        if (from !=address(0)) { balanceFrom -=amount; }
        if (to !=address(0)) { balanceTo +=amount; }
        storage_.setUint({key: balanceA, value: balanceTo});
        storage_.setUint({key: balanceB, value: balanceFrom});
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

    function _verify(address account, address contract_, string memory signature)
    internal {
        sentinel.verify({account: account, contract_: contract_, signature: signature});
    }
}


*/
/*
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
    IStorage storage_;
    ISentinel sentinel;

    modifier verify(string memory signature) {
        _verify({account: msg.sender, contract_: address(this), signature: signature});
        _;
    }

    constructor(address storage__, address sentinel_)
    ERC20("EmberToken", "EMBER")
    ERC20Permit("EmberToken") {
        storage_ =IStorage(storage__);
        sentinel =ISentinel(sentinel_);
    }

    function getCurrentSnapshotId()
    external view
    returns (uint index) {
        return _getCurrentSnapshotId();
    }

    function mint(address account, uint amount)
    external
    verify("mint(address,uint)") {
        _mint({account: account, amount: amount});
    }

    function snapshot()
    external
    verify("snapshot()")
    returns (uint index) {
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
        uint balanceTo =storage_.getUint({key: balanceA});
        uint balanceFrom =storage_.getUint({key: balanceB});
        if (from !=address(0)) { balanceFrom -=amount; }
        if (to !=address(0)) { balanceTo +=amount; }
        storage_.setUint({key: balanceA, value: balanceTo});
        storage_.setUint({key: balanceB, value: balanceFrom});
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

    function _verify(address account, address contract_, string memory signature)
    internal {
        sentinel.verify({account: account, contract_: contract_, signature: signature});
    }
}

*/

contract Bridge {
    
}