// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

library __Timelock {
    struct Settings {
        uint timelock;
        uint timeout;
    }

    struct Tracker {
        uint numRequests;
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
        uint endTimestap;
        uint timeoutTimestamp;
        address origin;
        bool isApproved;
        bool isRejected;
        bool isExecuted;
        bool isPending;
        Class class;
    }

    function onlyIfApproved(Request[] storage requests, uint id)
        public view {
        require(requests[id].isApproved, "__Timelock: request has not been approved");
    }

    function onlyIfRejected(Request[] storage requests, uint id)
        public view {
        require(requests[id].isRejected, "__Timelock: request has not been rejected");
    }

    function onlyIfExecuted(Request[] storage requests, uint id)
        public view {
        require(requests[id].isExecuted, "__Timelock: request has not been executed");
    }

    function onlyIfPending(Request[] storage requests, uint id)
        public view {
        require(requests[id].isPending, "__Timelock: request is not pending");
    }

    function onlyIfNotApproved(Request[] storage requests, uint id)
        public view {
        require(!requests[id].isApproved, "__Timelock: request has been approved");
    }

    function onlyIfNotRejected(Request[] storage requests, uint id)
        public view {
        require(!requests[id].isRejected, "__Timelock: request has been rejected");
    }

    function onlyIfNotExecuted(Request[] storage requests, uint id)
        public view {
        require(!requests[id].isExecuted, "__Timelock: request has been executed");
    }

    function onlyIfNotPending(Request[] storage requests, uint id)
        public view {
        require(!requests[id].isPending, "__Timelock: request is pending");
    }

    function queue(Request[] storage requests, Settings storage settings, address target, string memory signature, bytes memory args)
        public {
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
        request.endTimestap = request.startTimestamp + request.timelock;
        request.timeoutTimestamp + request.endTimestap + request.timeout;
        request.origin = msg.sender;
        request.isPending = true;
        request.class = Class.DEFAULT;
    }

    function queueBatch(Request[] storage requests, Settings storage settings, address[] memory targets, string[] memory signatures, bytes[] memory args)
        public {
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
        request.endTimestap = request.startTimestamp + request.timelock;
        request.timeoutTimestamp + request.endTimestap + request.timeout;
        request.origin = msg.sender;
        request.isPending = true;
        request.class = Class.BATCH;
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
        require(requests[id].class == Class.DEFAULT, "__Timelock: request is only batch executable");
        onlyIfNotPending(requests, id);
        onlyIfNotRejected(requests, id);
        onlyIfNotExecuted(requests, id);
        onlyIfApproved(requests, id);
        requests[id].isExecuted = true;
    }

    function executeBatch(Request[] storage requests, uint id)
        public {
        require(requests[id].class == Class.BATCH, "__Timelock: request is only standard executable");
        onlyIfNotPending(requests, id);
        onlyIfNotRejected(requests, id);
        onlyIfNotExecuted(requests, id);
        onlyIfApproved(requests, id);
        requests[id].isExecuted = true;
    }
}