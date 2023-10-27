// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";

/**
* targetKey => address
* dataKey => bytes
 */
abstract contract Payload is Storage {

    /**
    * @dev Returns the key for storing the target address.
    */
    function targetKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("TARGET"));
    }

    /**
    * @dev Returns the key for storing the data.
    */
    function dataKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DATA"));
    }

    /**
    * @dev Returns the current target address.
    */
    function target() public view virtual returns (address) {
        return _address[targetKey()];
    }

    /**
    * @dev Returns the current data bytes.
    */
    function data() public view virtual returns (bytes memory) {
        return _bytes[dataKey()];
    }

    /**
    * @dev Sets the target address.
    */
    function _setTarget(address account) internal virtual {
        _address[targetKey()] = account;
    }

    /**
    * @dev Sets the data.
    */
    function _setData(bytes memory data) internal virtual {
        _bytes[dataKey()] = data;
    }
}