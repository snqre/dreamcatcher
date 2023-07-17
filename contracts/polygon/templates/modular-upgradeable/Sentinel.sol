// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

library Validator {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct Key {
        bool isStandard;
        bool isTimed;
        bool isConsumable;
        uint startTimestamp;
        uint endTimestamp;
        uint balance;
    }

    function _encode(string memory value)
        private pure
        returns (bytes32) {
        return keccak256(abi.encode(value));
    }

    function _mustBeExistingKey(EnumerableSet.Bytes32Set storage _keys, string memory key)
        private view {
        require(
            _keys.contains(_encode(key)),
            "__Validator: KEY_MATCH_NOT_FOUND"
        );
    }

    function _mustNotBeExistingKey(EnumerableSet.Bytes32Set storage _keys, string memory key)
        private view {
        require(
            !_keys.contains(_encode(key)),
            "__Validator: KEY_MATCH_WAS_FOUND"
        );
    }

    function _add(EnumerableSet.Bytes32Set storage _keys, string memory key)
        private {
        _mustNotBeExistingKey(_keys, key);
        _keys.add(_encode(key));
    }

    function _remove(EnumerableSet.Bytes32Set storage _keys, string memory key)
        private {
        _mustBeExistingKey(_keys, key);
        _keys.remove(_encode(key));
    }

    function _setKey(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, bool isStandard, bool isTimed, bool isConsumable, uint startTimestamp, uint endTimestamp, uint balance)
        private {
        if (_keys.contains(_encode(key))) {
            _remove(_keys, key);
            _add(_keys, key);
        }
        else {
            _add(_keys, key);
        }
        data.isStandard = isStandard;
        data.isTimed = isTimed;
        data.isConsumable = isConsumable;
        data.startTimestamp = startTimestamp;
        data.endTimestamp = endTimestamp;
        data.balance = balance;
    }

    function _getKey(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key)
        private view
        returns (bytes32, bool, bool, bool, uint, uint, uint) {
        _mustBeExistingKey(_keys, key);
        return (_encode(key), data.isStandard, data.isTimed, data.isConsumable, data.startTimestamp, data.endTimestamp, data.balance);
    }

    function _revokeAnyKey(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key)
        private {
        _setKey(_keys, data, key, false, false, false, 0, 0, 0);
        _remove(_keys, key);
    }

    function _grantStandardKey(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key)
        private {
        _mustNotBeExistingKey(_keys, key);
        _revokeAnyKey(_keys, data, key);
        _setKey(_keys, data, key, true, false, false, 0, 0, 0);
    }

    function _grantTimedKey(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint startTimestamp, uint endTimestamp)
        private {
        _mustNotBeExistingKey(_keys, key);
        _revokeAnyKey(_keys, data, key);
        _setKey(_keys, data, key, false, true, false, startTimestamp, endTimestamp, 0);
    }

    function _increaseTimedKeyDuration(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint increase)
        private {
        _mustBeExistingKey(_keys, key);
        require(
            !data.isStandard
            && data.isTimed
            && !data.isConsumable
            && data.startTimestamp != 0
            && data.endTimestamp != 0
            && data.balance == 0,
            "__Validator: KEY_IS_NOT_OF_TYPE"
        );
        data.endTimestamp = data.startTimestamp + ((data.endTimestamp - data.startTimestamp) + increase);
        _setKey(_keys, data, key, data.isStandard, data.isTimed, data.isConsumable, data.startTimestamp, data.endTimestamp, data.balance);
    }

    function _decreaseTimedKeyDuration(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint decrease)
        private {
        _mustBeExistingKey(_keys, key);
        require(
            !data.isStandard
            && data.isTimed
            && !data.isConsumable
            && data.startTimestamp != 0
            && data.endTimestamp != 0
            && data.balance == 0,
            "__Validator: KEY_IS_NOT_OF_TYPE"
        );
        uint newValue = data.startTimestamp + ((data.endTimestamp - data.startTimestamp) - decrease);
        require(newValue > data.endTimestamp, "__Validator: KEY_CANNOT_EXPIRE_BEFORE_GRANTED");
        data.endTimestamp = newValue;
        _setKey(_keys, data, key, data.isStandard, data.isTimed, data.isConsumable, data.startTimestamp, data.endTimestamp, data.balance);
    }

    function _grantConsumableKey(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint balance)
        private {
        _mustNotBeExistingKey(_keys, key);
        _revokeAnyKey(_keys, data, key);
        _setKey(_keys, data, key, false, false, true, 0, 0, balance);
    }

    function _increaseConsumableKeyBalance(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint increase)
        private {
        _mustBeExistingKey(_keys, key);
        require(
            !data.isStandard
            && !data.isTimed
            && data.isConsumable
            && data.startTimestamp == 0
            && data.endTimestamp == 0,
            "__Validator: KEY_IS_NOT_OF_TYPE"
        );
        data.balance += increase;
        _setKey(_keys, data, key, data.isStandard, data.isTimed, data.isConsumable, data.startTimestamp, data.endTimestamp, data.balance);
    }

    function _decreaseConsumableKeyBalance(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint decrease)
        private {
        _mustBeExistingKey(_keys, key);
        require(
            !data.isStandard
            && !data.isTimed
            && data.isConsumable
            && data.startTimestamp == 0
            && data.endTimestamp == 0,
            "__Validator: KEY_IS_NOT_OF_TYPE"
        );
        require(data.balance != 0, "__Validator: KEY_BALANCE_IS_ZERO");
        data.balance -= decrease;
        _setKey(_keys, data, key, data.isStandard, data.isTimed, data.isConsumable, data.startTimestamp, data.endTimestamp, data.balance);
    }

    function _validate(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key)
        private {
        _mustBeExistingKey(_keys, key);
        if (data.isTimed) {
            require(block.timestamp >= data.startTimestamp, "__Validator: KEY_IS_NOT_GRANTED_YET");
            require(block.timestamp <= data.endTimestamp, "__Validator: KEY_IS_NO_LONGER_VALID");
        }
        else if (data.isConsumable) {
            require(data.balance != 0, "__Validator: KEY_BALANCE_IS_ZERO");
            data.balance--;
        }
    }

    function encode(string memory value)
        public pure
        returns (bytes32) {
        return _encode(value);
    }

    function revokeAnyKey(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key)
        public 
        returns (bool) {
        _revokeAnyKey(_keys, data, key);
        return true;
    }

    function grantStandardKey(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key)
        public 
        returns (bool) {
        _grantStandardKey(_keys, data, key);
        return true;
    }

    function grantTimedKey(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint startTimestamp, uint endTimestamp)
        public
        returns (bool) {
        _grantTimedKey(_keys, data, key, startTimestamp, endTimestamp);
        return true;
    }

    function increaseTimedKeyDuration(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint increase)
        public
        returns (bool) {
        _increaseTimedKeyDuration(_keys, data, key, increase);
        return true;
    }

    function decreaseTimedKeyDuration(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint decrease)
        public
        returns (bool) {
        _decreaseConsumableKeyBalance(_keys, data, key, decrease);
        return true;
    }

    function grantConsumableKey(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint balance)
        public
        returns (bool) {
        _grantConsumableKey(_keys, data, key, balance);
        return true;
    }

    function increaseConsumableKeyBalance(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint increase)
        public
        returns (bool) {
        _increaseConsumableKeyBalance(_keys, data, key, increase);
        return true;
    }

    function decreaseConsumableKeyBalance(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key, uint decrease)
        public
        returns (bool) {
        _decreaseConsumableKeyBalance(_keys, data, key, decrease);
        return true;
    }

    function validate(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key)
        public
        returns (bool) {
        _validate(_keys, data, key);
        return true;
    }

    function getKey(EnumerableSet.Bytes32Set storage _keys, Key storage data, string memory key)
        public view
        returns (bytes32, bool, bool, bool, uint, uint, uint) {
        return _getKey(_keys, data, key);
    }
}

