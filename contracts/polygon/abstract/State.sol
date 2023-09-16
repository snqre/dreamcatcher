// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/utils/structs/BitMaps.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/Checkpoints.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/DoubleEndedQueue.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableMap.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

abstract contract State {

    /** Imports */

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

    /** Native Storage Mappings */

    /** Standard */

    /** String Mapping
    * key: bytes32
    * value: string
     */
    mapping(bytes32 => string) internal _string;

    /** Bytes Mapping
    * key: bytes32
    * value: bytes
     */
    mapping(bytes32 => bytes) internal _bytes;

    /** Uint256 Mapping
    * key: bytes32
    * value: uint256
     */
    mapping(bytes32 => uint256) internal _uint256;

    /** Int256 Mapping
    * key: bytes32
    * value: int256
     */
    mapping(bytes32 => int256) internal _int256;

    /** Address Mapping
    * key: bytes32
    * value: address
     */
    mapping(bytes32 => address) internal _address;

    /** Bool Mapping
    * key: bytes32
    * value: bool
     */
    mapping(bytes32 => bool) internal _bool;

    /** Bytes32 Mapping
    * key: bytes32
    * value: bytes32
     */
    mapping(bytes32 => bytes32) internal _bytes32;

    /** Arrays */

    /** String[] Mapping
    * key: bytes32
    * value: string[]
     */
    mapping(bytes32 => string[]) internal _stringArray;

    /** Bytes[] Mapping
    * key: bytes32
    * value: bytes[]
     */
    mapping(bytes32 => bytes[]) internal _bytesArray;
    
    /** Uint256[] Mapping
    * key: bytes32
    * value: uint256[]
     */
    mapping(bytes32 => uint256[]) internal _uint256Array;

    /** Int256[] Mapping
    * key: bytes32
    * value: int256[]
     */
    mapping(bytes32 => int256[]) internal _int256Array;

    /** Address[] Mapping
    * key: bytes32
    * value: address[]
     */
    mapping(bytes32 => address[]) internal _addressArray;

    /** Bool[] Mapping
    * key: bytes32
    * value: bool[]
     */
    mapping(bytes32 => bool[]) internal _boolArray;

    /** Bytes32[] Mapping
    * key: bytes32
    * value: bytes32[]
     */
    mapping(bytes32 => bytes32[]) internal _bytes32Array;

    /** Openzeppelin Storage Mappings. */

    /** BitMap Mapping
    * key: bytes32
    * value: BitMaps.BitMap
     */
    mapping(bytes32 => BitMaps.BitMap) internal _bitmap;

    /** Trace224 Mapping
    * key: bytes32
    * value: Checkpoints.Trace224
     */
    mapping(bytes32 => Checkpoints.Trace224) internal _trace224;

    /** Bytes32Deque Mapping
    * key: bytes32
    * value: DoubleEndedQueue.Bytes32Deque
     */
    mapping(bytes32 => DoubleEndedQueue.Bytes32Deque) internal _bytes32Deque;

    /** Bytes32ToBytes32Map Mapping
    * key: bytes32
    * value: EnumerableMap.Bytes32ToBytes32Map
     */
    mapping(bytes32 => EnumerableMap.Bytes32ToBytes32Map) internal _bytes32ToBytes32Map;

    /** UintToUintMap Mapping
    * key: bytes32
    * value: EnumerableMap.UintToUintMap
     */
    mapping(bytes32 => EnumerableMap.UintToUintMap) internal _uintToUintMap;

    /** UintToAddressMap Mapping
    * key: bytes32
    * value: EnumerableMap.UintToAddressMap
     */
    mapping(bytes32 => EnumerableMap.UintToAddressMap) internal _uintToAddressMap;

    /** AddressToUintMap Mapping
    * key: bytes32
    * value: EnumerableMap.AddressToUintMap
     */
    mapping(bytes32 => EnumerableMap.AddressToUintMap) internal _addressToUintMap;

    /** Bytes32ToUintMap Mapping
    * key: bytes32
    * value: EnumerableMap.Bytes32ToUintMap
     */
    mapping(bytes32 => EnumerableMap.Bytes32ToUintMap) internal _bytes32ToUintMap;

    /** AddressSet Mapping
    * key: bytes32
    * value: EnumerableSet.AddressSet
     */
    mapping(bytes32 => EnumerableSet.AddressSet) internal _addressSet;

    /** Bytes32Set Mapping
    * key: bytes32
    * value: EnumerableSet.Bytes32Set
     */
    mapping(bytes32 => EnumerableSet.Bytes32Set) internal _bytes32Set;

    /** UintSet Mapping
    * key: bytes32
    * value: EnumerableSet.UintSet
     */
    mapping(bytes32 => EnumerableSet.UintSet) internal _uintSet;
}
