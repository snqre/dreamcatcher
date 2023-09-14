// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// File: contracts\polygon\external\openzeppelin\utils\Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: contracts\polygon\external\openzeppelin\security\Pausable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: contracts\polygon\external\openzeppelin\utils\structs\EnumerableSet.sol

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

// File: contracts\polygon\interfaces\IState.sol

interface IState {
    event Stored(address indexed msgSender, bytes32 indexed location, bytes indexed data);

    event Updated(address indexed msgSender, string indexed module);

    event TimerSet(address indexed msgSender, uint64 indexed duration);

    event Upgraded(address indexed msgSender, address indexed newLogic);

    event Locked(address indexed msgSender);

    event Wiped(address indexed msgSender);

    function previous(uint index) external view returns (address);

    function latest() external view returns (address);

    function access(bytes32 location) external view returns (bytes memory);

    function module() external view returns (string memory);

    function version() external view returns (uint256);

    function empty(bytes32 location) external view returns (bool);

    function timestamp() external view returns (uint64);

    function locked() external view returns (bool);

    function core() external view returns (bool);

    function timerSet() external view returns (bool);

    function logic() external view returns (address);

    function terminal() external view returns (address);

    function state(bytes32) external view returns (bytes memory);

    function paused() external view returns (bool);

    function store(bytes32 location, bytes memory data) external;

    function update(string memory nameModule) external;

    function timer(uint64 duration) external;

    function lock() external;

    function wipe() external;

    function upgrade(address newLogic) external;

    function pause() external;

    function unpause() external;
}

// File: contracts\polygon\State.sol

/**
* minimalist implementation of ERC930
* able to set core or lockable
 */
