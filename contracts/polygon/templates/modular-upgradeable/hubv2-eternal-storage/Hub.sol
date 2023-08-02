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
        returns (bytes[] memory) {
        bytes32 accountKeys = __Encoder.encodeWithAccount("keys", account);
        return storage_.getBytesArray(accountKeys);
    }

    function grantKey(address to, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        external {
        bool success = _grantKey(to, of_, signature, type_, startTimestamp, endTimestamp, balance);
        require(success, "Hub: unable to grant key");
    }

    function revokeKey(address from, address of_, string memory signature)
        external {
        bool success = _revokeKey(from, of_, signature);
        require(success, "Hub: unable to revoke key");
    }

    function _grantKey(address account, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        internal 
        returns (bool) {
        
        bool success;

        // standard
        if (type_ == 0) {
            require(startTimestamp == 0, "Hub: key is standard but startTimestamp is not default");
            require(endTimestamp == 0, "Hub: key is standard but endTimestamp is not default");
            require(balance == 0, "Hub: key is standard but balance is not default");
        }

        // timed
        else if (type_ == 1) {
            require(startTimestamp >= block.timestamp, "Hub: key is timed but startTimestamp is in the past");
            require(endTimestamp >= startTimestamp, "Hub: key is timed but endTimestamp is before startTimestamp");
            require(balance == 0, "Hub: key is timed but balance is not default");
        }

        // consumable
        else if (type_ == 2) {
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

        // check if there is any duplicate keys
        for (uint i = 0; i < storage_.lengthBytesArray(accountKeys); i++) {
            bytes memory encodedKey_ = storage_.indexBytesArray(accountKeys, i);
            
            // decode key
            bytes memory emptyBytes;
            if (keccak256(encodedKey_) != keccak256(emptyBytes)) {
                (address of__, string memory signature_, , , ,) = abi.decode(encodedKey_, (address, string, uint, uint, uint, uint));
                bool sameContract = of__ == of_;
                bool sameSignature = keccak256(abi.encodePacked(signature_)) == keccak256(abi.encodePacked(signature));
                bool isAMatch = sameContract == true && sameSignature == true;

                require(!isAMatch, "Hub: a key with the same contract and signature was found");
            }
            else {
                // in the case that it is empty bytes
            }
        }

        storage_.pushBytesArray(accountKeys, encodedKey);

        success = true;
        return success;
    }


    function _revokeKey(address account, address of_, string memory signature)
        internal 
        returns (bool) {
        
        bool success;

        require(account != address(0x0), "Hub: account address is zero");
        require(of_ != address(0x0), "Hub: of_ address is zero");
        
        bytes32 accountKeys = __Encoder.encodeWithAccount("keys", account);
        for (uint i = 0; i < storage_.lengthBytesArray(accountKeys); i++) {
            bytes memory encodedKey = storage_.indexBytesArray(accountKeys, i);

            // decode key
            bytes memory emptyBytes;
            if (keccak256(encodedKey) != keccak256(emptyBytes)) {
                (address of__, string memory signature_, , , ,) = abi.decode(encodedKey, (address, string, uint, uint, uint, uint));
                bool sameContract = of__ == of_;
                bool sameSignature = keccak256(abi.encodePacked(signature_)) == keccak256(abi.encodePacked(signature));
                bool isAMatch = sameContract == true && sameSignature == true;

                if (isAMatch) {

                    // we update the index of the array with value but we dont just set it to an emptyByte we sent null values like a struct so we can decode it later
                    
                    storage_.setIndexBytesArray(accountKeys, i, emptyBytes);
                    break;
                }
            }
            else {
                // in the case that it is empty bytes
            }
        }

        success = true;
        return success;
    }
}