library Anchor {
    using EnumerableSet for EnumerableSet.AddressSet;

    function _mustBeExistingTerminal(EnumerableSet.AddressSet storage _terminals, address terminal)
        private view {
        require(
            _terminals.contains(terminal), 
            "__Anchor: TERMINAL_MATCH_NOT_FOUND"
        );
    }

    function _mustNotBeExistingTerminal(EnumerableSet.AddressSet storage _terminals, address terminal)
        private view {
        require(
            !_terminals.contains(terminal),
            "__Anchor: TERMINAL_MATCH_WAS_FOUND"
        );
    }

    function _mustBeExistingRouter(EnumerableSet.AddressSet storage _routers, address router)
        private view {
        require(
            _routers.contains(router),
            "__Anchor: ROUTER_MATCH_NOT_FOUND"
        );
    }

    function _mustNotBeExistingRouter(EnumerableSet.AddressSet storage _routers, address router)
        private view {
        require(
            !_routers.contains(router),
            "__Anchor: ROUTER_MATCH_WAS_FOUND"
        );
    }

    function _call(address target, string memory signature, bytes memory args)
        private 
        returns (bytes memory) {
        (bool success, bytes memory response) = target.call(abi.encodeWithSignature(signature, args));
        require(success, "__Anchor: FAILED_CALL");
        return response;
    }

    function assignTerminal(EnumerableSet.AddressSet storage _terminals, address terminal)
        public
        returns (bool) {
        _mustNotBeExistingTerminal(_terminals, terminal);
        _terminals.add(terminal);
        return true;
    }

    function unassignTerminal(EnumerableSet.AddressSet storage _terminals, address terminal)
        public
        returns (bool) {
        _mustBeExistingTerminal(_terminals, terminal);
        _terminals.remove(terminal);
        return true;
    }

    function assignRouter(EnumerableSet.AddressSet storage _routers, address router)
        public
        returns (bool) {
        _mustNotBeExistingRouter(_routers, router);
        _routers.add(router);
        return true;
    }

    function unassignRouter(EnumerableSet.AddressSet storage _routers, address router)
        public
        returns (bool) {
        _mustBeExistingRouter(_routers, router);
        _routers.remove(router);
        return true;
    }    
}

