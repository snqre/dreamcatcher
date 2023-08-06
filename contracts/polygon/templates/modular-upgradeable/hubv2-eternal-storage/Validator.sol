// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/__Encoder.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";

contract Validator is ReentrancyGuard {

    /**
    
        addressSet: role, "members"     members
        bytesArray: role, "keys"        keys
        

     */

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
        external 
        nonReentrant {
        _verify(msg.sender, address(this), "grantKey");
        bool success = _grantKey(account, of_, signature, type_, startTimestamp, endTimestamp, balance);
        _requireSuccess(success);
    }

    function revokeKey(address account, address of_, string memory signature)
        external 
        nonReentrant {
        _verify(msg.sender, address(this), "revokeKey");
        bool success = _revokeKey(account, of_, signature);
        _requireSuccess(success);
    }

    function resetKeys(address account)
        external 
        nonReentrant {
        _verify(msg.sender, address(this), "resetKeys");
        bool success = _resetKeys(account);
        _requireSuccess(success);
    }

    function verify(address account, address of_, string memory signature)
        external 
        nonReentrant {
        bool success = _verify(account, of_, signature);
        _requireSuccess(success);
    }

    function grantKeyToRole(string memory role, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        external 
        nonReentrant {
        _verify(msg.sender, address(this), "grantKeyToRole");
        bool success = _grantKeyToRole(role, of_, signature, type_, startTimestamp, endTimestamp, balance);
        _requireSuccess(success);
    }

    function revokeKeyFromRole(string memory role, address of_, string memory signature)
        external 
        nonReentrant {
        _verify(msg.sender, address(this), "revokeKeyFromRole");
        bool success = _revokeKeyFromRole(role, of_, signature);
        _requireSuccess(success);
    }

    function resetRoleKeys(string memory role)
        external 
        nonReentrant {
        _verify(msg.sender, address(this), "resetRoleKeys");
        bool success = _resetRoleKeys(role);
        _requireSuccess(success);
    }

    function grantRole(address account, string memory role)
        external 
        nonReentrant {
        _verify(msg.sender, address(this), "grantRole");
        bool success = _grantRole(account, role);
        _requireSuccess(success);
    }

    function revokeRole(address account, string memory role)
        external 
        nonReentrant {
        _verify(msg.sender, address(this), "revokeRole");
        bool success = _revokeRole(account, role);
        _requireSuccess(success);
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

    function _account(address account, string memory string_)
        internal pure
        returns (bytes32) {
        return keccak256(abi.encode(account, string_));
    }

    function _role(string memory role, string memory string_)
        internal pure
        returns (bytes32) {
        return keccak256(abi.encode(role, string_));
    }

    function _requireSuccess(bool success)
        internal pure {
        require(success, "Validator: failed execution");
    }

    function _isMatchingBytes(bytes memory pBytes1, bytes memory pBytes2)
        internal pure 
        returns (bool) {
        return keccak256(pBytes1) == keccak256(pBytes2);
    }

    function _isMatchingString(string memory pString1, string memory pString2)
        internal pure
        returns (bool) {
        return keccak256(abi.encodePacked(pString1)) == keccak256(abi.encodePacked(pString2));
    }

    function _isMatchingKeyContractAndSignature(address contract1, string memory signature1, address contract2, string memory signature2)
        internal pure
        returns (bool) {
        bool sameContract = contract1 == contract2;
        bool sameSignature = _isMatchingString(signature1, signature2);
        return sameContract && sameSignature;
    }

    function _requireStandardKey(uint startTimestamp, uint endTimestamp, uint balance) 
        internal pure {
        require(startTimestamp == 0, "Validator: startTimestamp must be zero");
        require(endTimestamp == 0, "Validator: endTimestamp must be zero");
        require(balance == 0, "Validator: balance must be zero");
    }

    function _requireConsumableKey(uint startTimestamp, uint endTimestamp, uint balance) 
        internal pure {
        require(startTimestamp == 0, "Validator: startTimestamp must be zero");
        require(endTimestamp == 0, "Validator: endTimestamp must be zero");
        require(balance >= 1, "Validator: balance is less than 1");
    }

    function _verifyConsumableKey(uint balance)
        internal pure 
        returns (uint) {
        require(balance >= 1, "Validator: consumable key is depleted");
        return balance -= 1;
    }

    function _requireNotAddressZero(address account)
        internal pure {
        require(account != address(0x0), "Validator: address zero");
    }

    function _requireTimedKey(uint startTimestamp, uint endTimestamp, uint balance)
        internal view {
        require(block.timestamp <= startTimestamp, "Validator: startTimestamp cannot be in the past");
        require(endTimestamp >= startTimestamp, "Validator: endTimestamp cannot be before startTimestamp");
        require(balance == 0, "Validator: balance must be zero");
    }

    function _verifyTimedKey(uint startTimestamp, uint endTimestamp)
        internal view {
        require(block.timestamp >= startTimestamp, "Validator: timed key cannot be used before granted");
        require(block.timestamp <= endTimestamp, "Validator: timed key is expired");
    }

    function _getKeyIndexByContractAndSignature(bytes32 array, address of_, string memory signature)
        internal view
        returns (bool, uint) {
        uint index;
        bool success;
        bytes memory emptyBytes;
        bytes[] memory bytesArray = storage_.getBytesArray(array);
        for (uint i = 0; i < bytesArray.length; i++) {
            bytes memory encodedKey = bytesArray[i];

            // decode
            if (!_isMatchingBytes(encodedKey, emptyBytes)) {
                (address of_2, string memory signature2, , , ,) = _decodeKey(encodedKey);
                bool isMatching = _isMatchingKeyContractAndSignature(of_, signature, of_2, signature2);

                if (isMatching) {
                    index = i;
                    success = true;
                    break;
                }
            }
        }

        return (success, index);
    }

    function _requireValidKeyInput(uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        internal view {
        if (type_ == 0) { _requireStandardKey(startTimestamp, endTimestamp, balance); }
        else if (type_ == 1) { _requireTimedKey(startTimestamp, endTimestamp, balance); }
        else if (type_ == 2) { _requireConsumableKey(startTimestamp, endTimestamp, balance); }
        
        else {
            revert("Hub: invalid type");
        }
    }

    function _requireNoDuplicateKey(bytes32 array, bytes memory encodedKey)
        internal view { 
        
        (address of_, string memory signature, , , ,) = _decodeKey(encodedKey);
        
        bytes memory emptyBytes;
        bytes[] memory bytesArray = storage_.getBytesArray(array);
        for (uint i = 0; i < bytesArray.length; i++) {
            bytes memory encodedKey2 = bytesArray[i];
            
            // decode
            if (!_isMatchingBytes(encodedKey2, emptyBytes)) {
                (address of_2, string memory signature2, , , ,) = _decodeKey(encodedKey2);
                bool isMatching = _isMatchingKeyContractAndSignature(of_, signature, of_2, signature2);
                require(!isMatching, "Hub: matching contract & address to an already existing key");
            }
        }
    }

    function _tryPushKeyToEmptyBytes(bytes32 array, bytes memory encodedKey)
        internal 
        returns (bool) {
        bool success;
        bytes memory emptyBytes;
        bytes[] memory bytesArray = storage_.getBytesArray(array);
        for (uint i = 0; i < bytesArray.length; i++) {
            bytes memory encodedKey2 = bytesArray[i];

            // check
            if (_isMatchingBytes(encodedKey2, emptyBytes)) {
                
                // only if empty
                storage_.setIndexBytesArray(array, i, encodedKey);
                success = true;
                break;
            }
        }

        return success;
    }

    function _grantKey(address account, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        internal 
        returns (bool) {
        
        bool success;
        _requireValidKeyInput(type_, startTimestamp, endTimestamp, balance);

        require(account != address(0x0), "Hub: account address is zero");
        require(of_ != address(0x0), "Hub: of_ address is zero");

        bytes memory encodedKey = abi.encode(of_, signature, type_, startTimestamp, endTimestamp, balance);
        bytes32 accountKeys = __Encoder.encodeWithAccount("keys", account);

        _requireNoDuplicateKey(accountKeys, encodedKey);
        success = _tryPushKeyToEmptyBytes(accountKeys, encodedKey);

        // no empty bytes were found
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
        (bool gotIndex, uint index) = _getKeyIndexByContractAndSignature(accountKeys, of_, signature);
        _requireSuccess(gotIndex);

        bytes memory emptyBytes;
        storage_.setIndexBytesArray(accountKeys, index, emptyBytes);

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
        
        _requireNotAddressZero(account);
        _requireNotAddressZero(of_);

        // context
        bytes32 keys = _account(account, "keys");
        bytes[] memory bytesArray = storage_.getBytesArray(keys);
        for (uint i = 0; i < bytesArray.length; i++) {

            bytes memory key = storage_.indexBytesArray(keys, i);
            (address of_2, string memory signature2, uint type_, uint startTimestamp, uint endTimestamp, uint balance) = _decodeKey(key);

            if (_isMatchingKeyContractAndSignature(of_, signature, of_2, signature2)) {

                if (type_ == 0) { success = true; }

                if (type_ == 1) {
                    _verifyTimedKey(startTimestamp, endTimestamp);
                    success = true;
                }
                
                if (type_ == 2) {
                   uint newBalance =  _verifyConsumableKey(balance);
                    
                    require(balance >= 1, "Validator: balance is zero");
                
                    bytes memory key2 = _encodeKey(of_2, signature2, type_, startTimestamp, endTimestamp, newBalance);
                    storage_.setIndexBytesArray(keys, i, key2);
                    success = true;
                }

                break;
            }
        }

        return success;
    }

    function _grantKeyToRole(string memory role, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        internal 
        returns (bool) {
            
        bool success;
        _requireValidKeyInput(type_, startTimestamp, endTimestamp, balance);

        require(of_ != address(0x0), "Validator: of_ address is zero");

        // context
        bytes memory key = _encodeKey(of_, signature, type_, startTimestamp, endTimestamp, balance);
        bytes32 keys = _role(role, "keys");
        
        _requireNoDuplicateKey(keys, key);
        success = _tryPushKeyToEmptyBytes(keys, key);

        // no empty bytes were found
        if (!success) {
            storage_.pushBytesArray(keys, key);
            success = true;
        }

        return success;
    }

    function _revokeKeyFromRole(string memory role, address of_, string memory signature)
        internal
        returns (bool) {
        
        bool success;

        require(of_ != address(0x0), "Validator: account address is zero");

        // context
        bytes32 keys = _role(role, "keys");
        (bool gotIndex, uint index) = _getKeyIndexByContractAndSignature(keys, of_, signature);
        _requireSuccess(gotIndex);

        bytes memory emptyBytes;
        storage_.setIndexBytesArray(keys, index, emptyBytes);

        success = true;
        return success;
    }

    function _resetRoleKeys(string memory role)
        internal
        returns (bool) {
        
        bool success;

        storage_.deleteBytesArray(_role(role, "keys"));

        success = true;
        return success;
    }

    function _grantRole(address account, string memory role)
        internal
        returns (bool) {
        
        // refresh account before assiging role
        _resetKeys(account);
        bool success;

        bytes[] memory bytesArray = storage_.getBytesArray(_role(role, "keys"));
        for (uint i = 0; i < bytesArray.length; i++) {
            
            bytes memory encodedKey = bytesArray[i];
            (address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) = _decodeKey(encodedKey);
            _grantKey(account, of_, signature, type_, startTimestamp, endTimestamp, balance);
        }

        // add address as member of the role
        storage_.addAddressSet(_role(role, "members"), account);

        success = true;
        return success;
    }

    function _revokeRole(address account, string memory role)
        internal
        returns (bool) {
        
        bool success;

        bytes[] memory bytesArray = storage_.getBytesArray(_role(role, "keys"));
        for (uint i = 0; i < bytesArray.length; i++) {

            bytes memory encodedKey = bytesArray[i];
            (address of_, string memory signature, , , ,) = _decodeKey(encodedKey);
            _revokeKey(account, of_, signature);
        }

        // remove address as member of the role
        storage_.removeAddressSet(_role(role, "members"), account);

        success = true;
        return success;
    }
}