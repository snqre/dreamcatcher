// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/modular-upgradeable/hubv2-eternal-storage/Validator.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";

/**

    requires validator role access
    requires storage to set it as an implementation bef

 */

contract Timelock is ReentrancyGuard {

    IStorage storage_;
    IValidator validator;

    constructor(address storage__, address validator_) {
        storage_ = IStorage(storage__);
        validator = IValidator(validator_);
    }

    function _encode(string memory string_)
        internal pure
        returns (bytes32) {
        return keccak256(abi.encode(string_));
    }

    function _encodeRequestPayload(address[] memory targets, string[] signatures, bytes[] memory args)
        internal pure
        returns (bytes memory) {
        return abi.encode(targets, signatures, args);
    }

    function _decodeRequestPayload(bytes memory payload)
        internal pure
        returns (address[] memory, string[] memory, bytes[] memory) {
        (address[] memory targets, string[] memory signatures, bytes[] memory args) = abi.decode(payload, (address[], string[], bytes[]));
        return (targets, signatures, args);
    }

    function _encodeRequestTimestamps(uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp)
        internal pure
        returns (bytes memory) {
        return abi.encode(startTimestamp, endTimelockTimestamp, endTimeoutTimestamp);
    }

    function _decodeRequestTimestamps(bytes memory timestamps)
        internal pure
        returns (uint, uint, uint) {
        (uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp) = abi.decode(timestamps, (uint, uint, uint));
        return (startTimestamp, endTimelockTimestamp, endTimeoutTimestamp);
    }

    function _encodeRequestState(bool isApproved, bool isRejected, bool isExecuted)
        internal pure
        returns (bytes memory) {
        return abi.encode(isApproved, isRejected, isExecuted);
    }

    function _decodeRequestState(bytes memory state)
        internal pure
        returns (bool, bool, bool) {
        (bool isApproved, bool isRejected, bool isExecuted) = abi.decode(state, (bool, bool, bool));
        return (isApproved, isRejected, isExecuted);
    }

    function _encodeRequest(address[] memory targets, string[] signatures, bytes[] memory args, uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp, bool isApproved, bool isRejected, bool isExecuted)
        internal pure
        returns (bytes memory) {
        bytes memory payload = _encodeRequestPayload(targets, signatures, args);
        bytes memory timestamps = _encodeRequestTimestamps(startTimestamp, endTimelockTimestamp, endTimeoutTimestamp);
        bytes memory state = _encodeRequestState(isApproved, isRejected, isExecuted);
        return abi.encode(payload, timestamps, state);
    }

    function _decodeRequest(bytes memory request)
        internal pure
        returns (address[] memory, string[], bytes[] memory, uint, uint, uint, bool, bool, bool) {
        
        // decode layer 1
        (bytes memory payload, bytes memory timestamps, bytes memory state) = abi.decode(request, (bytes, bytes, bytes));

        // decode layer 2
        (address[] memory targets, string[] memory signatures, bytes[] memory args) = _decodeRequestPayload(payload);
        (uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp) = _decodeRequestTimestamps(timestamps);
        (bool isApproved, bool isRejected, bool isExecuted) = _decodeRequestState(state);

        // return
        return (targets, signatures, args, startTimestamp, endTimelockTimestamp, endTimeoutTimestamp, isApproved, isRejected, isExecuted);
    }

    function _call(address target, string memory signature, bytes memory args)
        internal
        returns (bool, bytes memory) {
        (bool success, bytes memory response) = target.call(abi.encodeWithSignature(signature, args));
        return (success, response);
    }
}