// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/__Encoder.sol";

contract Hub {
    IStorage storage_;

    constructor(address storage__) {
        storage_ = IStorage(storage__);
    }

    function getKeys(address account)
        external view
        returns (address[] memory, string[] memory, uint[] memory, uint[] memory, uint[] memory, uint[] memory) {
        // returns keys of an account as arrays of its data
        bytes32 accountKeys = __Encoder.encodeWithAccount("keys", account);
        bytes[] memory bytesArray = storage_.getBytesArray(accountKeys);
        uint len = storage_.lengthBytesArray(accountKeys);
        address[] memory contracts;
        string[] memory signatures;
        uint[] memory types;
        uint[] memory startTimestamps;
        uint[] memory endTimestamps;
        uint[] memory balances;
        for (uint i = 0; i < len; i++) {
            (address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) = abi.decode(bytesArray[i], (address, string, uint, uint, uint, uint));
            contracts[i] = of_;
            signatures[i] = signature;
            types[i] = type_;
            startTimestamps[i] = startTimestamp;
            endTimestamps[i] = endTimestamp;
            balances[i] = balance;
        }
        return (contracts, signatures, types, startTimestamps, endTimestamps, balances);
    }

    function grantKey(address to, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        external {
        _grantKey(to, of_, signature, type_, startTimestamp, endTimestamp, balance);
    }

    function revokeKey(address from, address of_, string memory signature)
        external {
        _revokeKey(from, of_, signature);
    }

    function _grantKey(address to, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        internal {
        /**

            we are using bytes array to store the keys
            this allows us to encode the args within them
            and decode them when we verify them
            it is more costly to do so but 
            we cannot store bytes within EnumerableSets

         */
        _requireNotZeroAddress(to);
        _requireNotZeroAddress(of_);
        _requireValidType(type_);
        require(startTimestamp >= block.timestamp || startTimestamp == 0, "Hub: invalid timestamp");
        require(endTimestamp >= startTimestamp, "Hub: invalid timestamp");
        bool success;
        // here we encode the args
        bytes memory encodedKey = abi.encode(of_, signature, type_, startTimestamp, endTimestamp, balance);
        // this is the same as account.keys[]
        bytes32 accountKeys = __Encoder.encodeWithAccount("keys", to);
        // try to find if there are any emptyArray spots first
        bytes[] memory bytesArray = storage_.getBytesArray(accountKeys);
        uint len = storage_.lengthBytesArray(accountKeys);
        for (uint i = 0; i < len; i++) {
            bytes memory emptyBytes;
            if (keccak256(bytesArray[i]) == keccak256(emptyBytes)) {
                bytesArray[i] = encodedKey;
                success = true;
            }
        }
        // if no empty bytes were found then push new bytes
        if (!success) {
            storage_.pushBytesArray(accountKeys, encodedKey);
        }
        /**
        
            it is possible to have duplicate keys for the same function
            however when being verified we read the of_ and type_ first
            we also perform clean up to remove outdated keys to make sure the array does not get too large

         */
    }

    function _revokeKey(address from, address of_, string memory signature)
        internal {
        /**
        
            here we only look through the of_ and signatures
            if there is a match we remove every copy of it from the account keys array
            so revoke key removes every instance of the key
            for more precice manipulation revokeSpecificKey
        
         */
        _requireNotZeroAddress(from);
        _requireNotZeroAddress(of_);
        // we import the array with the account's keys
        bytes32 accountKeys = __Encoder.encodeWithAccount("keys", from);
        bytes[] memory bytesArray = storage_.getBytesArray(accountKeys);
        uint len = storage_.lengthBytesArray(accountKeys);
        // then we loop through it
        for (uint i = 0; i < len; i++) {
            // for each one we decode them please note these are different from param variables "var__"
            (address of__, string memory signature_, , , , ) = abi.decode(bytesArray[i], (address, string, uint, uint, uint, uint));
            // if there is a match
            if (of__ == of_ && keccak256(bytes(signature_)) == keccak256(bytes(signature))) {
                /** tried to do this by poping it but cannot pop() within memory bytesArray
                    // get the value for the last element of the array
                    bytes memory value = bytesArray[len - 1];
                    // swap current value with last value of array
                    bytesArray[len - 1] = bytesArray[i];
                    bytesArray[i] = value;
                    // and finally pop
                    bytesArray.pop();
                */

                // set value to empty bytes
                bytes memory emptyBytes;
                bytesArray[i] = emptyBytes;
            }
        }
        // update
        storage_.setBytesArray(accountKeys, bytesArray);
    }


    function _requireNotZeroAddress(address account)
        internal pure {
        require(account != address(0x0), "Hub: invalid address");
    }

    function _requireValidType(uint type_)
        internal pure {
        require(type_ >= 0 && type_ <= 2, "Hub: invalid type");
    }

    function _requireTimestampNotBeforeGivenTimestamp(uint timestamp, uint givenTimestamp)
        internal pure {
        require(timestamp >= givenTimestamp, "Hub: invalid timestamp");
    }
}