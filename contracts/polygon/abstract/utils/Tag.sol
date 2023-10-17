// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";

/**
* captionKey => string
* messageKey => string
* creatorKey => address
 */
abstract contract Tag is Storage {

    /**
    * @dev Returns the key for storing the caption in storage.
    */
    function captionKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("CAPTION"));
    }

    /**
    * @dev Returns the key for storing the message in storage.
    */
    function messageKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MESSAGE"));
    }

    /**
    * @dev Returns the key for storing the creator in storage.
    */
    function creatorKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("CREATOR"));
    }

    /**
    * @dev Returns the caption associated with the proposal.
    */
    function caption() public view virtual returns (string memory) {
        return _string[captionKey()];
    }

    /**
    * @dev Returns the message associated with the proposal.
    */
    function message() public view virtual returns (string memory) {
        return _string[messageKey()];
    }

    /**
    * @dev Returns the address of the creator of the proposal.
    */
    function creator() public view virtual returns (address) {
        return _address[creatorKey()];
    }

    /**
    * @dev Sets the caption of the proposal.
    * @param caption The new caption to be set.
    */
    function _setCaption(string memory caption) internal virtual {
        _string[captionKey()] = caption;
    }

    /**
    * @dev Sets the message of the proposal.
    * @param message The new message to be set.
    */
    function _setMessage(string memory message) internal virtual {
        _string[messageKey()] = message;
    }

    /**
    * @dev Sets the creator of the proposal.
    * @param account The address of the new creator.
    */
    function _setCreator(address account) internal virtual {
        _address[creatorKey()] = account;
    }
}