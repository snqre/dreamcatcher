// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/math/Math.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/structs/Structs.sol";
import "contracts/polygon/templates/errors/Errors.sol";





library Authenticator {
    function revokeAnyKey(Key storage key)
        public {
        key.isOwned = false;
        key.isTimed = false;
        key.isStandard = false;
        key.isConsumable = false;
        key.startTimestamp = 0;
        key.endTimestamp = 0;
        key.numUses = 0;
    }

    function grantStandardKey(Key storage key)
        public {
        revokeAnyKey(key);
        key.isOwned = true;
        key.isStandard = true;
    }

    function grantTimedKey(Key storage key, uint startTimestamp, uint duration)
        public {
        revokeAnyKey(key);
        key.isOwned = true;
        key.isTimed = true;
        key.startTimestamp = startTimestamp;
        key.endTimestamp = startTimestamp + duration;
    }

    function increaseTimedKeyDuration(Key storage key, uint increase)
        public {
        if (!key.isOwned) { revert KeyIsNotOfType(key); }
        if (!key.isTimed) { revert KeyIsNotOfType(key); }

        key.endTimestamp = key.startTimestamp + ((key.endTimestamp - key.startTimestamp) + increase);
    }

    function decreaseTimedKeyDuration(Key storage key, uint decrease)
        public {
        if (!key.isOwned) { revert KeyIsNotOfType(key); }
        if (!key.isTimed) { revert KeyIsNotOfType(key); }

        uint newEndTimestamp = key.startTimestamp + ((key.endTimestamp - key.startTimestamp) - decrease);
        require(newEndTimestamp > key.startTimestamp);
        key.endTimestamp = newEndTimestamp;
    }

    function grantConsumableKey(Key storage key, uint numUses)
        public {
        revokeAnyKey(key);
        key.isOwned = true;
        key.isConsumable = true;
        key.numUses = numUses;
    }

    function increaseConsumableKeyUses(Key storage key, uint increase)
        public {
        if (!key.isOwned) { revert KeyIsNotOfType(key); }
        if (!key.isConsumable) { revert KeyIsNotOfType(key); }

        // assuming solidity ^0.8.0 should check for overflow.
        key.numUses += increase;
    }

    function decreaseConsumableKeyUses(Key storage key, uint decrease)
        public {
        if (!key.isOwned) { revert KeyIsNotOfType(key); }
        if (!key.isConsumable) { revert KeyIsNotOfType(key); }

        // assuming solidity ^0.8.0 should check for overflow.
        key.numUses -= decrease;
    }

    function authenticate(Key storage key)
        public {
        if (!key.isOwned) { revert KeyIsNotOwned(key); }

        else if (key.isTimed) {
            uint currentTimestamp = block.timestamp;
            bool early = currentTimestamp < key.startTimestamp;
            bool late = currentTimestamp > key.endTimestamp;

            if (early) { revert KeyAccessPremature(key, currentTimestamp); }
            if (isLate) { revert KeyAccessExpired(key, currentTimestamp); }
        }

        else if (key.isConsumable) {
            if (key.numUses == 0) { revert KeyAccessZero(key); }
            key.numUses --;
        }
    }
}





