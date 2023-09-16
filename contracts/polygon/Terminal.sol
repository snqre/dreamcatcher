// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/access/AccessControlDefaultAdminRules.sol";

import "contracts/polygon/external/openzeppelin/access/AccessControlEnumerable.sol";

import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";

import "contracts/polygon/external/openzeppelin/security/Pausable.sol";

import "contracts/polygon/external/openzeppelin/security/ReentrancyGuard.sol";

import "contracts/polygon/external/openzeppelin/utils/Address.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/BitMaps.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/Checkpoints.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/DoubleEndedQueue.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableMap.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

contract Terminal is AccessControlDefaultAdminRules, AccessControlEnumerable, ReentrancyGuard, Pausable, Proxy {

    /** Imports. */

    /**
    * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
    * Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
    */
    using BitMaps for BitMaps.BitMap;

    /**
    * @dev This library defines the `History` struct, for checkpointing values as they change at different points in
    * time, and later looking up past values by block number. See {Votes} as an example.
    *
    * To create a history of checkpoints define a variable type `Checkpoints.History` in your contract, and store a new
    * checkpoint for the current transaction block using the {push} function.
    *
    * _Available since v4.5._
    */
    using Checkpoints for Checkpoints.Trace224;

    /**
    * @dev A sequence of items with the ability to efficiently push and pop items (i.e. insert and remove) on both ends of
    * the sequence (called front and back). Among other access patterns, it can be used to implement efficient LIFO and
    * FIFO queues. Storage use is optimized, and all operations are O(1) constant time. This includes {clear}, given that
    * the existing queue contents are left in storage.
    *
    * The struct is called `Bytes32Deque`. Other types can be cast to and from `bytes32`. This data structure can only be
    * used in storage, and not in memory.
    * ```solidity
    * DoubleEndedQueue.Bytes32Deque queue;
    * ```
    *
    * _Available since v4.6._
    */
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;

    /**
    * @dev Library for managing an enumerable variant of Solidity's
    * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
    * type.
    *
    * Maps have the following properties:
    *
    * - Entries are added, removed, and checked for existence in constant time
    * (O(1)).
    * - Entries are enumerated in O(n). No guarantees are made on the ordering.
    *
    * ```solidity
    * contract Example {
    *     // Add the library methods
    *     using EnumerableMap for EnumerableMap.UintToAddressMap;
    *
    *     // Declare a set state variable
    *     EnumerableMap.UintToAddressMap private myMap;
    * }
    * ```
    *
    * The following map types are supported:
    *
    * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
    * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
    * - `bytes32 -> bytes32` (`Bytes32ToBytes32Map`) since v4.6.0
    * - `uint256 -> uint256` (`UintToUintMap`) since v4.7.0
    * - `bytes32 -> uint256` (`Bytes32ToUintMap`) since v4.7.0
    *
    * [WARNING]
    * ====
    * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
    * unusable.
    * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
    *
    * In order to clean an EnumerableMap, you can either remove all elements one by one or create a fresh instance using an
    * array of EnumerableMap.
    * ====
    */
    using EnumerableMap for EnumerableMap.Bytes32ToBytes32Map;

    using EnumerableMap for EnumerableMap.UintToUintMap;

    using EnumerableMap for EnumerableMap.UintToAddressMap;

    using EnumerableMap for EnumerableMap.AddressToUintMap;

    using EnumerableMap for EnumerableMap.Bytes32ToUintMap;

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
    using EnumerableSet for EnumerableSet.AddressSet;

    using EnumerableSet for EnumerableSet.Bytes32Set;

    using EnumerableSet for EnumerableSet.UintSet;

    /** TODO State Variables. */

    /** Native Storage Mappings. */

    /**
    * port: uint256
    * key: bytes32
    * value: string
     */
    mapping(uint256 => mapping(bytes32 => string)) private _string;
    
    /**
    * port: uint256
    * key: bytes32
    * value: bytes
     */
    mapping(uint256 => mapping(bytes32 => bytes)) private _bytes;

    /**
    * port: uint256
    * key: bytes32
    * value: uint256
     */
    mapping(uint256 => mapping(bytes32 => uint256)) private _uint256;

    /**
    * port: uint256
    * key: bytes32
    * value: int256
     */
    mapping(uint256 => mapping(bytes32 => int256)) private _int256;

    /**
    * port: uint256
    * key: bytes32
    * value: address
     */
    mapping(uint256 => mapping(bytes32 => address)) private _address;

    /**
    * port: uint256
    * key: bytes32
    * value: bool
     */
    mapping(uint256 => mapping(bytes32 => bool)) private _bool;

    /**
    * port: uint256
    * key: bytes32
    * value: bytes32
     */
    mapping(uint256 => mapping(bytes32 => bytes32)) private _bytes32;

    /**
    * port: uint256
    * key: bytes32
    * value: string[]
     */
    mapping(uint256 => mapping(bytes32 => string[])) private _stringArray;

    /**
    * port: uint256
    * key: bytes32
    * value: bytes[]
     */
    mapping(uint256 => mapping(bytes32 => bytes[])) private _bytesArray;
    
    /**
    * port: uint256
    * key: bytes32
    * value: uint256[]
     */
    mapping(uint256 => mapping(bytes32 => uint256[])) private _uint256Array;

    /**
    * port: uint256
    * key: bytes32
    * value: int256[]
     */
    mapping(uint256 => mapping(bytes32 => int256[])) private _int256Array;

    /**
    * port: uint256
    * key: bytes32
    * value: address[]
     */
    mapping(uint256 => mapping(bytes32 => address[])) private _addressArray;

    /**
    * port: uint256
    * key: bytes32
    * value: bool[]
     */
    mapping(uint256 => mapping(bytes32 => bool[])) private _boolArray;

    /**
    * port: uint256
    * key: bytes32
    * value: bytes32[]
     */
    mapping(uint256 => mapping(bytes32 => bytes32[])) private _bytes32Array;

    /** Openzeppelin Storage Mappings. */

    /**
    * port: uint256
    * key: bytes32
    * value: BitMaps.BitMap
     */
    mapping(uint256 => mapping(bytes32 => BitMaps.BitMap)) private _bitmap;

    /**
    * port: uint256
    * key: bytes32
    * value: Checkpoints.Trace224
     */
    mapping(uint256 => mapping(bytes32 => Checkpoints.Trace224)) private _trace224;

    /**
    * port: uint256
    * key: bytes32
    * value: DoubleEndedQueue.Bytes32Deque
     */
    mapping(uint256 => mapping(bytes32 => DoubleEndedQueue.Bytes32Deque)) private _bytes32Deque;

    /**
    * port: uint256
    * key: bytes32
    * value: EnumerableMap.Bytes32ToBytes32Map
     */
    mapping(uint256 => mapping(bytes32 => EnumerableMap.Bytes32ToBytes32Map)) private _bytes32ToBytes32Map;

    /**
    * port: uint256
    * key: bytes32
    * value: EnumerableMap.UintToUintMap
     */
    mapping(uint256 => mapping(bytes32 => EnumerableMap.UintToUintMap)) private _uintToUintMap;

    /**
    * port: uint256
    * key: bytes32
    * value: EnumerableMap.UintToAddressMap
     */
    mapping(uint256 => mapping(bytes32 => EnumerableMap.UintToAddressMap)) private _uintToAddressMap;

    /**
    * port: uint256
    * key: bytes32
    * value: EnumerableMap.AddressToUintMap
     */
    mapping(uint256 => mapping(bytes32 => EnumerableMap.AddressToUintMap)) private _addressToUintMap;

    /**
    * port: uint256
    * key: bytes32
    * value: EnumerableMap.Bytes32ToUintMap
     */
    mapping(uint256 => mapping(bytes32 => EnumerableMap.Bytes32ToUintMap)) private _bytes32ToUintMap;

    /**
    * port: uint256
    * key: bytes32
    * value: EnumerableSet.AddressSet
     */
    mapping(uint256 => mapping(bytes32 => EnumerableSet.AddressSet)) private _addressSet;

    /**
    * port: uint256
    * key: bytes32
    * value: EnumerableSet.Bytes32Set
     */
    mapping(uint256 => mapping(bytes32 => EnumerableSet.Bytes32Set)) private _bytes32Set;

    /**
    * port: uint256
    * key: bytes32
    * value: EnumerableSet.UintSet
     */
    mapping(uint256 => mapping(bytes32 => EnumerableSet.UintSet)) private _uintSet;

    /**
    * @param initialDelay
    * @param initialDefaultAdmin Set initial admin
    * @note 
     */
    constructor(uint48 initialDelay, address initialDefaultAdmin) AccessControlDefaultAdminRules(initialDelay, initialDefaultAdmin) {}
/** TODO SET WHAT IMPLEMENTATION IS SELECTED */
    /** External.  */

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual override {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual override {
        _fallback();
    }

    /** Internal View. */

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     * @dev @note This has been overriden here.
     */
    function _implementation() internal view virtual override returns (address) {
        super._implementation();
        /** TODO */
    }

    /** Internal. */

    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual override {
        super._delegate(implementation);
    }

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual override {
        super._fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual override {
        super._beforeFallback();
    }
}