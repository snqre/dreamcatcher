// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/utils/structs/BitMaps.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/Checkpoints.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/DoubleEndedQueue.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableMap.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

/**
 * @title StateV1
 * @dev Abstract contract utilizing OpenZeppelin libraries for efficient storage and data management.
 *
 * This contract serves as a foundation for other contracts, providing implementations for various data structures
 * such as bitmaps, checkpoints, double-ended queues, enumerable maps, and enumerable sets. It leverages OpenZeppelin
 * libraries to ensure gas-efficient and secure storage management.
 *
 * @notice This contract defines multiple mappings with different key-value types, enabling the storage and retrieval
 * of diverse data types within the Ethereum blockchain.
 *
 * @dev The contract imports and utilizes OpenZeppelin libraries, including BitMaps, Checkpoints, DoubleEndedQueue,
 * and EnumerableMap, to enhance the functionality and efficiency of data structures.
 *
 * @dev Developers extending this contract can benefit from the pre-implemented and optimized storage solutions
 * provided by OpenZeppelin, enabling them to focus on higher-level contract logic.
 */
abstract contract StateV1 {
    
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

    /**
    * @dev Importing and enabling the use of the EnumerableMap library for the Bytes32ToBytes32Map type.
    * @dev Allows the Bytes32ToBytes32Map type to benefit from the functionalities provided by the EnumerableMap library.
    */
    using EnumerableMap for EnumerableMap.Bytes32ToBytes32Map;

    /**
    * @dev Importing and enabling the use of the EnumerableMap library for the UintToUintMap type.
    * @dev Allows the UintToUintMap type to benefit from the functionalities provided by the EnumerableMap library.
    */
    using EnumerableMap for EnumerableMap.UintToUintMap;

    /**
    * @dev Importing and enabling the use of the EnumerableMap library for the UintToAddressMap type.
    * @dev Allows the UintToAddressMap type to benefit from the functionalities provided by the EnumerableMap library.
    */
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    /**
    * @dev Importing and enabling the use of the EnumerableMap library for the AddressToUintMap type.
    * @dev Allows the AddressToUintMap type to benefit from the functionalities provided by the EnumerableMap library.
    */
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    /**
    * @dev Importing and enabling the use of the EnumerableMap library for the Bytes32ToUintMap type.
    * @dev Allows the Bytes32ToUintMap type to benefit from the functionalities provided by the EnumerableMap library.
    */
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

    /**
    * @dev Importing and enabling the use of the EnumerableSet library for the AddressSet type.
    * @dev Allows the AddressSet type to benefit from the functionalities provided by the EnumerableSet library.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @dev Importing and enabling the use of the EnumerableSet library for the Bytes32Set type.
    * @dev Allows the Bytes32Set type to benefit from the functionalities provided by the EnumerableSet library.
    */
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /**
    * @dev Importing and enabling the use of the EnumerableSet library for the UintSet type.
    * @dev Allows the UintSet type to benefit from the functionalities provided by the EnumerableSet library.
    */
    using EnumerableSet for EnumerableSet.UintSet;

    /**
    * @dev String Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are of type string.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => string) internal _string;

    /**
    * @dev Bytes Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are of type bytes.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => bytes) internal _bytes;

    /**
    * @dev Uint256 Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are of type uint256.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => uint256) internal _uint256;

    /**
    * @dev Int256 Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are of type int256.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => int256) internal _int256;

    /**
    * @dev Address Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are of type address.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => address) internal _address;

    /**
    * @dev Bool Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are of type bool.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => bool) internal _bool;

    /**
    * @dev Bytes32 Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are of type bytes32.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => bytes32) internal _bytes32;

    /**
    * @dev String Array Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are arrays of strings.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => string[]) internal _stringArray;

    /**
    * @dev Bytes Array Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are arrays of bytes.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => bytes[]) internal _bytesArray;
    
    /**
    * @dev Uint256 Array Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are arrays of uint256.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => uint256[]) internal _uint256Array;

    /**
    * @dev Int256 Array Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are arrays of int256.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => int256[]) internal _int256Array;

    /**
    * @dev Address Array Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are arrays of addresses.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => address[]) internal _addressArray;

    /**
    * @dev Bool Array Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are arrays of bools.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => bool[]) internal _boolArray;

    /**
    * @dev Bytes32 Array Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are arrays of bytes32.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => bytes32[]) internal _bytes32Array;

    /**
    * @dev BitMap Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are instances of the BitMaps.BitMap type.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => BitMaps.BitMap) internal _bitmap;

    /**
    * @dev Trace224 Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are instances of the Checkpoints.Trace224 type.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => Checkpoints.Trace224) internal _trace224;

    /**
    * @dev Bytes32Deque Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are instances of the DoubleEndedQueue.Bytes32Deque type.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => DoubleEndedQueue.Bytes32Deque) internal _bytes32Deque;

    /**
    * @dev Bytes32ToBytes32Map Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are instances of the EnumerableMap.Bytes32ToBytes32Map type.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => EnumerableMap.Bytes32ToBytes32Map) internal _bytes32ToBytes32Map;

    /**
    * @dev UintToUintMap Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are instances of the EnumerableMap.UintToUintMap type.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => EnumerableMap.UintToUintMap) internal _uintToUintMap;

    /**
    * @dev UintToAddressMap Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are instances of the EnumerableMap.UintToAddressMap type.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => EnumerableMap.UintToAddressMap) internal _uintToAddressMap;

    /**
    * @dev AddressToUintMap Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are instances of the EnumerableMap.AddressToUintMap type.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => EnumerableMap.AddressToUintMap) internal _addressToUintMap;

    /**
    * @dev Bytes32ToUintMap Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are instances of the EnumerableMap.Bytes32ToUintMap type.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => EnumerableMap.Bytes32ToUintMap) internal _bytes32ToUintMap;

    /**
    * @dev AddressSet Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are instances of the EnumerableSet.AddressSet type.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => EnumerableSet.AddressSet) internal _addressSet;

    /**
    * @dev Bytes32Set Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are instances of the EnumerableSet.Bytes32Set type.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => EnumerableSet.Bytes32Set) internal _bytes32Set;

    /**
    * @dev UintSet Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are instances of the EnumerableSet.UintSet type.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => EnumerableSet.UintSet) internal _uintSet;
}