library Timelock {
    struct Request {
        address target;
        string signature;
        bytes args;
        uint startTimestamp;
        uint timelock;
        uint timeout;
        address creator;
        string message;
        bool isRejected;
        bool isApproved;
        bool isExecuted;
        bool isPending;
    }

    function generateUniqueId()
        public
        returns (bytes32) {
        
    }

    function queue(EnumerableSet.Bytes32Set storage _requests, Request storage request, uint timelock, uint timeout, address target, string signature, bytes args, address creator, string memory message)
        public
        returns (bool) {
        _requests.add(generateUniqueId());
    }
}

contract SentinelA {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    mapping(address => EnumerableSet.Bytes32Set) internal _keys;
    mapping(address => mapping(bytes32 => Validator.Key)) internal _keysData;

    function revokeAnykey(address from, string memory key)
        public
        returns (bool) {
        return Validator.revokeAnyKey(_keys[from], _keysData[from][Validator.encode(key)], key);
    }    

    function grantStandardKey(address to, string memory key)
        public
        returns (bool) {
        return Validator.grantStandardKey(_keys[to], _keysData[to][Validator.encode(key)], key);
    }

    function grantTimedKey(address to, string memory key, uint startTimestamp, uint endTimestamp)
        public
        returns (bool) {
        return Validator.grantTimedKey(_keys[to], _keysData[to][Validator.encode(key)], key, startTimestamp, endTimestamp);
    }

    function increaseTimedKeyDuration(address of_, string memory key, uint increase)
        public
        returns (bool) {
        return Validator.increaseTimedKeyDuration(_keys[of_], _keysData[of_][Validator.encode(key)], key, increase);
    }

    function decreaseTimedKeyDuration(address of_, string memory key, uint decrease)
        public
        returns (bool) {
        return Validator.decreaseTimedKeyDuration(_keys[of_], _keysData[of_][Validator.encode(key)], key, decrease);
    }

    function grantConsumableKey(address to, string memory key, uint balance)
        public
        returns (bool) {
        return Validator.grantConsumableKey(_keys[to], _keysData[to][Validator.encode(key)], key, balance);
    }

    function increaseConsumableKeyBalance(address of_, string memory key, uint increase)
        public
        returns (bool) {
        return Validator.increaseConsumableKeyBalance(_keys[of_], _keysData[of_][Validator.encode(key)], key, increase);
    }

    function decreaseConsumableKeyBalance(address of_, string memory key, uint decrease)
        public
        returns (bool) {
        return Validator.decreaseConsumableKeyBalance(_keys[of_], _keysData[of_][Validator.encode(key)], key, decrease);
    }

    function validate(address from, string memory key)
        public
        returns (bool) {
        return Validator.validate(_keys[from], _keysData[from][Validator.encode(key)], key);
    }

    function getKey(address of_, string memory key)
        public view
        returns (bytes32, bool, bool, bool, uint, uint, uint) {
        return Validator.getKey(_keys[of_], _keysData[of_][Validator.encode(key)], key);
    }

    function getKeyValues(address of_)
        public view 
        returns (bytes32[] memory) {
        return _keys[of_].values();
    }
}

