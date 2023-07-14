// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

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

interface IRouter {
    function upgradeable() external view returns (bool);
    function enabled() external view returns (bool);
    function name() external view returns (string memory);
    function terminal() external view returns (address);
    function enable() external;
    function disable() external;
    function upgrade(address implementation) external;
    function downgrade(uint version) external;
    function swapTerminal(address terminal_) external;
    function getLatestImplementation() external returns (address);
    function getLatestVersion() external returns (uint);
}

contract Router is IRouter {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _implementations;
    bool public immutable upgradeable;
    bool public enabled;
    string public name;
    address public terminal;

    error ROUTER_DISABLED();
    error INVALID_VERSION();

    modifier onlyIfEnabled() {
        if (!enabled) { revert ROUTER_DISABLED();}
        _;
    }

    modifier onlyKey(string memory key) {
        ITerminal(terminal).validate(msg.sender, string(abi.encodePacked(name, key)));
        _;
    }

    constructor(string memory name_, address implementation, bool upgradeable_) {
        _implementations.add(implementation);
        upgradeable = upgradeable_;
        name = name_;
        terminal = msg.sender;
    }

    function enable()
        public 
        onlyKey("->enable()") {
        enabled = true;
    }

    function disable()
        public
        onlyKey("->disable()") {
        enabled = false;
    }

    function upgrade(address implementation)
        public
        onlyIfEnabled
        onlyKey("->upgrade()") {
        _implementations.add(implementation);
    }

    function downgrade(uint version)
        public
        onlyIfEnabled
        onlyKey("->downgrade") {
        if (version >= _implementations.length()) { revert INVALID_VERSION(); }
        _implementations.add(_implementations.at(version));
    }

    function swapTerminal(address terminal_)
        public
        onlyIfEnabled
        onlyKey("->swapTerminal()") {
        terminal = terminal_;
    }

    function getLatestImplementation()
        public view
        onlyIfEnabled
        returns (address) {
        return _implementations.at(getLatestVersion());
    }

    function getLatestVersion()
        public view
        onlyIfEnabled
        returns (uint) {
        return _implementations.length() - 1;
    }
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
        if (block.timestamp < (request.start + request.timelock)) { 
            revert IS_PENDING(request); 
        } 
    }

    function mustBeBeforeTimelock(Request memory request)
        private view { 
        if (block.timestamp >= (request.start + request.timelock)) { 
            revert IS_NO_LONGER_PENDING(request); 
        } 
    }

    function mustBeBeforeTimeout(Request memory request)
        private view { 
        if (block.timestamp >= (request.start + request.timelock) + request.timeout) { 
            revert IS_TIMED_OUT(request); 
        } 
    }
    
    function mustNotBeRejected(Request memory request)
        private pure { 
        if (request.rejected) { 
            revert IS_REJECTED(request); 
        } 
    }

    function mustNotBeExecuted(Request memory request)
        private pure { 
        if (request.executed) { 
            revert IS_EXECUTED(request); 
        } 
    }

    function mustBeApproved(Request memory request)
        private pure { 
        if (!request.approved) { 
            revert IS_NOT_APPROVED(request); 
        } 
    }

    function mustNotBeApproved(Request memory request)
        private pure { 
        if (request.approved) { 
            revert IS_APPROVED(request); 
        } 
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
        if (block.timestamp < (request.start + request.timelock)) { 
            revert IS_PENDING(request); 
        } 
    }

    function mustBeBeforeTimelock(BatchRequest memory request)
        private view { 
        if (block.timestamp >= (request.start + request.timelock)) { 
            revert IS_NO_LONGER_PENDING(request); 
        } 
    }

    function mustBeBeforeTimeout(BatchRequest memory request)
        private view { 
        if (block.timestamp >= (request.start + request.timelock) + request.timeout) { 
            revert IS_TIMED_OUT(request); 
        } 
    }
    
    function mustNotBeRejected(BatchRequest memory request)
        private pure { 
        if (request.rejected) { 
            revert IS_REJECTED(request); 
        } 
    }

    function mustNotBeExecuted(BatchRequest memory request)
        private pure { 
        if (request.executed) { 
            revert IS_EXECUTED(request); 
        } 
    }

    function mustBeApproved(BatchRequest memory request)
        private pure { 
        if (!request.approved) { 
            revert IS_NOT_APPROVED(request); 
        } 
    }

    function mustNotBeApproved(BatchRequest memory request)
        private pure { 
        if (request.approved) { 
            revert IS_APPROVED(request); 
        } 
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

interface ITerminal {
    function validate(address from, string memory key) external;
    function revokeAnyKey(address from, string memory key) external;
    function grantStandardKey(address to, string memory key) external;
    function grantTimedKey(address to, string memory key, uint start, uint duration) external;
    function increaseTimedKeyDuration(address of_, string memory key, uint increase) external;
    function decreaseTimedKeyDuration(address of_, string memory key, uint decrease) external;
    function grantConsumableKey(address to, string memory key, uint uses) external;
    function increaseConsumableKeyUses(address of_, string memory key, uint increase) external;
    function decreaseConsumableKeyUses(address of_, string memory key, uint decrease) external;
    function queue(address target, string memory signature, bytes memory args, address creator, string memory message) external;
    function execute(uint identifier) external;
    function reject(uint identifier) external;
    function approve(uint identifier) external;
    function queueBatch(address[] memory targets, string[] memory signatures, bytes[] memory args, address creator, string memory message) external;
    function executeBatch(uint identifier) external;
    function rejectBatch(uint identifier) external;
    function approveBatch(uint identifier) external;
    function deployRouter(string memory name, address implementation, bool upgradeable, bool enabled) external returns (address);
    function route(string memory signature, bytes memory args, bool globalSearch) external returns (bool, bytes memory);
}

contract Terminal is ITerminal {
    uint public timelock;
    uint public timeout;
    bool public enabledSelfApprove;
    bool public enabledRelayMode;
    bool public enabled_;

    Request[] public requests;
    BatchRequest[] public requestsBatch;
    Router[] public routers;
    address[] public terminals;
    address[] public nonNativeRouters;

    mapping(string => bool) public nameHasBeenUsed;
    mapping(address => bool) public addressHasBeenUsed;
    string[] public routersNames;
    mapping(string => uint) public nameRepeats;

    mapping(address => mapping(string => Key)) public keys;

    error ROUTER_NAME_ALREADY_IN_USE();
    error ROUTER_ADDRESS_ALREADY_IN_USE();
    error TERMINAL_RELAY_MODE_ENABLED();
    error TERMINAL_DISABLED();
    error ROUTE_UNABLE_TO_FIND_FUNCTION();

    modifier onlyKey(string memory key) {
        validate(msg.sender, key);
        _;
    }

    modifier onlyIfEnabled() {
        if (enabled_) { revert TERMINAL_DISABLED(); }
        _;
    }

    modifier onlyIfRelayModeDisabled() {
        if (enabledRelayMode) { revert TERMINAL_RELAY_MODE_ENABLED(); }
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
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->revokeAnyKey()") { 
        Validator.revokeAnyKey(keys[from][key]); 
    }

    function grantStandardKey(address to, string memory key)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->grantStandardKey()") { 
        Validator.grantStandardKey(keys[to][key]); 
    }

    function grantTimedKey(address to, string memory key, uint start, uint duration)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->grantTimedKey()") { 
        Validator.grantTimedKey(keys[to][key], start, duration);
    }
    
    function increaseTimedKeyDuration(address of_, string memory key, uint increase)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->increaseTimedKeyDuration()") { 
        Validator.increaseTimedKeyDuration(keys[of_][key], increase); 
    }
    
    function decreaseTimedKeyDuration(address of_, string memory key, uint decrease)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->decreaseTimedKeyDuration()") { 
        Validator.decreaseTimedKeyDuration(keys[of_][key], decrease); 
    }

    function grantConsumableKey(address to, string memory key, uint uses)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->grantConsumableKey()") { 
        Validator.grantConsumableKey(keys[to][key], uses); 
    }
    
    function increaseConsumableKeyUses(address of_, string memory key, uint increase)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->increaseConsumableKeyUses()") { 
        Validator.increaseConsumableKeyUses(keys[of_][key], increase); 
    }
    
    function decreaseConsumableKeyUses(address of_, string memory key, uint decrease)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->decreaseConsumableKeyUses()") { 
        Validator.decreaseConsumableKeyUses(keys[of_][key], decrease); 
    }
    
    function queue(address target, string memory signature, bytes memory args, address creator, string memory message)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->queue()") {
        uint identifier = TimelockRequest.queue(timelock, timeout, requests, target, signature, args, creator, message);
        if (enabledSelfApprove) { TimelockRequest.approve(requests, identifier); }
    }

    function execute(uint identifier)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->execute()") {
        TimelockRequest.execute(requests, identifier);
    }

    function reject(uint identifier)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->reject()") {
        TimelockRequest.reject(requests, identifier);
    }

    function approve(uint identifier)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->approve()") {
        TimelockRequest.approve(requests, identifier);
    }

    function queueBatch(address[] memory targets, string[] memory signatures, bytes[] memory args, address creator, string memory message)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->queueBatch()") {
        uint identifier = TimelockBatchRequest.queue(timelock, timeout, requestsBatch, targets, signatures, args, creator, message);
        if (enabledSelfApprove) { TimelockBatchRequest.approve(requestsBatch, identifier); }
    }

    function executeBatch(uint identifier)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->executeBatch()") {
        TimelockBatchRequest.execute(requestsBatch, identifier);
    }
    
    function rejectBatch(uint identifier)
        public
        onlyKey("Terminal->rejectBatch()") {
        TimelockBatchRequest.reject(requestsBatch, identifier);
    }

    function approveBatch(uint identifier)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->approveBatch()") {
        TimelockBatchRequest.approve(requestsBatch, identifier);
    }

    function deployRouter(string memory name, address implementation, bool upgradeable, bool enabled)
        public 
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->deployRouter()")
        returns (address) {
        if (nameHasBeenUsed[name]) { revert ROUTER_NAME_ALREADY_IN_USE(); }
        nameHasBeenUsed[name] = true;
        routersNames.push(name);
        routers.push(new Router(name, implementation, upgradeable));
        uint identifier = routers.length - 1;
        if (enabled) { routers[identifier].enable(); }
        addressHasBeenUsed[address(routers[identifier])] = true;
        return address(routers[identifier]);
    }

    // for non native router access.
    function plugInRouter(address router_)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal-plugInRouter()") 
        returns (address) {
        IRouter router = IRouter(router_);
        if (addressHasBeenUsed[address(router)]) { revert ROUTER_ADDRESS_ALREADY_IN_USE(); }
        if (nameHasBeenUsed[router.name()]) { revert ROUTER_NAME_ALREADY_IN_USE(); }
        addressHasBeenUsed[address(router)] = true;
        router.swapTerminal(address(this));
        router.enable();
        nonNativeRouters.push(router_);
        return address(router);
    }

    function broadcast(string memory signature, bytes memory args)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->broadcast()") 
        returns (bool[] memory) {
        bool[] memory successes;
        for (uint i = 0; i < routers.length; i++) {
            (bool success, ) = address(routers[i]).call(abi.encodeWithSignature(signature, args));
            successes[successes.length] = success; 
        }
        for (uint i = 0; i < nonNativeRouters.length; i++) {
            (bool success, ) = address(nonNativeRouters[i]).call(abi.encodeWithSignature(signature, args));
            successes[successes.length] = success;
        }
        return successes;
    }

    function upgrade(address implementation, bool carryRouters)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->upgrade()") {
        // move router's terminal to new terminal implementation.
        if (carryRouters) {
            bytes memory args = abi.encode(implementation);
            broadcast("swapTerminal(address)", args);
        }
        // grant keys of this contract.
        terminals.push(implementation);
        address to = implementation;
        grantStandardKey(to, "Terminal->revokeAnyKey()");
        grantStandardKey(to, "Terminal->grantTimedKey()");
        grantStandardKey(to, "Terminal->increaseTimedKeyDuration");
        grantStandardKey(to, "Terminal->decreaseTimedKeyDuration");
        grantStandardKey(to, "Terminal->grantConsumableKey()");
        grantStandardKey(to, "Terminal->increaseConsumableKeyUses()");
        grantStandardKey(to, "Terminal->decreaseConsumableKeyUses()");
        grantStandardKey(to, "Terminal->queue()");
        grantStandardKey(to, "Terminal->execute()");
        grantStandardKey(to, "Terminal->reject()");
        grantStandardKey(to, "Terminal->approve()");
        grantStandardKey(to, "Terminal->queueBatch()");
        grantStandardKey(to, "Terminal->executeBatch()");
        grantStandardKey(to, "Terminal->rejectBatch()");
        grantStandardKey(to, "Terminal->approveBatch()");
        grantStandardKey(to, "Terminal->deployRouter()");
        grantStandardKey(to, "Terminal->plugInRouter()");
        grantStandardKey(to, "Terminal->broadcast()");
        grantStandardKey(to, "Terminal->upgrade()");
    }
    /// route.
    function route(string memory signature, bytes memory args, bool globalSearch)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled
        returns (bool, bytes memory) {
        bool success;
        bytes memory response;
        // first search through local native routers.
        for (uint i = 0; i < routers.length; i++) {
            address target = routers[i].getLatestImplementation();
            (success, response) = target.call(abi.encodeWithSignature(signature, args));
            if (success) { break; }
        }
        // search non native routers.
        if (!success) {
            for (uint i = 0; i < nonNativeRouters.length; i++) {
                address target = IRouter(nonNativeRouters[i]).getLatestImplementation();
                (success, response) = target.call(abi.encodeWithSignature(signature, args));
                if (success) { break; }    
            }
        }
        // search global.
        if (!success && globalSearch) {
            for (uint i = 0; i < terminals.length; i++) {
                // first call terminal.
                (success, response) = ITerminal(terminals[i]).route(signature, args, globalSearch);
                if (success) { break; }
            }
        }
        return (success, response);
    }
}