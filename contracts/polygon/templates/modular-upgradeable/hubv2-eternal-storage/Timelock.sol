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

    function _encodeRequestPayload(address[] memory targets, string[] memory signatures, bytes[] memory args)
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

    function _encodeRequest(address[] memory targets, string[] memory signatures, bytes[] memory args, uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp, bool isApproved, bool isRejected, bool isExecuted)
        internal pure
        returns (bytes memory) {
        bytes memory payload = _encodeRequestPayload(targets, signatures, args);
        bytes memory timestamps = _encodeRequestTimestamps(startTimestamp, endTimelockTimestamp, endTimeoutTimestamp);
        bytes memory state = _encodeRequestState(isApproved, isRejected, isExecuted);
        return abi.encode(payload, timestamps, state);
    }

    function _decodeRequest(bytes memory request)
        internal pure
        returns (address[] memory, string[] memory, bytes[] memory, uint, uint, uint, bool, bool, bool) {
        
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

    function _queue(address[] memory targets, string[] memory signatures, bytes[] memory args)
        internal 
        returns (uint) {
        bytes memory request = _encodeRequest(targets, signatures, args, block.timestamp, block.timestamp + storage_.getUint(_encode("durationTimelock")), block.timestamp + storage_.getUint("durationTimeout"), false, false, false);
        storage_.pushBytesArray(_encode("requests"), request);
        return storage_.lengthBytesArray(_encode("requests")) - 1;
    }

    function _execute(uint index)
        internal 
        returns (bool[] memory, bytes[] memory) {
        bytes memory request = storage_.indexBytesArray(_encode("requests"), index);
        (address[] memory targets, string[] memory signatures, bytes memory args, uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp, bool isApproved, bool isRejected, bool isExecuted) = _decodeRequest(request);
        require(block.timestamp >= endTimelockTimestamp, "Timelock: request cannot be executed before timelock is over");
        require(block.timestamp <= endTimeoutTimestamp, "Timelock: request cannot be executed after it is timedout");
        require(isApproved, "Timelock: request cannot be executed if it is not approved");
        require(!isRejected, "Timelock: request cannot be executed if it is rejected");
        require(!isExecuted, "Timelock: request cannot be executed if it is executed");
        require(targets.length == signatures.length == args.length, "Timelock: unequal payload arguments");

        bool[] memory successes;
        bytes[] memory responses;

        // execute calls
        for (uint i = 0; targets.length; i++) {

            (successes[i], responses[i]) = _call(targets[i], signatures[i], args[i]);
        }

        return (successes, responses);
    }

    function _setTimelockDuration(uint value)
        internal {
        require(value >= 1, "Timelock: timelock value is too low");
        storage_.setUint(_encode("durationTimelock"), value);
    }

    function _setTimeoutDuration(uint value)
        internal {
        require(value >= storage_.getUint(_encode("requests")) + 3600 seconds, "Timelock: timeout duration is less than timelock");
        storage_.setUint(_encode("durationTimeout"), value);
    }
}