// for requests handling.
library TimelockA {
    error IsLocked(ConnectionRequest request);
    error IsUnlocked(ConnectionRequest request);
    error IsTimedOut(ConnectionRequest request);
    error IsRejected(ConnectionRequest request);
    error IsExecuted(ConnectionRequest request);
    error IsApproved(ConnectionRequest request);
    error IsNotApproved(ConnectionRequest request);

    function mustBeAfterTimelock(ConnectionRequest memory request)
        public {
        bool isTooEarly = block.timestamp < (request.connectionRequestSchedule.startTimestamp + request.connectionRequestSchedule.timelockDuration);
        if (isTooEarly) { revert IsLocked(request); }
    }

    function mustBeBeforeTimelock(ConnectionRequest memory request)
        public {
        bool isTooLate = block.timestamp >= (request.connectionRequestSchedule.startTimestamp + request.connectionRequestSchedule.timelockDuration);
        if (isTooLate) { revert isUnlocked(request); }
    }

    function mustBeBeforeTimeout(ConnectionRequest memory request)
        public {
        bool isTooLate = block.timestamp >= (request.connectionRequestSchedule.startTimestamp + request.connectionRequestSchedule.timelockDuration) + request.connectionRequestSchedule.timeoutDuration;
        if (isTooLate) { revert IsTimedOut(request); }
    }

    function mustNotBeRejected(ConnectionRequest memory request)
        public {
        if (request.rejected) { revert IsRejected(request); }
    }

    function mustNotBeExecuted(ConnectionRequest memory request)
        public {
        if (request.executed) { revert IsExecuted(request); }
    }

    function mustBeApproved(ConnectionRequest memory request)
        public {
        if (!request.approved) { revert IsNotApproved(request); }
    }

    function mustNotBeApproved(ConnectionRequest memory request)
        public {
        if (request.approved) { revert IsApproved(request); }
    }

    function queueRequest(TimelockSettings memory settings, ConnectionRequest[] storage requests, uint storage numRequests, Payload memory payload, string memory message)
        public
        returns (uint) {
        numRequests ++;
        uint newIdentifier = numRequests;
        ConnectionRequest storage newRequest = requests[newIdentifier];
        newRequest.payload = Payload({
            target: payload.target,
            signature: payload.signature,
            args: payload.args
        });

        newRequest.connectionRequestSchedule = ConnectionRequestSchedule({
            startTimestamp: block.timestamp,
            timelockDuration: settings.timelockDuration,
            timeoutDuration: settings.timeoutDuration
        });

        newRequest.identifier = newIdentifier;
        newRequest.origin = msg.sender;
        newRequest.message = message;
        newRequest.pending = true;

        return newIdentifier;
    }

    function executeRequest(ConnectionRequest[] storage requests, uint identifier)
        public 
        returns (bool, bytes memory) {
        ConnectionRequest storage request = requests[identifier];
        mustBeAfterTimelock(request);
        mustBeBeforeTimeout(request);
        mustNotBeRejected(request);
        mustNotBeExecuted(request);
        mustBeApproved(request);

        request.pending = false;
        request.executed = true;

        address target = request.payload.target;
        string memory signature = request.payload.signature;
        bytes memory args = request.payload.args;

        (bool success, bytes memory response) = request.payload.target.call(abi.encodeWithSignature(signatire, args));
        
        return (success, response);
    }

    function rejectRequest(ConnectionRequest[] storage requests, uint identifier)
        public {
        ConnectionRequest storage request = requests[identifier];
        mustBeBeforeTimelock(request);
        mustNotBeExecuted(request);
        mustNotBeRejected(request);
        mustNotBeApproved(request);

        request.pending = false;
        request.rejected = true;
    }

    function approveRequest(ConnectionRequest[] storage requests, uint identifier)
        public {
        ConnectionRequest storage request = requests[identifier];
        mustBeBeforeTimelock(request);
        mustNotBeExecuted(request);
        mustNotBeRejected(request);
        mustNotBeApproved(request);

        request.pending = false;
        request.approved = true;
    }
}





