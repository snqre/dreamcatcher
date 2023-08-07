// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/modular-upgradeable/hubv1-eternal-storage/Validator.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";

/**

    requires validator role access
    requires storage to set it as an implementation bef

 */

contract Timelock is ReentrancyGuard {

    IStorage storage_;
    IValidator validator;

    constructor(
        address storage__,
        address validator_,
        bool enabledApproveAll,
        uint durationTimelock,
        uint durationTimeout
        ) {
        _setApproveAll(enabledApproveAll);
        _setTimelockDuration(durationTimelock);
        _setTimeoutDuration(durationTimeout);
    }

    constructor(address storage__, address validator_) {
        requests = keccak256(abi.encode("requests"));


        storage_ = IStorage(storage__);
        validator = IValidator(validator_);

        storage_.setBool(_encode("enabledApproveAll"), true);
        _setTimelockDuration(3600);
        _setTimeoutDuration(7200);
    }

    function queue(
        address[] memory targets, 
        string[] memory signatures, 
        bytes[] memory args
        ) external
        returns (uint index) {
        validator.verify({
            account: msg.sender,
            of_: address(this),
            signature: "queue"
        });
        index = _queue({
            targets: targets,
            signatures: signatures,
            args: args
        });
        if (storage_.getBool(_enabledApproveAll())) {
            _approve(index);
        }
        return index;
    }

    function approve(uint index)
        external {
        validator.verify({
            account: msg.sender,
            of_: address(this),
            signature: "approve"
        });
        _approve(index);
    }

    function reject(uint index)
        external {
        validator.verify({
            account: msg.sender,
            of_: address(this),
            signature: "reject"
        });
        _reject(index);
    }

    function execute(uint index)
        external {
        validator.verify({
            account: msg.sender,
            of_: address(this),
            signature: "execute"
        });
        _execute(index);
    }

    function _encodeRequest(
        address[] memory targets, 
        string[] memory signatures, 
        bytes[] memory args, 
        uint startTimestamp, 
        uint endTimelockTimestamp, 
        uint endTimeoutTimestamp, 
        bool isApproved, 
        bool isRejected, 
        bool isExecuted
        ) internal pure
        returns (bytes memory) {
        return abi.encode(
            targets, 
            signatures, 
            args, 
            startTimestamp, 
            endTimelockTimestamp, 
            endTimeoutTimestamp, 
            isApproved, 
            isRejected, 
            isExecuted
        );
    }

    function _decodeRequest(bytes memory request)
        internal pure
        returns (
            address[] memory targets,
            string[] memory signatures,
            bytes[] memory args,
            uint startTimestamp,
            uint endTimelockTimestamp,
            uint endTimeoutTimestamp,
            bool isApproved,
            bool isRejected,
            bool isExecuted
        ) {
        return abi.decode(request, (
            address[],
            string[],
            bytes[],
            uint,
            uint,
            uint,
            bool,
            bool,
            bool
        ));
    }

    function _requests()
        internal pure
        returns (bytes32) {
        return keccak256(
            abi.encode(
                "requests"
            )
        );
    }

    function _durationTimelock()
        internal pure
        returns (bytes32) {
        return keccak256(
            abi.encode(
                "durationTimelock"
            )
        );
    }

    function _durationTimeout()
        internal pure
        returns (bytes32) {
        return keccak256(
            abi.encode(
                "durationTimeout"
            )
        );
    }

    function _enabledApproveAll()
        internal pure
        returns (bytes32) {
        return keccak256(
            abi.encode(
                "enabledApproveAll"
            )
        );
    }

    function _call(
        address target, 
        string memory signature, 
        bytes memory args
        ) internal
        returns (
            bool success, 
            bytes memory response
        ) {
        return target.call(
            abi.encodeWithSignature(
                signature, 
                args
            )
        );
    }

    function _queue(
        address[] memory targets,
        string[] memory signatures,
        bytes[] memory args
        ) internal
        returns (uint index) {
        // fetch settings
        uint durationTimelock = storage_.getUint(_durationTimelock());
        uint durationTimeout = storage_.getUint(_durationTimeout());
        uint now_ = block.timestamp;
        // push new bytes to array
        storage_.pushBytesArray({
            key: _requests(),
            value: _encodeRequest({
                targets: targets,
                signatures: signatures,
                args: args,
                startTimestamp: now_,
                endTimelockTimestamp: now_ + durationTimelock,
                endTimeoutTimestamp: now_ + durationTimeout,
                isApproved: false,
                isRejected: false,
                isExecuted: false
            })
        });
        return storage_.lengthBytesArray(_requests()) - 1;
    }

    function _approve(uint index)
        internal {
        // decode key get params
        (
            address[] memory targets,
            string[] memory signatures,
            bytes[] memory args,
            uint startTimestamp,
            uint endTimelockTimestamp,
            uint endTimeoutTimestamp,
            bool isApproved,
            bool isRejected,
            bool isExecuted
        ) = _decodeRequest(
            storage_.indexBytesArray(
                _requests(), 
                index
            )
        );
        // check params and encode new request with new params
        require(!isApproved, "Timelock: must not be approved");
        require(!isRejected, "Timelock: must not be rejected");
        require(!isExecuted, "Timelock: must not be executed");
        isApproved = true;
        storage_.setIndexBytesArray({
            key: _requests(),
            index: index,
            value: _encodeRequest({
                targets: targets,
                signatures: signatures,
                args: args,
                startTimestamp: startTimestamp,
                endTimelockTimestamp: endTimelockTimestamp,
                endTimeoutTimestamp: endTimeoutTimestamp,
                isApproved: isApproved,
                isRejected: isRejected,
                isExecuted: isExecuted
            })
        });
    }

    function _reject(uint index)
        internal {
        // decode key get params
        (
            address[] memory targets,
            string[] memory signatures,
            bytes[] memory args,
            uint startTimestamp,
            uint endTimelockTimestamp,
            uint endTimeoutTimestamp,
            bool isApproved,
            bool isRejected,
            bool isExecuted
        ) = _decodeRequest(
            storage_.indexBytesArray(
                _requests(), 
                index
            )
        );
        // check params and encode new request with new params
        require(!isApproved, "Timelock: must not be approved");
        require(!isRejected, "Timelock: must not be rejected");
        require(!isExecuted, "Timelock: must not be executed");
        isRejected = true;
        storage_.setIndexBytesArray({
            key: _requests(),
            index: index,
            value: _encodeRequest({
                targets: targets,
                signatures: signatures,
                args: args,
                startTimestamp: startTimestamp,
                endTimelockTimestamp: endTimelockTimestamp,
                endTimeoutTimestamp: endTimeoutTimestamp,
                isApproved: isApproved,
                isRejected: isRejected,
                isExecuted: isExecuted
            })
        });
    }
    
    function _execute(uint index)
        internal
        returns (
            bool[] memory successes,
            bytes[] memory responses
        ) {
        // decode key get params
        (
            address[] memory targets,
            string[] memory signatures,
            bytes[] memory args,
            uint startTimestamp,
            uint endTimelockTimestamp,
            uint endTimeoutTimestamp,
            bool isApproved,
            bool isRejected,
            bool isExecuted
        ) = _decodeRequest(
            storage_.indexBytesArray(
                _requests(),
                index
            )
        );
        // check params and execute
        require(block.timestamp >= endTimelockTimestamp, "Timelock: early");
        require(block.timestamp <= endTimeoutTimestamp, "Timelock: expired");
        require(isApproved, "Timelock: must be approved");
        require(!isRejected, "Timelock: must not be rejected");
        require(!isExecuted, "Timelock: must not be executed");
        require(targets.length == signatures.length == args.length, "Timelock: unequal payload arguments");
        // execute
        for (uint i = 0; targets.length; i++) {
            (
                successes,
                responses
            ) = _call({
                target: targets[i],
                signature: signatures[i],
                args: args[i]
            });
        }
        return (
            successes,
            responses
        );
    }

    function _setTimelockDuration(uint value)
        internal {
        require(value >= 1, "Timelock: value too low");
        storage_.setUint({
            key: _durationTimelock,
            value: value
        });
    }

    function _setTimeoutDuration(uint value)
        internal {
        require(value >= storage_.getUint(_durationTimeout) + 3600 seconds, "Timelock: timeout is less than timelock");
        storage_.setUint({
            key: _durationTimeout,
            value: value
        });
    }

    function _setApproveAll(bool value)
        internal {
        storage_.setBool({
            key: _enabledApproveAll(),
            value: value
        });
    }
}