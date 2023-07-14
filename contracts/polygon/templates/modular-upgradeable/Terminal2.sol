// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

struct Key {
    bool owned;
    bool timed;
    bool standard;
    bool consumable;
    uint start;
    uint end;
    uint uses;
}

struct Request {
    address target;
    string signature;
    bytes args;
    uint start;
    uint timelock;
    uint timeout;
    uint identifier;
    address creator;
    string message;
    bool rejected;
    bool approved;
    bool executed;
    bool pending;
}

struct BatchRequest {
    address[] targets;
    string[] signatures;
    bytes[] args;
    uint start;
    uint timelock;
    uint timeout;
    uint identifier;
    address creator;
    string message;
    bool rejected;
    bool approved;
    bool executed;
    bool pending;
}

library Validator {
    error KEY_IS_NOT_OF_TYPE(Key);
    error KEY_CANNOT_EXPIRE_BEFORE_GRANTED(Key);
    error KEY_IS_NOT_OWNED(Key);
    error KEY_IS_NOT_GRANTED_YET(Key);
    error KEY_IS_NO_LONGER_VALID(Key);
    error KEY_USES_IS_DEPLETED(Key);

    function revokeAnyKey(Key storage key)
        public {
        key.owned = false;
        key.timed = false;
        key.standard = false;
        key.consumable = false;
        key.start = 0;
        key.end = 0;
        key.uses = 0;
    }

    function grantStandardKey(Key storage key)
        public {
        revokeAnyKey(key);
        key.owned = true;
        key.standard = true;
    }
    
    function grantTimedKey(Key storage key, uint start, uint duration)
        public {
        revokeAnyKey(key);
        key.owned = true;
        key.timed = true;
        key.start = start;
        key.end = start + duration;
    }
    
    function increaseTimedKeyDuration(Key storage key, uint increase)
        public {
        if (!key.owned) { revert KEY_IS_NOT_OF_TYPE(key); }
        if (!key.timed) { revert KEY_IS_NOT_OF_TYPE(key); }
        key.end = key.start + ((key.end - key.start) + increase);
    }

    function decreaseTimedKeyDuration(Key storage key, uint decrease)
        public {
        if (!key.owned) { revert KEY_IS_NOT_OF_TYPE(key); }
        if (!key.timed) { revert KEY_IS_NOT_OF_TYPE(key); }
        uint new_ = key.start + ((key.end - key.start) - decrease);
        if (new_ <= key.start) { revert KEY_CANNOT_EXPIRE_BEFORE_GRANTED(key); }
        key.end = new_;
    }

    function grantConsumableKey(Key storage key, uint uses)
        public {
        revokeAnyKey(key);
        key.owned = true;
        key.consumable = true;
        key.uses = uses;
    }

    function increaseConsumableKeyUses(Key storage key, uint increase)
        public {
        if (!key.owned) { revert KEY_IS_NOT_OF_TYPE(key); }
        if (!key.consumable) { revert KEY_IS_NOT_OF_TYPE(key); }
        key.uses += increase;
    }

    function decreaseConsumableKeyUses(Key storage key, uint decrease)
        public {
        if (!key.owned) { revert KEY_IS_NOT_OF_TYPE(key); }
        if (!key.consumable) { revert KEY_IS_NOT_OF_TYPE(key); }
        key.uses -= decrease;
    }

    function validate(Key storage key)
        public {
        if (!key.owned) { revert KEY_IS_NOT_OWNED(key); }
        else if (key.timed) {
            if (block.timestamp < key.start) { revert KEY_IS_NOT_GRANTED_YET(key); }
            if (block.timestamp > key.end) { revert KEY_IS_NO_LONGER_VALID(key); }
        }
        else if (key.consumable) {
            if (key.uses == 0) { revert KEY_USES_IS_DEPLETED(key); }
            key.uses--;
        }
    }
}

