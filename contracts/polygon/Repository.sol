// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

interface IRepository {
    function getAdmins() external view returns (address[] memory);
    function getLogics() external view returns (address[] memory);

    function getString(bytes32 key) external view returns (string memory);
    function getBytes(bytes32 key) external view returns (bytes memory);
    function getUint(bytes32 key) external view returns (uint);
    function getInt(bytes32 key) external view returns (int);
    function getAddress(bytes32 key) external view returns (address);
    function getBool(bytes32 key) external view returns (bool);
    function getBytes32(bytes32 key) external view returns (bytes32);

    function getStringArray(bytes32 key) external view returns (string[] memory);
    function getBytesArray(bytes32 key) external view returns (bytes[] memory);
    function getUintArray(bytes32 key) external view returns (uint[] memory);
    function getIntArray(bytes32 key) external view returns (int[] memory);
    function getAddressArray(bytes32 key) external view returns (address[] memory);
    function getBoolArray(bytes32 key) external view returns (bool[] memory);
    function getBytes32Array(bytes32 key) external view returns (bytes32[] memory);

    function getIndexedStringArray(bytes32 key, uint index) external view returns (string memory);
    function getIndexedBytesArray(bytes32 key, uint index) external view returns (bytes memory);
    function getIndexedUintArray(bytes32 key, uint index) external view returns (uint);
    function getIndexedIntArray(bytes32 key, uint index) external view returns (int);
    function getIndexedAddressArray(bytes32 key, uint index) external view returns (address);
    function getIndexedBoolArray(bytes32 key, uint index) external view returns (bool);
    function getIndexedBytes32Array(bytes32 key, uint index) external view returns (bytes32);
    
    function getLengthStringArray(bytes32 key) external view returns (uint);
    function getLengthBytesArray(bytes32 key) external view returns (uint);
    function getLengthUintArray(bytes32 key) external view returns (uint);
    function getLengthIntArray(bytes32 key) external view returns (uint);
    function getLengthAddressArray(bytes32 key) external view returns (uint);
    function getLengthBoolArray(bytes32 key) external view returns (uint);
    function getLengthBytes32Array(bytes32 key) external view returns (uint);

    function getAddressSet(bytes32 key) external view returns (address[] memory);
    function getUintSet(bytes32 key) external view returns (uint[] memory);
    function getBytes32Set(bytes32 key) external view returns (bytes32[] memory);

    function getIndexedAddressSet(bytes32 key, uint index) external view returns (address);
    function getIndexedUintSet(bytes32 key, uint index) external view returns (uint);
    function getIndexedBytes32Set(bytes32 key, uint index) external view returns (bytes32);

    function getLengthAddressSet(bytes32 key) external view returns (uint);
    function getLengthUintSet(bytes32 key) external view returns (uint);
    function getLengthBytes32Set(bytes32 key) external view returns (uint);
    
    function addressSetContains(bytes32 key, address value) external view returns (bool);
    function uintSetContains(bytes32 key, uint value) external view returns (bool);
    function bytes32SetContains(bytes32 key, bytes32 value) external view returns (bool);

    function addAdmin(address account) external;
    function addLogic(address account) external;
    
    function removeAdmin(address account) external;
    function removeLogic(address account) external;

    function setString(bytes32 key, string memory value) external;
    function setBytes(bytes32 key, bytes memory value) external;
    function setUint(bytes32 key, uint value) external;
    function setInt(bytes32 key, int value) external;
    function setAddress(bytes32 key, address value) external;
    function setBool(bytes32 key, bool value) external;
    function setBytes32(bytes32 key, bytes32 value) external;

    function setStringArray(bytes32 key, uint index, string memory value) external;
    function setBytesArray(bytes32 key, uint index, bytes memory value) external;
    function setUintArray(bytes32 key, uint index, uint value) external;
    function setIntArray(bytes32 key, uint index, int value) external;
    function setAddressArray(bytes32 key, uint index, address value) external;
    function setBoolArray(bytes32 key, uint index, bool value) external;
    function setBytes32Array(bytes32 key, uint index, bytes32 value) external;

    function pushStringArray(bytes32 key, string memory value) external;
    function pushBytesArray(bytes32 key, bytes memory value) external;
    function pushUintArray(bytes32 key, uint value) external;
    function pushIntArray(bytes32 key, int value) external;
    function pushAddressArray(bytes32 key, address value) external;
    function pushBoolArray(bytes32 key, bool value) external;
    function pushBytes32Array(bytes32 key, bytes32 value) external;

    function deleteStringArray(bytes32 key) external;
    function deleteBytesArray(bytes32 key) external;
    function deleteUintArray(bytes32 key) external;
    function deleteIntArray(bytes32 key) external;
    function deleteAddressArray(bytes32 key) external;
    function deleteBoolArray(bytes32 key) external;
    function deleteBytes32Array(bytes32 key) external;
    
    function addAddressSet(bytes32 key, address value) external;
    function addUintSet(bytes32 key, uint value) external;
    function addBytes32Set(bytes32 key, bytes32 value) external;

    function removeAddressSet(bytes32 key, address value) external;
    function removeUintSet(bytes32 key, uint value) external;
    function removeBytes32Set(bytes32 key, bytes32 value) external;
}

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