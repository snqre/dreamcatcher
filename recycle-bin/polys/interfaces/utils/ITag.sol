// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ITag {

    /**
    * @dev Returns the key for storing the caption in storage.
    */
    function captionKey() external pure returns (bytes32);

    /**
    * @dev Returns the key for storing the message in storage.
    */
    function messageKey() external pure returns (bytes32);

    /**
    * @dev Returns the key for storing the creator in storage.
    */
    function creatorKey() external pure returns (bytes32);

    /**
    * @dev Returns the caption associated with the proposal.
    */
    function caption() external view returns (string memory);

    /**
    * @dev Returns the message associated with the proposal.
    */
    function message() external view returns (string memory);

    /**
    * @dev Returns the address of the creator of the proposal.
    */
    function creator() external view returns (address);
}