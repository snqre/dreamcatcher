// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

library __Timelock {
    struct Settings {
        uint durationTimelock;
        uint durationTimeout;
        bool enabledApproveAll;
    }

    /// for single request
    struct PayloadA {
        address target;
        string signature;
        bytes args;
    }

    /// for batch request
    struct PayloadB {
        address[] targets;
        string[] signatures;
        bytes[] args;
    }

    enum Class {
        DEFAULT,
        BATCH
    }

    struct Request {
        PayloadA payloadA;
        PayloadB payloadB;
        uint timelock;
        uint timeout;
        uint startTimestamp;
        uint endTimestamp;
        uint timeoutTimestamp;
        address origin;
        bool isApproved;
        bool isRejected;
        bool isExecuted;
        Class class;
    }

    function queue(Request[] storage requests, Settings storage settings, address target, string memory signature, bytes memory args)
        public
        returns (uint) {
        requests.push();
        Request storage request = requests[requests.length - 1];
        request.payloadA = PayloadA({target: target, signature: signature, args: args});
        request.durationTimelock = settings.durationTimelock;
        request.durationTimeout = 
    }

    function queue(Request[] storage requests, Settings storage settings, address target, string memory signature, bytes memory args)
        public 
        returns (uint) {
        requests.push();

        Request storage request = requests[requests.length - 1];
        request.payloadA = PayloadA({
            target: target,
            signature: signature,
            args: args
        });
        request.timelock = settings.timelock;
        request.timeout = settings.timeout;
        request.startTimestamp = block.timestamp;
        request.endTimestamp = request.startTimestamp + request.timelock;
        request.timeoutTimestamp + request.endTimestamp + request.timeout;
        request.origin = msg.sender;
        request.isPending = true;
        request.class = Class.DEFAULT;
        return requests.length - 1;
    }

    function queueBatch(Request[] storage requests, Settings storage settings, address[] memory targets, string[] memory signatures, bytes[] memory args)
        public 
        returns (uint) {
        requests.push();
        Request storage request = requests[requests.length - 1];
        request.payloadB = PayloadB({
            targets: targets,
            signatures: signatures,
            args: args
        });
        request.timelock = settings.timelock;
        request.timeout = settings.timeout;
        request.startTimestamp = block.timestamp;
        request.endTimestamp = request.startTimestamp + request.timelock;
        request.timeoutTimestamp + request.endTimestamp + request.timeout;
        request.origin = msg.sender;
        request.isPending = true;
        request.class = Class.BATCH;
        return requests.length - 1;
    }

    function approve(Request[] storage requests, uint id)
        public {
        onlyIfPending(requests, id);
        onlyIfNotRejected(requests, id);
        onlyIfNotExecuted(requests, id);
        onlyIfNotApproved(requests, id);
        requests[id].isApproved = true;
    }

    function reject(Request[] storage requests, uint id)
        public {
        onlyIfPending(requests, id);
        onlyIfNotRejected(requests, id);
        onlyIfNotExecuted(requests, id);
        onlyIfNotApproved(requests, id);
        requests[id].isRejected = true;
        requests[id].isPending = false;
    }

    function execute(Request[] storage requests, uint id)
        public {
        require(requests[id].class == Class.DEFAULT, "__Timelock: request cannot be of batch class");
        if (block.timestamp > requests[id].endTimestamp) { requests[id].isPending = false; }
        if (block.timestamp < )
        onlyIfNotPending(requests, id);
        onlyIfNotRejected(requests, id);
        onlyIfNotExecuted(requests, id);
        onlyIfApproved(requests, id);
        requests[id].isExecuted = true;
    }

    function executeBatch(Request[] storage requests, uint id)
        public {
        require(requests[id].class == Class.BATCH, "__Timelock: request cannot be of default class");
        if (block.timestamp > requests[id].endTimestamp) {
            requests[id].isPending = false;
        }
        onlyIfNotPending(requests, id);
        onlyIfNotRejected(requests, id);
        onlyIfNotExecuted(requests, id);
        onlyIfApproved(requests, id);
        requests[id].isExecuted = true;
    }

    function getRequest(Request[] storage requests, uint id)
        public view 
        returns (uint, uint, uint, uint, uint, address, bool, bool, bool, bool, __Timelock.Class) {
        Request storage request = requests[id];
        return (request.timelock, request.timeout, request.startTimestamp, request.endTimestamp, request.timeoutTimestamp, request.origin, request.isApproved, request.isRejected, request.isExecuted, request.isPending, request.class);
    }

    function getPayload(Request[] storage requests, uint id)
        public view
        returns (address, string memory, bytes memory) {
        require(requests[id].class == Class.DEFAULT, "__Timelock: request cannot be of batch class");
        Request storage request = requests[id];
        return (request.payloadA.target, request.payloadA.signature, request.payloadA.args);
    }

    function getBatchPayload(Request[] storage requests, uint id)
        public view
        returns (address[] memory, string[] memory, bytes[] memory) {
        require(requests[id].class == Class.BATCH, "__Timelock: request cannot be of default class");
        Request storage request = requests[id];
        return (request.payloadB.targets, request.payloadB.signatures, request.payloadB.args);
    }
}