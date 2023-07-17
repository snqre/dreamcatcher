// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

contract Router2 {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Self {
        EnumerableSet.AddressSet implementations;
        bool upgradeable;
        bool enabled;
        string id;
        address terminal;
        string[] requiredKeys;
        address latestImplementation;
        uint latestVersion;
    }

    Self public self;

    error ROUTER_DISABLED();
    error INVALID_VERSION();

    modifier onlyKey(uint id) {
        ITerminal(terminal).validate(msg.sender, self.requiredKeys[id]);
        _;
    }

    modifier onlyIfEnabled() {
        if (!self.enabled) { revert ROUTER_DISABLED(); }
        _;
    }

    constructor(string memory id, address implementation, string[] requiredKeys, bool upgradeable, bool enabled) {
        self.implementations.add(implementation);
        self.upgradeable = upgradeable;
        self.enabled = enabled;
        self.id = id;
        self.terminal = msg.sender;
        self.requiredKeys = requiredKeys;
        self.latestImplementation = implementation;
        self.latestVersion = self.implementations.length() - 1;
    }

    function enable()
        public
        onlyKey(0) {
        self.enabled = true;
    }

    function disable()
        public
        onlyKey(1) {
        self.enabled = false;
    }

    function upgrade(address implementation)
        public
        onlyIfEnabled
        onlyKey(2) {
        self.implementations.add(implementation);
        self.latestImplementation = implementation;
        self.latestVersion = self.implementations.length() - 1;
    }

    function downgrade(uint version)
        public
        onlyIfEnabled
        onlyKey(3) {
        if (version >= self.implementations.length()) { revert INVALID_VERSION(); }
        self.implementations.add(self.implementations.at(version));
    }

    function getLatestVersion()
        public
        onlyIfEnabled {
        return self.implementations.length() - 1;
    }


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


library TimelockRequest {
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
        request.approved = true;
    }
}