library TimelockRequest {
    error IS_PENDING(Request);
    error IS_NO_LONGER_PENDING(Request);
    error IS_TIMED_OUT(Request);
    error IS_REJECTED(Request);
    error IS_EXECUTED(Request);
    error IS_APPROVED(Request);
    error IS_NOT_APPROVED(Request);
    error INVALID_IDENTIFIER(uint max);

    function mustBeAfterTimelock(Request memory request)
        private view { 
        if (block.timestamp < (request.start + request.timelock)) { revert IS_PENDING(request); } 
    }

    function mustBeBeforeTimelock(Request memory request)
        private view { 
        if (block.timestamp >= (request.start + request.timelock)) { revert IS_NO_LONGER_PENDING(request); } 
    }

    function mustBeBeforeTimeout(Request memory request)
        private view { 
        if (block.timestamp >= (request.start + request.timelock) + request.timeout) { revert IS_TIMED_OUT(request); } 
    }
    
    function mustNotBeRejected(Request memory request)
        private pure { 
        if (request.rejected) { revert IS_REJECTED(request); } 
    }

    function mustNotBeExecuted(Request memory request)
        private pure { 
        if (request.executed) { revert IS_EXECUTED(request); } 
    }

    function mustBeApproved(Request memory request)
        private pure { 
        if (!request.approved) { revert IS_NOT_APPROVED(request); } 
    }

    function mustNotBeApproved(Request memory request)
        private pure { 
        if (request.approved) { revert IS_APPROVED(request); } 
    }
    
    function queue(uint timelock, uint timeout, Request[] storage requests, address target, string memory signature, bytes memory args, address creator, string memory message)
        public
        returns (uint) {
        if (requests.length == 0) { requests.push(); }
        Request memory request = Request({
            target: target,
            signature: signature,
            args: args,
            start: block.timestamp,
            timelock: timelock,
            timeout: timeout,
            identifier: requests.length,
            creator: creator,
            message: message,
            rejected: false,
            approved: false,
            executed: false,
            pending: true
        });
        requests.push(request);
        return request.identifier;
    }

    function execute(Request[] storage requests, uint identifier)
        public {
        if (identifier >= requests.length) { revert INVALID_IDENTIFIER(requests.length); }
        Request storage request = requests[identifier];
        mustBeAfterTimelock(request);
        mustBeBeforeTimeout(request);
        mustNotBeRejected(request);
        mustNotBeExecuted(request);
        mustBeApproved(request);
        request.pending = false;
        request.executed = true;
    }

    function reject(Request[] storage requests, uint identifier)
        public {
        if (identifier >= requests.length) { revert INVALID_IDENTIFIER(requests.length); }
        Request storage request = requests[identifier];
        mustBeBeforeTimelock(request);
        mustNotBeExecuted(request);
        mustNotBeRejected(request);
        mustNotBeApproved(request);
        request.pending = false;
        request.rejected = true;
    }

    function approve(Request[] storage requests, uint identifier)
        public {
        if (identifier >= requests.length) { revert INVALID_IDENTIFIER(requests.length); }
        Request storage request = requests[identifier];
        mustBeBeforeTimelock(request);
        mustNotBeExecuted(request);
        mustNotBeRejected(request);
        mustNotBeApproved(request);
        request.pending = false;
        request.approved = true;
    }
}

library TimelockBatchRequest {
    error IS_PENDING(BatchRequest);
    error IS_NO_LONGER_PENDING(BatchRequest);
    error IS_TIMED_OUT(BatchRequest);
    error IS_REJECTED(BatchRequest);
    error IS_EXECUTED(BatchRequest);
    error IS_APPROVED(BatchRequest);
    error IS_NOT_APPROVED(BatchRequest);
    error INVALID_IDENTIFIER(uint max);

    function mustBeAfterTimelock(BatchRequest memory request)
        private view { 
        if (block.timestamp < (request.start + request.timelock)) { revert IS_PENDING(request); } 
    }

    function mustBeBeforeTimelock(BatchRequest memory request)
        private view { 
        if (block.timestamp >= (request.start + request.timelock)) { revert IS_NO_LONGER_PENDING(request); } 
    }

    function mustBeBeforeTimeout(BatchRequest memory request)
        private view { 
        if (block.timestamp >= (request.start + request.timelock) + request.timeout) { revert IS_TIMED_OUT(request); } 
    }
    
    function mustNotBeRejected(BatchRequest memory request)
        private pure { 
        if (request.rejected) { revert IS_REJECTED(request); } 
    }

    function mustNotBeExecuted(BatchRequest memory request)
        private pure { 
        if (request.executed) { revert IS_EXECUTED(request); } 
    }

    function mustBeApproved(BatchRequest memory request)
        private pure { 
        if (!request.approved) { revert IS_NOT_APPROVED(request); } 
    }

    function mustNotBeApproved(BatchRequest memory request)
        private pure { 
        if (request.approved) { revert IS_APPROVED(request); } 
    }
    
    function queue(uint timelock, uint timeout, BatchRequest[] storage requests, address[] memory targets, string[] memory signatures, bytes[] memory args, address creator, string memory message)
        public
        returns (uint) {
        if (requests.length == 0) { requests.push(); }
        BatchRequest memory request = BatchRequest({
            targets: targets,
            signatures: signatures,
            args: args,
            start: block.timestamp,
            timelock: timelock,
            timeout: timeout,
            identifier: requests.length,
            creator: creator,
            message: message,
            rejected: false,
            approved: false,
            executed: false,
            pending: true
        });
        requests.push(request);
        return request.identifier;
    }

    function execute(BatchRequest[] storage requests, uint identifier)
        public {
        if (identifier >= requests.length) { revert INVALID_IDENTIFIER(requests.length); }
        BatchRequest storage request = requests[identifier];
        mustBeAfterTimelock(request);
        mustBeBeforeTimeout(request);
        mustNotBeRejected(request);
        mustNotBeExecuted(request);
        mustBeApproved(request);
        request.pending = false;
        request.executed = true;
    }

    function reject(BatchRequest[] storage requests, uint identifier)
        public {
        if (identifier >= requests.length) { revert INVALID_IDENTIFIER(requests.length); }
        BatchRequest storage request = requests[identifier];
        mustBeBeforeTimelock(request);
        mustNotBeExecuted(request);
        mustNotBeRejected(request);
        mustNotBeApproved(request);
        request.pending = false;
        request.rejected = true;
    }

    function approve(BatchRequest[] storage requests, uint identifier)
        public {
        if (identifier >= requests.length) { revert INVALID_IDENTIFIER(requests.length); }
        BatchRequest storage request = requests[identifier];
        mustBeBeforeTimelock(request);
        mustNotBeExecuted(request);
        mustNotBeRejected(request);
        mustNotBeApproved(request);
        request.pending = false;
        request.approved = true;
    }
}

