// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

/// authenticator allows to lock every function within the ecosystem behind three types of keys.
/// allows for more flexibility.

interface IAuthenticator {
    /// standard key.
    function authenticate(address from, string memory key, bool canBeConsumable, bool canBeTimed) 
    external
    returns (bool success);

    /// authenticator-grant-key
    function grantKey(address to, string memory key)
    external
    returns (bool success);

    /// authenticator-revoke-key
    function revokeKey(address from, string memory key)
    external
    returns (bool success);

    function authenticateConsumable(address from, string memory consumableKey)
    external
    returns (bool success);

    /// authenticator-grant-consumable
    function grantConsumable(address to, string memory consumableKey)
    external
    returns (bool success);

    /// authenticator-consume
    function consume(address from, string memory consumableKey)
    external
    returns (bool success);

    function authenticateTimed(address from, string memory timedKey)
    external
    returns (bool success);

    /// authenticator-grant-timed
    function grantTimed(address to, string memory timedKey, uint startTimestamp, uint duration)
    external
    returns (bool success);

    /// authenticator-revoke-timed
    function revokeTimed(address to, string memory timedKey)
    external
    returns (bool success);

    /// authenticator-create-role
    function createRole(string memory caption, string[] memory keys_, string[] memory consumableKeys_, string[] memory timedKeys_, uint[] memory startTimestamps, uint[] memory durations)
    external
    returns (bool success);

    /// authenticator-delete-role
    function deleteRole(string memory caption)
    external
    returns (bool success);

    /// authenticator-reset
    function reset(address to)
    external
    returns (bool success);

    /// authenticator-grant-role
    function grantRole(address to, string memory caption, bool reset)
    external
    returns (bool success);

    event KeyGranted(address indexed to, string indexed key);
    event KeyRevoked(address indexed from, string indexed key);
    event Approved(address indexed from, string indexed requiredKey);

    event ConsumableKeyGranted(address indexed to, string indexed consumableKey);
    event ConsumableKeyConsumed(address from, string indexed consumableKey);
    event ConsumableApproved(address indexed from, string indexed consumableKey);

    event TimedKeyGranted(address indexed to, string indexed timedKey, uint startTimestamp, uint endTimestamp, uint duration);
    event TimedKeyRevoked(address indexed to, string indexed timedKey);
    event TimedApproved(address indexed from, string indexed timedKey);

    event RoleCreated(string caption, string[] indexed keys_, string[] indexed consumableKeys_, string[] indexed timeKeys_, uint[] startTimestamps, uint[] durations);
    event RoleDeleted(string caption);
    event Reset(address to);
    event RoleGranted(address indexed to, string indexed caption, bool indexed reset);

    error KeyNotAvailable(address caller, string requiredKey);
    error UnableToGrantKey(address to, string key, bool consumable, bool timed);
    error UnableToRevokeKey(address from, string key, bool consumable, bool timed);
    error LengthMismatch(uint len1, uint len2, uint len3);
}

/** KEY NAMING CONVENSION
** key intended to be used as standard, consumable, and timed.
    <contract name>-<function-name>

** keys intended to only be used for one specific type.
    <type>-<contract name>-<function name>
    ie. timed-authenticator-grant-timed

** please pay attention to naming convention.
 */

/**
Current Limitations.
    - may not scale well with large sets of keys.
    - may become expensive as storage becomes larger. 

Advantages.
    - ability to transfer data as array to future upgraded contract.
 */
