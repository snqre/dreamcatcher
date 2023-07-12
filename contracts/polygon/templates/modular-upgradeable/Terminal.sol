// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
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
        require(key.isOwned);
        require(key.isTimed);
        key.endTimestamp = key.startTimestamp + ((key.endTimestamp - key.startTimestamp) + increase);
    }

    function decreaseTimedKeyDuration(Key storage key, uint decrease)
        public {
        require(key.isOwned);
        require(key.isTimed);
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
        require(key.isOwned);
        require(key.isConsumable);
        key.numUses += increase;
    }

    function decreaseConsumableKeyUses(Key storage key, uint decrease)
        public {
        require(key.isOwned);
        require(key.isConsumable);
        key.numUses -= decrease;
    }

    function authenticate(Key storage key)
        public {
        if (key.isStandard) { require(key.isOwned); }
        else if (key.isTimed) {
            require(key.isOwned);

            uint currentTimestamp = block.timestamp;

            if (currentTimestamp < key.startTimestamp) {
                revert TimedKeyIsPremature(currentTimestamp, key.startTimestamp);
            }

            if (currentTimestamp > key.endTimestamp) {
                revert TimedKeyIsExpired(currentTimestamp, key.endTimestamp);
            }
        }

        else if (key.isConsumable) {
            require(key.numUses > 0);
            key.numUses -= 1;
        }
    }
}

library ModuleManager {

}

contract Terminal {
    
    mapping(address => mapping(string => Key)) public keys;
    mapping(string => Module) private _modules;

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
        public {
        Authenticator.authenticate(keys[from][key]);
    }

    // --------------
    // MODULE MANAGER.
    // --------------

    
}