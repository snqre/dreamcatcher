// SPDX-License-Identifier: MIT

/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.19;

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




/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.19;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}




/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.19;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v5.0._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v5.0._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v5.0._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v5.0._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v5.0._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}




/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableMap.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableMap.js.

pragma solidity ^0.8.19;

////import "./EnumerableSet.sol";

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
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Bytes32ToBytes32Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToBytes32Map storage map, bytes32 key, bytes32 value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToBytes32Map storage map, bytes32 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Bytes32ToBytes32Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToBytes32Map storage map) internal view returns (bytes32[] memory) {
        return map._keys.values();
    }

    // UintToUintMap

    struct UintToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToUintMap storage map, uint256 key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToUintMap storage map, uint256 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key)));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToUintMap storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToAddressMap storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressToUintMap

    struct AddressToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(AddressToUintMap storage map, address key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressToUintMap storage map, uint256 index) internal view returns (address, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (address(uint160(uint256(key))), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(AddressToUintMap storage map) internal view returns (address[] memory) {
        bytes32[] memory store = keys(map._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // Bytes32ToUintMap

    struct Bytes32ToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToUintMap storage map, bytes32 key, uint256 value) internal returns (bool) {
        return set(map._inner, key, bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToUintMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToUintMap storage map, uint256 index) internal view returns (bytes32, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (key, uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, key);
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToUintMap storage map, bytes32 key) internal view returns (uint256) {
        return uint256(get(map._inner, key));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToUintMap storage map) internal view returns (bytes32[] memory) {
        bytes32[] memory store = keys(map._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}




/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/DoubleEndedQueue.sol)
pragma solidity ^0.8.19;

////import "../math/SafeCast.sol";

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
library DoubleEndedQueue {
    /**
     * @dev An operation (e.g. {front}) couldn't be completed due to the queue being empty.
     */
    error Empty();

    /**
     * @dev An operation (e.g. {at}) couldn't be completed due to an index being out of bounds.
     */
    error OutOfBounds();

    /**
     * @dev Indices are signed integers because the queue can grow in any direction. They are 128 bits so begin and end
     * are packed in a single storage slot for efficient access. Since the items are added one at a time we can safely
     * assume that these 128-bit indices will not overflow, and use unchecked arithmetic.
     *
     * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
     * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
     * lead to unexpected behavior.
     *
     * Indices are in the range [begin, end) which means the first item is at data[begin] and the last item is at
     * data[end - 1].
     */
    struct Bytes32Deque {
        int128 _begin;
        int128 _end;
        mapping(int128 => bytes32) _data;
    }

    /**
     * @dev Inserts an item at the end of the queue.
     */
    function pushBack(Bytes32Deque storage deque, bytes32 value) internal {
        int128 backIndex = deque._end;
        deque._data[backIndex] = value;
        unchecked {
            deque._end = backIndex + 1;
        }
    }

    /**
     * @dev Removes the item at the end of the queue and returns it.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function popBack(Bytes32Deque storage deque) internal returns (bytes32 value) {
        if (empty(deque)) revert Empty();
        int128 backIndex;
        unchecked {
            backIndex = deque._end - 1;
        }
        value = deque._data[backIndex];
        delete deque._data[backIndex];
        deque._end = backIndex;
    }

    /**
     * @dev Inserts an item at the beginning of the queue.
     */
    function pushFront(Bytes32Deque storage deque, bytes32 value) internal {
        int128 frontIndex;
        unchecked {
            frontIndex = deque._begin - 1;
        }
        deque._data[frontIndex] = value;
        deque._begin = frontIndex;
    }

    /**
     * @dev Removes the item at the beginning of the queue and returns it.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function popFront(Bytes32Deque storage deque) internal returns (bytes32 value) {
        if (empty(deque)) revert Empty();
        int128 frontIndex = deque._begin;
        value = deque._data[frontIndex];
        delete deque._data[frontIndex];
        unchecked {
            deque._begin = frontIndex + 1;
        }
    }

    /**
     * @dev Returns the item at the beginning of the queue.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function front(Bytes32Deque storage deque) internal view returns (bytes32 value) {
        if (empty(deque)) revert Empty();
        int128 frontIndex = deque._begin;
        return deque._data[frontIndex];
    }

    /**
     * @dev Returns the item at the end of the queue.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function back(Bytes32Deque storage deque) internal view returns (bytes32 value) {
        if (empty(deque)) revert Empty();
        int128 backIndex;
        unchecked {
            backIndex = deque._end - 1;
        }
        return deque._data[backIndex];
    }

    /**
     * @dev Return the item at a position in the queue given by `index`, with the first item at 0 and last item at
     * `length(deque) - 1`.
     *
     * Reverts with `OutOfBounds` if the index is out of bounds.
     */
    function at(Bytes32Deque storage deque, uint256 index) internal view returns (bytes32 value) {
        // int256(deque._begin) is a safe upcast
        int128 idx = SafeCast.toInt128(int256(deque._begin) + SafeCast.toInt256(index));
        if (idx >= deque._end) revert OutOfBounds();
        return deque._data[idx];
    }

    /**
     * @dev Resets the queue back to being empty.
     *
     * NOTE: The current items are left behind in storage. This does not affect the functioning of the queue, but misses
     * out on potential gas refunds.
     */
    function clear(Bytes32Deque storage deque) internal {
        deque._begin = 0;
        deque._end = 0;
    }

    /**
     * @dev Returns the number of items in the queue.
     */
    function length(Bytes32Deque storage deque) internal view returns (uint256) {
        // The interface preserves the invariant that begin <= end so we assume this will not overflow.
        // We also assume there are at most int256.max items in the queue.
        unchecked {
            return uint256(int256(deque._end) - int256(deque._begin));
        }
    }

    /**
     * @dev Returns true if the queue is empty.
     */
    function empty(Bytes32Deque storage deque) internal view returns (bool) {
        return deque._end <= deque._begin;
    }
}




/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/Checkpoints.sol)
// This file was procedurally generated from scripts/generate/templates/Checkpoints.js.

pragma solidity ^0.8.19;

////import "../math/Math.sol";
////import "../math/SafeCast.sol";

/**
 * @dev This library defines the `History` struct, for checkpointing values as they change at different points in
 * time, and later looking up past values by block number. See {Votes} as an example.
 *
 * To create a history of checkpoints define a variable type `Checkpoints.History` in your contract, and store a new
 * checkpoint for the current transaction block using the {push} function.
 *
 * _Available since v4.5._
 */
library Checkpoints {
    struct Trace224 {
        Checkpoint224[] _checkpoints;
    }

    struct Checkpoint224 {
        uint32 _key;
        uint224 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace224 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     */
    function push(Trace224 storage self, uint32 key, uint224 value) internal returns (uint224, uint224) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the first (oldest) checkpoint with key greater or equal than the search key, or zero if there is none.
     */
    function lowerLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero if there is none.
     */
    function upperLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero if there is none.
     *
     * NOTE: This is a variant of {upperLookup} that is optimised to find "recent" checkpoint (checkpoints with high keys).
     */
    function upperLookupRecent(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace224 storage self) internal view returns (uint224) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace224 storage self) internal view returns (bool exists, uint32 _key, uint224 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint224 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace224 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Returns checkpoint at given position.
     */
    function at(Trace224 storage self, uint32 pos) internal view returns (Checkpoint224 memory) {
        return self._checkpoints[pos];
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(Checkpoint224[] storage self, uint32 key, uint224 value) private returns (uint224, uint224) {
        uint256 pos = self.length;

        if (pos > 0) {
            // Copying to memory is ////important here.
            Checkpoint224 memory last = _unsafeAccess(self, pos - 1);

            // Checkpoint keys must be non-decreasing.
            require(last._key <= key, "Checkpoint: decreasing keys");

            // Update or push new checkpoint
            if (last._key == key) {
                _unsafeAccess(self, pos - 1)._value = value;
            } else {
                self.push(Checkpoint224({_key: key, _value: value}));
            }
            return (last._value, value);
        } else {
            self.push(Checkpoint224({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the last (most recent) checkpoint with key lower or equal than the search key, or `high` if there is none.
     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key is greater or equal than the search key, or `high` if there is none.
     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    /**
     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.
     */
    function _unsafeAccess(
        Checkpoint224[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint224 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }

    struct Trace160 {
        Checkpoint160[] _checkpoints;
    }

    struct Checkpoint160 {
        uint96 _key;
        uint160 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace160 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     */
    function push(Trace160 storage self, uint96 key, uint160 value) internal returns (uint160, uint160) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the first (oldest) checkpoint with key greater or equal than the search key, or zero if there is none.
     */
    function lowerLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero if there is none.
     */
    function upperLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero if there is none.
     *
     * NOTE: This is a variant of {upperLookup} that is optimised to find "recent" checkpoint (checkpoints with high keys).
     */
    function upperLookupRecent(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace160 storage self) internal view returns (uint160) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace160 storage self) internal view returns (bool exists, uint96 _key, uint160 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint160 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace160 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Returns checkpoint at given position.
     */
    function at(Trace160 storage self, uint32 pos) internal view returns (Checkpoint160 memory) {
        return self._checkpoints[pos];
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(Checkpoint160[] storage self, uint96 key, uint160 value) private returns (uint160, uint160) {
        uint256 pos = self.length;

        if (pos > 0) {
            // Copying to memory is ////important here.
            Checkpoint160 memory last = _unsafeAccess(self, pos - 1);

            // Checkpoint keys must be non-decreasing.
            require(last._key <= key, "Checkpoint: decreasing keys");

            // Update or push new checkpoint
            if (last._key == key) {
                _unsafeAccess(self, pos - 1)._value = value;
            } else {
                self.push(Checkpoint160({_key: key, _value: value}));
            }
            return (last._value, value);
        } else {
            self.push(Checkpoint160({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the last (most recent) checkpoint with key lower or equal than the search key, or `high` if there is none.
     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key is greater or equal than the search key, or `high` if there is none.
     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    /**
     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.
     */
    function _unsafeAccess(
        Checkpoint160[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint160 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }
}




/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/BitMaps.sol)
pragma solidity ^0.8.19;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */
library BitMaps {
    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(BitMap storage bitmap, uint256 index, bool value) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}




/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;
////import "contracts/polygon/external/openzeppelin/utils/structs/BitMaps.sol";
////import "contracts/polygon/external/openzeppelin/utils/structs/Checkpoints.sol";
////import "contracts/polygon/external/openzeppelin/utils/structs/DoubleEndedQueue.sol";
////import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableMap.sol";
////import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

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
 * @dev The contract ////imports and utilizes OpenZeppelin libraries, including BitMaps, Checkpoints, DoubleEndedQueue,
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
    * @dev ////Importing and enabling the use of the EnumerableMap library for the Bytes32ToBytes32Map type.
    * @dev Allows the Bytes32ToBytes32Map type to benefit from the functionalities provided by the EnumerableMap library.
    */
    using EnumerableMap for EnumerableMap.Bytes32ToBytes32Map;

    /**
    * @dev ////Importing and enabling the use of the EnumerableMap library for the UintToUintMap type.
    * @dev Allows the UintToUintMap type to benefit from the functionalities provided by the EnumerableMap library.
    */
    using EnumerableMap for EnumerableMap.UintToUintMap;

    /**
    * @dev ////Importing and enabling the use of the EnumerableMap library for the UintToAddressMap type.
    * @dev Allows the UintToAddressMap type to benefit from the functionalities provided by the EnumerableMap library.
    */
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    /**
    * @dev ////Importing and enabling the use of the EnumerableMap library for the AddressToUintMap type.
    * @dev Allows the AddressToUintMap type to benefit from the functionalities provided by the EnumerableMap library.
    */
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    /**
    * @dev ////Importing and enabling the use of the EnumerableMap library for the Bytes32ToUintMap type.
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
    * @dev ////Importing and enabling the use of the EnumerableSet library for the AddressSet type.
    * @dev Allows the AddressSet type to benefit from the functionalities provided by the EnumerableSet library.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @dev ////Importing and enabling the use of the EnumerableSet library for the Bytes32Set type.
    * @dev Allows the Bytes32Set type to benefit from the functionalities provided by the EnumerableSet library.
    */
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /**
    * @dev ////Importing and enabling the use of the EnumerableSet library for the UintSet type.
    * @dev Allows the UintSet type to benefit from the functionalities provided by the EnumerableSet library.
    */
    using EnumerableSet for EnumerableSet.UintSet;

    /**
    * @dev Bytes Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are of type bytes.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => bytes) internal _bytes;

    /**
    * @dev String Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are of type string.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => string) internal _string;

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



/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.19;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}




/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;
////import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";
////import "contracts/polygon/abstract/storage/state/StateV1.sol";

/**
 * @title Proxy State V1
 * @dev Abstract contract combining state management and proxy functionality.
 * @dev Inherited from StateV1 for state-related features and Proxy for proxy behavior.
 */
abstract contract ProxyStateV1 is StateV1, Proxy {

    /**
    * @dev Upgraded Event
    * @dev Emitted when the contract undergoes an upgrade to a new implementation.
    *
    * This event is typically used in the context of proxy contracts to notify external observers
    * when the contract's implementation is upgraded to a new address. The `implementation` parameter
    * is indexed for efficient event filtering.
    *
    * @param implementation The address of the newly upgraded implementation contract.
    */
    event Upgraded(address indexed implementation);

    /**
    * @dev Implementation Address Is Zero Error
    * @dev Custom error indicating that the implementation address is set to zero during contract execution.
    *
    * This error is typically used in the context of proxy contracts to signal that the implementation address
    * is not set before attempting to delegate to the implementation contract. It helps developers identify and
    * handle scenarios where the implementation address is unexpectedly zero.
    */
    error ImplementationAddressIsZero();

    /**
    * @dev Fallback Function
    * @dev Executed when the contract receives Ether without a specific function call.
    * @dev Calls the _fallback() function, which can be overridden by inheriting contracts.
    *
    * This function allows the contract to handle incoming Ether transactions in a customizable way.
    * Developers can override the _fallback() function in their contracts to implement specific logic
    * when Ether is sent to the contract without a specific function call.
    *
    * @notice Ensure that inheriting contracts implement the _fallback() function as needed.
    */
    fallback() external payable virtual override {
        _fallback();
    }

    /**
    * @dev Receive Function
    * @dev Automatically called when the contract receives Ether.
    * @dev Calls the _fallback() function, which can be overridden by inheriting contracts.
    *
    * This function is invoked when the contract receives Ether, providing a way to handle incoming transactions.
    * Developers can customize the behavior by implementing the _fallback() function in their contracts.
    *
    * @notice Ensure that inheriting contracts implement the _fallback() function as needed.
    */
    receive() external payable virtual override {
        _fallback();
    }

    /**
    * @dev Implementation Key Function
    * @dev Generates a unique key for identifying the implementation contract.
    *
    * This function returns the keccak256 hash of the string "IMPLEMENTATION", providing a unique identifier
    * (key) commonly used in the context of proxy contracts to associate an implementation contract with a key.
    *
    * @return A bytes32 key representing the implementation contract.
    */
    function implementationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("IMPLEMENTATION"));
    }

    /**
    * @dev Implementation Function
    * @dev Retrieves the address of the current implementation contract.
    * @dev Calls the _implementation() function, which can be overridden by inheriting contracts.
    *
    * This function is often used in the context of proxy contracts to obtain the address of the underlying
    * implementation contract. Developers can override the _implementation() function in their contracts to
    * dynamically specify the implementation address.
    *
    * @return The address of the current implementation contract.
    */
    function implementation() public view virtual returns (address) {
        return _implementation();
    }

    /**
    * @dev Implementation Address Retrieval
    * @dev Retrieves the address of the current implementation contract.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This function is often used in the context of proxy contracts to obtain the address of the underlying
    * implementation contract. Developers can override this function in their contracts to dynamically specify
    * the implementation address.
    *
    * @return The address of the current implementation contract.
    */
    function _implementation() internal view virtual override returns (address) {
        return _address[implementationKey()];
    }

    /**
    * @dev Internal virtual function to perform the initial upgrade of the contract to the provided implementation.
    * @param implementation The address of the new implementation contract.
    */
    function _initialize(address implementation) internal virtual {
        _upgrade(implementation);
    }

    /**
    * @dev Upgrade Function
    * @dev Updates the implementation address and emits an Upgraded event.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This function is typically used in the context of proxy contracts to upgrade the implementation address.
    * It updates the `_address` mapping with the new implementation using the generated key from `implementationKey()`.
    * Developers can override this function in their contracts to implement custom upgrade logic.
    *
    * @param implementation The new address of the upgraded implementation contract.
    */
    function _upgrade(address implementation) internal  virtual {
        _address[implementationKey()] = implementation;
        emit Upgraded(implementation);
    }

    /**
    * @dev Delegate Function
    * @dev Delegates to the specified implementation address using the parent contract's _delegate function.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This function is often used in the context of proxy contracts to delegate to a specific implementation.
    * It internally calls the _delegate function from the parent contract, providing a way to customize delegation logic
    * in inheriting contracts.
    *
    * @param implementation The address of the implementation contract to which the delegation occurs.
    */
    function _delegate(address implementation) internal virtual override {
        super._delegate(implementation);
    }

    /**
    * @dev Fallback Function Override
    * @dev Customizes the behavior of the fallback function and ensures the implementation address is not zero.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This function is typically used in the context of proxy contracts to customize the behavior of the fallback function.
    * It checks whether the implementation address is set and reverts if it's zero. If the check passes, it delegates to
    * the parent contract's fallback logic using super._fallback().
    *
    * @notice Ensure that the implementation address is set before calling this function to avoid reversion.
    * @notice Developers can override this function in their contracts to implement custom fallback logic.
    */
    function _fallback() internal virtual override {
        if (implementation() == address(0)) {
            revert ImplementationAddressIsZero();
        }
        super._fallback();
    }

    /**
    * @dev Before Fallback Hook
    * @dev Executes logic before the fallback function is delegated to the implementation contract.
    * @dev Internal function that can be overridden by inheriting contracts.
    *
    * This hook is designed for customization in the context of proxy contracts. It allows developers to
    * execute additional logic before the fallback function is delegated to the implementation contract.
    *
    * @notice Developers can override this function in their contracts to implement custom logic
    * that should be executed before the fallback function.
    */
    function _beforeFallback() internal virtual override {
        super._beforeFallback();
    }
}



/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.9;
////import "contracts/polygon/abstract/storage/state/StateV1.sol";
////import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

/**
 * @title RoleStateV1
 * @dev Abstract contract for managing roles with state on the Polygon network.
 * @notice This contract provides functionalities for role management, including role granting, revocation, and role admin assignment.
 * @notice It utilizes the EnumerableSet library to manage sets of addresses efficiently.
 * @dev Roles are identified by unique keys, and each role has an associated admin role.
 * @dev The DEFAULT_ADMIN_ROLE has the highest privileges and is typically set during contract initialization.
 * @dev Admin roles can be changed, and additional roles can be created to grant specific permissions.
 * @dev The contract emits events for role admin changes, role granting, and role revocation.
 * @dev It also includes error codes for unauthorized access, existing role assignment, missing role, and attempts to set an existing role admin.
 */
abstract contract RoleStateV1 is StateV1 {

    /**
    * @dev ////Importing the EnumerableSet library for managing sets of addresses.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @dev ////Importing the EnumerableSet library for managing sets of bytes32 values.
    */
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /**
    * @dev Emitted when the admin role of a role is changed.
    * @param role The role for which the admin role is changed.
    * @param previousAdminRole The previous admin role of the specified role.
    * @param newAdminRole The new admin role assigned to the specified role.
    */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
    * @dev Emitted when an account is granted a role.
    * @param role The role that is granted.
    * @param account The address that is granted the role.
    * @param sender The address initiating the role grant.
    */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
    * @dev Emitted when an account has a role revoked.
    * @param role The role that is revoked.
    * @param account The address that has the role revoked.
    * @param sender The address initiating the role revocation.
    */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
    * @dev Reverts with "Unauthorized" error if an account lacks the required role.
    * @param account The address that lacks the required role.
    * @param roleRequired The required role that is missing.
    */
    error Unauthorized(address account, bytes32 roleRequired);

    /**
    * @dev Reverts with "AlreadyHasRole" error if an account already has the specified role.
    * @param account The address that already has the role.
    * @param role The role that the account already has.
    */
    error AlreadyHasRole(address account, bytes32 role);

    /**
    * @dev Reverts with "DoesNotHaveRoleYet" error if an account does not have the specified role yet.
    * @param account The address that does not have the role yet.
    * @param role The role that the account does not have yet.
    */
    error DoesNotHaveRoleYet(address account, bytes32 role);

    /**
    * @dev Reverts with "AlreadyRoleAdmin" error if the specified role already has the provided role admin.
    * @param role The role that already has the specified role admin.
    * @param roleAdmin The role admin that the role already has.
    */
    error AlreadyRoleAdmin(bytes32 role, bytes32 roleAdmin);

    /**
    * @dev Reverts with "IsNotRoleAdmin" error if the sender lacks the required role admin privilege.
    * @dev If the sender does not have the DEFAULT_ADMIN_ROLE, it checks if the sender has the role admin privilege.
    * @dev If the sender does not have the role admin privilege, it reverts with the IsNotRoleAdmin error.
    */
    error IsNotRoleAdmin();

    /**
    * @dev Public pure function to compute the keccak256 hash of a given string.
    * @param dat The input string to hash.
    * @return bytes32 representing the keccak256 hash of the input string.
    */
    function hash(string memory dat) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(dat));
    }

    /**
    * @dev Public pure function to generate a unique key for the set of available roles.
    * @return bytes32 representing the unique key for the set of available roles.
    */
    function rolesKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("ROLES"));
    }

    /**
    * @dev Public pure function to generate a unique key for a role in the context of storing members.
    * @param role The role for which to generate the key.
    * @return bytes32 representing the unique key for the specified role in the context of storing members.
    */
    function roleKey(bytes32 role) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(role, "MEMBERS"));
    }

    /**
    * @dev Public pure function to generate a unique key for the role admin of a specified role.
    * @param role The role for which to generate the role admin key.
    * @return bytes32 representing the unique key for the role admin of the specified role.
    */
    function roleAdminKey(bytes32 role) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(role, "ROLE_ADMIN"));
    }

    /**
    * @dev Public pure virtual function to generate a unique key for the default admin role.
    * @return bytes32 representing the unique key for the default admin role.
    * @dev This function must be implemented in derived contracts to provide the default admin role key.
    */
    function defaultAdminRoleKey() public pure virtual returns (bytes32) {
        return 0xb4dd7b07910623c7c742febfbc4566bdec285f874faa2742c472acd10e26be29;
    }

    /**
    * @dev Public view function to check if an account has a specified role.
    * @param role The role for which to check.
    * @param account The address of the account to check for the specified role.
    * @return bool indicating whether the account has the specified role.
    */
    function hasRole(bytes32 role, address account) public view  virtual returns (bool) {
        return _addressSet[roleKey(role)].contains(account);
    }

    /**
    * @dev Public view function to retrieve the list of members for a specified role.
    * @param role The role for which to retrieve the members.
    * @return address[] memory representing the array of addresses that have the specified role.
    * @dev This function returns the addresses that have the specified role in the order they were added.
    */
    function members(bytes32 role, uint256 id) public view virtual returns (address) {
        return _addressSet[roleKey(role)].at(id);
    }

    /**
    * @dev Public view virtual function to retrieve the number of members in a role.
    * @param role The role for which to retrieve the number of members.
    * @return uint256 representing the number of members in the specified role.
    */
    function membersLength(bytes32 role) public view virtual returns (uint256) {
        return _addressSet[roleKey(role)].length();
    }

    /**
    * @dev Public view function to retrieve the list of roles available.
    * @return bytes32[] memory representing the array of roles.
    * @dev This function returns the roles in the order they were added.
    */
    function roles(uint256 id) public view virtual returns (bytes32) {
        return _bytes32Set[rolesKey()].at(id);
    }

    /**
    * @dev Public view virtual function to retrieve the number of roles.
    * @return uint256 representing the number of roles.
    */
    function rolesLength() public view virtual returns (uint256) {
        return _bytes32Set[rolesKey()].length();
    }

    /**
    * @dev Public function to require that the calling account has a specified role.
    * @param role The role that the account must have.
    * @param account The address of the account to check for the specified role.
    * @dev If the account does not have the required role, it reverts with the "Unauthorized" error.
    */
    function requireRole(bytes32 role, address account) public view virtual {
        if (!hasRole(defaultAdminRoleKey(), msg.sender)) {
            if (!hasRole(role, account)) {
                revert Unauthorized(account, role);
            }
        }
    }

    /**
    * @dev Public view function to retrieve the admin role for a specified role.
    * @param role The role for which to retrieve the admin role.
    * @return bytes32 representing the admin role for the specified role.
    */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _bytes32[roleAdminKey(role)];
    }

    /**
    * @dev Public function to grant a role to a specified account.
    * @param role The role to be granted.
    * @param account The address of the account to which the role will be granted.
    * @dev This function can only be called by a role admin.
    * @dev It grants the specified role to the specified account and emits the RoleGranted event.
    */
    function grantRole(bytes32 role, address account) public virtual {
        _onlyRoleAdmin(role);
        _grantRole(role, account);
    }

    /**
    * @dev Public function to revoke a role from a specified account.
    * @param role The role to be revoked.
    * @param account The address of the account from which the role will be revoked.
    * @dev This function can only be called by a role admin.
    * @dev It revokes the specified role from the specified account and emits the RoleRevoked event.
    */
    function revokeRole(bytes32 role, address account) public virtual {
        _onlyRoleAdmin(role);
        _revokeRole(role, account);
    }

    /**
    * @dev Public function to set a new role admin for a specified role.
    * @param role The role for which the admin is being set.
    * @param newRoleAdmin The new role admin address.
    * @dev This function can only be called by the default admin role.
    * @dev It sets the new role admin and emits the RoleAdminChanged event.
    */
    function setRoleAdmin(bytes32 role, bytes32 newRoleAdmin) public virtual {
        _onlyDefaultAdminRole();
        _setRoleAdmin(role, newRoleAdmin);
    }

    /**
    * @dev Internal view function to check if the sender has the role admin privilege.
    * @param role The role for which the admin privilege is being checked.
    * @dev If the sender does not have the DEFAULT_ADMIN_ROLE, it checks if the sender has the role admin privilege.
    * @dev If the sender does not have the role admin privilege, it reverts with the IsNotRoleAdmin error.
    */
    function _onlyRoleAdmin(bytes32 role) internal view virtual {
        if (!hasRole(defaultAdminRoleKey(), msg.sender)) {
            if (!hasRole(getRoleAdmin(role), msg.sender)) {
                revert IsNotRoleAdmin();
            }
        }
    }

    /**
    * @dev Internal view function to check if the sender has the DEFAULT_ADMIN_ROLE.
    * @dev If the sender does not have the DEFAULT_ADMIN_ROLE, it reverts with the Unauthorized error.
    */
    function _onlyDefaultAdminRole() internal view virtual {
        if (!hasRole(defaultAdminRoleKey(), msg.sender)) {
            revert Unauthorized(msg.sender, roleKey(hash("DEFAULT_ADMIN_ROLE")));
        }
    }

    /**
    * @dev Internal virtual function to grant DEFAULT_ADMIN_ROLE to the contract deployer during initialization.
    0xb4dd7b07910623c7c742febfbc4566bdec285f874faa2742c472acd10e26be29
    */
    function _initialize() internal virtual {
        _grantRole(roleKey(hash("DEFAULT_ADMIN_ROLE")), msg.sender);
    }

    /**
    * @dev Internal function to set a new role admin for the given role.
    * @param role The role for which to set a new admin.
    * @param newRoleAdmin The address of the new admin for the role.
    * @dev This function checks if the new admin is the same as the current one and reverts if so.
    * @dev It updates the role admin in storage and emits the `RoleAdminChanged` event.
    */
    function _setRoleAdmin(bytes32 role, bytes32 newRoleAdmin) internal virtual {
        if (getRoleAdmin(role) == newRoleAdmin) {
            revert AlreadyRoleAdmin(role, newRoleAdmin);
        }
        bytes32 previousAdminRole = _bytes32[roleAdminKey(role)];
        _bytes32[roleAdminKey(role)] = newRoleAdmin;
        emit RoleAdminChanged(role, previousAdminRole, newRoleAdmin);
    }

    /**
    * @dev Internal function to grant a role to an account.
    * @param role The role to grant.
    * @param account The address to grant the role to.
    * @dev This function checks if the account already has the role and reverts if so.
    * @dev It adds the account to the role set in storage and emits the `RoleGranted` event.
    */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) { revert AlreadyHasRole(account, role); }
        _addressSet[roleKey(role)].add(account);
        _addRole(role);
        emit RoleGranted(role, account, msg.sender);
    }

    /**
    * @dev Internal function to revoke a role from an account.
    * @param role The role to revoke.
    * @param account The address to revoke the role from.
    * @dev This function checks if the account already has the role and reverts if not.
    * @dev It removes the account from the role set in storage and emits the `RoleRevoked` event.
    */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) { revert DoesNotHaveRoleYet(account, role); }
        _addressSet[roleKey(role)].remove(account);
        _subRole(role);
        emit RoleRevoked(role, account, msg.sender);
    }

    /**
    * @dev Internal function to add a new role to the list of available roles.
    * @param role The role to be added.
    * @dev This function checks if the role has at least one member and adds it to the roles set.
    */
    function _addRole(bytes32 role) internal virtual {
        if (membersLength(role) >= 1) {
            _bytes32Set[rolesKey()].add(role);
        }
    }

    /**
    * @dev Internal function to remove a role from the list of available roles.
    * @param role The role to be removed.
    * @dev This function checks if the role has no members and removes it from the roles set.
    */
    function _subRole(bytes32 role) internal virtual {
        if (membersLength(role) == 0) {
            _bytes32Set[rolesKey()].remove(role);
        }
    }
}



/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;
////import "contracts/polygon/abstract/proxy/proxy-state/ProxyStateV1.sol";

/**
 * @dev Abstract contract for managing upgrade history in a proxy contract.
 * @dev This contract extends `ProxyStateV1` and provides functions for managing upgrade history.
 */
abstract contract ProxyStateHistoryV1 is ProxyStateV1 {

    /**
    * @dev Public pure virtual function to generate a unique key for storing history information.
    * @return bytes32 representing the unique key for history information.
    * @dev This function must be implemented in derived contracts to provide a unique key for history storage.
    */
    function historyKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("HISTORY"));
    }

    /**
    * @dev Public view virtual function to retrieve an array of implementation addresses from history.
    * @return address representing the array of implementation addresses.
    * @dev This function must be implemented in derived contracts to provide the history of implementation addresses.
    */
    function implementations(uint256 id) public view virtual returns (address) {
        return _addressArray[historyKey()][id];
    }

    /**
    * @dev Public view virtual function to retrieve the number of implementations in the upgrade history.
    * @return uint256 representing the length of the array of implementation addresses in history.
    * @dev This function returns the length of the array of implementation addresses in history.
    */
    function implementationsLength() public view virtual returns (uint256) {
        return _addressArray[historyKey()].length;
    }

    /**
    * @dev Internal virtual function to log an upgrade by adding the new implementation address to history.
    * @param implementation The address of the new implementation to be logged.
    * @dev This function must be implemented in derived contracts to log upgrades in history.
    */
    function _logUpgrade(address implementation) internal virtual {
        _addressArray[historyKey()].push(implementation);
    }

    /**
    * @dev Internal virtual function to upgrade the contract to a new implementation.
    * @param implementation The address of the new implementation to upgrade to.
    * @dev This function overrides the parent implementation and ensures that the base contract is upgraded.
    * @dev After upgrading the base contract, it logs the upgrade in history using the `_logUpgrade` function.
    */
    function _upgrade(address implementation) internal virtual override {
        super._upgrade(implementation);
        _logUpgrade(implementation);
    }
}



/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;
////import "contracts/polygon/abstract/proxy/proxy-state/ProxyStateV1.sol";

/**
 * @title ProxyStateRouterV1
 * @dev Abstract contract for a stateful proxy with routing capabilities.
 * @dev It extends ProxyStateV1 and allows setting different implementations for specific senders.
 */
abstract contract ProxyStateRouterV1 is ProxyStateV1 {

    /**
    * @dev Emitted when the route for a sender is set to a specific implementation.
    * @param sender The address for which the route is set.
    * @param implementation The address of the implementation to which the route is set.
    */
    event SenderRouteSetTo(address indexed sender, address implementation);

    /**
    * @dev Error indicating that the route for a sender is already set to a specific implementation.
    * @param sender The address for which the route is already set.
    * @param implementation The address of the implementation to which the route is already set.
    */
    error SenderRouteAlreadySetTo(address sender, address implementation);

    /**
    * @dev Public pure function to generate a unique key for routing information associated with a sender.
    * @param sender The address of the sender for which to generate the route key.
    * @return bytes32 representing the unique key for the routing information of the specified sender.
    * @dev The function uses keccak256 hashing to create a unique key based on the sender's address and the "ROUTE" identifier.
    */
    function routeKey(address sender) public pure returns (bytes32) {
        return keccak256(abi.encode(sender, "ROUTE"));
    }

    /**
    * @dev Public view function to retrieve the routing information for a specified sender.
    * @param sender The address of the sender for which to retrieve the route.
    * @return address representing the routing information for the specified sender.
    * @dev The function looks up the routing information stored in the contract state using the generated route key.
    */
    function route(address sender) public view returns (address) {
        return _address[routeKey(sender)];
    }

    /**
    * @dev Internal virtual function to initialize the contract with a specific implementation.
    * @param implementation The address of the implementation to set as the current implementation.
    * @dev This function overrides the parent implementation and ensures that the base contract is also initialized.
    */
    function _initialize(address implementation) internal virtual override {
        super._initialize(implementation);
    }

    /**
    * @dev Internal virtual function to set the implementation address for a specific sender.
    * @param sender The address of the sender for which to set the implementation.
    * @param implementation The address of the implementation to set for the specified sender.
    * @dev It checks if the current implementation is already set to the provided one and reverts if so.
    * @dev It updates the implementation address in storage and emits the `SenderRouteSetTo` event.
    */
    function _setRoute(address sender, address implementation) internal virtual {
        if (route(sender) == implementation) {
            revert SenderRouteAlreadySetTo(sender, implementation);
        }
        _address[routeKey(sender)] = implementation;
        emit SenderRouteSetTo(sender, implementation);
    }

    /**
    * @dev Internal virtual function to handle the fallback function.
    * @dev If the sender has a specific route set, it delegates the call to that implementation.
    * @dev Otherwise, it calls the fallback function of the parent contract.
    */
    function _fallback() internal virtual override {
        if (route(msg.sender) != address(0)) {
            _delegate(route(msg.sender));
        }
        else {
            super._fallback();
        }
    }
}



/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;
////import "contracts/polygon/abstract/proxy/proxy-state-router/ProxyStateRouterV1.sol";
////import "contracts/polygon/abstract/proxy/proxy-state-history/ProxyStateHistoryV1.sol";
////import "contracts/polygon/abstract/access-control/role-state/RoleStateV1.sol";

/**
 * @dev Abstract contract combining functionality from ProxyStateRouterV1, ProxyStateHistoryV1, and RoleStateV1.
 */
abstract contract ProxyStateBaseV1 is ProxyStateRouterV1, ProxyStateHistoryV1, RoleStateV1 {

    /**
    * @dev Error indicating that the contract has already been initialized.
    */
    error AlreadyInitialized();

    /**
    * @dev Error indicating that the contract has not been initialized yet.
    */
    error HasNotBeenInitializedYet();

    /**
    * @dev Public pure virtual function to generate a unique key for tracking initialization status.
    * @return bytes32 representing the unique key for tracking initialization status.
    * @dev This function must be implemented in derived contracts to provide a unique key for initialization status.
    */
    function initializedKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("INITIALIZED"));
    }

    /**
    * @dev Public view virtual function to check if the contract has been initialized.
    * @return bool indicating whether the contract has been initialized.
    * @dev This function must be implemented in derived contracts to provide the initialization status.
    */
    function initialized() public view virtual returns (bool) {
        return _bool[initializedKey()];
    }

    /**
    * @dev Public function to initialize the contract.
    * @dev It can only be called once, ensuring that the contract has not been initialized before.
    */
    function initialize(address implementation) public virtual {
        _onlynotInitialized();
        _initialize(implementation);
    }

    /**
    * @dev Public function to set the implementation route for a specific sender.
    * @param sender The address of the sender for which to set the route.
    * @param implementation The address of the implementation to set for the specified sender.
    * @dev It requires the sender to have the "ROUTER_ROLE" and then sets the route using the internal function `_setRoute`.
    */
    function setRoute(address sender, address implementation) public virtual {
        requireRole(roleKey("ROUTER_ROLE"), msg.sender);
        _setRoute(sender, implementation);
    }

    /**
    * @dev Public function to upgrade the contract to a new implementation.
    * @param implementation The address of the new implementation to upgrade to.
    * @dev It requires the sender to have the "UPGRADER_ROLE" and then upgrades using the internal function `_upgrade`.
    */
    function upgrade(address implementation) public virtual {
        requireRole(roleKey(hash("UPGRADER_ROLE")), msg.sender);
        _upgrade(implementation);
    }

    /**
    * @dev Internal view function to check if the contract has not been initialized yet.
    * @dev If the contract has already been initialized, it reverts with the "AlreadyInitialized" error.
    */
    function _onlynotInitialized() internal view virtual {
        if (initialized()) {
            revert AlreadyInitialized();
        }
    }

    /**
    * @dev Internal virtual function to initialize the contract with a specific implementation.
    * @param implementation The address of the implementation to set as the current implementation.
    * @dev This function overrides the parent implementation and ensures that the base contracts are also initialized.
    */
    function _initialize(address implementation) internal virtual override(ProxyStateRouterV1, ProxyStateV1) {
        ProxyStateRouterV1._initialize(implementation);
        RoleStateV1._initialize();
        _bool[initializedKey()] = true;
    }

    /**
    * @dev Internal virtual function to upgrade the contract to a new implementation.
    * @param implementation The address of the new implementation to upgrade to.
    * @dev This function overrides the parent implementation and ensures that the base contract is upgraded.
    * @dev After upgrading the base contract, it logs the upgrade in history using the `_logUpgrade` function.
    */
    function _upgrade(address implementation) internal virtual override(ProxyStateHistoryV1, ProxyStateV1) {
        ProxyStateHistoryV1._upgrade(implementation);
    }

    /**
    * @dev Internal virtual function to handle the fallback function.
    * @dev If the sender has a specific route set, it delegates the call to that implementation.
    * @dev Otherwise, it calls the fallback function of the parent contract.
    */
    function _fallback() internal virtual override(ProxyStateRouterV1, ProxyStateV1) {}
}

/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\governor\governor-implementation\GovernorImplementationV1.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;
////import "contracts/polygon/abstract/proxy/proxy-state-base/ProxyStateBaseV1.sol";

contract GovernorImplementationV1 is ProxyStateBaseV1 {}
