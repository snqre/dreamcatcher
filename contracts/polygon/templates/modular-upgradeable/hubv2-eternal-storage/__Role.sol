// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/__Encoder.sol";

library __Role {
    function _check(address storage__, address of_)
        private pure {
        require(storage__ != address(0x0), "__Role: invalid storage address");
        require(of_ != address(0x0), "__Role: invalid contract");
    }

    // similar to the grant key function
    function grantKeyToRole(address storage__, string memory role, address of_, string memory signature)
        public {
        // check that params have been inserted correctly
        _check(storage__, of_);
        /** require(type_ >= 0 && type_ <= 2, "_Role: invalid key type"); */
        IStorage storage_ = IStorage(storage__);
        // make sure this key doesnt exist aready within the account
        require(!storage_.containsBytes32Set(__Encoder.encodeWithRole("keys", role), __Encoder.encodeKey(of_, signature)), "__Role: role already has this key");
        storage_.addBytes32Set(__Encoder.encodeWithRole("keys", role), __Encoder.encodeKey(of_, signature));
        // add properties to this role's version

        /** this does nothing
        storage_.setUint(__Encoder.encodeKeyPropertyWithRole(role, "type", of_, signature), type_);
        storage_.setUint(__Encoder.encodeKeyPropertyWithRole(role, "startTimestamp", of_, signature), startTimestamp);
        storage_.setUint(__Encoder.encodeKeyPropertyWithRole(role, "endTimestamp", of_, signature), endTimestamp);
        storage_.setUint(__Encoder.encodeKeyPropertyWithRole(role, "balance", of_, signature), balance);
        */
    }

    function revokeKeyFromRole(address storage__, string memory role, address of_, string memory signature)
        public {
        // check that params have been inserted correctly
        _check(storage__, of_);
        IStorage storage_ = IStorage(storage__);
        require(storage_.containsBytes32Set(__Encoder.encodeWithRole("keys", role), __Encoder.encodeKey(of_, signature)), "__Role: role does not have this role");
        storage_.removeBytes32Set(__Encoder.encodeWithRole("keys", role), __Encoder.encodeKey(of_, signature));
        // remove properties from this role's version

        /** deprecated
        storage_.setUint(__Encoder.encodeKeyPropertyWithRole(role, "type", of_, signature), 0);
        storage_.setUint(__Encoder.encodeKeyPropertyWithRole(role, "startTimestamp", of_, signature), 0);
        storage_.setUint(__Encoder.encodeKeyPropertyWithRole(role, "endTimestamp", of_, signature), 0);
        storage_.setUint(__Encoder.encodeKeyPropertyWithRole(role, "balance", of_, signature), 0);
        */
    }

    function grantRole(address storage__, string memory role, address account)
        public {
        // check that params have been inserted correctly
        require(storage__ != address(0x0), "__Role: invalid storage address");
        IStorage storage_ = IStorage(storage__);
        // add this account as a member of the role
        bytes32 members = __Encoder.encodeWithRole("members", role);
        storage_.addAddressSet(members, account);
        // get all the keys within the role
        bytes32[] memory keys = storage_.valuesBytes32Set(__Encoder.encodeWithRole("keys", role));
        for (uint i = 0; i < keys.length; i++) {
            // this is effectively like the grant key function in __Validator but we bypass ecoding of_ and signature
            // this only supports standard keys at the moment
            // check if the key is not already in the account in some form
            if (!storage_.containsBytes32Set(__Encoder.encodeWithAccount("keys", account), keys[i])) {
                storage_.addBytes32Set(__Encoder.encodeWithAccount("keys", account), keys[i]);
                // note that there are no properties as this only supports standard keys
            }
            else {
                // if the key is present within the account then do nothing
                // will not override any already existing keys with the same name
            }
        }
    }

    function revokeRole(address storage__, string memory role, address account)
        public {
        // check that params have been inserted correctly
        require(storage__ != address(0x0), "__Role: invalid storage address");
        IStorage storage_ = IStorage(storage__);
        // remove this account as a member of this role
        bytes32 members = __Encoder.encodeWithRole("members", role);
        storage_.removeAddressSet(members, account);
        // get all the keys within the role
        bytes32[] memory keys = storage_.valuesBytes32Set(__Encoder.encodeWithRole("keys", role));
        for (uint i = 0; i < keys.length; i++) {
            // if the account contains this key
            if (storage_.containsBytes32Set(__Encoder.encodeWithAccount("keys", account), keys[i])) {
                // we dont have access to the key type so note that when we remove this key its properties will still remain and will not be reset
                // this is not a problem because verify() will not permit the account to use the key as it does not own it in the first place
                // and the next time it is granted it will be overriden by new settings
                // but this may cause some confusion
                // also note we dont have to encode the key as it is already received as encodedKey
                storage_.removeBytes32Set(__Encoder.encodeWithAccount("keys", account), keys[i]);
                // again note there are no property modifications here
            }
            else {
                // if the key is not present we do nothing
            }
        }
    }

    function getKeys(address storage__, string memory role)
        public view
        returns (bytes32[] memory) {
        // returns the keys a role has been assigned
        IStorage storage_ = IStorage(storage__);
        bytes32 roleKeys = __Encoder.encodeWithRole("keys", role);
        return storage_.valuesBytes32Set(roleKeys);
    }

    function getMembers(address storage__, string memory role)
        public view 
        returns (address[] memory) {
        require(storage__ != address(0x0), "__Role: invalid storage address");
        IStorage storage_ = IStorage(storage__);
        bytes32 members = __Encoder.encodeWithRole("members", role);
        return storage_.valuesAddressSet(members);
    }

    function getSize(address storage__, string memory role)
        public view
        returns (uint) {
        require(storage__ != address(0x0), "__Role: invalid storage address");
        IStorage storage_ = IStorage(storage__);
        bytes32 members = __Encoder.encodeWithRole("members", role);
        return storage_.lengthAddressSet(members);
    }
}