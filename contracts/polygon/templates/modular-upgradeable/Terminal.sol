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

library ModuleManager {
    function aquireModule(Module storage module, address implementation, bool isUpgradeable)
        public {
        if (module.isInUse) { revert ModuleIsNotEmpty(module); }
        
        module.implementations.add(implementation);
        module.isUpgradeable = isUpgradeable;
        module.isInUse = true;
    }

    function upgradeModule(Module storage module, address implementation)
        public {
        if (!module.isInUse) { revert ModuleIsEmpty(module); }
        if (!module.isUpgradeable) { revert ModuleIsNotUpgradeable(module); }

        module.implementations.add(implementation);
        return module;
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

}

contract Terminal {
    mapping(address => mapping(string => Key)) public keys;
    mapping(string => Module) private _modules;
    ConnectionRequest[] public requests;
    BatchRequest[] public batches;
    uint numRequests;
    uint numBatches;

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

    // --------------
    // MODULE MANAGER.
    // --------------

    function aquireModule(string memory name, string[] memory keys_, address implementation, bool isUpgradeable)
        external 
        returns (Module memory) {
        authenticate(msg.sender, "terminal-aquire-module");
        Module storage module = _modules[name];
        ModuleManager.aquireModule(module, implementation, isUpgradeable);

        for (uint i = 0; i < keys_.length; i++) { Authenticator.grantStandardKey(keys[address(this)][keys_[i]]); }

        emit ModuleAquired(name, module);
        return module;
    }

    function upgradeModule(string memory name, string[] memory keys_, address implementation)
        external
        returns (Module memory) {
        authenticate(msg.sender, "terminal-upgrade-module");
        Module storage module = _modules[name];
        ModuleManager.upgradeModule(module, implementation);

        for (uint i = 0; i < keys_.length; i++) { Authenticator.grantStandardKey(keys[address(this)][keys_[i]]); }

        emit ModuleUpgraded(name, module);
        return module;
    }

    // ---------------------------
    // CONNECTION QUEUE W TIMELOCK.
    // ---------------------------

    // request -> queued -> | exec window | -> execution -> connect -> module function

    function queueConnect()

    function connect(address target, string memory signature, bytes memory args)
        external {
        authenticate(msg.sender, "terminal-connect");
    }
    
    
}