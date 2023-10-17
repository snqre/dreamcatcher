// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* targetKey => address
* dataKey => bytes
 */
interface IPayload {

    /**
    * @dev Returns the key for storing the target address.
    */
    function targetKey() external pure returns (bytes32);

    /**
    * @dev Returns the key for storing the data.
    */
    function dataKey() external pure returns (bytes32);

    /**
    * @dev Returns the current target address.
    */
    function target() external view returns (address);

    /**
    * @dev Returns the current data bytes.
    */
    function data() external view returns (bytes memory);
}