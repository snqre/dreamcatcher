// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

/** @dev Store target, data, and last response for low level call exection. */
abstract contract PayloadLite is StorageLite {

    event TargetUpdated(address indexed previousTarget, address indexed newTarget);

    event DataUpdated(bytes indexed previousData, bytes indexed newData);

    event LastResponseUpdated(bytes indexed previousResponse, bytes indexed newResponse);

    function target() public view virtual returns (address) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____target()]) == keccak256(emptyBytes)) {
            return address(0);
        }
        return abi.decode(_bytes[____target()], (address));
    }

    function data() public view virtual returns (bytes memory) {
        return _bytes[____data()];
    }

    function lastResponse() public view virtual returns (bytes memory) {
        return _bytes[____lastResponse()];
    }

    function ____target() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("TARGET"));
    }

    function ____data() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("DATA"));
    }

    function ____lastResponse() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("LAST_RESPONSE"));
    }

    function _setTarget(address newTarget) internal virtual {
        address previousTarget = target();
        _bytes[____target()] = abi.encode(newTarget);
        emit TargetUpdated(previousTarget, newTarget);
    }

    function _setData(bytes memory newData) internal virtual {
        bytes memory previousData = data();
        _bytes[____data()] = newData;
        emit DataUpdated(previousData, newData);
    }

    function _setLastResponse(bytes memory newResponse) internal virtual {
        bytes memory previousResponse = lastResponse();
        _bytes[____lastResponse()] = newResponse;
        emit LastResponseUpdated(previousResponse, newResponse);
    }
}