// for batches handling.
library TimelockB {
    error IsLocked(BatchConnectionRequest request);
    error IsUnlocked(BatchConnectionRequest request);
    error IsTimedOut(BatchConnectionRequest request);
    error IsRejected(BatchConnectionRequest request);
    error IsExecuted(BatchConnectionRequest request);
    error IsApproved(BatchConnectionRequest request);
    error IsNotApproved(BatchConnectionRequest request);
    
    function mustBeAfterTimelock(BatchConnectionRequest memory request)
        public {
        bool isTooEarly = block.timestamp < (request.connectionRequestSchedule.startTimestamp + request.connectionRequestSchedule.timelockDuration);
        if (isTooEarly) { revert IsLocked(request); }
    }

    function mustBeBeforeTimelock(BatchConnectionRequest memory request)
        public {
        bool isTooLate = block.timestamp >= (request.connectionRequestSchedule.startTimestamp + request.connectionRequestSchedule.timelockDuration);
        if (isTooLate) { revert isUnlocked(request); }
    }

    function mustBeBeforeTimeout(BatchConnectionRequest memory request)
        public {
        bool isTooLate = block.timestamp >= (request.connectionRequestSchedule.startTimestamp + request.connectionRequestSchedule.timelockDuration) + request.connectionRequestSchedule.timeoutDuration;
        if (isTooLate) { revert IsTimedOut(request); }
    }

    function mustNotBeRejected(BatchConnectionRequest memory request)
        public {
        if (request.rejected) { revert IsRejected(request); }
    }

    function mustNotBeExecuted(BatchConnectionRequest memory request)
        public {
        if (request.executed) { revert IsExecuted(request); }
    }

    function mustBeApproved(BatchConnectionRequest memory request)
        public {
        if (!request.approved) { revert IsNotApproved(request); }
    }

    function mustNotBeApproved(BatchConnectionRequest memory request)
        public {
        if (request.approved) { revert IsApproved(request); }
    }

    function queueBatchRequest(TimelockSettings memory settings, BatchConnectionRequest[] storage requests, uint storage numRequests, Batch memory batch, string memory message)
        public
        returns (uint) {
        numRequests ++;
        uint newIdentifier = numRequests;
        BatchConnectionRequest storage newRequest = requests[newIdentifier];
        newRequest.batch = Batch({
            targets: batch.targets,
            signatures: batch.signatures,
            args: batch.args
        });

        newRequest.connectionRequestSchedule = ConnectionRequestSchedule({
            startTimestamp: block.timestamp,
            timelockDuration: settings.timelockDuration,
            timeoutDuration: settings.timeoutDuration
        });

        newRequest.identifier = newIdentifier;
        newRequest.origin = msg.sender;
        newRequest.message = message;
        newRequest.pending = true;

        return newIdentifier;
    }
    
    function executeBatchRequest(BatchConnectionRequest[] storage requests, uint identifier)
        public 
        returns (bool[] memory, bytes[] memory) {
        BatchConnectionRequest storage request = requests[identifier];
        mustBeAfterTimelock(request);
        mustBeBeforeTimeout(request);
        mustNotBeRejected(request);
        mustNotBeExecuted(request);
        mustBeApproved(request);

        request.pending = false;
        request.executed = true;

        address[] memory targets = request.batch.targets;
        string[] memory signatures = request.batch.signatures;
        bytes[] memory args = request.batch.args;

        bool[] memory successes;
        bytes[] memory responses;
        for (uint i = 0; i < targets.length; i++) {
            (successes[i], bytes[i]) = targets[i].call(abi.encodeWithSignature(signatures[i], args[i]));
        }

        return (successes, responses);
    }

    function rejectBatchRequest(BatchConnectionRequest[] storage requests, uint identifier)
        public {
        BatchConnectionRequest storage request = requests[identifier];
        mustBeBeforeTimelock(request);
        mustNotBeExecuted(request);
        mustNotBeRejected(request);
        mustNotBeApproved(request);

        request.pending = false;
        request.rejected = true;
    }

    function approveBatchRequest(BatchConnectionRequest[] storage requests, uint identifier)
        public {
        BatchConnectionRequest storage request = requests[identifier];
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
    mapping(string => Module) private _modules;
    string[] public modules;
    ConnectionRequest[] public requests;
    BatchConnectionRequest[] public batchRequests;
    uint numBatchRequests;
    uint numRequests;

    TimelockSettings public timelockSettings;

    constructor() {
        timelockSettings.timelockDuration = 4 weeks;
        timelockSettings.timeoutDuration = 7 days;

        Authenticator.grantStandardKey("terminal-revoke-any-key");
        Authenticator.grantStandardKey("terminal-grant-standard-key");
        Authenticator.grantStandardKey("terminal-grant-timed-key");
        Authenticator.grantStandardKey("terminal-aquire-module");
        Authenticator.grantStandardKey("terminal-upgrade-module");
    }

    // -------------
    // AUTHENTICATOR.
    // -------------

    function revokeAnyKey(address from, string memory key)
        external {
        authenticate(msg.sender, "terminal-revoke-any-key");
        Authenticator.revokeAnyKey(keys[from][key]);
    }

    function grantStandardKey(address to, string memory key)
        external {
        authenticate(msg.sender, "terminal-grant-standard-key");
        Authenticator.grantStandardKey(keys[to][key]);
    }

    function grantTimedKey(address to, string memory key, uint startTimestamp, uint duration)
        external {
        authenticate(msg.sender, "terminal-grant-timed-key");
        Authenticator.grantTimedKey(keys[to][key], startTimestamp, duration);
    }

    function grantConsumableKey(address to, string memory key, uint numUses)
        external {
        authenticate(msg.sender, "terminal-grant-consumable-key");
        Authenticator.grantConsumableKey(keys[to][key], numUses);
    }

    function authenticate(address from, string memory key)
        public { Authenticator.authenticate(keys[from][key]); }

    // ==============|
    // MODULE MANAGER|
    // ==============|

    function addModule(string memory name, address implementation, string[] memory keys_, bool upgradeable)
        external
        returns (Module memory) {
        authenticate(msg.sender, "terminal-add-module");
        Module storage module = _modules[name];

        if (module.used) { revert ModuleIsNotEmpty(module); }
        module.implementations.add(implementation);
        module.latestImplementation = implementation;
        module.latestVersion = module.implementations.length() - 1;
        module.upgradeable = upgradeable;
        module.used = true;

        // pass authentication keys to terminal.
        for (uint i = 0; i < keys_.length; i++) { Authenticator.grantStandardKey(keys[address(this)][keys_[i]]); }
        emit ModuleAquired(name, module);
        return module;
    }

    function removeModule(string memory name)
        external
        returns (Module memory) {
        authenticate(msg.sender, "terminal-remove-module");
        Module storage module = _modules[name];
        
        if (!module.used) { revert ModuleIsEmpty(module); }
        module = Module({
            /** clear implementations array */
            upgradeable: false,
            used: false
        });
    }

    function upgradeModule(string memory name, address implementation, string[] memory keys_, bool force)
        external
        returns (Module memory, uint version) {
        authenticate(msg.sender, "terminal-upgrade-module");
        Module storage module = _modules[name];

        if (!module.used) { revert ModuleIsEmpty(module); }
        if (!module.upgradeable) { revert ModuleIsNotUpgradeable(module); }

        // disable previous implementation.
        uint latest = module.implementations.length() - 1;
        address latestImplementation = module.implementations.at(latest);

        (bool success, bytes memory response) = latestImplementation.call(abi.encodeWithSignature("disable()"));

        if (!success && !force) {

            // force will push the upgrade regardless of confirming the previous implementation is disabled.
            revert UnableToConfirmPreviousImplementationIsDisabled(module);
        }

        // upgrade.
        module.implementations.add(implementation);

        return (module, module.implementations.length() - 1);
    }

    // -----------|
    // BROADCASTER|
    // -----------|

    /** makes a call to all modules with to the same signature with the same args 
    @dev assuming each implementation is built on the implementation wrapper they should all have the same drm001 standard.
     */
    function broadcast(string memory signature, bytes memory args)
        public
        returns (bool[] memory successes, bytes[] memory responses) {
        authenticate(msg.sender, "terminal-broadcast");
        for (uint i = 0; i < modules.length; i++) {
            Module storage module = _modules[modules[i]];
            module.latestImplementation.call(abi.encodeWithSignature(signature, args));
        }
    }


    // ... iteralet over all modules and make the same call.
    // if they have a module wrapper terminal should be able to pause all of them.
    // identify module types and differences.

    /** deploy parent terminal as new upgrade and brodcast new terminal */

    // --------------
    // SINGLE REQUEST.
    // --------------
    
    function queueRequest(Payload memory payload, string memory message)
        external
        returns (uint) {
        authenticate(msg.sender, "terminal-queue-request");
        return TimelockA.queueRequest(timelockSettings, requests, numRequests, payload, message);
    }

    function executeRequest(uint identifier)
        external
        returns (bool, bytes memory) {
        authenticate(msg.sender, "terminal-execute-request");
        return TimelockA.executeRequest(requests, identifier);
    }

    function rejectRequest(uint identifier)
        external {
        authenticate(msg.sender, "terminal-reject-request");
        TimelockA.rejectRequest(requests, identifier);
    }

    function approveRequest(uint identifier)
        external {
        authenticate(msg.sender, "terminal-approve-request");
        TimelockA.approveRequest(requests, identifier);
    }

    // -------------
    // BATCH REQUEST.
    // -------------

    function queueBatchRequest(Batch memory batch, string memory message)
        external
        returns (uint) {
        authenticate(msg.sender, "terminal-queue-batch-request");
        return TimelockB.queueBatchRequest(timelockSettings, batchRequests, numBatchRequests, batch, message);
    }

    function executeBatchRequest(uint identifier)
        external
        returns (bool[] memory, bytes[] memory) {
        authenticate(msg.sender, "terminal-execute-batch-request");
        return TimelockB.executeBatchRequest(batchRequests, identifier);
    }

    function rejectBatchRequest(uint identifier)
        external {
        authenticate(msg.sender, "terminal-reject-batch-request");
        TimelockB.rejectBatchRequest(batchRequests, identifier);
    }

    function approveBatchRequest(uint identifier)
        external {
        authenticate(msg.sender, "terminal-approve-batch-request");
        TimelockB.approveBatchRequest(batchRequests, identifier);
    }
}

// protocols are fast tracked instructions to terminal
// can only be executed if the conditions are met
contract Protocol7777 { // catastrophic failure
    fallback()
    public {
        // get price
        (, bytes memory response) = Terminal.queueRequest(payload, message);


    }
}