contract Terminal {
    mapping(address => mapping(string => Key)) public keys;
    Request[] public requests;
    BatchRequest[] public requestsBatch;
    
    uint public timelock;
    uint public timeout;

    event KeyGranted();

    modifier onlyKey(string memory key) {
        validate(msg.sender, key);
        _;
    }

    constructor() {
        timelock = 1814400 seconds;
        timeout = 604800 seconds;
        address to = address(this);
        Validator.grantStandardKey(keys[to]["Terminal.revokeAnyKey()"]);
    }

    function validate(address from, string memory key)
        public { 
        Validator.validate(keys[from][key]); 
    }
    
    function revokeAnyKey(address from, string memory key)
        external 
        onlyKey("Terminal->revokeAnyKey()") { 
        Validator.revokeAnyKey(keys[from][key]); 
    }

    function grantStandardKey(address to, string memory key)
        external
        onlyKey("Terminal->grantStandardKey()") { 
        Validator.grantStandardKey(keys[to][key]); 
    }

    function grantTimedKey(address to, string memory key, uint start, uint duration)
        external
        onlyKey("Terminal->grantTimedKey()") { 
        Validator.grantTimedKey(keys[to][key], start, duration);
    }
    
    function increaseTimedKeyDuration(address of_, string memory key, uint increase)
        external
        onlyKey("Terminal->increaseTimedKeyDuration()") { 
        Validator.increaseTimedKeyDuration(keys[of_][key], increase); 
    }
    
    function decreaseTimedKeyDuration(address of_, string memory key, uint decrease)
        external
        onlyKey("Terminal->decreaseTimedKeyDuration()") { 
        Validator.decreaseTimedKeyDuration(keys[of_][key], decrease); 
    }

    function grantConsumableKey(address to, string memory key, uint uses)
        external
        onlyKey("Terminal->grantConsumableKey()") { 
        Validator.grantConsumableKey(keys[to][key], uses); 
    }
    
    function increaseConsumableKeyUses(address of_, string memory key, uint increase)
        external
        onlyKey("Terminal->increaseConsumableKeyUses()") { 
        Validator.increaseConsumableKeyUses(keys[of_][key], increase); 
    }
    
    function decreaseConsumableKeyUses(address of_, string memory key, uint decrease)
        external
        onlyKey("Terminal->decreaseConsumableKeyUses()") { 
        Validator.decreaseConsumableKeyUses(keys[of_][key], decrease); 
    }
    
    function queue(address target, string memory signature, bytes memory args, address creator, string memory message)
        external
        onlyKey("Terminal->queue()") {
        TimelockRequest.queue(timelock, timeout, requests, target, signature, args, creator, message);
    }

    // ... request mechanism
    // ... batch request mechanism
    // ... router management
    // ... implementation management
    // ... terminal manipulation
    // ... universals
}