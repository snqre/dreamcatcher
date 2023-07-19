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
        address[] target;
        string[] signature;
        bytes[] args;
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
    }

    function queue(Request[] storage requests, Tracker storage tracker, Settings storage settings, uint id, address target, string memory signature, bytes memory args)
        public {
        tracker.numRequests++;
        Request storage request = requests[id];
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
    }
}