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



enum KeyType {
    STANDARD,
    TIMED,
    CONSUMABLE
}

enum RequestStage {
    PENDING,
    REJECTED,
    APPROVED,
    EXECUTED
}



library Match {
    function isMatchingBytes(bytes memory _bytesA, bytes memory _bytesB)
    external pure
    returns (bool _isMatch) {
        return keccak256(_bytesA) ==keccak256(_bytesB);
    }

    function isMatchingString(string memory _stringA, string memory _stringB)
    external pure
    returns (bool _isMatch) {
        return keccak256(abi.encodePacked(_stringA)) ==keccak256(abi.encodePacked(_stringB));
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

    function encodeRequest(address[] memory targets, string[] memory signatures, bytes[] memory args, uint endTimelockTimestamp, uint endTimeoutTimestamp, RequestStage requestStage)
    external pure
    returns (bytes memory request) {
        return abi.encode(targets, signatures, args, endTimelockTimestamp, endTimeoutTimestamp, requestStage);
    }

    function decodeRequest(bytes memory request)
    external pure
    returns (address[] memory targets, string[] memory signatures, bytes[] memory args, uint endTimelockTimestamp, uint endTimeoutTimestamp, RequestStage requestStage) {
        return abi.decode(request, (address[],string[],bytes[],uint,uint,RequestStage));
    }

    // MERGED VARS

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

    // SINGLE VARS

    function governor()
    external pure
    returns (bytes32 variable) {
        return keccak256(abi.encode("governor"));
    }
}



library Calls {
    function call(address target, string memory signature, bytes memory args)
    external
    returns (bool success, bytes memory response) {
        (success, response) =target.call(abi.encodeWithSignature(signature, args));
        return (success, response);
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

interface IStorage {
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
    EnumerableSet.AddressSet internal _admins;
    EnumerableSet.AddressSet internal _logics;

    /**
    * @dev Mappings to store data of different types associated with specific bytes32 variables.
    * Each mapping corresponds to a different data type: strings, bytes, uints, integers, addresses, booleans, and bytes32 values.
    */
    mapping(bytes32 => string) internal _string;
    mapping(bytes32 => bytes) internal _bytes;
    mapping(bytes32 => uint) internal _uint;
    mapping(bytes32 => int) internal _int;
    mapping(bytes32 => address) internal _address;
    mapping(bytes32 => bool) internal _bool;
    mapping(bytes32 => bytes32) internal _bytes32;

    /**
    * @dev Mappings to store arrays of different data types associated with specific bytes32 variables.
    * Each mapping corresponds to a different data type: strings, bytes, uints, integers, addresses, booleans, and bytes32 values.
    */
    mapping(bytes32 => string[]) internal _stringArray;
    mapping(bytes32 => bytes[]) internal _bytesArray;
    mapping(bytes32 => uint[]) internal _uintArray;
    mapping(bytes32 => int[]) internal _intArray;
    mapping(bytes32 => address[]) internal _addressArray;
    mapping(bytes32 => bool[]) internal _boolArray;
    mapping(bytes32 => bytes32[]) internal _bytes32Array;

    /**
    * @dev Mappings to store sets of data associated with specific bytes32 variables.
    * Each mapping corresponds to a different data type: addresses, uints, and bytes32 values.
    */
    mapping(bytes32 => EnumerableSet.AddressSet) internal _addressSet;
    mapping(bytes32 => EnumerableSet.UintSet) internal _uintSet;
    mapping(bytes32 => EnumerableSet.Bytes32Set) internal _bytes32Set;

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

    /**
    * @dev Getter function to retrieve stored data from the contract's storage.
    * @param variable The identifier of the data variable to retrieve.
    * @return The value of the data variable.
    */
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
    function indexBytes32Set(bytes32 variable, uint index) external view returns (uint) { return _bytes32Set[variable].at(index); }

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
        require(admin !=address(0), "Storage: admin is address zero");
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
        require(logic !=address(0), "Storage: logic is address zero");
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
        require(admin !=address(0), "Storage: admin is address zero");
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
        require(logic !=address(0), "Storage: logic is address zero");
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
        _string[variable] =data;
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
        _bytes[variable] =data;
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
        _uint[variable] =data;
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
        _int[variable] =data;
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
        _address[variable] =data;
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
        _bool[variable] =data;
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
        _bytes32[variable] =data;
        emit SetBytes32({variable: variable, data: data});
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
        _stringArray[variable][index] =data;
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
        _bytesArray[variable][index] =data;
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
        _uintArray[variable][index] =data;
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
        _intArray[variable][index] =data;
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
        _addressArray[variable][index] =data;
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
        _boolArray[variable][index] =data;
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
        _bytes32Array[variable][index] =data;
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
    onlylogic {
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
    onlylogic {
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
        _uintSet[variable].add(value);
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
    /**
    * @dev Retrieves the index of the first matching key in the given bytes array based on contract and signature.
    * @param storage_ The storage contract where the bytes array is stored.
    * @param variable The key identifying the bytes array in storage.
    * @param contract_ The address of the contract associated with the key.
    * @param signature The function signature associated with the key.
    * @return success True if a matching key is found, false otherwise.
    * @return index The index of the first matching key, or the length of the array if not found.
    */
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

    /**
    * @dev Retrieves the index of the first empty bytes entry in the given bytes array.
    * @param storage_ The storage contract where the bytes array is stored.
    * @param variable The key identifying the bytes array in storage.
    * @return success True if an empty bytes entry is found, false otherwise.
    * @return index The index of the first empty bytes entry, or the length of the array if not found.
    */
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

    /**
    * @dev Checks the correctness of input parameters based on the key type.
    * @param keyType The type of the key (STANDARD, TIMED, CONSUMABLE).
    * @param startTimestamp The start timestamp for the key.
    * @param endTimestamp The end timestamp for the key.
    * @param balance The balance associated with the key.
    */
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



/** STORAGE VARS USAGE
    <addr/account>  "keys"       _bytesArray
    <str/role>      "keys"       _bytesArray
    <str/role>      "members"    _addressSet
    "governor"                   _address

    **governor can bypass verification
    **governor must not be address zero to bypass verification
    **note ie. dKey dContract stands for decoded key or decoded contract
 */
library Validator {

    /**
    * @dev Retrieves the keys associated with a specific account from the provided storage.
    * @param storage_ The storage contract where the keys are stored.
    * @param account The address of the account to retrieve keys for.
    * @return keys An array containing the keys associated with the specified account.
    */
    function getKeys(IStorage storage_, address account)
    external view
    returns (bytes[] memory keys) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 varAccountKeys =Encoder.account({account: account, property: "keys"});
        return storage_.getBytesArray({key: varAccountKeys});
    }

    /**
    * @dev Retrieves the keys associated with a specific role from the provided storage.
    * @param storage_ The storage contract where the keys are stored.
    * @param role The name of the role to retrieve keys for.
    * @return keys An array containing the keys associated with the specified role.
    */
    function getRoleKeys(IStorage storage_, string memory role)
    external view
    returns (bytes[] memory keys) {
        bytes32 varRoleKeys =Encoder.role({role: role, property: "keys"});
        return storage_.getBytesArray({key: varRoleKeys});
    }

    /**
    * @dev Retrieves the members associated with a specific role from the provided storage.
    * @param storage_ The storage contract where the members are stored.
    * @param role The name of the role to retrieve members for.
    * @return members An array containing the addresses of members associated with the specified role.
    */
    function getRoleMembers(IStorage storage_, string memory role)
    external view
    returns (address[] memory members) {
        bytes32 varRoleMembers =Encoder.role({role: role, property: "members"});
        return storage_.getAddressSet({key: varRoleMembers});
    }

    /**
    * @dev Retrieves the number of members associated with a specific role from the provided storage.
    * @param storage_ The storage contract where the members are stored.
    * @param role The name of the role to retrieve the size for.
    * @return size The number of members associated with the specified role.
    */
    function getRoleSize(IStorage storage_, string memory role)
    external view
    returns (uint size) {
        bytes32 varRoleMembers =Encoder.role({role: role, property: "members"});
        address[] memory addressArray =storage_.getAddressSet({key: varRoleMembers});
        return addressArray.length;
    }

    function grantKey(IStorage storage_, address account, )

    function grantKey(IStorage storage_, address account, address contract_, string memory signature, KeyType keyType, uint startTimestamp, uint endTimestamp, uint balance)
    external
    returns (bool success, uint index) {
        ValidatorToolkit.requireCorrectInput({keyType: keyType, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        require(account !=address(0), "Validator: account is address zero");
        require(contract_ !=address(0), "Validator: contract is address zero");
        bytes memory key =Encoder.encodeKey({contract_: contract_, signature: signature, keyType: keyType, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        bytes32 varAccountKeys =Encoder.account({account: account, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({storage_: storage_, variable: varAccountKeys, contract_: contract_, signature: signature});
        require(!success, "Validator: matching existing key: contract and address");
        (success, index) =ValidatorToolkit.getKeyIndexByEmptyBytes({storage_: storage_, variable: varAccountKeys});
        if (success) { storage_.setIndexBytesArray({key: varAccountKeys, index: index, value: key}); }
        else {
            storage_.pushBytesArray({key: varAccountKeys, value: key});
            bytes[] memory bytesArray =storage_.getBytesArray({key: varAccountKeys});
            index =bytesArray.length -1;
            success =true;
        }
        Utils.requireSuccess({success: success});
        return (success, index);
    }

    /**
    * @dev Revokes a key associated with an account and contract address.
    * @param storage_ The storage contract where the key is stored.
    * @param account The address of the account for which the key will be revoked.
    * @param contract_ The address of the contract associated with the key.
    * @param signature The signature string of the key to be revoked.
    * @return success True if the key revocation was successful, false otherwise.
    * @return index The index of the revoked key in the account's key list.
    */
    function revokeKey(IStorage storage_, address account, address contract_, string memory signature)
    external
    returns (bool success, uint index) {
        require(account !=address(0), "Validator: account is address zero");
        require(contract_ !=address(0), "Validator: contract is address zero");
        bytes32 varAccountKeys =Encoder.account({account: account, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({storage_: storage_, variable: varAccountKeys, contract_: contract_, signature: signature});
        require(success, "Validator: unable to find key: contract and address");
        bytes memory emptyBytes;
        storage_.setIndexBytesArray({key: varAccountKeys, index: index, value: emptyBytes});
        success =true;
        return (success, index);
    }

    /**
    * @dev Resets (deletes) all keys associated with a specific account.
    * @param storage_ The storage contract where the keys are stored.
    * @param account The address of the account for which keys will be reset.
    * @return success True if the key reset was successful, false otherwise.
    */
    function resetKeys(IStorage storage_, address account)
    external
    returns (bool success) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 varAccountKeys =Encoder.account({account: account, property: "keys"});
        storage_.deleteBytesArray({key: varAccountKeys});
        success =true;
        return success;
    }

    /**
    * @dev Verifies a key associated with an account and contract address, and performs actions based on key type.
    * @param storage_ The storage contract where the keys are stored.
    * @param account The address of the account for which the key will be verified.
    * @param contract_ The address of the contract associated with the key.
    * @param signature The signature string of the key to be verified.
    * @return success True if the key verification was successful, false otherwise.
    * @return index The index of the verified key in the account's key list.
    */
    function verify(IStorage storage_, address account, KeyDataMini keyDataPrefix)
    external {
        require(account !=address(0), "Validator: account is address zero");
        require(keyDataPrefix.contract_ !=address(0), "Validator: contract_ is address zero");


    }

    function verify(IStorage storage_, address account, address contract_, string memory signature)
    external
    returns(bool success, uint index) {
        require(account !=address(0), "Validator: account is address zero");
        require(contract_ !=address(0), "Validator: contract_ is address zero");

        if (account !=storage_.getAddress({key: Encoder.governor()})) {

            bytes[] memory bytesArray =storage_.getBytesArray({key: Encoder.account({account: account, property: "keys"})});

            // does the account have this key?
            (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({
                storage_: storage_, 
                variable: Encoder.account({
                    account: account,
                    property: "keys"
                }), 
            contract_: contract_, 
            signature: signature
            });
            
            // the account must have this key
            require(success, "Validator: unable to find key: contract and address");

            // assuming it has this key get data from it
            (
                address dContract, 
                string memory dSignature, 
                KeyType dKeyType, 
                uint dStartTimestamp, 
                uint dEndTimestamp, 
                uint dBalance
            ) =Encoder.decodeKey({
                key: storage_.indexBytesArray({
                    key: Encoder.account({
                        account: account, 
                        property: "keys"
                    }), 
                index: index
                })
            });

            // if the key is simply a standard key then account is verified because we have proven they have the key
            if (dKeyType ==KeyType.STANDARD) { success =true; }

            // if it is timed the make sure it is still valid
            else if (dKeyType ==KeyType.TIMED) {
                require(block.timestamp >=dStartTimestamp, "Validator: cannot use key before granted");
                require(block.timestamp <=dEndTimestamp, "Validator: expired");
                success =true;
            }

            // if consumable make sure it has a balance and then deduct 1 and encode a new key with new value
            else if (dKeyType ==KeyType.CONSUMABLE) {
                require(dBalance >=1, "Validator: insufficient balance");
                dBalance--;

                storage_.setIndexBytesArray({
                    key: Encoder.account({
                        account: account,
                        property: "keys"
                    }),
                    index: index,
                    value: Encoder.encodeKey({
                        contract_: dContract,
                        signature: dSignature,
                        keyType: dKeyType,
                        startTimestamp: dStartTimestamp,
                        endTimestamp: dEndTimestamp,
                        balance: dBalance
                    })
                });

                success =true;
            }

            // require true and return success and index
            Utils.requireSuccess({success: success});
            return (success, index);

        } else { // assuming the account is a governor address

            // check that address is not address zero then bypass verification
            require(
                storage_.getAddress({key: Encoder.governor()}) !=address(0),
                "Validator: governor is address zero"
            );

            success =true;
            return (success, index);
        }
    }

    /**
    * @dev Grants a key to a role with the specified parameters.
    * @param storage_ The storage contract where the key will be stored.
    * @param role The name of the role to which the key will be granted.
    * @param contract_ The address of the contract associated with the key.
    * @param signature The signature string for the key.
    * @param keyType The type of the key (STANDARD, TIMED, CONSUMABLE).
    * @param startTimestamp The start timestamp for the key.
    * @param endTimestamp The end timestamp for the key.
    * @param balance The balance associated with the key.
    * @return success True if the key granting to the role was successful, false otherwise.
    * @return index The index of the granted key in the role's key list.
    */
    function grantKeyToRole(IStorage storage_, string memory role, address contract_, string memory signature, KeyType keyType, uint startTimestamp, uint endTimestamp, uint balance)
    external
    returns (bool success, uint index) {
        ValidatorToolkit.requireCorrectInput({keyType: keyType, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes memory key =Encoder.encodeKey({contract_: contract_, signature: signature, keyType: keyType, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        bytes32 varRoleKeys =Encoder.role({role: role, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({storage_: storage_, variable: varRoleKeys, contract_: contract_, signature: signature});
        require(!success, "Validator: matching existing key: contract and address");
        (success, index) =ValidatorToolkit.getKeyIndexByEmptyBytes({storage_: storage_, variable: varRoleKeys});
        if (success) { storage_.setIndexBytesArray({key: varRoleKeys, index: index, value: key}); }
        else {
            storage_.pushBytesArray({key: varRoleKeys, value: key});
            bytes[] memory bytesArray =storage_.getBytesArray({key: varRoleKeys});
            index =bytesArray.length -1;
            success =true;
        }
        Utils.requireSuccess({success: success});
        return (success, index);
    }

    /**
    * @dev Revokes a key associated with a role.
    * @param storage_ The storage contract where the keys are stored.
    * @param role The name of the role from which the key will be revoked.
    * @param contract_ The address of the contract associated with the key.
    * @param signature The signature string of the key to be revoked.
    * @return success True if the key revocation from the role was successful, false otherwise.
    * @return index The index of the revoked key in the role's key list.
    */
    function revokeKeyFromRole(IStorage storage_, string memory role, address contract_, string memory signature)
    external
    returns (bool success, uint index) {
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes32 varRoleKeys =Encoder.role({role: role, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({storage_: storage_, variable: varRoleKeys, contract_: contract_, signature: signature});
        require(success, "Validator: unable to find key: contract and address");
        bytes memory emptyBytes;
        storage_.setIndexBytesArray({key: varRoleKeys, index: index, value: emptyBytes});
        success =true;
        return (success, index);
    }

    /**
    * @dev Resets (deletes) all keys associated with a specific role.
    * @param storage_ The storage contract where the keys are stored.
    * @param role The name of the role for which keys will be reset.
    * @return success True if the role's keys reset was successful, false otherwise.
    */
    function resetRoleKeys(IStorage storage_, string memory role)
    external
    returns (bool success) {
        bytes32 varRoleKeys =Encoder.role({role: role, property: "keys"});
        storage_.deleteBytesArray({key: varRoleKeys});
        success =true;
        return success;
    }

    /**
    * @dev Grants a role to an account, copying keys associated with the role to the account.
    * @param storage_ The storage contract where the keys and roles are stored.
    * @param account The address of the account to which the role will be granted.
    * @param role The name of the role to be granted.
    * @return success True if the role granting was successful, false otherwise.
    */
    function grantRole(IStorage storage_, address account, string memory role) external returns (bool success) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 varRoleKeys =Encoder.role({role: role, property: "keys"});
        bytes32 varAccountKeys =Encoder.account({account: account, property: "keys"});
        storage_.deleteBytesArray({key: varAccountKeys});
        bytes[] memory roleKeys =storage_.getBytesArray({key: varRoleKeys});
        for (uint i =0; i <roleKeys.length; i++) {
            success =false;
            (address contract_, string memory signature, KeyType keyType, uint startTimestamp, uint endTimestamp, uint balance) =Encoder.decodeKey({key: roleKeys[i]});
            ValidatorToolkit.requireCorrectInput({keyType: keyType, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
            storage_.pushBytesArray({key: varAccountKeys, value: roleKeys[i]});
        }
        bytes32 varRoleMembers =Encoder.role({role: role, property: "members"});
        storage_.addAddressSet({key: varRoleMembers, value: account});
        success =true;
        return success;
    }

    function swapGovernor(IStorage storage_, address account)
    external {
        storage_.setAddress({key: Encoder.encode({string_: "governor"}), value: account});
    }

    /**
    * @dev Revokes a role from an account, removing associated keys from the account.
    * @param storage_ The storage contract where the keys and roles are stored.
    * @param account The address of the account from which the role will be revoked.
    * @param role The name of the role to be revoked.
    * @return success True if the role revocation was successful, false otherwise.
    * @return index The index of the last revoked key in the role's key list.
    */
    function revokeRole(IStorage storage_, address account, string memory role)
    external
    returns (bool success, uint index) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 varRoleKeys =Encoder.role({role: role, property: "keys"});
        bytes32 varAccountKeys =Encoder.account({account: account, property: "keys"});
        bytes[] memory roleKeys =storage_.getBytesArray({key: varRoleKeys});
        bytes memory emptyBytes;
        for (uint i =0; i <roleKeys.length; i++) {
            (address contract_, string memory signature, , , ,) =Encoder.decodeKey({key: roleKeys[i]});
            success =false;
            index =0;
            (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({storage_: storage_, variable: varRoleKeys, contract_: contract_, signature: signature});
            if (success) { storage_.setIndexBytesArray({key: varAccountKeys, index: index, value: emptyBytes}); }
        }
        success =true;
        return (success, index);
    }
}



interface ISentinel {
    function init() external;
    function getKeys(address account) external view returns (bytes[] memory);
    function getRoleKeys(string memory role) external view returns (bytes[] memory);
    function getRoleMembers(string memory role) external view returns (address[] memory);
    function getRoleSize(string memory role) external view returns (uint);
    function swapGovernor(address account) external;
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



/**
 * @title Sentinel Contract
 * @dev The Sentinel contract serves as a secure key management system with role-based access control.
 * It allows users to manage keys, roles, and perform key verification securely. The contract implements
 * the ISentinel interface and inherits from the Pausable and ReentrancyGuard contracts to ensure
 * proper functioning and protection against reentrancy attacks.
 *
 * This contract enables the verification of keys, retrieval of keys associated with accounts and roles,
 * management of roles, and initialization of permissions. It provides a secure environment for managing
 * access to various functions and operations within a decentralized application.
 */
contract Sentinel is Pausable, ReentrancyGuard {
    bool internal _init;
    address internal _deployer;
    IStorage storage_;

    /**
    * @dev Verifies a key for the sender (msg.sender) using a specified signature.
    * @param signature The signature of the key to be verified.
    * @notice This modifier verifies a key for the sender and can be used to secure functions.
    */
    modifier verify_(string memory signature) {
        _verify({account: msg.sender, contract_: address(this), signature: signature});
        _;
    }

    constructor(address storage__) {
        _deployer =msg.sender;
        storage_ =IStorage(storage__);
    }

    /**
    * @dev Initializes the contract and grants necessary permissions to the deployer.
    * This function should be called only once after the contract is deployed by the designated deployer.
    */
    function init()
    external {
        require(msg.sender ==_deployer, "Sentinel: only _deployer can call");
        require(!_init, "Sentienl: _init");
        bool isLogic;
        address[] memory logics =storage_.getLogics();
        for (uint i =0; i <logics.length; i++) {
            if (address(this) ==logics[i]) { isLogic =true; }
        }
        require(isLogic, "Sentinel: cannot init without setting as logic first");
        Validator.grantKeyToRole({storage_: storage_, role: "validator", contract_: address(this), signature: "grantKey(address,address,string,uint256,uint256,uint256,uint256)", keyType: KeyType.STANDARD, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({storage_: storage_, role: "validator", contract_: address(this), signature: "revokeKey(address,address,string)", keyType: KeyType.STANDARD, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({storage_: storage_, role: "validator", contract_: address(this), signature: "resetKeys(address)", keyType: KeyType.STANDARD, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({storage_: storage_, role: "validator", contract_: address(this), signature: "grantKeyToRole(string,address,string,uint256,uint256,uint256,uint256)", keyType: KeyType.STANDARD, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({storage_: storage_, role: "validator", contract_: address(this), signature: "revokeKeyFromRole(string,address,string)", keyType: KeyType.STANDARD, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({storage_: storage_, role: "validator", contract_: address(this), signature: "resetRoleKeys(string)", keyType: KeyType.STANDARD, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({storage_: storage_, role: "validator", contract_: address(this), signature: "grantRole(address,string)", keyType: KeyType.STANDARD, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({storage_: storage_, role: "validator", contract_: address(this), signature: "revokeRole(address,string)", keyType: KeyType.STANDARD, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantRole({storage_: storage_, account: msg.sender, role: "validator"});
        _init =true;
    }

    /**
    * @dev Retrieves the keys associated with a specific account.
    * @param account The address of the account to retrieve keys for.
    * @return keys An array containing the keys associated with the specified account.
    */
    function getKeys(address account)
    external view
    returns (bytes[] memory) {
        return Validator.getKeys({storage_: storage_, account: account});
    }

    /**
    * @dev Retrieves the keys associated with a specific role.
    * @param role The role for which to retrieve keys.
    * @return keys An array containing the keys associated with the specified role.
    */
    function getRoleKeys(string memory role)
    external view
    returns (bytes[] memory) {
        return Validator.getRoleKeys({storage_: storage_, role: role});
    }

    /**
    * @dev Retrieves the members associated with a specific role.
    * @param role The role for which to retrieve members.
    * @return members An array containing the members associated with the specified role.
    */
    function getRoleMembers(string memory role)
    external view
    returns (address[] memory) {
        return Validator.getRoleMembers({storage_: storage_, role: role});
    }

    /**
    * @dev Retrieves the number of members in a specific role.
    * @param role The role for which to retrieve the member count.
    * @return size The number of members associated with the specified role.
    */
    function getRoleSize(string memory role)
    external view
    returns (uint) {
        return Validator.getRoleSize({storage_: storage_, role: role});
    }

    function swapGovernor(address account)
    external {
        Validator.swapGovernor({storage_: storage_, account: account});
    }

    /**
    * @dev Verifies a key for a specific account using a provided signature.
    * If the sender is the governor, additional checks are performed.
    * @param account The address of the account to verify the key for.
    * @param contract_ The address of the contract associated with the key.
    * @param signature The signature of the key to be verified.
    * @notice This function is non-reentrant to prevent reentrancy attacks.
    */
    function verify(address account, address contract_, string memory signature)
    external 
    nonReentrant {
        _verify({account: account, contract_: contract_, signature: signature});
    }

    function grantKey(address account, address contract_, string memory signature, KeyType keyType, uint startTimestamp, uint endTimestamp, uint balance)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("grantKey(address,address,string,uint256,uint256,uint256,uint256)") {
        Validator.grantKey({storage_: storage_, account: account, contract_: contract_, signature: signature, keyType: keyType, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
    }

    /**
    * @dev Revokes a previously granted key associated with a specified account.
    * @param account The address of the account from which to revoke the key.
    * @param contract_ The address of the contract associated with the key.
    * @param signature The signature of the key.
    * @notice This function is non-reentrant and can only be called when the contract is not paused.
    *         It verifies the provided key and revokes access accordingly.
    */
    function revokeKey(address account, address contract_, string memory signature)
    external
    nonReentrant
    whenNotPaused 
    verify_("revokeKey(address,address,string)") {
        Validator.revokeKey({storage_: storage_, account: account, contract_: contract_, signature: signature});
    }

    /**
    * @dev Resets all keys associated with a specific account.
    * @param account The address of the account for which to reset keys.
    * @notice This function is non-reentrant and can only be called when the contract is not paused.
    *         It verifies the provided signature and resets all keys associated with the given account.
    */
    function resetKeys(address account)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("resetKeys(address)") {
        Validator.resetKeys({storage_: storage_, account: account});
    }

    function grantKeyToRole(string memory role, address contract_, string memory signature, KeyType keyType, uint startTimestamp, uint endTimestamp, uint balance)
    external 
    nonReentrant
    whenNotPaused
    verify_("grantKeyToRole(string,address,string,uint256,uint256,uint256,uint256)") {
        Validator.grantKeyToRole({storage_: storage_, role: role, contract_: contract_, signature: signature, keyType: keyType, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
    }

    /**
    * @dev Revokes a key from a specified role.
    * @param role The role from which the key will be revoked.
    * @param contract_ The address of the contract associated with the key.
    * @param signature The signature of the key.
    * @notice This function is non-reentrant and can only be called when the contract is not paused.
    *         It verifies the provided signature and revokes a key from the specified role.
    */
    function revokeKeyFromRole(string memory role, address contract_, string memory signature)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("revokeKeyFromRole(string,address,string)") {
        Validator.revokeKeyFromRole({storage_: storage_, role: role, contract_: contract_, signature: signature});
    }

    /**
    * @dev Resets the keys associated with a specified role.
    * @param role The role for which keys will be reset.
    * @notice This function is non-reentrant and can only be called when the contract is not paused.
    *         It verifies the provided signature and resets the keys associated with the specified role.
    */
    function resetRoleKeys(string memory role)
    external 
    nonReentrant
    whenNotPaused
    verify_("resetRoleKeys(string)") {
        Validator.resetRoleKeys({storage_: storage_, role: role});
    }

    /**
    * @dev Grants a role to a specified account.
    * @param account The address of the account to be granted the role.
    * @param role The role to be granted to the account.
    * @notice This function is non-reentrant and can only be called when the contract is not paused.
    *         It verifies the provided signature and grants the specified role to the given account.
    */
    function grantRole(address account, string memory role)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("grantRole(address,string)") {
        Validator.grantRole({storage_: storage_, account: account, role: role});
    }

    /**
    * @dev Revokes a role from a specified account.
    * @param account The address of the account from which the role will be revoked.
    * @param role The role to be revoked from the account.
    * @notice This function is non-reentrant and can only be called when the contract is not paused.
    *         It verifies the provided signature and revokes the specified role from the given account.
    */
    function revokeRole(address account, string memory role)
    external 
    nonReentrant
    whenNotPaused
    verify_("revokeRole(address,string)") {
        Validator.revokeRole({storage_: storage_, account: account, role: role});
    }

    /**
    * @dev Verifies a key for a specific account using a provided signature.
    * @param account The address of the account to verify the key for.
    * @param contract_ The address of the contract associated with the key.
    * @param signature The signature of the key to be verified.
    * @notice This function is used internally to verify a key for a specific account.
    */
    function _verify(address account, address contract_, string memory signature)
    internal {
        Validator.verify({storage_: storage_, account: account, contract_: contract_, signature: signature});
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
library Timelock {
    /**
    * @dev Queues a new request by encoding and storing it in the contract.
    * @param storage_ The storage contract where the request and its details will be stored.
    * @param targets An array of target addresses for the function calls within the request.
    * @param signatures An array of function signatures for the function calls within the request.
    * @param args An array of encoded arguments for the function calls within the request.
    */
    function queueRequest(IStorage storage_, address[] memory targets, string[] memory signatures, bytes[] memory args)
    external 
    returns (uint index) {
        uint now_ =block.timestamp;
        bytes32 varDurationTimelock =Encoder.encode({string_: "durationTimelock"});
        bytes32 varDurationTimeout =Encoder.encode({string_: "durationTimeout"});
        bytes32 varSelfApprove =Encoder.encode({string_: "selfApprove"});
        uint durationTimelock =storage_.getUint({key: varDurationTimelock});
        uint durationTimeout =storage_.getUint({key: varDurationTimeout});
        bool selfApprove =storage_.getBool({key: varSelfApprove});
        RequestStage requestStage;
        if (selfApprove) { requestStage =RequestStage.APPROVED; }
        else { requestStage =RequestStage.PENDING; }
        bytes memory request =Encoder.encodeRequest({targets: targets, signatures: signatures, args: args, endTimelockTimestamp: now_ +durationTimelock, endTimeoutTimestamp: now_ +durationTimeout, requestStage: requestStage});
        bytes32 varRequests =Encoder.encode({string_: "requests"});
        storage_.pushBytesArray({key: varRequests, value: request});
        bytes[] memory bytesArray =storage_.getBytesArray({key: varRequests});
        return bytesArray.length -1;
    }

    /**
    * @dev Approves a request at the specified index by updating its request stage to APPROVED.
    * @param storage_ The storage contract where the request and its array are stored.
    * @param index The index of the request to be approved.
    */
    function approveRequest(IStorage storage_, uint index)
    external {
        bytes32 varRequests =Encoder.encode({string_: "requests"});
        bytes memory request =storage_.indexBytesArray({key: varRequests, index: index});
        (address[] memory dTargets, string[] memory dSignatures, bytes[] memory dArgs, uint dEndTimelockTimestamp, uint dEndTimeoutTimestamp, RequestStage dRequestStage) =Encoder.decodeRequest({request: request});
        require(dRequestStage ==RequestStage.PENDING, "Timelock: must be pending");
        require(block.timestamp <=dEndTimelockTimestamp, "Timelock: cannot approve after timelock");
        dRequestStage =RequestStage.APPROVED;
        bytes memory newRequest =Encoder.encodeRequest({targets: dTargets, signatures: dSignatures, args: dArgs, endTimelockTimestamp: dEndTimelockTimestamp, endTimeoutTimestamp: dEndTimeoutTimestamp, requestStage: dRequestStage});
        storage_.setIndexBytesArray({key: varRequests, index: index, value: newRequest});
    }

    /**
    * @dev Rejects a request at the specified index by updating its request stage to REJECTED.
    * @param storage_ The storage contract where the request and its array are stored.
    * @param index The index of the request to be rejected.
    */
    function rejectRequest(IStorage storage_, uint index)
    external {
        bytes32 varRequests =Encoder.encode({string_: "requests"});
        bytes memory request =storage_.indexBytesArray({key: varRequests, index: index});
        (address[] memory dTargets, string[] memory dSignature, bytes[] memory dArgs, uint dEndTimelockTimestamp, uint dEndTimeoutTimestamp, RequestStage dRequestStage) =Encoder.decodeRequest({request: request});
        require(dRequestStage ==RequestStage.PENDING, "Timelock: must be pending");
        require(block.timestamp <=dEndTimelockTimestamp, "Timelock: cannot approve after timelock");
        dRequestStage =RequestStage.REJECTED;
        bytes memory newRequest =Encoder.encodeRequest({targets: dTargets, signatures: dSignature, args: dArgs, endTimelockTimestamp: dEndTimelockTimestamp, endTimeoutTimestamp: dEndTimeoutTimestamp, requestStage: dRequestStage});
        storage_.setIndexBytesArray({key: varRequests, index: index, value: newRequest});
    }

    /**
    * @dev Executes a previously approved request at the specified index.
    * @param storage_ The storage contract where the request and its array are stored.
    * @param index The index of the request to be executed.
    * @return successes An array of boolean values indicating the success of each external call.
    * @return responses An array of response data from each external call.
    */
    function executeRequest(IStorage storage_, uint index)
    external 
    returns (bool[] memory successes, bytes[] memory responses) {
        bytes32 varRequests =Encoder.encode({string_: "requests"});
        bytes memory request =storage_.indexBytesArray({key: varRequests, index: index});
        (address[] memory dTargets, string[] memory dSignature, bytes[] memory dArgs, uint dEndTimelockTimestamp, uint dEndTimeoutTimestamp, RequestStage dRequestStage) =Encoder.decodeRequest({request: request});
        require(dRequestStage ==RequestStage.APPROVED, "Timelock: must be approved");
        require(block.timestamp >dEndTimelockTimestamp, "Timelock: cannot execute before timelock");
        require(block.timestamp <=dEndTimeoutTimestamp, "Timelock: cannot execute after timeout");
        dRequestStage =RequestStage.EXECUTED;
        bytes memory newRequest =Encoder.encodeRequest({targets: dTargets, signatures: dSignature, args: dArgs, endTimelockTimestamp: dEndTimelockTimestamp, endTimeoutTimestamp: dEndTimeoutTimestamp, requestStage: dRequestStage});
        storage_.setIndexBytesArray({key: varRequests, index: index, value: newRequest});
        for (uint i =0; i <dTargets.length; i++) {
            (successes[i], responses[i]) =Calls.call({target: dTargets[i], signature: dSignature[i], args: dArgs[i]});
        }
        return (successes, responses);
    }
}



contract Key is Pausable, ReentrancyGuard {
    bool internal _init;
    address internal _deployer;
    IStorage storage_;
    ISentinel sentinel;

    modifier verify(string memory signature) {
        _verify({account: msg.sender, contract_: address(this), signature: signature});
        _;
    }

    constructor(address storage__, address sentinel_) {
        _deployer =msg.sender;
        storage_ =IStorage(storage__);
        sentinel =ISentinel(sentinel_);
    }

    function init()
    external {
        require(msg.sender ==_deployer, "Key: only _deployer can call");
        require(!_init, "Key: _init");
        bool isLogic;
        address[] memory logics =storage_.getLogics();
        for (uint i =0; i <logics.length; i++) {
            if (address(this) ==logics[i]) { isLogic =true; }
        }
        require(isLogic, "Key: cannot init without setting as logic first");
        bytes32 varSelfApprove =Encoder.encode({string_: "selfApprove"});
        storage_.setBool({key: varSelfApprove, value: true});
        _init =true;
    }

    function queueRequest(address[] memory targets, string[] memory signatures, bytes[] memory args)
    external
    nonReentrant
    whenNotPaused
    verify("queueRequest(address[],string[],bytes[])")
    returns (uint index) {
        return Timelock.queueRequest({storage_: storage_, targets: targets, signatures: signatures, args: args});
    }

    function _verify(address account, address contract_, string memory signature)
    internal {
        sentinel.verify({account: account, contract_: contract_, signature: signature});
    }
}



/** STORAGE VARS USAGE


    **community earns anima by achieving goals within the ecosystem
    **represent achievements from the community
    **conditions for earning rewards are checked from storage
    **some anima have byte code which when checked by contract can "do certain things"
    **community can create new anima conditions for any achievement with costum code
 */
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



contract Bridge {
    
}