contract SentinelB is SentinelA {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    mapping(string => EnumerableSet.Bytes32Set) internal _bundles;
    mapping(string => mapping(bytes32 => Validator.Key)) internal _bundlesData;

    function _removeAnyKeysFromBundle(string memory label, string[] memory keys)
        internal {
        for (uint i = 0; i < keys.length; i++) {
            Validator.revokeAnyKey(_bundles[label], _bundlesData[label][Validator.encode(keys[i])], keys[i]);
        }
    }

    function _addStandardKeysToBundle(string memory label, string[] memory keys)
        internal {
        for (uint i = 0; i < keys.length; i++) {
            Validator.grantStandardKey(_bundles[label], _bundlesData[label][Validator.encode(keys[i])], keys[i]);
        }
    }

    function _addTimedKeysToBundle(string memory label, string[] memory keys, uint[] memory startTimestamp, uint[] memory endTimestamp)
        internal {
        for (uint i = 0; i < keys.length; i++) {
            Validator.grantTimedKey(_bundles[label], _bundlesData[label][Validator.encode(keys[i])], keys[i], startTimestamp[i], endTimestamp[i]);
        }
    }

    function _addConsumableKeysToBundle(string memory label, string[] memory keys, uint[] memory balance)
        internal {
        for (uint i = 0; i < keys.length; i++) {
            Validator.grantConsumableKey(_bundles[label], _bundlesData[label][Validator.encode(keys[i])], keys[i], balance[i]);
        }
    }

    function _getBundle(string memory label, string memory key)
        internal view 
        returns (bytes32, bool, bool, bool, uint, uint, uint) {
        return Validator.getKey(_bundles[label], _bundlesData[label][Validator.encode(key)], key);
    }

    function removeAnyKeysFromBundle(string memory label, string[] memory keys)
        public 
        returns (bool) {
        _removeAnyKeysFromBundle(label, keys);
        return true;
    }

    function addStandardKeysToBundle(string memory label, string[] memory keys)
        public
        returns (bool) {
        _addStandardKeysToBundle(label, keys);
        return true;
    }

    function addTimedKeysToBundle(string memory label, string[] memory keys, uint[] memory startTimestamp, uint[] memory endTimestamp)
        public
        returns (bool) {
        _addTimedKeysToBundle(label, keys, startTimestamp, endTimestamp);
        return true;
    }

    function addConsumableKeysToBundle(string memory label, string[] memory keys, uint[] memory balance)
        public
        returns (bool) {
        _addConsumableKeysToBundle(label, keys, balance);
        return true;
    }

    function getBundle(string memory label, string memory key)
        public view
        returns (bytes32, bool, bool, bool, uint, uint, uint) {
        return _getBundle(label, key);
    }

    function getBundleValues(string memory label)
        public view 
        returns (bytes32[] memory) {
        return _bundles[label].values();
    }
}

contract SentinelC is SentinelB {
    /**
    
        sentinel:
            -> keeps track of terminals and routers
            -> updates terminals and routers
            -> convinient way of viewing terminals

     */

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet internal _terminals;
    mapping(address => EnumerableSet.AddressSet) internal _routers;

    function assignTerminal(address terminal)
        public
        returns (bool) {
        Anchor.assignTerminal(_terminals, terminal);
        return true;
    }

    function unassignTerminal(address terminal)
        public
        returns (bool) {
        Anchor.unassignTerminal(_terminals, terminal);
        return true;
    }

    function assignRouter(address terminal, address router)
        public
        returns (bool) {
        Anchor.assignRouter(_routers[terminal], router);
        return true;
    }

    function unassignRouter(address terminal, address router)
        public
        returns (bool) {
        Anchor.unassignRouter(_routers[terminal], router);
        return true;
    }
    
    function getTerminals()
        public view
        returns (address[] memory) {
        return _terminals.values();
    }

    function getRouters(address terminal)
        public view
        returns (address[] memory) {
        return _routers[terminal].values();
    }

    /**
    
        should loop over each terminal and its implementation to look for the first successful call
    
     */
    function connect(string memory signature, bytes memory args)
        public
        returns (bytes memory) {
        address target;
        bool success;
        bytes memory response;
        /// for each terminal
        for (uint i = 0; i < _terminals.length(); i++) {
            
            /// loop through each router
            for (uint x = 0; x < _routers[_terminals.at(i)].length(); x++) {
                /// make call to its latestImplementation
                target = _routers[_terminals.at(i)].at(x);
                (success, response) = target.call(abi.encodeWithSignature(signature, args));
                if (success) { break; }
            }

            if (success) { break; }
        }
        require(success, "Sentinel: FAILED_TO_FIND_SIGNATURE");
        return response;
    }
}

contract SentinelD {
    /**
    
        Timelock.
            -> queue()
    
     */

    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.Bytes32Set internal _requests;
    mapping(bytes32 => Timelock.Request) internal _requestsData;


}