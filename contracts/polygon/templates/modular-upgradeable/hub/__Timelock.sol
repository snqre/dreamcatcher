// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

library __Timelock {
    struct Settings {
        uint timelock;
        uint timeout;
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

    function onlyPending(Request[] storage requests, uint id)
        public view {
        Request storage request = requests[id];
        require(
            block.timestamp >= request.startTimestamp
            && block.timestamp <= request.endTimestamp,
            "__Timelock: request is not pending"
        );
    }

    function onlyNotPending(Request[] storage requests, uint id)
        public view {
        Request storage request = requests[id];
        require(
            block.timestamp < request.startTimestamp
            && block.timestamp > request.endTimestamp,
            "__Timelock: request is pending"
        );
    }

    function onlyWindow(Request[] storage requests, uint id)
        public view {
        Request storage request = requests[id];
        require(
            block.timestamp > request.endTimestamp
            && block.timestamp <= request.timeoutTimestamp,
            "__Timelock: request is not within execution window"
        );
    }

    function onlyRejected(Request[] storage requests, uint id)
        public view {
        Request storage request = requests[id];
        require(
            request.isRejected,
            "__Timelock: request is not rejected"
        );
    }

    function onlyNotRejected(Request[] storage requests, uint id)
        public view {
        Request storage request = requests[id];
        require(
            !request.isRejected,
            "__Timelock: request is rejected"
        );
    }

    function onlyApproved(Request[] storage requests, uint id)
        public view {
        Request storage request = requests[id];
        require(
            request.isApproved,
            "__Timelock: request is not approved"
        );
    }

    function onlyNotApproved(Request[] storage requests, uint id)
        public view {
        Request storage request = requests[id];
        require(
            !request.isApproved,
            "__Timelock: request is approved"
        );
    }

    function onlyExecuted(Request[] storage requests, uint id)
        public view {
        Request storage request = requests[id];
        require(
            request.isExecuted,
            "__Timelock: request is not executed"
        );
    }

    function onlyNotExecuted(Request[] storage requests, uint id)
        public view {
        Request storage request = requests[id];
        require(
            !request.isExecuted,
            "__Timelock: request is executed"
        );
    }

    function onlyDEFAULT(Request[] storage requests, uint id)
        public view {
        Request storage request = requests[id];
        require(
            request.class == Class.DEFAULT,
            "__Timelock: request cannot have a batch payload"
        );
    }

    function onlyBATCH(Request[] storage requests, uint id)
        public view {
        Request storage request = requests[id];
        require(
            request.class == Class.BATCH,
            "__Timelock: request cananot have a default payload"
        );
    }

    function queue(Request[] storage requests, Settings storage settings, address target, string memory signature, bytes memory args)
        public
        returns (uint) {
        requests.push();
        Request storage request = requests[requests.length - 1];
        request.payloadA = PayloadA({target: target, signature: signature, args: args});
        request.timelock = settings.timelock;
        request.timeout = settings.timeout;
        request.startTimestamp = block.timestamp;
        request.endTimestamp = request.startTimestamp + settings.timelock;
        request.timeoutTimestamp = request.endTimestamp + request.timeout;
        request.origin = msg.sender;
        request.class = Class.DEFAULT;
        return requests.length - 1;
    }
    
    function queueBatch(Request[] storage requests, Settings storage settings, address[] memory targets, string[] memory signatures, bytes[] memory args)
        public
        returns (uint) {
        requests.push();
        Request storage request = requests[requests.length - 1];
        request.payloadB = PayloadB({targets: targets, signatures: signatures, args: args});
        request.timelock = settings.timelock;
        request.timeout = settings.timeout;
        request.startTimestamp = block.timestamp;
        request.endTimestamp = request.startTimestamp + settings.timelock;
        request.timeoutTimestamp = request.endTimestamp + request.timeout;
        request.origin = msg.sender;
        request.class = Class.DEFAULT;
        return requests.length - 1;
    }

    function approve(Request[] storage requests, uint id)
        public {
        onlyPending(requests, id);
        onlyNotApproved(requests, id);
        onlyNotRejected(requests, id);
        onlyNotExecuted(requests, id);
        Request storage request = requests[id];
        request.isApproved = true;
    }

    function reject(Request[] storage requests, uint id)
        public {
        onlyPending(requests, id);
        onlyNotApproved(requests, id);
        onlyNotRejected(requests, id);
        onlyNotExecuted(requests, id);
        Request storage request = requests[id];
        request.isRejected = true;
    }

    function execute(Request[] storage requests, uint id)
        public {
        onlyDEFAULT(requests, id);
        onlyWindow(requests, id);
        onlyNotExecuted(requests, id);
        onlyApproved(requests, id);
        onlyNotRejected(requests, id);
        Request storage request = requests[id];
        request.isExecuted = true;
    }

    function executeBatch(Request[] storage requests, uint id)
        public {
        onlyBATCH(requests, id);
        onlyWindow(requests, id);
        onlyNotExecuted(requests, id);
        onlyApproved(requests, id);
        onlyNotRejected(requests, id);
        Request storage request = requests[id];
        request.isExecuted = true;
    }

    function getRequest(Request[] storage requests, uint id)
        public view 
        returns (uint, uint, uint, uint, uint, address, bool, bool, bool, __Timelock.Class) {
        Request storage request = requests[id];
        return (request.timelock, request.timeout, request.startTimestamp, request.endTimestamp, request.timeoutTimestamp, request.origin, request.isApproved, request.isRejected, request.isExecuted, request.class);
    }

    function getPayload(Request[] storage requests, uint id)
        public view
        returns (address, string memory, bytes memory) {
        onlyDEFAULT(requests, id);
        Request storage request = requests[id];
        return (request.payloadA.target, request.payloadA.signature, request.payloadA.args);
    }

    function getBatchPayload(Request[] storage requests, uint id)
        public view
        returns (address[] memory, string[] memory, bytes[] memory) {
        onlyBATCH(requests, id);
        Request storage request = requests[id];
        return (request.payloadB.targets, request.payloadB.signatures, request.payloadB.args);
    }
}