contract State is Pausable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /// State Variables

    Dat private _dat;

    address public terminal;
    address public logic;

    bool private _locked;
    bool private _core;
    bool private _timer;
    bool private _timerSet;

    uint64 private _timestamp;

    mapping(bytes32 => bytes) public state;

    EnumerableSet.Bytes32Set private _empty;

    EnumerableSet.AddressSet private _implementations;

    /// Events

    event Stored(address indexed msgSender, bytes32 indexed location, bytes indexed data);

    event Updated(address indexed msgSender, string indexed module);

    event TimerSet(address indexed msgSender, uint64 indexed duration);

    event Upgraded(address indexed msgSender, address indexed newLogic);
    
    event Locked(address indexed msgSender);
    
    event Wiped(address indexed msgSender);

    /// Function Modifiers

    modifier onlyLogic() {
        require(msg.sender == latest(), "State: msg.sender != logic");
        _;
    }

    modifier onlyTerminal() {
        require(msg.sender == terminal, "State: msg.sender != terminal");
        _;
    }

    modifier onlyNotLocked() {
        require(!locked(), "State: permanently locked");
        _;
    }

    modifier onlyNotTimedOut() {
        if (_timer && timerSet()) {
            require(block.timestamp <= timestamp(), "State: permanently locked"); /** noted use of block.timestamp and its vulnerabilities */
        }
        _;
    }

    modifier onlyNotCore() {
        require(!core(), "State: is core");
        _;
    }

    modifier onlyNotTimed() {
        require(timestamp() == 0, "State: is timed");
        _;
    }

    modifier onlyIfTimerNotSet() {
        require(!timerSet(), "State: timer already set");
        _;
    }

    modifier onlyIfNotAddressZero() {
        require(msg.sender != address(0), "State: caller is address zero");
        _;
    }

    /// Struct, Arrays or Enums

    struct Dat { string module; }

    /// Constructor

    /** @param isCore if the state is lockable or can expire */
    constructor(string memory nameModule, bool isCore) payable {
        terminal = msg.sender;
        /** logic starts as address zero which is unable to call any functions */
        _locked = false;
        _core = isCore;
        _timer = false;
        _timerSet = false;
        _timestamp = 0;
        update(nameModule);
    }

    /// External

    /**
    * @dev set a timer and once block.timestamp is over new data will not be able to be stored
    * SHOULD only be able to be called by terminal
    * SHOULD only be able to called if not locked
    * SHOULD only be able to called if not already timed out
    * SHOULD only be able to called if the timer was not set already
    * SHOULD only be able to called if the state is not a core module
    * SHOULD only be able to called if not paused
    * WARNING permanently locks entire contract!
    * SHOULD only be able to be called if caller is not address zero
     */
    function timer(uint64 duration) external onlyTerminal() onlyNotLocked() onlyNotTimedOut() onlyIfTimerNotSet() onlyNotCore() whenNotPaused() onlyIfNotAddressZero() {
        _timer = true;
        _timerSet = true;
        _timestamp = uint64(block.timestamp); /** noted use of block.timestamp and its potential vulnerabilities */
        /** x = x + y is more gas effective than x += y */
        _timestamp = _timestamp + duration;
        emit TimerSet(msg.sender, duration);
    }

    /**
    * @dev lock the state so new data will not be able to be stored
    * SHOULD only be able to be called by terminal
    * SHOULD only be able to be called if not locked
    * SHOULD only be able to be called if not timed out
    * SHOULD only be able to be called if not timed
    * SHOULD only be able to be called if timer was not set already
    * SHOULD only be able to be called if the state is not a core module
    * SHOULD only be able to be called if not paused
    * SHOULD only be able to be called if caller is not address zero
    * WARNING permanently locks entire contract!
     */
    function lock() external onlyTerminal() onlyNotLocked() onlyNotTimedOut() onlyNotTimed() onlyIfTimerNotSet() onlyNotCore() whenNotPaused() onlyIfNotAddressZero() {
        _locked = true;
        emit Locked(msg.sender);
    }

    /**
    * @dev wipe all data within state mapping
    * SHOULD only be able to be called by current logic address
    * SHOULD only be able to be called if not locked
    * SHOULD only be able to be called if not timed out
    * SHOULD only be able to be called if not paused
    * SHOULD only be able to be called if caller is not address zero
    * SHOULD only be able to called if the state is not a core module
    * note unchecked because if the iteration gets large enough there wont be a enough gas to continue
     */
    function wipe() external onlyLogic() onlyNotLocked() onlyNotTimedOut() whenNotPaused() onlyIfNotAddressZero() onlyNotCore() {
        unchecked {
            bytes memory emptyBytes;
            uint256 len = _empty.length();
            for (uint256 i = 0; i < len; ++i) {
                store(_empty.at(i - 1), emptyBytes);
            }
            emit Wiped(msg.sender);
        }
    }

    /**
    * @dev upgrade logic by giving permission to new logic
    * SHOULD only be able to be called by terminal
    * SHOULD only be able to be called if not locked
    * SHOULD only be able to be called if not timed out
    * SHOULD only be able to be called if not paused
    * SHOULD only be able to be called if caller is not address zero
     */
    function upgrade(address newLogic) external onlyTerminal() onlyNotLocked() onlyNotTimedOut() whenNotPaused() onlyIfNotAddressZero() {
        require(!_implementations.contains(newLogic), "State: previous implementation");
        require(newLogic != address(0), "State: newLogic is address zero");
        _implementations.add(newLogic);
        logic = newLogic;
        emit Upgraded(msg.sender, newLogic);
    }

    function pause() external onlyTerminal() onlyNotLocked() onlyNotTimedOut() onlyIfNotAddressZero() onlyNotCore() {
        _pause();
        /** @dev event inherited and emited within _pause */
    }

    function unpause() external onlyTerminal() onlyNotLocked() onlyNotTimedOut() onlyIfNotAddressZero() onlyNotCore() {
        _unpause();
        /** @dev event inherited and emitted within _unpause */
    }

    /// External View

    function previous(uint256 index) external view returns (address) {
        return _implementations.at(index);
    }

    function access(bytes32 location) external view returns (bytes memory) {
        return state[location];
    }

    /// Public View

    function module() public view returns (string memory) {
        return _dat.module;
    }

    function version() public view returns (uint256) {
        return _implementations.length();
    }

    function empty(bytes32 location) public view returns (bool) {
        bytes memory emptyBytes;
        return keccak256(state[location]) == keccak256(emptyBytes);
    }

    function timestamp() public view returns (uint64) {
        return _timestamp;
    }

    function locked() public view returns (bool) {
        return _locked;
    }

    function core() public view returns (bool) {
        return _core;
    }

    function timerSet() public view returns (bool) {
        return _timerSet;
    }

    function latest() public view returns (address) {
        return _implementations.at(version() - 1);
    }

    /// Public

    /**
    * @dev store data within state mapping
    * @param location key of where to store the data
    * @param data can store any type of data by converting to bytes
    * SHOULD only be able to be called by current logic address
    * SHOULD only be able to be called if not locked
    * SHOULD only be able to be called if not timed out
    * SHOULD only be able to be called if not paused
    * SHOULD only be able to be called if caller is not address zero
     */
    function store(bytes32 location, bytes memory data) public onlyLogic() onlyNotLocked() onlyNotTimedOut() whenNotPaused() onlyIfNotAddressZero() {
        if (_empty.contains(location) && empty(location)) { _empty.remove(location); }
        if (!_empty.contains(location) && !empty(location)) { _empty.add(location); }
        state[location] = data;
        emit Stored(msg.sender, location, data);
    }

    /** @dev updates module name */
    function update(string memory nameModule) public onlyTerminal() whenNotPaused() onlyIfNotAddressZero() {
        require(!_isSameString(module(), nameModule), "State: same module name");
        _dat.module = nameModule;
        emit Updated(msg.sender, nameModule);
    }

    /// Private Pure

    function _isSameString(string memory stringA, string memory stringB) private pure returns (bool) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }
}

