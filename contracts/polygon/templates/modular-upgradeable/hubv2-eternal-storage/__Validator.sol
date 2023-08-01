// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/__Encoder.sol";

/**

    type 0 key is standard
    type 1 key is timed meaning it has a start date and an expiry
    type 2 key is consumable meaning it can only be accessed an amount of time

 */
library __Validator {
    function _check(address storage__, address account, address of_)
        private pure {
        require(storage__ != address(0x0), "__Validator: invalid storage address");
        require(account != address(0x0), "__Validator: invalid account");
        require(of_ != address(0x0), "__Validator: invalid contract");
    }

    function grantKey(address storage__, address account, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        public {
        // check that params have been inserted correctly
        _check(storage__, account, of_);
        require(type_ >= 0 && type_ <= 2, "__Validator: invalid key type");
        IStorage storage_ = IStorage(storage__);
        // make sure this key doesnt exist already within the account
        require(!storage_.containsBytes32Set(__Encoder.encodeWithAccount("keys", account), __Encoder.encodeKey(of_, signature)), "__Validator: account already has this key");
        storage_.addBytes32Set(__Encoder.encodeWithAccount("keys", account), __Encoder.encodeKey(of_, signature));
        // add properties to this account's version of the key
        storage_.setUint(__Encoder.encodeKeyPropertyWithAccount(account, "type", of_, signature), type_);
        storage_.setUint(__Encoder.encodeKeyPropertyWithAccount(account, "startTimestamp", of_, signature), startTimestamp);
        storage_.setUint(__Encoder.encodeKeyPropertyWithAccount(account, "endTimestamp", of_, signature), endTimestamp);
        storage_.setUint(__Encoder.encodeKeyPropertyWithAccount(account, "balance", of_, signature), balance);
    }

    function revokeKey(address storage__, address account, address of_, string memory signature)
        public {
        // check that params have been inserted correctly
        _check(storage__, account, of_);
        IStorage storage_ = IStorage(storage__);
        // make sure this key exists within the account
        require(storage_.containsBytes32Set(__Encoder.encodeWithAccount("keys", account), __Encoder.encodeKey(of_, signature)), "__Validator: account does not have this key");
        storage_.removeBytes32Set(__Encoder.encodeWithAccount("keys", account), __Encoder.encodeKey(of_, signature));
        // remove properties from this account's version of the key **set to default
        storage_.setUint(__Encoder.encodeKeyPropertyWithAccount(account, "type", of_, signature), 0);
        storage_.setUint(__Encoder.encodeKeyPropertyWithAccount(account, "startTimestamp", of_, signature), 0);
        storage_.setUint(__Encoder.encodeKeyPropertyWithAccount(account, "endTimestamp", of_, signature), 0);
        storage_.setUint(__Encoder.encodeKeyPropertyWithAccount(account, "balance", of_, signature), 0);
    }

    function verify(address storage__, address account, address of_, string memory signature)
        public {
        _check(storage__, account, of_);
        IStorage storage_ = IStorage(storage__);
        // first check if they have the key
        require(storage_.containsBytes32Set(__Encoder.encodeWithAccount("keys", account), __Encoder.encodeKey(of_, signature)), "__Validator: caller does not have this key");
        // get properties of the key
        uint type_ = storage_.getUint(__Encoder.encodeKeyPropertyWithAccount(account, "type", of_, signature));
        uint startTimestamp = storage_.getUint(__Encoder.encodeKeyPropertyWithAccount(account, "startTimestamp", of_, signature));
        uint endTimestamp = storage_.getUint(__Encoder.encodeKeyPropertyWithAccount(account, "endTimestamp", of_, signature));
        uint balance = storage_.getUint(__Encoder.encodeKeyPropertyWithAccount(account, "balance", of_, signature));
        // custom logic for each type
        if (type_ == 1) { // timed key
            // check that the key is being used within the correct timeframe
            require(block.timestamp >= startTimestamp, "__Validator: timed key has not been activated yet");
            require(block.timestamp <= endTimestamp, "__Validator: timed key has expired");
        }
        else if (type_ == 2) { // consumable key
            // check if balance is greater than 1 and then decrease by 1
            require(balance >= 1, "__Validator: insufficient balance left on consumable key");
            storage_.setUint(__Encoder.encodeKeyPropertyWithAccount(account, "balance", of_, signature), balance -= 1);
        }
        // assuming zero no check required as the only check required is that the account has the key
        // ... congratulations you're allowed to access this function
    }

    // returns encoded keys of an account
    function getKeys(address storage__, address account)
        public view
        returns (bytes32[] memory) {
        IStorage storage_ = IStorage(storage__);
        return storage_.valuesBytes32Set(__Encoder.encodeWithAccount("keys", account));
    }
}