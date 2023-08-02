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

        bool success = _grantKey(to, of_, signature, type_, startTimestamp, endTimestamp, balance);
        require(success, "Hub: failed to grant key");
    }

    function revokeKey(address from, address of_, string memory signature)
        external {

        _revokeKey(from, of_, signature);
    }

    function _grantKey(address account, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        internal 
        returns (bool) {
        
        bool success;

        if (type_ == 0) { // standard key
            require(startTimestamp == 0, "Hub: key is standard but startTimestamp is not default");
            require(endTimestamp == 0, "Hub: key is standard but endTimestamp is not default");
            require(balance == 0, "Hub: key is standard but balance is not default");
        }

        else if (type_ == 1) { // timed key
            require(startTimestamp >= block.timestamp, "Hub: key is timed but startTimestamp is in the past");
            require(endTimestamp >= startTimestamp, "Hub: key is timed but endTimestamp is before startTimestamp");
            require(balance == 0, "Hub: key is timed but balance is not default");
        }

        else if (type_ == 2) { // consumable key
            require(startTimestamp == 0, "Hub: key is consumable but startTimestamp is not default");
            require(endTimestamp == 0, "Hub: key is consumable but endTimestamp is not default");
            require(balance >= 1, "Hub: key is consumable but balance is set to default");
        }

        else {
            revert("Hub: invalid type");
        }

        require(account != address(0x0), "Hub: account address is zero");
        require(of_ != address(0x0), "Hub: of_ address is zero");

        bytes memory encodedKey = abi.encode(of_, signature, type_, startTimestamp, endTimestamp, balance);
        bytes32 accountKeys = __Encoder.encodeWithAccount("keys", account);
        storage_.pushBytesArray(accountKeys, encodedKey);

        success = true;
        return success;
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
}