// File: contracts\polygon\Terminal.sol

/**
* control routers, upgrades, all in one place
* call Terminal to find the up to date location of all other modules and use the appropriate interface
* with this mechanism old implementations cannot store information within each router hence they will not be able to be used
 */
contract Terminal is Pausable {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// State Variables

    Dat private _dat;

    address public admin;

    EnumerableSet.AddressSet private _module;

    EnumerableSet.AddressSet private _active;
    EnumerableSet.AddressSet private _locked;
    EnumerableSet.AddressSet private _paused;
    
    mapping(string => uint256) public moduleMapping;

    /// Events

    event RouterDeployed(address indexed msgSender, string indexed module);

    event RouterUpgraded(address indexed msgSender, string indexed module, address indexed newLogic);

    event RouterRenamed(address indexed msgSender, string indexed module, string indexed newModule);

    event RouterLocked(address indexed msgSender, string indexed module);

    event RouterTimerSet(address indexed msgSender, string indexed module, uint64 indexed duration);

    event RouterPaused(address indexed msgSender, string indexed module);

    event RouterUnpaused(address indexed msgSender, string indexed module);

    event OwnershipTransferred(address indexed msgSender, address indexed newOwner);

    event Updated(address indexed msgSender, string indexed newName);
    
    /// Function Modifiers

    modifier onlyAdmin() {
        require(msg.sender == admin, "Terminal: msg.sender != admin");
        _;
    }
    
    /// Struct, Arrays or Enums

    struct Dat { string name; }

    /// Constructor

    constructor(string memory newName) payable {
        admin = msg.sender;
        _dat.name = newName;
        _module.add(address(new State("root", false)));
    }

    /// Plublic View

    function name() public view returns (string memory) {
        return _dat.name;
    }

    function access(string memory module, bytes32 location) public view returns (bytes memory) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.access(location);
    }

    function version(string memory module) public view returns (uint256) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.version();
    }

    function latest(string memory module) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.latest();
    }

    function previous(string memory module, uint256 index) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.previous(index);
    }

    function empty(string memory module, bytes32 location) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.empty(location);
    }

    function timestamp(string memory module) public view returns (uint64) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.timestamp();
    }

    function locked(string memory module) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.locked();
    }

    function core(string memory module) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.core();
    }

    function timerSet(string memory module) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.timerSet();
    }

    function logic(string memory module) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.logic();
    }

    function terminal(string memory module) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.terminal();
    }

    /** @dev lookup routers by module name */
    function searchByName(string memory module) public view
    returns (
        string memory module_,
        address terminal_,
        address state_,
        address logic_,
        uint256 version_,
        uint64 timestamp_,
        bool core_,
        bool locked_,
        bool paused_,
        bool timerSet_
    ) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return (
            state.module(),
            state.terminal(),
            address(state),
            state.logic(),
            state.version(),
            state.timestamp(),
            state.core(),
            state.locked(),
            state.paused(),
            state.timerSet()
        );
    }

    /** @dev look up routers by module index */
    function searchByIndex(uint index) public view
    returns (
        string memory module,
        address terminal_,
        address state_,
        address logic_,
        uint256 version_,
        uint64 timestamp_,
        bool core_,
        bool locked_,
        bool paused_,
        bool timerSet_
    ) {
        IState state = IState(_module.at(index));
        return (
            state.module(),
            state.terminal(),
            address(state),
            state.logic(),
            state.version(),
            state.timestamp(),
            state.core(),
            state.locked(),
            state.paused(),
            state.timerSet()
        );
    }

    /** @dev look up routers by address */
    function searchByAccount(address account) public view
    returns (
        string memory module,
        address terminal_,
        address state_,
        address logic_,
        uint256 version_,
        uint64 timestamp_,
        bool core_,
        bool locked_,
        bool paused_,
        bool timerSet_
    ) {
        require(_module.contains(account), "State: module not found");
        IState state = IState(account);
        return (
            state.module(),
            state.terminal(),
            address(state),
            state.logic(),
            state.version(),
            state.timestamp(),
            state.core(),
            state.locked(),
            state.paused(),
            state.timerSet()
        );
    }

    function arrayActive() public view returns (address[] memory) {
        return _active.values();
    }

    function arrayLocked() public view returns (address[] memory) {
        return _locked.values();
    }

    function arrayPaused() public view returns (address[] memory) {
        return _paused.values();
    }

    /** @dev number of routrs deployed without root router */
    function count() public view returns (uint256) {
        return _module.length() - 1;
    }

    /// Public

    /**
    * @dev deploys a State.sol contract (see State.sol) which acts as a router and ERC930 implementation
    * @param core_ core router cannot be paused, unpaused, locked, or set to exipire
     */
    function deploy(string memory module, bool core_) public onlyAdmin() {
        _reqNotInUse(module);
        _module.add(address(new State(module, core_)));
        moduleMapping[module] = _module.length() - 1;
        _active.add(_module.at(moduleMapping[module]));
        emit RouterDeployed(msg.sender, module);
    }

    function upgrade(string memory module, address newLogic) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.upgrade(newLogic);
        emit RouterUpgraded(msg.sender, module, newLogic);
    }

    function rename(string memory module, string memory newModule) public onlyAdmin() {
        _reqInUse(module);
        _reqNotInUse(newModule);
        moduleMapping[newModule] = moduleMapping[module];
        moduleMapping[module] = 0;
        IState state = IState(_module.at(moduleMapping[module]));
        state.update(newModule);
        emit RouterRenamed(msg.sender, module, newModule);
    }

    /** @dev WARNING permanently locks non core router which will not be able to store any more data */
    function lock(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.lock();
        _active.remove(_module.at(moduleMapping[module]));
        _locked.add(_module.at(moduleMapping[module]));
        emit RouterLocked(msg.sender, module);
    }

    function pause(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.pause();
        _paused.add(_module.at(moduleMapping[module]));
        emit RouterPaused(msg.sender, module);
    }

    function unpause(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.unpause();
        _paused.remove(_module.at(moduleMapping[module]));
        emit RouterUnpaused(msg.sender, module);
    }

    /** @dev set a timer at which the non core router will stop storing data */
    function setTimer(string memory module, uint64 duration) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.timer(duration);
        emit RouterTimerSet(msg.sender, module, duration);
    }

    /** update terminal name */
    function update(string memory newName) public onlyAdmin() {
        _dat.name = newName;
        emit Updated(msg.sender, newName);
    }

    function transferOwnership(address account) public onlyAdmin() {
        admin = account;
        emit OwnershipTransferred(msg.sender, account);
    }

    /// Private View

    function _reqNotInUse(string memory module) private view {
        require(moduleMapping[module] == 0, "Terminal: module != 0");
    }

    function _reqInUse(string memory module) private view {
        require(moduleMapping[module] != 0, "Terminal: module == 0");
    }
}
