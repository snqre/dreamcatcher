// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

interface IAuthenticator {
    // -------------
    // STANDARD KEYS.
    // -------------

    // key: authenticator-grant-standard-key
    function grantStandardKey(address to, string memory key)
        external
        returns (bool);

    // key: authenticator-revoke-standard-key
    function revokeStandardKey(address from, string memory key)
        external
        returns (bool);

    /// @dev **prefered means of authentication.
    function authenticate(address from, string memory requiredKey, bool lookForStandardKey, bool lookForConsumableKey, bool lookForTimedKey)
        external
        returns (bool);

    // ---------------
    // CONSUMABLE KEYS.
    // ---------------

    // key: authenticator-grant-consumable-key
    function grantConsumableKey(address to, string memory key)
        external
        returns (bool);
    
    // key: authenticator-consume
    function consume(address from, string memory key)
        external
        returns (bool);

    /// @dev **for most cases authenticate will be enough but its much faster to use specialized authentication.
    function authenticateConsumableKey(address from, string memory requiredKey)
        external
        returns (bool);
    
    // ----------
    // TIMED KEYS.
    // ----------
    
    // key: authenticator-grant-timed-key
    function grantTimedKey(address to, string memory key, uint startTimestamp, uint duration)
        external
        returns (bool);

    // key: authenticator-revoke-timed-key
    function revokeTimedKey(address from, string memory key)
        external
        returns (bool);
    
    /// @dev **for most cases authenticate will be enough but its much faster to use specialized authentication.
    function authenticateTimedKey(address from, string memory requiredKey)
        external
        returns (bool);
    
    // -------
    // BUNDLES.
    // -------

    // key: authenticator-create-bundle
    function createBundle(string memory label, string[] memory keys, string[] memory consumableKeys, Lib.TimedKey[] memory timedKeys)
        external
        returns (bool, uint);
    
    // key: authenticator-grant-bundle
    function grantBundle(address to, string memory label)
        external
        returns (bool);
    
    // key: authenticator-revoke-bundle
    function revokeBundle(address from, string memory label)
        external
        returns (bool);
    
    // key: authenticator-delete-bundle
    function deleteBundle(string memory label)
        external
        returns (bool);
    
    // key: authenticator-copy-bundle
    function copyBundle(string memory labelA, string memory labelB)
        external
        returns (bool, uint);
    
    // key: authenticator-merge-bundles
    function mergeBundles(string[] memory mergedBundlesLabels, string memory label)
        external
        returns (bool, uint);

    event StandardKeyGranted(address indexed to, string indexed key);
    event StandardKeyRevoked(address indexed from, string indexed key);
    event Authenticated(address indexed from, string indexed requiredKey);
    event ConsumableKeyGranted(address indexed to, string indexed key);
    event ConsumableKeyConsumed(address indexed from, string indexed key);
    event AuthenticatedConsumableKey(address indexed from, string indexed requiredKey);
    event TimedKeyGranted(address indexed to, string indexed key, uint startTimestamp, uint duration);
    event TimedKeyRevoked(address indexed from, string indexed key);
    event AuthenticatedTimedKey(address indexed from, string indexed requiredKey);
    event BundleCreated(string indexed label, string[] indexed keys, string[] indexed consumableKeys, Lib.TimedKey[] timedKeys);
    event BundleGranted(address indexed to, string indexed label);
    event BundleRevoked(address indexed from, string indexed label);
    event BundleDeleted(string indexed label);
    event BundleCopied(string indexed labelA, string indexed labelB);
    event BundleMerged(string[] indexed mergedBundlesLabels, string indexed label);
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

        require(success, "Authenticator: Unable to approve due to insufficient authorization.");

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

                // check timestamps.
                bool isAfterStart = block.timestamp >= account.timedKeys[i].startTimestamp;
                bool isBeforeEnd = block.timestamp < account.timedKeys[i].endTimestamp;
                
