// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title StateLite
 * @dev Abstract contract defining a bytes mapping for efficient storage of binary data.
 *
 * This contract includes a mapping where keys are of type bytes32 and values are of type bytes,
 * providing a convenient way to store and retrieve binary data associated with unique identifiers.
 *
 * @notice Developers extending this contract can use the _bytes mapping to efficiently manage and retrieve arbitrary byte data.
 */
abstract contract StorageLite {

    /**
    * @dev Bytes Mapping
    * @dev Represents a mapping where the keys are of type bytes32 and the values are of type bytes.
    * @dev Internal visibility to restrict access to the mapping within the current contract.
    */
    mapping(bytes32 => bytes) internal _bytes;
}