contract Authenticator is IAuthenticator {

    /// allows to create custom roles with pre existing key access.
    struct Role {
        string caption;
        string[] keys;
        string[] consumableKeys;
        string[] timedKeys;
        uint[] timedKeysStartTimestamp;
        uint[] timedKeysDurations;
    }

    mapping(string => Role) public roles;
    mapping(address => string[]) public keys;
    mapping(address => string[]) public consumableKeys;
    mapping(address => string[]) public timedKeys;
    mapping(address => mapping(string => uint)) public timedKeysStartTimestamp;
    mapping(address => mapping(string => uint)) public timedKeysEndTimestamp;

    constructor() {
        /// create authenticator role.
        string[] memory keys_;
        keys_[0] = "authenticator-grant-key";
        keys_[1] = "authenticator-revoke-key";
        keys_[2] = "authenticator-consume";
        keys_[3] = "authenticator-grant-consumable";
        keys_[4] = "authenticator-grant-timed";
        keys_[5] = "authenticator-revoke-timed";
        keys_[6] = "authenticator-create-role";
        keys_[7] = "authenticator-delete-role";
        keys_[8] = "authenticator-reset";
        keys_[9] = "authenticator-grant-role";
        _createRole("authenticator", keys_, new string[](0), new string[](0), new uint[](0), new uint[](0));
        _grantRole(msg.sender, "authenticator", false);
    }

    /// ------
    /// ACCESS.
    /// ------

    function _grantKey(address to, string memory key)
        private
        returns (bool) {
        /// looks for an empty result to store new key at.
        bool success;
        for (uint i = 0; i < keys[to].length; i ++) {
            string memory result = keys[to][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(""))) {
                keys[to][i] = key;
                success = true;
            }
        }

        /// no empty result was found then push as is to array.
        if (!success) {
            keys[to].push(key);
            success = true;
        }

        if (!success) { revert UnableToGrantKey(to, key, false, false); }

        emit KeyGranted(to, key);
        return success;
    }

    function _revokeKey(address from, string memory key)
        private
        returns (bool) {
        bool success;
        for (uint i = 0; i < keys[from].length; i ++) {
            string memory result = keys[from][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(key))) {
                keys[from][i] = "";
                success = true;
                break;
            }
        }

        if (!success) { revert UnableToRevokeKey(from, key, false, false); }

        emit KeyRevoked(from, key);
        return success;
    }

    /** WARNING
    * NOTE search hierarchy (assuming all options enabled) works as such:
    * 1) standard key
    * 2) consumable key
    * 3) timed key
    
    * if a key has the same name accross each type -
    * it will prioritize normal key search first -
    * when naming keys please refer to naming convention.
     */
    /// it is preferable to use the specialized authenticators for each case but a general one can be used if any type is accepted.
    function authenticate(address from, string memory key, bool canBeConsumable, bool canBeTimed)
        public
        returns (bool) {
        bool success;
        for (uint i = 0; i < keys[from].length; i ++) {
            string memory result = keys[from][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(key))) {
                success = true;
                break;
            }
        }

        /// if canBeConsumable is enabled allow for consumableKey search.
        if (!success && canBeConsumable) {
            success = authenticateConsumable(from, key);
        }

        /// if can be timed and the key still has not been found check timed.
        if (!success && canBeTimed) {
            success = authenticateTimed(from, key);
        }

        /// if no key was found in both then send revert error.
        if (!success) { revert KeyNotAvailable(msg.sender, key); }

        /// emit Approved(from, key);
        return success;
    }

    function grantKey(address to, string memory key)
        external
        returns (bool) {
        authenticate(msg.sender, "authenticator-grant-key", true, true);
        bool success = _grantKey(to, key);
        return success;
    }

    function revokeKey(address from, string memory key)
        external
        returns (bool) {
        authenticate(msg.sender, "authenticator-revoke-key", true, true);
        bool success = _revokeKey(from, key);
        return success;
    }

    /// -----------------
    /// CONSUMABLE ACCESS.
    /// -----------------

    function _grantConsumable(address to, string memory consumableKey)
        private
        returns (bool) {
        /// looks for an empty result to store new key at.
        bool success;
        for (uint i = 0; i < consumableKeys[to].length; i ++) {
            string memory result = consumableKeys[to][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(""))) {
                consumableKeys[to][i] = consumableKey;
                success = true;
            }
        }

        /// no empty result was found then push as is to array.
        if (!success) {
            consumableKeys[to].push(consumableKey);
            success = true;
        }

        if (!success) { revert UnableToGrantKey(to, consumableKey, true, false); }

        emit ConsumableKeyGranted(to, consumableKey);
        return success;
    }

    function _consume(address from, string memory consumableKey)
        private
        returns (bool) {
        /// looks for a matching result and removes the first matching result found.
        /// note if there are multiple keys of the same type it will only consume one.
        bool success;
        for (uint i = 0; i < consumableKeys[from].length; i ++) {
            string memory result = consumableKeys[from][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(consumableKey))) {
                /// remove.
                consumableKeys[from][i] = "";
                success = true;
                break;
            }
        }

        if (!success) { revert UnableToRevokeKey(from, consumableKey, true, false); }

        emit ConsumableKeyConsumed(from, consumableKey);
        return success;
    }

    function authenticateConsumable(address from, string memory consumableKey)
        public
        returns (bool) {
        bool success = _consume(from, consumableKey);
        if (!success) { revert KeyNotAvailable(from, consumableKey); }
        emit ConsumableApproved(from, consumableKey);
        return success;
    }

    function grantConsumable(address to, string memory consumableKey)
        external
        returns (bool) {
        authenticate(msg.sender, "authenticator-grant-consumable", true, true);
        bool success = _grantConsumable(to, consumableKey);
        return success;
    }

    function consume(address from, string memory consumableKey)
        external
        returns (bool) {
        authenticate(msg.sender, "authenticator-consume", true, true);
        bool success = _consume(from, consumableKey);
        return success;
    }

    /// ------------
    /// TIMED ACCESS.
    /// ------------

    function _grantTimed(address to, string memory timedKey, uint startTimestamp, uint duration)
        private
        returns (bool) {
        /// looks for an empty result to store new key at.
        bool success;
        for (uint i = 0; i < timedKeys[to].length; i ++) {
            string memory result = timedKeys[to][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(""))) {
                timedKeys[to][i] = timedKey;
                success = true;
            }
        }

        /// no empty result was found then push as is to array.
        if (!success) {
            timedKeys[to].push(timedKey);
            success = true;
        }

        if (!success) { revert UnableToGrantKey(to, timedKey, false, true); }

        /// set start and end of access.
        timedKeysStartTimestamp[to][timedKey] = startTimestamp;
        timedKeysEndTimestamp[to][timedKey] = startTimestamp + duration;

        emit TimedKeyGranted(to, timedKey, startTimestamp, timedKeysEndTimestamp[to][timedKey], duration);
        return success;
    }

    function _revokeTimed(address from, string memory timedKey)
        private
        returns (bool) {
        bool success;
        for (uint i = 0; i < timedKeys[from].length; i ++) {
            string memory result = timedKeys[from][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(timedKey))) {
                timedKeys[from][i] = "";
                success = true;
                break;
            }
        }

        if (!success) { revert UnableToRevokeKey(from, timedKey, false, true); }

        emit TimedKeyRevoked(from, timedKey);
        return success;
    }

    function authenticateTimed(address from, string memory timedKey)
        public
        returns (bool) {
        bool success;
        for (uint i = 0; i < timedKeys[from].length; i ++) {
            string memory result = timedKeys[from][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(timedKey))) {
                /// also check if access has started or has expired.
                uint start = timedKeysStartTimestamp[from][timedKey];
                uint end = timedKeysEndTimestamp[from][timedKey];
                uint now_ = block.timestamp;
                if (now_ >= start && now_ < end) { success = true; }
                break;
            }
        }

        if (!success) { revert KeyNotAvailable(from, timedKey); }

        emit TimedApproved(from, timedKey);
        return success;
    }

    function grantTimed(address to, string memory timedKey, uint startTimestamp, uint duration)
        external
        returns (bool success) {
        authenticate(msg.sender, "authenticator-grant-timed", true, true);
        return _grantTimed(to, timedKey, startTimestamp, duration);
    }

    function revokeTimed(address to, string memory timedKey)
        external
        returns (bool success) {
        authenticate(msg.sender, "authenticator-revoke-timed", true, true);
        return _revokeTimed(to, timedKey);
    }

    /// -----
    /// ROLES.
    /// -----

    function _createRole(string memory caption, string[] memory keys_, string[] memory consumableKeys_, string[] memory timedKeys_, uint[] memory startTimestamps, uint[] memory durations) 
        private
        returns (bool success) {
        /// creates a role with preset keys.
        Role storage role = roles[caption];
        role.caption = caption;
        
        for (uint i = 0; i < keys_.length; i ++) {
            role.keys.push(keys_[i]);
        }

        for (uint i = 0; i < consumableKeys_.length; i ++) {
            role.consumableKeys.push(consumableKeys_[i]);
        }

        /// check that the last three arrays must be equal in length or caller has made a mistake.
        uint lenTimedKeys = timedKeys_.length;
        uint lenTimestamps = startTimestamps.length;
        uint lenDurations = durations.length;
        bool allEqualToEachOther = lenTimedKeys == lenTimestamps && lenTimestamps == lenDurations && lenDurations == lenTimedKeys;
        if (!allEqualToEachOther) { revert LengthMismatch(lenTimedKeys, lenTimestamps, lenDurations); }
        
        /// push params.
        for (uint i = 0; i < timedKeys_.length; i ++) {
            role.timedKeys.push(timedKeys_[i]);
            role.timedKeysStartTimestamp.push(startTimestamps[i]);
            role.timedKeysDurations.push(durations[i]);
        }

        emit RoleCreated(caption, keys_, consumableKeys_, timedKeys_, startTimestamps, durations);
        return true;
    }

    function _deleteRole(string memory caption)
        private
        returns (bool success) {
        /// deletes all preset keys.
        Role storage role = roles[caption];
        delete role.keys;
        delete role.consumableKeys;
        delete role.timedKeys;
        delete role.timedKeysStartTimestamp;
        delete role.timedKeysDurations;

        emit RoleDeleted(caption);
        return true;
    }

    function _reset(address to)
        private
        returns (bool success) {
        delete keys[to];
        delete consumableKeys[to];

        /// iterate over each timestamp data for timed key before deletion.
        for (uint i = 0; i < timedKeys[to].length; i ++) {
            string memory result = timedKeys[to][i];
            delete timedKeysStartTimestamp[to][result];
            delete timedKeysEndTimestamp[to][result];
        }

        /// delete timedKeys.
        delete timedKeys[to];

        emit Reset(to);
        return true;
    }

    function _grantRole(address to, string memory caption, bool reset_)
        private
        returns (bool) {
        Role memory role = roles[caption];

        /// option to reset all keys before role is granted.
        if (reset_) { _reset(to); }
        
        for (uint i = 0; i < role.keys.length; i ++) {
            keys[to].push(role.keys[i]);
        }

        for (uint i = 0; i < role.consumableKeys.length; i ++) {
            consumableKeys[to].push(role.consumableKeys[i]);
        }

        for (uint i = 0; i < role.timedKeys.length; i ++) {
            string memory key_ = role.timedKeys[i];
            timedKeys[to].push(key_);
            timedKeysStartTimestamp[to][key_] = role.timedKeysStartTimestamp[i];
            timedKeysEndTimestamp[to][key_] = role.timedKeysStartTimestamp[i] + role.timedKeysDurations[i];
        }

        emit RoleGranted(to, caption, reset_);
        return true;
    }

    function createRole(string memory caption, string[] memory keys_, string[] memory consumableKeys_, string[] memory timedKeys_, uint[] memory startTimestamps, uint[] memory durations)
        external
        returns (bool) {
        authenticate(msg.sender, "authenticator-create-role", true, true);
        return _createRole(caption, keys_, consumableKeys_, timedKeys_, startTimestamps, durations);
    }

    function deleteRole(string memory caption)
        external
        returns (bool success) {
        authenticate(msg.sender, "authenticator-delete-role", true, true);
        return _deleteRole(caption);
    }

    function reset(address to)
        external
        returns (bool success) {
        authenticate(msg.sender, "authenticator-reset", true, true);
        return _reset(to);
    }

    function grantRole(address to, string memory caption, bool reset_)
        external
        returns (bool success) {
        authenticate(msg.sender, "authenticator-grant-role", true, true);
        return _grantRole(to, caption, reset_);
    }
}