// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/__Timelock.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Role.sol";

contract Timelock is Role {
    __Timelock.Request[] private requests;
    __Timelock.Settings private _settings;
    
    constructor() {
        _settings.timelock = 3600 seconds;
        _settings.timeout = 3600 seconds;
    }

    function queue(address target, string memory signature, bytes memory args)
        public {
        __Timelock.queue(requests, _settings, target, signature, args);
    }

    function queueBatch(address[] memory targets, string[] memory signatures, bytes[] memory args)
        public {
        __Timelock.queueBatch(requests, _settings, targets, signatures, args);
    }

    function approve(uint id)
        public {
        validate(msg.sender, address(this), "approve");
        __Timelock.approve(requests, id);
    }

    function reject(uint id)
        public {
        validate(msg.sender, address(this), "reject");
        __Timelock.reject(requests, id);
    }

    function execute(uint id)
        public 
        returns (bytes memory) {
        validate(msg.sender, address(this), "execute");
        __Timelock.execute(requests, id);
        __Timelock.Request memory request = requests[id];
        (, bytes memory response) = request.payloadA.target.call(abi.encodeWithSignature(request.payloadA.signature, request.payloadA.args));
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
        return responses;
    }
}