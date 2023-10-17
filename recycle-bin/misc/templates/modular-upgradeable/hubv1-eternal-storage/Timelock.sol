// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/modular-upgradeable/hubv1-eternal-storage/Validator.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";

/**

    **set as universal-key from validator
    **set as implementation from storage

    # purpose
    - universal access of the ecosystem
    - delay calls
    - bypass validator

    **rated 85%
 */

interface ITimelock {
    function getRequest(uint index) external view returns (address[] memory targets, string[] memory signatures, bytes[] memory args, uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp, bool isApproved, bool isRejected, bool isExecuted);
    function init() external;
    function queue(address[] memory targets, string[] memory signatures, bytes[] memory args) external returns (uint index);
    function approve(uint index) external;
    function reject(uint index) external;
    function execute(uint index) external;
    function setTimelockDuration(uint value) external;
    function setTimeoutDuration(uint value) external;
    function setApproveAll(bool value) external;
}

contract Timelock is ReentrancyGuard {

    bool private _init;
    address public deployer;

    IStorage public storage_;
    IValidator public validator;

    modifier verify(string memory signature) {
        validator.verify({account: msg.sender, of_: address(this), signature: signature});
        _;
    }

    constructor(address storage__, address validator_) {
        storage_ =IStorage(storage__);
        validator =IValidator(validator_);
        deployer =msg.sender;
    }

    function getRequest(uint index)
    external view
    returns (address[] memory targets, string[] memory signatures, bytes[] memory args, uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp, bool isApproved, bool isRejected, bool isExecuted) {
        return _decodeRequest(storage_.indexBytesArray({key: _requests(), index: index}));
    }

    function init(bool enabledApproveAll, uint durationTimelock, uint durationTimeout) 
        external {
        require(msg.sender ==deployer, "Timelock: only deployer can init");
        require(!_init, "Validator: !init");
        _setApproveAll({value: enabledApproveAll});
        _setTimelockDuration({value: durationTimelock});
        _setTimeoutDuration({value: durationTimeout});
        _init =true;
    }

    function queue(address[] memory targets, string[] memory signatures, bytes[] memory args)
    external
    nonReentrant
    verify("queue(address[],string[],bytes[])")
    returns (uint index) {
        index = _queue({targets: targets, signatures: signatures, args: args});
        if (storage_.getBool({key: _enabledApproveAll()})) { _approve({index: index}); }
        return index;
    }

    function approve(uint index)
    external 
    nonReentrant
    verify("approve(uint)") {
        _approve({index: index});
    }

    function reject(uint index)
    external
    nonReentrant
    verify("reject(uint)") {
        _reject({index: index});
    }

    function execute(uint index)
    external
    nonReentrant
    verify("execute(uint)") {
        _execute({index: index});
    }

    function setTimelockDuration(uint value)
    external
    nonReentrant
    verify("setTimelockDuration(uint)") {
        _setTimelockDuration({value: value});
    }

    function setTimeoutDuration(uint value)
    external
    nonReentrant
    verify("setTimeoutDuration(uint)") {
        _setTimeoutDuration({value: value});
    }

    function setApproveAll(bool value)
    external
    nonReentrant
    verify("setApproveAll(bool)") {
        _setApproveAll(value);
    }

    function _encodeRequest(address[] memory targets, string[] memory signatures, bytes[] memory args, uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp, bool isApproved, bool isRejected, bool isExecuted)
    internal pure
    returns (bytes memory request) {
        return abi.encode(targets, signatures, args, startTimestamp, endTimelockTimestamp, endTimeoutTimestamp, isApproved, isRejected, isExecuted);
    }

    function _decodeRequest(bytes memory request)
    internal pure
    returns (address[] memory targets, string[] memory signatures, bytes[] memory args, uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp, bool isApproved, bool isRejected, bool isExecuted) {
        return abi.decode(request, (address[],string[],bytes[],uint,uint,uint,bool,bool,bool));
    }

    function _requests()
    internal pure
    returns (bytes32) {
        return keccak256(abi.encode("requests"));
    }

    function _durationTimelock()
    internal pure
    returns (bytes32) {
        return keccak256(abi.encode("durationTimelock"));
    }

    function _durationTimeout()
    internal pure
    returns (bytes32) {
        return keccak256(abi.encode("durationTimeout"));
    }

    function _enabledApproveAll()
    internal pure
    returns (bytes32) {
        return keccak256(abi.encode("enabledApproveAll"));
    }

    function _isEqual(uint a, uint b, uint c)
    internal pure
    returns (bool) {
        if (a ==b && b ==c && c ==a) { return true; } 
        else { return false; }
    }

    function _call(address target, string memory signature, bytes memory args)
    internal
    returns (bool success, bytes memory response) {
        return target.call(abi.encodeWithSignature(signature, args));
    }

    function _queue(address[] memory targets, string[] memory signatures, bytes[] memory args)
    internal
    returns (uint index) {
        uint durLock =storage_.getUint({key: _durationTimelock()});
        uint durTOut =storage_.getUint({key: _durationTimeout()});
        uint now_ =block.timestamp;
        storage_.pushBytesArray({key: _requests(), value: _encodeRequest({targets: targets, signatures: signatures, args: args, startTimestamp: now_, endTimelockTimestamp: now_ +durLock, endTimeoutTimestamp: now_ +durTOut, isApproved: false, isRejected: false, isExecuted: false})});
        bytes[] memory bytesArray = storage_.getBytesArray({key: _requests()});
        return bytesArray.length -1;
    }

    function _approve(uint index)
    internal {
        (address[] memory targets, string[] memory signatures, bytes[] memory args, uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp, bool isApproved, bool isRejected, bool isExecuted) = _decodeRequest({request: storage_.indexBytesArray({key: _requests(), index: index})});
        require(!isApproved, "Timelock: must not be approved");
        require(!isRejected, "Timelock: must not be rejected");
        require(!isExecuted, "Timelock: must not be executed");
        isApproved = true;
        storage_.setIndexBytesArray({key: _requests(), index: index, value: _encodeRequest({targets: targets, signatures: signatures, args: args, startTimestamp: startTimestamp, endTimelockTimestamp: endTimelockTimestamp, endTimeoutTimestamp: endTimeoutTimestamp, isApproved: isApproved, isRejected: isRejected, isExecuted: isExecuted})});
    }

    function _reject(uint index)
    internal {
        (address[] memory targets, string[] memory signatures, bytes[] memory args, uint startTimestamp, uint endTimelockTimestamp, uint endTimeoutTimestamp, bool isApproved, bool isRejected, bool isExecuted) = _decodeRequest({request: storage_.indexBytesArray({key: _requests(), index: index})});
        require(!isApproved, "Timelock: must not be approved");
        require(!isRejected, "Timelock: must not be rejected");
        require(!isExecuted, "Timelock: must not be executed");
        isRejected = true;
        storage_.setIndexBytesArray({key: _requests(), index: index, value: _encodeRequest({targets: targets, signatures: signatures, args: args, startTimestamp: startTimestamp, endTimelockTimestamp: endTimelockTimestamp, endTimeoutTimestamp: endTimeoutTimestamp, isApproved: isApproved, isRejected: isRejected, isExecuted: isExecuted})});
    }

    function _execute(uint index)
    internal
    returns (bool[] memory successes, bytes[] memory responses) {
        (address[] memory targets, string[] memory signatures, bytes[] memory args, , uint endTimelockTimestamp, uint endTimeoutTimestamp, bool isApproved, bool isRejected, bool isExecuted) = _decodeRequest({request: storage_.indexBytesArray({key: _requests(), index: index})});
        require(isApproved, "Timelock: must be approved");
        require(!isRejected, "Timelock: must not be rejected");
        require(!isExecuted, "Timelock: must not be executed");
        require(block.timestamp >=endTimelockTimestamp, "Timelock: timelocked");
        require(block.timestamp <=endTimeoutTimestamp, "Timelock: expired");
        require(_isEqual({a: targets.length, b: signatures.length, c: args.length}));
        for (uint i =0; i <targets.length; i++) {
            (successes[i], responses[i]) =_call({target: targets[i], signature: signatures[i], args: args[i]});
        }
        return (successes, responses);
    }

    function _setTimelockDuration(uint value)
    internal {
        require(value >=3600 seconds, "Timelock: value too low");
        storage_.setUint({key: _durationTimeout(), value: value});
    }

    function _setTimeoutDuration(uint value)
    internal {
        require(value >=storage_.getUint({key: _durationTimeout()}) +3600 seconds, "Timelock: value too low");
        storage_.setUint({key: _durationTimeout(), value: value});
    }
    
    function _setApproveAll(bool value)
    internal {
        storage_.setBool({key: _enabledApproveAll(), value: value});
    }
}