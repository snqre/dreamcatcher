// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

library Validator2 {

    /**
    * Key advantages of the authenticator system
    *   -> allows use to lock any function behind keys
    *   -> grant bundles of keys as an alternative roles system
    *
    * Disadvantages
    *   -> potential of clashing keys if unique key name is not given
    *
     */

    /**
    * @param id unique identifier for key
    * @param isOwned if the key is owned by the address
    * @param isTimed if the key is of the type timed
    * @param isStandard if the key is of type standard
    * @param isConsumable if the key is of type consumable
    * @param startTimestamp (if timed) when it was/will be granted
    * @param endTimestamp (if timed) when it has/will be invalid
    * @param balance (if consumable) number of uses left
    * @param timestamps every time the key was used
     */

    struct Key {
        bytes id;
        bool isOwned;
        bool isTimed;
        bool isStandard;
        bool isConsumable;
        uint32 startTimestamp;
        uint32 endTimestamp;
        uint8 balance;
        uint[] timestamps;
    }

    /**
    * @param key key instance to reset to default
     */

    /// ... is it possible to manipulate mapping directly on library?
    function revokeAnyKey(Key storage key)
        public {
        delete key.id;
        delete key.isOwned;
        delete key.isTimed;
        delete key.isStandard;
        delete key.startTimestamp;
        delete key.endTimestamp;
        delete key.balance;
        delete key.timestamps;
    }

    /**
    * @param key key instance that will turn into a standard key
     */

    function grantStandardKey(Key storage key)
        public {
        revokeAnyKey(key);
        key.isOwned = true;
        key.isStandard = true;
    }

    /**
    * @param key key instance that will turn into a timed key
     */

    function grantTimedKey(Key storage key, uint32 startTimestamp, uint32 duration)
        public {
        revokeAnyKey(key);
        key.isOwned = true;
        key.isTimed = true;
        key.startTimestamp = startTimestamp;
        key.endTimestamp = startTimestamp + duration;
    }

    /**
    * @param key timed key instance that will last longer
    * @param increase increase in duration
     */

    function increaseTimedKeyDuration(Key storage key, uint32 increase)
        public {
        if (!key.isOwned) { revert KEY_IS_NOT_OF_TYPE(key); }
        if (!key.isTimed) { revert KEY_IS_NOT_OF_TYPE(key); }
        uint32 x = key.startTimestamp;
        uint32 y = key.endTimestamp;
        key.endTimestamp = x + ((y - x) + increase);
    }

    /**
    * @param key timed key instance that will be shortened
    * @param decrease decrease in duration
     */

    function decreaseTimedKeyDuration(Key storage key, uint32 decrease)
        public {
        if (!key.isOwned) { revert KEY_IS_NOT_OF_TYPE(key); }
        if (!key.isTimed) { revert KEY_IS_NOT_OF_TYPE(key); }
        uint32 x = key.startTimestamp;
        uint32 y = key.endTimestamp;
        uint32 new_ = x + ((y - x) - decrease);
        if (new_ <= x) { revert KEY_CANNOT_EXPIRE_BEFORE_GRANTED(key); }
        key.endTimestamp = new_;
    }

    /**
    * @param key key instance that will turn into a consumable key
    * @param balance initial balance and allowed uses
     */

    function grantConsumableKey(Key storage key, uint8 balance)
        public {
        revokeAnyKey(key);
        key.isOwned = true;
        key.isConsumable = true;
        key.balance = balance;
    }

    /**
    * @param key key instance that will get a balance increase
    * @param increase amount of uses to add
     */

    function increaseConsumableKeyBalance(Key storage key, uint8 increase)
        public {
        if (!key.isOwned) { revert KEY_IS_NOT_OF_TYPE(key); }
        if (!key.isConsumable) { revert KEY_IS_NOT_OF_TYPE(key); }
        key.balance += increase;
    }

    /**
    * @param key key instance that will get a balance decrease
    * @param decrease amount of uses to remove
     */

    function decreaseConsumableKeyBalance(Key storage key, uint8 decrease)
        public {
        if (!key.isOwned) { revert KEY_IS_NOT_OF_TYPE(key); }
        if (!key.isConsumable) { revert KEY_IS_NOT_OF_TYPE(key); }
        key.balance -= decrease;
    }

    /**
    * @param key will check the instance of the key for the type and if it is owned
    *
    * Validate should be called within terminal, routers, and implementations to use this system
    * example {
        ITerminal(address).validate(from, "<uniqueKeyNameForUniqueFunction>")
    } see TerminalA for reference
    * Due to the interconnected nature of the project, it is possible for key names to clash
    * It is also possible for some functions to never be found as using connect will look for the first executable function with the given signature
     */
    
    function validate(Key storage key)
        public {
        /// pathway for standard keys
        if (!key.isOwned) { revert KEY_IS_NOT_OWNED(key); }
        /// pathway for timed keys
        else if (key.isTimed) {
            if (block.timestamp < key.startTimestamp) { revert KEY_IS_NOT_GRANTED_YET(key); }
            if (block.timestamp > key.endTimestamp) { revert KEY_IS_NO_LONGER_VALID(key); }
        }
        /// pathway for consumable keys
        else if (key.isConsumable) {
            if (key.balance == 0) { revert KEY_BALANCE_IS_ZERO(key); }
            key.balance--;
        }
    }

    
    error KEY_IS_NOT_OWNED(Key);
    error KEY_IS_NOT_OF_TYPE(Key);
    error KEY_CANNOT_EXPIRE_BEFORE_GRANTED(Key);
    error KEY_IS_NOT_GRANTED_YET(Key);
    error KEY_IS_NO_LONGER_VALID(Key);
    error KEY_BALANCE_IS_ZERO(Key);
}

