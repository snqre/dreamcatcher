// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

interface IAuthenticator {
    event ConsumableKeyGranted(address indexed to, string indexed consumableKey);

    error KeyNotAvailable(address caller, string requiredKey);
    error UnableToGrantKey(address to, string key, bool consumable, bool timed);
    error UnableToRevokeKey(address from, string key, bool consumable, bool timed);
}

/** KEY NAMING CONVENSION
** key intended to be used as standard, consumable, and timed.
    <contract name>-<function name>

** keys intended to only be used for one specific type.
    <type>-<contract name>-<function name>
    ie. timed-authenticator-grantTimed

** please pay attention to naming convention.
 */

/**
Current Limitations.
    - may not scale well with large sets of keys.
    - may become expensive as storage becomes larger. 

Advantages.
    - ability to transfer data as array to future upgraded contract.
 */
contract Authenticator is IAuthenticator, Ownable {

    mapping(address => string[]) public consumableKeys;
    mapping(address => string[]) public keys;

    mapping(address => string[]) public timedKeys;
    mapping(address => mapping(string => uint)) public timedKeysStartTimestamp;
    mapping(address => mapping(string => uint)) public timedKeysEndTimestamp;

    constructor() Ownable(msg.sender) {
        _grantKey(msg.sender, "authenticator-grant-key");
        _grantKey(msg.sender, "authenticator-revoke-key");
        _grantKey(msg.sender, "authenticator-consume");
        _grantKey(msg.sender, "authenticator-grant-consumable");
    }

    /// ------
    /// ACCESS.
    /// ------

    function _grantKey(address to, string memory key)
        private
        returns (bool success) {
        /// looks for an empty result to store new key at.
        bool success;
        for (uint i = 0; i < keys.length; i ++) {
            string memory result = keys[from][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(""))) {
                keys[from][i] = key;
                success = true;
            }
        }

        /// no empty result was found then push as is to array.
        if (!success) {
            keys[to].push(key);
            success = true;
        }

        if (!success) { revert UnableToGrantKey(to, key, false, false); }
        return success;
    }

    function _revokeKey(address from, string memory key)
        private
        returns (bool success) {
        bool success;
        for (uint i = 0; keys.length; i ++) {
            string memory result = keys[from][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(key))) {
                keys[from][i] = "";
                success = true;
                break;
            }
        }

        if (!success) { revert UnableToRevokeKey(from, key, false, false); }
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
    /// it is preferable to use the specialized authenticators for each case but a general one can be used.
    function authenticate(address from, string memory key, bool canBeConsumable, bool canBeTimed)
        public view
        returns (bool success) {
        bool success;
        for (uint i = 0; keys.length; i ++) {
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
        return success;
    }

    function grantKey(address to, string memory key)
        external
        returns (bool success) {
        authenticate(msg.sender, "authenticator-grant-key", true);
        bool success = _grantKey(to, key);
        return success;
    }

    function revokeKey(address from, string memory key)
        external
        returns (bool success) {
        authenticate(msg.sender, "authenticator-revoke-key", true);
        bool success = _revokeKey(from, key);
        return success;
    }

    /// -----------------
    /// CONSUMABLE ACCESS.
    /// -----------------

    function _grantConsumable(address to, string memory consumableKey)
        private
        returns (bool success) {
        /// looks for an empty result to store new key at.
        bool success;
        for (uint i = 0; i < consumableKeys.length; i ++) {
            string memory result = consumableKeys[from][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(""))) {
                consumableKeys[from][i] = consumableKey;
                success = true;
            }
        }

        /// no empty result was found then push as is to array.
        if (!success) {
            consumableKeys[to].push(consumableKey);
            success = true;
        }

        if (!success) { revert UnableToGrantKey(to, consumableKey, true, false); }
        return success;
    }

    function _consume(address from, string memory consumableKey)
        private
        returns (bool success) {
        /// looks for a matching result and removes the first matching result found.
        /// note if there are multiple keys of the same type it will only consume one.
        bool success;
        for (uint i = 0; i < consumableKey.length; i ++) {
            string memory result = consumableKeys[from][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(consumableKey))) {
                /// remove.
                consumableKeys[from][i] = "";
                success = true;
                break;
            }
        }

        if (!success) { revert UnableToRevokeKey(from, consumableKey, true, false); }

        /// is false if no match of the key was found.
        return success;
    }

    function authenticateConsumable(address from, string memory consumableKey)
        public
        returns (bool success) {
        bool success = _consume(from, consumableKey);
        if (!success) { revert KeyNotAvailable(from, consumableKey); }
        return success;
    }

    function grantConsumable(address to, string memory consumableKey)
        external
        returns (bool success) {
        authenticate(msg.sender, "authenticator-grant-consumable", true);
        bool success = _grantConsumable(to, consumableKey);
        return success;
    }

    function consume(address from, string memory consumableKey)
        external
        returns (bool success) {
        authenticate(msg.sender, "authenticator-consume", true);
        bool success = _consume(from, consumableKey);
        return success;
    }

    /// ------------
    /// TIMED ACCESS.
    /// ------------

    function _grantTimedKey(address to, string memory timedKey, uint startTimestamp, uint duration)
        private
        returns (bool success) {
        /// looks for an empty result to store new key at.
        bool success;
        for (uint i = 0; i < timedKeys.length; i ++) {
            string memory result = timedKeys[from][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(""))) {
                timedKeys[from][i] = timedKey;
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
        return success;
    }

    function _revokeTimedKey(address to, string memory timedKey)
        private
        returns (bool success) {
        bool success;
        for (uint i = 0; timedKeys.length; i ++) {
            string memory result = timedKeys[from][i];
            if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked(timedKey))) {
                timedKeys[from][i] = "";
                success = true;
                break;
            }
        }

        if (!success) { revert UnableToRevokeKey(from, timedKey, false, true); }
        return success;
    }

    function authenticateTimed(address from, string memory timedKey)
        public view
        returns (bool success) {
        bool success;
        for (uint i = 0; timedKeys.length; i ++) {
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
        return success;
    }

    function grantTimed(address to, string memory timedKey, uint startTimestamp, uint duration)
        external
        returns (bool success) {
        authenticate(from, key, canBeConsumable, canBeTimed);
    }
}