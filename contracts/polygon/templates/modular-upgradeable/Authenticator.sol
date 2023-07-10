// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
/// @author Marco Bizzaro

/**
1) Can create key for every function within a contract in a dynamic way.
2) Can create 3 types of keys: standard key, consumable key, and timed key.
 */
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

    error RoleIsAlreadyInUse(string caption);
}

library Lib {
    struct TimedKey {
        string key;
        uint startTimestamp;
        uint endTimestamp;
        uint duration;
    }

    struct Account {
        string[] keys;
        string[] consumableKeys;
        TimedKey[] timedKeys;
    }

    struct Tracker { uint numBundles; }

    // ---------
    // UTILITIES.
    // ---------

    function compare(string memory stringA, string memory stringB)
        public pure
        returns (bool) {
        return keccak256(abi.encodePacked(stringA)) == keccak256(abi.encodePacked(stringB));
    }

    function allThreeAreEqual(uint a, uint b, uint c)
        public pure
        returns (bool, uint) {
        bool isEqual = a == b && b == c && c == a;
        uint sum = a + b + c;
        return (isEqual, sum);
    }

    // -------------
    // STANDARD KEYS.
    // -------------

    /// @dev function does not revert if false.
    function grantStandardKey(Account storage account, string memory key)
        public
        returns (bool) {
        bool matchWasFound;
        bool success;

        uint len = account.keys.length;

        // check for a match.
        for (uint i = 0; i < len; i++) {
            matchWasFound = compare(account.keys[i], key);
            if (matchWasFound) {
                success = true;
                break;
            }
        }

        // if a match was not found.
        if (!matchWasFound) {

            // look for empty string.
            for (uint i = 0; i < len; i++) {
                if (compare(account.keys[i], "")) {
                    account.keys[i] = key;
                    success = true;
                    break;
                }
            }

            // if no empty string then push.
            if (!success) {
                account.keys.push(key);
                success = true;
            }
        }

        return success;
    }

    /// @dev function does not revert if false.
    function revokeStandardKey(Account storage account, string memory key)
        public
        returns (bool) {
        bool success;
        
        for (uint i = 0; i < account.keys.length; i++) {
            if (compare(account.keys[i], key)) {
                account.keys[i] = "";
                success = true;
                break;
            }
        }

        return success;
    }

    /// @dev function does not revert if false.
    function authenticate(Account storage account, string memory requiredKey, bool lookForStandardKey, bool lookForConsumableKey, bool lookForTimedKey)
        public
        returns (bool) {
        bool success;
        
        // will look for a standard key as valid authentication.
        if (!success && lookForStandardKey) {
            for (uint i = 0; i < account.keys.length; i++) {
                if (compare(account.keys[i], requiredKey)) {
                    success = true;
                    break;
                }
            }
        }

        // will look for consumable key as valid authentication.
        if (!success && lookForConsumableKey) { success = authenticateConsumableKey(account, requiredKey); }
        

        // will look for timed key as valid authentication.
        if (!success && lookForTimedKey) { success = authenticateTimedKey(account, requiredKey); }

        return success;
    }

    // ---------------
    // CONSUMABLE KEYS.
    // ---------------

    /// @dev function does not revert if false.
    function grantConsumableKey(Account storage account, string memory key)
        public
        returns (bool) {
        bool matchWasFound;
        bool success;

        uint len = account.consumableKeys.length;

        // check for a match.
        for (uint i = 0; i < len; i++) {
            matchWasFound = compare(account.consumableKeys[i], key);
            if (matchWasFound) {
                success = true;
                break;
            }
        }

        // if a match was not found.
        if (!matchWasFound) {

            // look for empty string.
            for (uint i = 0; i < len; i++) {
                if (compare(account.consumableKeys[i], "")) {
                    account.keys[i] = key;
                    success = true;
                    break;
                }
            }

            // if no empty string then push.
            if (!success) {
                account.consumableKeys.push(key);
                success = true;
            }
        }

        return success;
    }

    /// @dev function does not revert if false.
    function consume(Account storage account, string memory key)
        public
        returns (bool) {
        bool success;
        for (uint i = 0; i < account.consumableKeys.length; i++) {
            if (compare(account.consumableKeys[i], key)) {
                // remove.
                account.consumableKeys[i] = "";
                success = true;
                break;
            }
        }

        return success;
    }

    /// @dev function does not revert if false.
    function authenticateConsumableKey(Account storage account, string memory requiredKey)
        public
        returns (bool) {
        bool success = consume(account, requiredKey);

        return success;
    }

    // ----------
    // TIMED KEYS.
    // ----------

    /// @dev function does not revert if false.
    function grantTimedKey(Account storage account, string memory key, uint startTimestamp, uint duration)
        public
        returns (bool) {
        // look for match.
        bool matchWasFound;
        bool success;

        uint len = account.timedKeys.length;

        TimedKey memory timedKey = TimedKey({
            key: key,
            startTimestamp: startTimestamp,
            endTimestamp: startTimestamp + duration,
            duration: duration
        });

        // check for a match.
        for (uint i = 0; i < len; i++) {
            matchWasFound = compare(account.timedKeys[i].key, key);
            if (matchWasFound) {
                success = true;
                break;
            }
        }

        // if a match was not found.
        if (!matchWasFound) {

            // look for empty string.
            for (uint i = 0; i < len; i++) {
                if (compare(account.timedKeys[i].key, "")) {
                    account.timedKeys[i] = timedKey;
                    success = true;
                    break;
                }
            }

            // if no empty string then push.
            if (!success) {
                account.timedKeys.push(timedKey);
                success = true;
            }
        }

        return success;
    }

    /// @dev function does not revert if false.
    function revokeTimedKey(Account storage account, string memory key)
        public
        returns (bool) {
        bool success;
        
        for (uint i = 0; i < account.timedKeys.length; i++) {
            if (compare(account.timedKeys[i].key, key)) {
                account.timedKeys[i].key = "";
                account.timedKeys[i].startTimestamp = 0;
                account.timedKeys[i].endTimestamp = 0;
                account.timedKeys[i].duration = 0;
                success = true;
                break;
            }
        }

        return success;
    }

    /// @dev function does not revert if false.
    function authenticateTimedKey(Account storage account, string memory requiredKey)
        public view
        returns (bool) {
        bool success;

        for (uint i = 0; i < account.timedKeys.length; i++) {
            if (compare(account.timedKeys[i].key, requiredKey)) {
                success = true;
                break;
            }
        }

        return success;
    }
    
    // -------
    // BUNDLES.
    // -------
    
    /// @dev function does not revert if false.
    function createBundle(Account[] storage accounts, Tracker storage tracker, string[] memory keys, string[] memory consumableKeys, TimedKey[] memory timedKeys)
        public
        returns (bool, uint) {
        // check if it is in use.
        (bool success, uint sum) = allThreeAreEqual(keys.length, consumableKeys.length, timedKeys.length);
        tracker.numBundles ++;
        uint identifier = tracker.numBundles;
        if (success && sum == 0) {
            Account storage account = accounts[identifier];

            for (uint i = 0; i < keys.length; i++) {
                grantStandardKey(account, keys[i]);
            }

            for (uint i = 0; i < consumableKeys.length; i++) {
                grantConsumableKey(account, consumableKeys[i]);
            }

            for (uint i = 0; i < timedKeys.length; i++) {
                grantTimedKey(account, timedKeys[i].key, timedKeys[i].startTimestamp, timedKeys[i].duration);
            }
        }
        
        // return success and unique identifier for new bundle.
        return (success, identifier);
    }

    /// @dev function does not revert if false.
    function grantBundle(Account storage account, Account[] storage accounts, uint identifier)
        public
        returns (bool) {
        Account storage bundle = accounts[identifier];
        
        for (uint i = 0; i < bundle.keys.length; i++) {
            grantStandardKey(account, bundle.keys[i]);
        }

        for (uint i = 0; i < bundle.consumableKeys.length; i++) {
            grantConsumableKey(account, bundle.consumableKeys[i]);
        }

        for (uint i = 0; i < bundle.timedKeys.length; i++) {
            grantTimedKey(account, bundle.timedKeys[i].key, bundle.timedKeys[i].startTimestamp, bundle.timedKeys[i].duration);
        }

        return true;
    }

    /// @dev function does not revert if false.
    function revokeBundle(Account storage account, Account[] storage accounts, uint identifier)
        public
        returns (bool) {
        Account storage bundle = accounts[identifier];

        for (uint i = 0; i < bundle.keys.length; i++) {
            revokeStandardKey(account, bundle.keys[i]);
        }

        for (uint i = 0; i < bundle.consumableKeys.length; i++) {

            // consume only consumes the first match found so we try to consume every key within the account.
            for (uint x = 0; x < account.consumableKeys.length; x++) {
                consume(account, bundle.consumableKeys[i]);
            }
        }

        for (uint i = 0; i < bundle.timedKeys.length; i++) {
            revokeTimedKey(account, bundle.timedKeys[i].key);
        }

        return true;
    }

    /// @dev function does not revert if false.
    function deleteBundle(Account[] storage accounts, uint identifier)
        public
        returns (bool) {
        Account storage bundle = accounts[identifier];
        
        // completely reset the bundle.
        for (uint i = 0; i < bundle.keys.length; i++) {
            bundle.keys[i] = "";
        }

        for (uint i = 0; i < bundle.consumableKeys.length; i++) {
            bundle.consumableKeys[i] = "";
        }

        for (uint i = 0; i < bundle.timedKeys.length; i++) {
            bundle.timedKeys[i].key = "";
            bundle.timedKeys[i].startTimestamp = 0;
            bundle.timedKeys[i].endTimestamp = 0;
            bundle.timedKeys[i].duration = 0;
        }

        return true;
    }

    /// @dev function does not revert if false.
    function copyBundle(uint identifier, Account[] storage accounts, Tracker storage tracker)
        public
        returns (bool, uint) {
        string[] memory keys;
        string[] memory consumableKeys;
        TimedKey[] memory timedKeys;

        Account storage copiedBundle = accounts[identifier];

        // create empty bundle.
        (, identifier) = createBundle(accounts, tracker, keys, consumableKeys, timedKeys);
        Account storage newBundle = accounts[identifier];

        for (uint i = 0; i < copiedBundle.keys.length; i++) {
            grantStandardKey(newBundle, copiedBundle.keys[i]);
        }

        for (uint i = 0; i < copiedBundle.consumableKeys.length; i++) {
            grantConsumableKey(newBundle, copiedBundle.consumableKeys[i]);
        }

        for (uint i = 0; i < copiedBundle.timedKeys.length; i++) {
            grantTimedKey(newBundle, copiedBundle.timedKeys[i].key, copiedBundle.timedKeys[i].startTimestamp, copiedBundle.timedKeys[i].duration);
        }

        return (true, identifier);
    }

    /// @dev function does not revert if false.
    function mergeBundles(uint[] memory mergedBundles, Account[] storage accounts, Tracker storage tracker)
        public
        returns (bool, uint) {
        string[] memory keys;
        string[] memory consumableKeys;
        TimedKey[] memory timedKeys;

        // create empty bundle.
        (, uint identifier) = createBundle(accounts, tracker, keys, consumableKeys, timedKeys);
        Account storage newBundle = accounts[identifier];

        // merge bundles into a new bundle.
        for (uint i = 0; i < mergedBundles.length; i++) {
            Account storage bundle = accounts[mergedBundles[i]];

            for (uint x = 0; x < bundle.keys.length; x++) {
                grantStandardKey(newBundle, bundle.keys[x]);
            }

            for (uint x = 0; x < bundle.consumableKeys.length; x++) {
                grantConsumableKey(newBundle, bundle.consumableKeys[x]);
            }

            for (uint x = 0; x < bundle.timedKeys.length; x++) {
                grantTimedKey(newBundle, bundle.timedKeys[x].key, bundle.timedKeys[x].startTimestamp, bundle.timedKeys[x].duration);
            }
        }

        return (true, identifier);
    }
}