library Validator {
    /**

        version 2.0.0

        -> fixed clashing key name problem    
        -> less gas expensive
        -> more light weight

     */
    
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Key {
        bytes32 id;
        EnumerableSet.AddressSet owners;
        
    }
    
}

contract Terminal {
    /**

        version 2.0.0

        -> fixed clashing key name problem    
        -> less gas expensive
        -> more light weight

     */

    using EnumerableSet for EnumerableSet.AddressSet;

    struct Key {
        bytes32 identifier;
        EnumerableSet.AddressSet holders;
    }
    
    struct Router {
        Key[] keys;
        address latestImplementation;
        uint latestVersion;
    }
    
    EnumerableSet.AddressSet private _routers;
    mapping(address => Router) private _router;

    /**
    
        var = abi.encode(type, type, type) -> bytes
        (type, type, type) = abi.decode(var, (type, type, type))
    
     */
    
    function _call(address target, string memory signature, bytes memory args, bool noArgs)
        private 
        returns (bytes memory) {
        bool success;
        bytes memory response;
        if (!noArgs) { /// pass args
            (success, response) = target.call(abi.encodeWithSignature(signature, args));
        }
        else { /// dont pass args
            (success, response) = target.call(abi.encodeWithSignature(signature));
        }
        
        if (!success) { response = abi.encode(success); }
        return response;
    }

    function anchorRouter(address router)
        external {
        if (_routers.contains(router)) { revert ROUTER_HAS_ALREADY_BEEN_ANCHORED(); }
        _routers.add(router);
        Router storage newRouter = _router[router];
        bytes memory args;
        bytes memory response;
        /// get latest implementation
        response = _call(router, "getLatestImplementation()", args, true);
        newRouter.latestImplementation = abi.decode(response, (address));
        /// get latest version
        response = _call(router, "getLatestVersion()", args, true);
        newRouter.latestVersion = abi.decode(response, (uint));
        
    }

    function broadcast(string memory signature, bytes memory args)
        public {
        uint count;
        for (uint i = 0; i < _routers.length(); i++) {

            (bool success, ) = _routers.at(i).call(abi.encodeWithSignature(signature, args));
            if (success) { count++; }
        }
    }

    function getNeighbouringRouters()
        public view
        returns (address[] memory) {
        address[] memory neighbouringRouters;
        for (uint i = 0; i < _routers.length(); i++) {
            neighbouringRouters[i] = _routers.at(i);
        }
        return neighbouringRouters;
    }

    function getNeighbouringTerminals()
        public view
        returns (address[] memory) {
        
    }

    error ROUTER_HAS_ALREADY_BEEN_ANCHORED();

}