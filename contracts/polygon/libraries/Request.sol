// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

library Request {
    enum Conduct {
        MULTI_SIG_REFERENDUM,
        REFERENDUM_MULTI_SIG,
        REFERENDUM,
        MULTI_SIG,
        NONE
    }

    struct Request_ {
        Payload[10] payloads;
        bool requireAllPayloadsAreSuccessful;
        Lock lock;
        Conduct conduct;
    }

    struct Signable {
        mapping(address => bool) isSigner;
        uint signed;
        uint count;
    }

    struct Lock {
        uint startTimestamp;
        uint duration;
        bool hasBeenSet;
    }

    struct Payload {
        address target;
        bytes args;
        bytes response;
    }

    function setConduct(Request_ storage request, Conduct conduct) internal {
        request.conduct = conduct;
    }

    /// write on a payload slot
    function setPayload(Request_ storage request, uint slotId, address target, bytes memory args) internal {
        bytes memory emptyBytes;
        request.payloads[slotId] = Payload(target, args, emptyBytes);
    }

    /// start the timelock timer
    function startLockTimer(Request_ storage request, uint duration) internal {
        request.lock.startTimestamp = block.timestamp;
        request.lock.duration = duration;
        request.lock.hasBeenSet = true;
    }

    /// execute payloads
    function execute(Request_ storage request) internal {
        /// cannot execute if the lock is not done or if the lock timer was not set
        require(request.lock.hasBeenSet, 'Lock timer has not been set');
        require(block.timestamp >= request.lock.startTimestamp + request.lock.duration, 'Locked');
        for (uint i = 0; i < request.payloads.length; i++) {
            address target = request.payloads[i].target;
            bytes memory args = request.payloads[i].args;
            (bool success, bytes memory response) = target.call(args);
            /// if setting is toggled then all calls must be successful
            if (request.requireAllPayloadsAreSuccessful) {
                require(success, 'Call was unsuccessful');
            }
            /// store response
            request.payloads[i].response = response;
        }
    }
}