contract Authenticator2 {
    using EnumerableSet for EnumerableSet.AddressSet;
    Lib.Account[] private _accounts;
    Lib.Account[] private _bundles;

    Lib.Tracker public tracker;

    EnumerableSet.AddressSet private _accountsAddresses;

    mapping(address => uint) public addressToAccountsMapping;
    mapping(string => uint) public labelToBundlesMapping;

    constructor() {}

    // -------------
    // STANDARD KEYS.
    // -------------
    
    function grantStandardKey(address to, string memory key)
        external
        returns (bool) {
        authenticate(msg.sender, "authenticator-grant-standard-key", true, true, true);

        if (_accountsAddresses.contains(to)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            Lib.grantStandardKey(account, key);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(to);
            addressToAccountsMapping[to] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            Lib.grantStandardKey(account, key);            
        }
        
        return true;
    }

    function revokeStandardKey(address from, string memory key)
        external
        returns (bool) {
        authenticate(msg.sender, "authenticator-revoke-standard-key", true, true, true);

        if (_accountsAddresses.contains(from)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            Lib.revokeStandardKey(account, key);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(from);
            addressToAccountsMapping[from] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            Lib.revokeStandardKey(account, key);
        }

        return true;
    }

    function authenticate(address from, string memory requiredKey, bool lookForStandardKey, bool lookForConsumableKey, bool lookForTimedKey)
        public
        returns (bool) {
        bool success;

        if (_accountsAddresses.contains(from)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            success = Lib.authenticate(account, requiredKey, lookForStandardKey, lookForConsumableKey, lookForTimedKey);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(from);
            addressToAccountsMapping[from] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            success = Lib.authenticate(account, requiredKey, lookForStandardKey, lookForConsumableKey, lookForTimedKey);
        }

        require(
            success,
            "Authenticator: INSUFFICIENT_AUTHENTICATION"
        );

        return success;
    }

    // ---------------
    // CONSUMABLE KEYS.
    // ---------------

    function grantConsumableKey(address to, string memory key)
        external
        returns (bool) {
        authenticate(msg.sender, "authenticator-grant-consumable-key", true, true, true);

        if (_accountsAddresses.contains(to)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            Lib.grantConsumableKey(account, key);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(to);
            addressToAccountsMapping[to] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            Lib.grantConsumableKey(account, key);           
        }
        
        return true;
    }

    function consume(address from, string memory key)
        external
        returns (bool) {
        if (_accountsAddresses.contains(from)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            Lib.consume(account, key);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(from);
            addressToAccountsMapping[from] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            Lib.consume(account, key);         
        }

        return true;
    }

    // ... wip

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

    /// ---------
    /// UTILITIES.
    /// ---------

    /// compare 2 strings.
    function _compare(string memory stringA, string memory stringB)
        private pure
        returns (bool) {
        bool matchWasFound;
        if (keccak256(abi.encodePacked(stringA)) == keccak256(abi.encodePacked(stringB))) {
            matchWasFound = true;
        }

        return matchWasFound;
    }

    /// ------
    /// ACCESS.
    /// ------

    function _grantKey(address to, string memory key)
        private
        returns (bool) {
        bool matchWasFound;
        bool success;
        /// check for a match.
        for (uint i = 0; i < keys[to].length; i++) {
            string memory result = keys[to][i];
            bool isDuplicate = _compare(result, key);
            if (isDuplicate) {
                matchWasFound = true;
                success = true;
                break;
            }
        }

        /// if a match was not found then we push one.
        if (!matchWasFound) {
            
            /// first we try to push one into an empty spot.
            for (uint i = 0; i < keys[to].length; i++) {
                string memory result = keys[to][i];
                bool isEmpty = _compare(result, "");
                if (isEmpty) {
                    keys[to][i] = key;
                    success = true;
                    break;
                }
            }

            /// if no empty spot was found then we push the key.
            if (!success) {
                keys[to].push(key);
                success = true;
            }
        }

        /// if something went wrong throw costum error.
        if (!success) { revert UnableToGrantKey(to, key, false, false); }
        
        emit KeyGranted(to, key);
        return success;
    }

    function _revokeKey(address from, string memory key)
        private
        returns (bool) {
        bool success;
        /// if found will remove and set entry as "".
        for (uint i = 0; i < keys[from].length; i ++) {
            string memory result = keys[from][i];
            if (_compare(result, key)) {
                keys[from][i] = "";
                success = true;
                break;
            }
        }

        /// if something went wrong throw costum error.
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
        /// look for a match.
        for (uint i = 0; i < keys[from].length; i ++) {
            string memory result = keys[from][i];
            if (_compare(result, key)) {
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

    /** ROLES
        A role is like is a set of keys that are passed on to anyone with that role.
        It is a neat way of organizing groups of functions and can grant temp access or single use access.
    */

    /**
    * @param caption - unique name for the role.
    * 
    *
    *
     */
    function _createRole(string memory caption, string[] memory keys_, string[] memory consumableKeys_, string[] memory timedKeys_, uint[] memory startTimestamps, uint[] memory durations) 
        private
        returns (bool success) {
        Role storage role = roles[caption];
        role.caption = caption;

        /// check if role is already in use.
        uint len1 = role.keys.length;
        uint len2 = role.consumableKeys.length;
        uint len3 = role.timedKeys.length;
        if (len1 == 0 && len2 == 0 && len3 == 0) {
            revert RoleIsAlreadyInUse(caption);
        }

        /// make space.
        delete len1;
        delete len2;
        delete len3;
        
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

        /// reset keys.
        for (uint i = 0; i < role.keys.length; i ++) {
            role.keys[i] = "";
        }

        /// reset consumables.
        for (uint i = 0; i < role.consumableKeys.length; i ++) {
            role.consumableKeys[i] = "";
        }

        /// reset timed keys.
        for (uint i = 0; i < role.timedKeys.length; i ++) {
            role.timedKeysStartTimestamp[i] = 0;
            role.timedKeysDurations[i] = 0;
            role.timedKeys[i] = "";
        }

        emit RoleDeleted(caption);
        return true;
    }

    /// removes all keys from an account.
    function _reset(address to)
        private
        returns (bool success) {
        /// reset keys.
        for (uint i = 0; i < keys[to].length; i ++) {
            keys[to][i] = "";
        }

        /// reset consumable keys.
        for (uint i = 0; i < consumableKeys[to].length; i ++) {
            consumableKeys[to][i] = "";
        }

        /// reset timed keys and timestamps.
        for (uint i = 0; i < timedKeys[to].length; i ++) {
            timedKeysStartTimestamp[to][timedKeys[to][i]] = 0;
            timedKeysEndTimestamp[to][timedKeys[to][i]] = 0;
            timedKeys[to][i] = "";
        }

        emit Reset(to);
        return true;
    }

    /**
    * @param to      - address of grantee.
    * @param caption - role name.
    * @param reset_  - reset all keys for the address before granting role.
     */
    function _grantRole(address to, string memory caption, bool reset_)
        private
        returns (bool) {
        Role memory role = roles[caption];

        /// option to reset all keys before role is granted.
        if (reset_) { _reset(to); }
        
        for (uint i = 0; i < role.keys.length; i ++) {
            /// if key is not an empty string.
            bool isEmpty = _compare(role.keys[i], "");
            if (!isEmpty) {
                keys[to].push(role.keys[i]);
            }
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