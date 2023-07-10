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

        require(success, "Authenticator: INSUFFICIENT_AUTHENTICATION");

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

contract Authenticator {
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
    
    /// @dev function does not revert if false.
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

    /// @dev function does not revert if false.
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

    /// @dev function does not revert if false.
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

        return success;
    }

    // ---------------
    // CONSUMABLE KEYS.
    // ---------------

    /// @dev function does not revert if false.
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

    /// @dev function does not revert if false.
    function consume(address from, string memory key)
        external
        returns (bool) {
        authenticate(msg.sender, "authenticator-consume", true, true, true);

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

    /// @dev function does not revert if false.
    function authenticateConsumableKey(address from, string memory requiredKey)
        public
        returns (bool) {
        bool success;

        if (_accountsAddresses.contains(from)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            success = Lib.authenticateConsumableKey(account, requiredKey);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(from);
            addressToAccountsMapping[from] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            success = Lib.authenticateConsumableKey(account, requiredKey);
        }

        return success;
    }

    // ----------
    // TIMED KEYS.
    // ----------

    /// @dev function does not revert if false.
    function grantTimedKey(address to, string memory key, uint startTimestamp, uint duration)
        external
        returns (bool) {
        authenticate(msg.sender, "authenticator-grant-timed-key", true, true, true);

        if (_accountsAddresses.contains(to)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            Lib.grantTimedKey(account, key, startTimestamp, duration);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(to);
            addressToAccountsMapping[to] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            Lib.grantTimedKey(account, key, startTimestamp, duration);          
        }
        
        return true;
    }

    /// @dev function does not revert if false.
    function revokeTimedKey(address from, string memory key)
        external
        returns (bool) {
        authenticate(msg.sender, "authenticator-revoke-timed-key", true, true, true);

        if (_accountsAddresses.contains(from)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            Lib.revokeTimedKey(account, key);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(from);
            addressToAccountsMapping[from] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            Lib.revokeTimedKey(account, key);          
        }
        
        return true;
    }

    // -------
    // BUNDLES.
    // -------

    function _isExistingBundle(string memory label)
        private view
        returns (bool) {
        if (labelToBundlesMapping[label] != 0) { return true; }
        else { return false; }
    }

    function createBundle(string memory label, string[] memory keys, string[] memory consumableKeys, Lib.TimedKey[] memory timedKeys)
        external
        returns (bool, uint) {
        require(!_isExistingBundle(label), "Authenticator: Unable to create bundle because there is already a bundle with the given label.");
        
        authenticate(msg.sender, "authenticator-create-bundle", true, true, true);

        // if label is not being used.
        if (labelToBundlesMapping[label] != 0) {
            (bool success, uint identifier) = Lib.createBundle(_bundles, tracker, keys, consumableKeys, timedKeys);
            labelToBundlesMapping[label] = identifier;


        (bool success, uint identifier) = Lib.createBundle(_bundles, tracker, keys, consumableKeys, timedKeys);
        labelToBundlesMapping[label] = identifier;
        return (success, identifier);
    }

    function grantBundle(address to, string memory label)
        external
        returns (bool) {
        require(_isExistingBundle(label), "Authenticator: Unable to grant bundle because there is no existing bundle with the given label.");

        authenticate(msg.sender, "authenticator-grant-bundle", true, true, true);

        if (_accountsAddresses.contains(to)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            bool success = Lib.grantBundle(account, _bundles, labelToBundlesMapping[label]);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(to);
            addressToAccountsMapping[to] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            bool success = Lib.grantBundle(account, _bundles, labelToBundlesMapping[label]);        
        }

        require(success, "Authenticator: Unable to grant bundle due to unsuccessful execution.");
        return true;
    }

    function revokeBundle(address from, string memory label)
        external
        returns (bool) {
        require(_isExistingBundle(label), "Authenticator: Unable to revoke bundle because there is no existing bundle with the given label.");

        authenticate(msg.sender, "authenticator-revoke-bundle", true, true, true);

        if (_accountsAddresses.contains(to)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            bool success = Lib.revokeBundle(account, _bundles, labelToBundlesMapping[label]);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(to);
            addressToAccountsMapping[to] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            bool success = Lib.revokeBundle(account, _bundles, labelToBundlesMapping[label]);        
        }
    }

    function deleteBundle(string memory label)
        external
        returns (bool) {
        require(_isExistingBundle(label), "Authenticator: Unable to delete bundle because there is no existing bundle with the given label.");

        authenticate(msg.sender, "authenticator-delete-bundle", true, true, true);

        bool success = Lib.deleteBundle(_bundles, labelToBundlesMapping[label]);

        require(success, "Authenticator: Unable to delete bundle due to unsuccessful execution.");

        labelToBundlesMapping[label] = 0;
        return success;
    }

    function copyBundle(string memory labelA, string memory labelB)
        external
        returns (bool, uint) {
        require(_isExistingBundle(labelA), "Authenticator: Unable to copy bundle because there is no existing bundle with the given label.");

        authenticate(msg.sender, "authenticator-copy-bundle", true, true, true);

        // creates a new bundle with the keys of the given bundle.
        (bool success, uint newIdentifier) = Lib.copyBundle(labelToBundlesMapping[labelA], _bundles, tracker);

        require(success, "Authenticator: Unable to copy bundle due to unsuccessful execution.");
        labelToBundlesMapping[labelB] = newIdentifier;
        return (success, newIdentifier);
    }

    function mergeBundles(string[] memory mergedBundlesLabels, string memory label)
        external
        returns (bool, uint) {
        uint[] memory identifiers;
        for (uint i = 0; i < mergedBundlesLabels.length; i++) {
            require(_isExistingBundle(mergedBundlesLabels[i]), "Unable to merge bundles because a label does not point to an existing bundle.");
            identifiers[i] = labelToBundlesMapping[mergedBundlesLabels[i]];
        }

        authenticate(msg.sender, "authenticator-merge-bundles", true, true, true);

        // creates a new bundle with the merged keys given.
        (bool success, uint newIdentifier) = Lib.mergeBundles(identifiers, _bundles, tracker);

        require(success, "Authenticator: Unable to merge bundles due to unsuccessful execution.");
        labelToBundlesMapping[label] = newIdentifier;
        return (success, newIdentifier);
    }
}