library TimelockBatchRequest {
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

    TimelockRequest.Request[] public requests;
    TimelockBatchRequest.BatchRequest[] public requestsBatch;
    Router[] public routers;
    address[] public terminals;
    address[] public nonNativeRouters;

    mapping(string => bool) public nameHasBeenUsed;
    mapping(address => bool) public addressHasBeenUsed;
    string[] public routersNames;
    mapping(string => uint) public nameRepeats;

    // account > the name of the key > Key
    mapping(address => mapping(string => Validator.Key)) public keys;

    error ROUTER_NAME_ALREADY_IN_USE();
    error ROUTER_ADDRESS_ALREADY_IN_USE();
    error TERMINAL_RELAY_MODE_ENABLED();
    error TERMINAL_DISABLED();
    error ROUTE_UNABLE_TO_FIND_FUNCTION();
    error INVALID_IDENTIFIER();

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

        /// grant keys to msg.sender.
        address to = msg.sender;
        Validator.grantStandardKey(keys[to]["Terminal.revokeAnyKey()"]);
        Validator.grantStandardKey(keys[to]["Terminal.grantTimedKey()"]);
        Validator.grantStandardKey(keys[to]["Terminal.increaseTimedKeyDuration()"]);
        Validator.grantStandardKey(keys[to]["Terminal.decreaseTimedKeyDuration()"]);
        Validator.grantStandardKey(keys[to]["Terminal->grantConsumableKey()"]);
        Validator.grantStandardKey(keys[to]["Terminal->increaseConsumableKeyUses()"]);
        Validator.grantStandardKey(keys[to]["Terminal->decreaseConsumableKeyUses()"]);
        Validator.grantStandardKey(keys[to]["Terminal->queue()"]);
        Validator.grantStandardKey(keys[to]["Terminal->execute()"]);
        Validator.grantStandardKey(keys[to]["Terminal->reject()"]);
        Validator.grantStandardKey(keys[to]["Terminal->approve()"]);
        Validator.grantStandardKey(keys[to]["Terminal->queueBatch()"]);
        Validator.grantStandardKey(keys[to]["Terminal->executeBatch()"]);
        Validator.grantStandardKey(keys[to]["Terminal->rejectBatch()"]);
        Validator.grantStandardKey(keys[to]["Terminal->approveBatch()"]);
        Validator.grantStandardKey(keys[to]["Terminal->deployRouter()"]);
        Validator.grantStandardKey(keys[to]["Terminal->plugInRouter()"]);
        Validator.grantStandardKey(keys[to]["Terminal->broadcast()"]);
        Validator.grantStandardKey(keys[to]["Terminal->upgrade()"]);

        /// grant keys to self.
        to = address(this);
        Validator.grantStandardKey(keys[to]["Terminal.revokeAnyKey()"]);
        Validator.grantStandardKey(keys[to]["Terminal.grantTimedKey()"]);
        Validator.grantStandardKey(keys[to]["Terminal.increaseTimedKeyDuration()"]);
        Validator.grantStandardKey(keys[to]["Terminal.decreaseTimedKeyDuration()"]);
        Validator.grantStandardKey(keys[to]["Terminal->grantConsumableKey()"]);
        Validator.grantStandardKey(keys[to]["Terminal->increaseConsumableKeyUses()"]);
        Validator.grantStandardKey(keys[to]["Terminal->decreaseConsumableKeyUses()"]);
        Validator.grantStandardKey(keys[to]["Terminal->queue()"]);
        Validator.grantStandardKey(keys[to]["Terminal->execute()"]);
        Validator.grantStandardKey(keys[to]["Terminal->reject()"]);
        Validator.grantStandardKey(keys[to]["Terminal->approve()"]);
        Validator.grantStandardKey(keys[to]["Terminal->queueBatch()"]);
        Validator.grantStandardKey(keys[to]["Terminal->executeBatch()"]);
        Validator.grantStandardKey(keys[to]["Terminal->rejectBatch()"]);
        Validator.grantStandardKey(keys[to]["Terminal->approveBatch()"]);
        Validator.grantStandardKey(keys[to]["Terminal->deployRouter()"]);
        Validator.grantStandardKey(keys[to]["Terminal->plugInRouter()"]);
        Validator.grantStandardKey(keys[to]["Terminal->broadcast()"]);
        Validator.grantStandardKey(keys[to]["Terminal->upgrade()"]);
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

    function setTimelock(uint value)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled
        onlyKey("Terminal->setTimelock()") {
        timelock = value;
    }

    function setTimeout(uint value)
        public
        onlyIfEnabled
        onlyIfRelayModeDisabled
        onlyKey("Terminal->setTimeout()") {
        timeout = value;
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

    // ... when router is deployed keys must be granted to terminal.
    function deployRouter(string memory name, address implementation, bool upgradeable, bool enabled)
        public 
        onlyIfEnabled
        onlyIfRelayModeDisabled 
        onlyKey("Terminal->deployRouter()")
        returns (address) {
        /// check if the name is being used by another router.
        if (nameHasBeenUsed[name]) { revert ROUTER_NAME_ALREADY_IN_USE(); }
        nameHasBeenUsed[name] = true;
        routersNames.push(name);

        /// deploy new router.
        routers.push(new Router(name, implementation, upgradeable));

        /// grant keys to standard router functions.
        address to = address(this);
        grantStandardKey(to, string(abi.encodePacked(name, "->enable()")));
        grantStandardKey(to, string(abi.encodePacked(name, "->disable()")));
        grantStandardKey(to, string(abi.encodePacked(name, "->upgrade()")));
        grantStandardKey(to, string(abi.encodePacked(name, "->downgrade()")));
        grantStandardKey(to, string(abi.encodePacked(name, "->swapTerminal()")));

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

    function connect(string memory signature, bytes memory args, bool global_)
        public
        onlyIfEnabled
        returns (bool, bytes memory) {
        
        bool success;
        bytes memory response;

        /// search local native
        for (uint i = 0; i < routers.length; i++) {
            
            address msgSender = msg.sender;
            args = abi.encodePacked(msgSender, args);
            
            /// check for response
            (success, response) = IRouter(routers[i]).connect(signature, args);
            
            if (success) { break; }
        }
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