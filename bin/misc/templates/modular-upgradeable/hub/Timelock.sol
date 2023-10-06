// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/__Timelock.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Role.sol";

interface ITimelock {
    event RequestQueued(uint id, address indexed target, string indexed signature, bytes indexed args);
    event RequestsQueued(uint id, address[] indexed targets, string[] indexed signatures, bytes[] indexed args);
    event RequestApproved(uint id);
    event RequestRejected(uint id);
    event RequestExecuted(uint id);
    event RequestsExecuted(uint id);
}

contract Timelock is ITimelock, Role {
    __Timelock.Request[] private requests;
    __Timelock.Settings private _settings;
    
    constructor() {
        _settings.timelock = 604800 seconds;
        _settings.timeout = 604800 seconds;
        _settings.enabledApproveAll = true;
    }

    function setTimelock(uint value)
        public {
        validate(msg.sender, address(this), "setTimelock");
        _settings.timelock = value;
    }

    function setTimeout(uint value)
        public {
        validate(msg.sender, address(this), "setTimeout");
        _settings.timeout = value;
    }

    function approveAll(bool value)
        public {
        validate(msg.sender, address(this), "approveAll");
        _settings.enabledApproveAll = value;
    }

    function queue(address target, string memory signature, bytes memory args)
        public 
        returns (uint) {
        validate(msg.sender, address(this), "queue");
        uint id = __Timelock.queue(requests, _settings, target, signature, args);
        if (_settings.enabledApproveAll) { approve(id); }
        emit RequestQueued(id, target, signature, args);
        return id;
    }

    function queueBatch(address[] memory targets, string[] memory signatures, bytes[] memory args)
        public 
        returns (uint) {
        validate(msg.sender, address(this), "queueBatch");
        uint id = __Timelock.queueBatch(requests, _settings, targets, signatures, args);
        emit RequestsQueued(id, targets, signatures, args);
        return id;
    }

    function approve(uint id)
        public {
        validate(msg.sender, address(this), "approve");
        __Timelock.approve(requests, id);
        emit RequestApproved(id);
    }

    function reject(uint id)
        public {
        validate(msg.sender, address(this), "reject");
        __Timelock.reject(requests, id);
        emit RequestRejected(id);
    }

    function execute(uint id)
        public 
        returns (bytes memory) {
        validate(msg.sender, address(this), "execute");
        __Timelock.execute(requests, id);
        __Timelock.Request memory request = requests[id];
        (, bytes memory response) = request.payloadA.target.call(abi.encodeWithSignature(request.payloadA.signature, request.payloadA.args));
        emit RequestExecuted(id);
        return response;
    }

    function executeBatch(uint id)
        public
        returns (bytes[] memory) {
        validate(msg.sender, address(this), "executeBatch");
        __Timelock.executeBatch(requests, id);
        __Timelock.Request memory request = requests[id];
        bytes[] memory responses;
        for (uint i = 0; i < request.payloadB.targets.length; i++) {
            (, bytes memory response) = request.payloadB.targets[i].call(abi.encodeWithSignature(request.payloadB.signatures[i], request.payloadB.args[i]));
            responses[i] = response;
        }
        emit RequestsExecuted(id);
        return responses;
    }

    function getRequest(uint id)
        public view
        returns (uint, uint, uint, uint, uint, address, bool, bool, bool, __Timelock.Class) {
        return __Timelock.getRequest(requests, id);
    }

    function getPayload(uint id)
        public view
        returns (address, string memory, bytes memory args) {
        return __Timelock.getPayload(requests, id);
    }

    function getBatchPayload(uint id)
        public view
        returns (address[] memory, string[] memory, bytes[] memory) {
        return __Timelock.getBatchPayload(requests, id);
    }
}