                if (isAfterStart && isBeforeEnd) { success = true; }
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

contract Authenticator is IAuthenticator {
    using EnumerableSet for EnumerableSet.AddressSet;
    Lib.Account[] private _accounts;
    Lib.Account[] private _bundles;

    Lib.Tracker public tracker;

    EnumerableSet.AddressSet private _accountsAddresses;

    mapping(address => uint) public addressToAccountsMapping;
    mapping(string => uint) public labelToBundlesMapping;

    constructor() {
        // for testing.
        address to = address(this);
        _grantStandardKey(to, "authenticator-grant-standard-key");
        _grantStandardKey(to, "authenticator-revoke-standard-key");
        _grantStandardKey(to, "authenticator-consumable-key");
        _grantStandardKey(to, "authenticator-consume");
        _grantStandardKey(to, "authenticator-grant-timed-key");
        _grantStandardKey(to, "authenticator-revoke-timed-key");
        _grantStandardKey(to, "authenticator-create-bundle");
        _grantStandardKey(to, "authenticator-grant-bundle");
        _grantStandardKey(to, "authenticator-revoke-bundle");
        _grantStandardKey(to, "authenticator-delete-bundle");
        _grantStandardKey(to, "authenticator-copy-bundle");
        _grantStandardKey(to, "authenticator-merge-bundles");
    }

    // for internal access.
    function _grantStandardKey(address to, string memory key)
        private
        returns (bool) {
        
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
        
        emit StandardKeyGranted(to, key);
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

        emit StandardKeyRevoked(from, key);
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

        emit Authenticated(from, requiredKey);
        return success;
    }

    function getStandardKeysOf(address from)
        external view
        returns (string[] memory) {
        require(_accountsAddresses.contains(from), "Authenticator: Unable to get standard keys because address has not been aknowledged.");
        Lib.Account memory account = _accounts[addressToAccountsMapping[from]];
        return account.keys;
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
        
        emit ConsumableKeyGranted(to, key);
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

        emit ConsumableKeyConsumed(from, key);
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

        require(success, "Authenticator: Unable to approve due to insufficient authorization.");

        emit AuthenticatedConsumableKey(from, requiredKey);
        return success;
    }

    function getConsumableKeysOf(address from)
        external view
        returns (string[] memory) {
        require(_accountsAddresses.contains(from), "Authenticator: Unable to get standard keys because address has not been aknowledged.");
        Lib.Account memory account = _accounts[addressToAccountsMapping[from]];
        return account.consumableKeys;
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
        
        emit TimedKeyGranted(to, key, startTimestamp, duration);
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
        
        emit TimedKeyRevoked(from, key);
        return true;
    }

    function authenticateTimedKey(address from, string memory requiredKey)
        external
        returns (bool) {
        bool success;

        if (_accountsAddresses.contains(from)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            success = Lib.authenticateTimedKey(account, requiredKey);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(from);
            addressToAccountsMapping[from] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            success = Lib.authenticateTimedKey(account, requiredKey);
        }

        require(success, "Authenticator: Unable to approve due to insufficient authorization.");

        emit AuthenticatedTimedKey(from, requiredKey);
        return success;
    }

    function getTimedKeysOf(address from)
        external view
        returns (Lib.TimedKey[] memory) {
        require(_accountsAddresses.contains(from), "Authenticator: Unable to get standard keys because address has not been aknowledged.");
        Lib.Account memory account = _accounts[addressToAccountsMapping[from]];
        return account.timedKeys;
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

        (bool success, uint identifier) = Lib.createBundle(_bundles, tracker, keys, consumableKeys, timedKeys);
        labelToBundlesMapping[label] = identifier;

        emit BundleCreated(label, keys, consumableKeys, timedKeys);
        return (success, identifier);
    }

    function grantBundle(address to, string memory label)
        external
        returns (bool) {
        require(_isExistingBundle(label), "Authenticator: Unable to grant bundle because there is no existing bundle with the given label.");

        authenticate(msg.sender, "authenticator-grant-bundle", true, true, true);

        bool success;
        if (_accountsAddresses.contains(to)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            success = Lib.grantBundle(account, _bundles, labelToBundlesMapping[label]);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(to);
            addressToAccountsMapping[to] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[to]];
            success = Lib.grantBundle(account, _bundles, labelToBundlesMapping[label]);        
        }

        require(success, "Authenticator: Unable to grant bundle due to unsuccessful execution.");
        return true;
    }

    function revokeBundle(address from, string memory label)
        external
        returns (bool) {
        require(_isExistingBundle(label), "Authenticator: Unable to revoke bundle because there is no existing bundle with the given label.");

        authenticate(msg.sender, "authenticator-revoke-bundle", true, true, true);

        bool success;
        if (_accountsAddresses.contains(from)) {
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            success = Lib.revokeBundle(account, _bundles, labelToBundlesMapping[label]);
        }

        else {
            // generate unique identifier for address.
            _accountsAddresses.add(from);
            addressToAccountsMapping[from] = _accountsAddresses.length();
            Lib.Account storage account = _accounts[addressToAccountsMapping[from]];
            success = Lib.revokeBundle(account, _bundles, labelToBundlesMapping[label]);        
        }

        emit BundleRevoked(from, label);
        return success;
    }

    function deleteBundle(string memory label)
        external
        returns (bool) {
        require(_isExistingBundle(label), "Authenticator: Unable to delete bundle because there is no existing bundle with the given label.");

        authenticate(msg.sender, "authenticator-delete-bundle", true, true, true);

        bool success = Lib.deleteBundle(_bundles, labelToBundlesMapping[label]);

        require(success, "Authenticator: Unable to delete bundle due to unsuccessful execution.");

        labelToBundlesMapping[label] = 0;
        emit BundleDeleted(label);
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
        emit BundleCopied(labelA, labelB);
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
        emit BundleMerged(mergedBundlesLabels, label);
        return (success, newIdentifier);
    }
}