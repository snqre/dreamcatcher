// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/__Encoder.sol";

contract Hub {
    IStorage storage_;

    constructor(address storage__) {
        storage_ = IStorage(storage__);
    }

    function encodeKey(address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        external pure
        returns (bytes memory) {
        return _encodeKey(of_, signature, type_, startTimestamp, endTimestamp, balance);
    }

    function decodeKey(bytes memory key)
        external pure
        returns (address, string memory, uint, uint, uint, uint) {
        return _decodeKey(key);
    }

    function getKeys(address account)
        external view
        returns (bytes[] memory) {
        bytes32 accountKeys = __Encoder.encodeWithAccount("keys", account);
        return storage_.getBytesArray(accountKeys);
    }

    function getRoleKeys(string memory role)
        external view
        returns (bytes[] memory) {
        bytes32 roleKeys = __Encoder.encodeWithRole("keys", role);
        return storage_.getBytesArray(roleKeys);
    }

    function getRoleMembers(string memory role)
        external view
        returns (address[] memory) {
        bytes32 roleMembers = __Encoder.encodeWithRole("members", role);
        return storage_.valuesAddressSet(roleMembers);
    }

    function getRoleSize(string memory role)
        external view
        returns (uint) {
        bytes32 roleMembers = __Encoder.encodeWithRole("members", role);
        return storage_.lengthAddressSet(roleMembers);
    }

    function grantKey(address account, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        external {
        bool success = _grantKey(account, of_, signature, type_, startTimestamp, endTimestamp, balance);
        require(success, "Hub: unable to grant key");
    }

    function revokeKey(address account, address of_, string memory signature)
        external {
        bool success = _revokeKey(account, of_, signature);
        require(success, "Hub: unable to revoke key");
    }

    function resetKeys(address account)
        external {
        bool success = _resetKeys(account);
        require(success, "Hub: unable to reset keys");
    }

    function verify(address account, address of_, string memory signature)
        external {
        bool success = _verify(account, of_, signature);
        require(success, "Hub: unable to verify key");
    }

    function grantKeyToRole(string memory role, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        external {
        bool success = _grantKeyToRole(role, of_, signature, type_, startTimestamp, endTimestamp, balance);
        require(success, "Hub: unable to grant key to role");
    }

    function revokeKeyFromRole(string memory role, address of_, string memory signature)
        external {
        bool success = _revokeKeyFromRole(role, of_, signature);
        require(success, "Hub: unable to revoke key from role");
    }

    function resetRoleKeys(string memory role)
        external {
        bool success = _resetRoleKeys(role);
        require(success, "Hub: unable to reset role keys");
    }

    function grantRole(address account, string memory role)
        external {
        bool success = _grantRole(account, role);
        require(success, "Hub: unable to grant role");
    }

    function revokeRole(address account, string memory role)
        external {
        bool success = _revokeRole(account, role);
        require(success, "Hub: unable to revoke role");
    }

    function _encodeKey(address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        internal pure
        returns (bytes memory) {
        return abi.encode(of_, signature, type_, startTimestamp, endTimestamp, balance);
    }

    function _decodeKey(bytes memory key)
        internal pure
        returns (address, string memory, uint, uint, uint, uint) {
        (address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) = abi.decode(key, (address, string, uint, uint, uint, uint));
        return (of_, signature, type_, startTimestamp, endTimestamp, balance);
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
                (address of__, string memory signature_, , , ,) = _decodeKey(encodedKey_);
                bool sameContract = of__ == of_;
                bool sameSignature = keccak256(abi.encodePacked(signature_)) == keccak256(abi.encodePacked(signature));
                bool isAMatch = sameContract == true && sameSignature == true;

                require(!isAMatch, "Hub: a key with the same contract and signature was found");
            }
            else {
                // in the case that it is empty bytes
            }
        }

        // before we push a new value we want to try and find an empty spot
        for (uint i = 0; i < storage_.lengthBytesArray(accountKeys); i++) {
            bytes memory encodedKey_ = storage_.indexBytesArray(accountKeys, i);

            // check if bytes are empty
            bytes memory emptyBytes;
            if (keccak256(encodedKey_) == keccak256(emptyBytes)) {
                
                // if empty
                storage_.setIndexBytesArray(accountKeys, i, encodedKey);
                success = true;
                break;
            }
        }

        // if no empty spots were found then push
        if (!success) {
            storage_.pushBytesArray(accountKeys, encodedKey);
            success = true;
        }

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
                (address of__, string memory signature_, , , ,) = _decodeKey(encodedKey);
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

    function _resetKeys(address account)
        internal
        returns (bool) {
        
        bool success;

        require(account != address(0x0), "Hub: account address is zero");

        bytes32 accountKeys = __Encoder.encodeWithAccount("keys", account);
        storage_.deleteBytesArray(accountKeys);

        success = true;
        return success;
    }

    function _verify(address account, address of_, string memory signature)
        internal 
        returns (bool) {
        
        bool success;
        
        require(account != address(0x0), "Hub: account address is zero");

        bytes32 accountKeys = __Encoder.encodeWithAccount("keys", account);
        for (uint i = 0; i < storage_.lengthBytesArray(accountKeys); i++) {

            bytes memory encodedKey = storage_.indexBytesArray(accountKeys, i);
            (address of__, string memory signature_, uint type_, uint startTimestamp, uint endTimestamp, uint balance) = _decodeKey(encodedKey);
            bool sameContract = of__ == of_;
            bool sameSignature = keccak256(abi.encodePacked(signature_)) == keccak256(abi.encodePacked(signature));
            bool isAMatch = sameContract == true && sameSignature == true;

            if (isAMatch) {

                // standard
                if (type_ == 0) {
                    // nothing happens here we already know the account has the key they are okay to pass
                    success = true;
                }

                // timed
                if (type_ == 1) {
                    require(block.timestamp >= startTimestamp, "Hub: timed key cannot be used before granted");
                    require(block.timestamp <= endTimestamp, "Hub: timed key is expired");
                    success = true;
                }
                
                // consumable
                if (type_ == 2) {
                    require(balance >= 1, "Hub: consumable key is depleted");
                    
                    // we encode a new key to replace the old one as now we have decreased balance by 1
                    balance -= 1;
                    bytes memory newEncodedKey = _encodeKey(of__, signature_, type_, startTimestamp, endTimestamp, balance);
                    storage_.setIndexBytesArray(accountKeys, i, newEncodedKey);
                    success = true;
                }

                // if have found what we are looking for so we can leave the loop
                break;
            }
        }

        return success;
    }

    function _grantKeyToRole(string memory role, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        internal 
        returns (bool) {
        // similar key as grantKey much room for refactoring

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

        require(of_ != address(0x0), "Hub: of_ address is zero");

        bytes memory encodedKey = _encodeKey(of_, signature, type_, startTimestamp, endTimestamp, balance);
        bytes32 roleKeys = __Encoder.encodeWithRole("keys", role);
        
        // check if there is any duplicate keys
        for (uint i = 0; i < storage_.lengthBytesArray(roleKeys); i++) {
            bytes memory encodedKey_ = storage_.indexBytesArray(roleKeys, i);
            
            // decode key
            bytes memory emptyBytes;
            if (keccak256(encodedKey_) != keccak256(emptyBytes)) {
                (address of__, string memory signature_, , , ,) = _decodeKey(encodedKey_);
                bool sameContract = of__ == of_;
                bool sameSignature = keccak256(abi.encodePacked(signature_)) == keccak256(abi.encodePacked(signature));
                bool isAMatch = sameContract == true && sameSignature == true;

                require(!isAMatch, "Hub: a key with the same contract and signature was found");
            }
            else {
                // in the case that it is empty bytes
            }
        }

        // before we push a new value we want to try and find an empty spot
        for (uint i = 0; i < storage_.lengthBytesArray(roleKeys); i++) {
            bytes memory encodedKey_ = storage_.indexBytesArray(roleKeys, i);

            // check if bytes are empty
            bytes memory emptyBytes;
            if (keccak256(encodedKey_) == keccak256(emptyBytes)) {
                
                // if empty
                storage_.setIndexBytesArray(roleKeys, i, encodedKey);
                success = true;
                break;
            }
        }

        // if no empty spots were found then push
        if (!success) {
            storage_.pushBytesArray(roleKeys, encodedKey);
            success = true;
        }

        return success;
    }

    function _revokeKeyFromRole(string memory role, address of_, string memory signature)
        internal
        returns (bool) {
        
        bool success;

        require(of_ != address(0x0), "Hub: account address is zero");

        bytes32  roleKeys = __Encoder.encodeWithRole("keys", role);
        for (uint i = 0; i < storage_.lengthBytesArray(roleKeys); i++) {
            bytes memory encodedKey = storage_.indexBytesArray(roleKeys, i);

            // decode key
            bytes memory emptyBytes;
            if (keccak256(encodedKey) != keccak256(emptyBytes)) {
                (address of__, string memory signature_, , , ,) = _decodeKey(encodedKey);
                bool sameContract = of__ == of_;
                bool sameSignature = keccak256(abi.encodePacked(signature_)) == keccak256(abi.encodePacked(signature));
                bool isAMatch = sameContract == true && sameSignature == true;

                if (isAMatch) {

                    // we update the index of the array with value but we dont just set it to an emptyByte we sent null values like a struct so we can decode it later
                    
                    storage_.setIndexBytesArray(roleKeys, i, emptyBytes);
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

    function _resetRoleKeys(string memory role)
        internal
        returns (bool) {
        
        bool success;

        bytes32 roleKeys = __Encoder.encodeWithRole("keys", role);
        storage_.deleteBytesArray(roleKeys);

        success = true;
        return success;
    }

    function _grantRole(address account, string memory role)
        internal
        returns (bool) {
        
        // refresh account before assiging role
        _resetKeys(account);
        bool success;

        bytes32 roleKeys = __Encoder.encodeWithRole("keys", role);
        bytes[] memory bytesArray = storage_.getBytesArray(roleKeys);
        for (uint i = 0; i < bytesArray.length; i++) {
            
            bytes memory encodedKey = bytesArray[i];
            (address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) = _decodeKey(encodedKey);
            _grantKey(account, of_, signature, type_, startTimestamp, endTimestamp, balance);
        }

        bytes32 roleMembers = __Encoder.encodeWithRole("members", role);
        storage_.addAddressSet(roleMembers, account);

        success = true;
        return success;
    }

    function _revokeRole(address account, string memory role)
        internal
        returns (bool) {
        
        bool success;

        bytes32 roleKeys = __Encoder.encodeWithRole("keys", role);
        bytes[] memory bytesArray = storage_.getBytesArray(roleKeys);
        for (uint i = 0; i < bytesArray.length; i++) {

            bytes memory encodedKey = bytesArray[i];
            (address of_, string memory signature, , , ,) = _decodeKey(encodedKey);
            _revokeKey(account, of_, signature);
        }

        bytes32 roleMembers = __Encoder.encodeWithRole("members", role);
        storage_.removeAddressSet(roleMembers, account);

        success = true;
        return success;
    }
}