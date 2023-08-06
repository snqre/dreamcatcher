// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";

interface IValidator {
    function encodeKey(address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) external pure returns (bytes memory);
    function decodeKey(bytes memory key) external pure returns (address, string memory, uint, uint, uint, uint);
    function getKeys(address account) external view returns (bytes[] memory);
    function getRoleKeys(string memory role) external view returns (bytes[] memory);
    function getRoleMembers(string memory role) external view returns (address[] memory);
    function getRoleSize(string memory role) external view returns (uint);
    function grantKey(address account, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) external;
    function revokeKey(address account, address of_, string memory signature) external;
    function resetKeys(address account) external;
    function verify(address account, address of_, string memory signature) external;
    function grantKeyToRole(string memory role, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) external;
    function revokeKeyFromRole(string memory role, address of_, string memory signature) external;
    function resetRoleKeys(string memory role) external;
    function grantRole(address account, string memory role) external;
    function revokeRole(address account, string memory role) external;
    function pause() external;
    function unpause() external;
}

contract Validator is IValidator, ReentrancyGuard, Pausable {

    /**
        addressSet: role,    "members"   members
        bytesArray: role,    "keys"      keys
        bytesArray: account, "keys"      keys
     */

    IStorage storage_;
    
    constructor(address storage__) {
        storage_ = IStorage(storage__);
        _grantKeyToRole("validator", address(this), "grantKey", 0, 0, 0, 0);
        _grantKeyToRole("validator", address(this), "revokeKey", 0, 0, 0, 0);
        _grantKeyToRole("validator", address(this), "resetKeys", 0, 0, 0, 0);
        _grantKeyToRole("validator", address(this), "grantKeyToRole", 0, 0, 0, 0);
        _grantKeyToRole("validator", address(this), "revokeKeyFromRole", 0, 0, 0, 0);
        _grantKeyToRole("validator", address(this), "resetRoleKeys", 0, 0, 0, 0);
        _grantKeyToRole("validator", address(this), "grantRole", 0, 0, 0, 0);
        _grantKeyToRole("validator", address(this), "revokeRole", 0, 0, 0, 0);
        _grantKeyToRole("validator", address(this), "pause", 0, 0, 0, 0);
        _grantKeyToRole("validator", address(this), "unpause", 0, 0, 0, 0);
        _grantRole(msg.sender, "validator");
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
        return storage_.getBytesArray(_account(account, "keys"));
    }

    function getRoleKeys(string memory role)
        external view
        returns (bytes[] memory) {
        return storage_.getBytesArray(_role(role, "keys"));
    }

    function getRoleMembers(string memory role)
        external view
        returns (address[] memory) {
        return storage_.valuesAddressSet(_role(role, "members"));
    }

    function getRoleSize(string memory role)
        external view
        returns (uint) {
        return storage_.lengthAddressSet(_role(role, "members"));
    }

    function grantKey(address account, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        external
        nonReentrant 
        whenNotPaused {
        _requireSuccess(_verify(msg.sender, address(this), "grantKey"));
        _requireSuccess(_grantKey(account, of_, signature, type_, startTimestamp, endTimestamp, balance));
    }

    function revokeKey(address account, address of_, string memory signature)
        external 
        nonReentrant 
        whenNotPaused {
        _requireSuccess(_verify(msg.sender, address(this), "revokeKey"));
        _requireSuccess(_revokeKey(account, of_, signature));
    }

    function resetKeys(address account)
        external 
        nonReentrant 
        whenNotPaused {
        _requireSuccess(_verify(msg.sender, address(this), "resetKeys"));
        _requireSuccess(_resetKeys(account));
    }

    function verify(address account, address of_, string memory signature)
        external 
        nonReentrant {
        // verify is mainly view and cannot be paused as to fix any issues or upgrade we need to be able to use this core function
        _requireSuccess(_verify(account, of_, signature));
    }

    function grantKeyToRole(string memory role, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        external 
        nonReentrant 
        whenNotPaused {
        _requireSuccess(_verify(msg.sender, address(this), "grantKeyToRole"));
        _requireSuccess(_grantKeyToRole(role, of_, signature, type_, startTimestamp, endTimestamp, balance));
    }

    function revokeKeyFromRole(string memory role, address of_, string memory signature)
        external 
        nonReentrant 
        whenNotPaused {
        _requireSuccess(_verify(msg.sender, address(this), "revokeKeyFromRole"));
        _requireSuccess(_revokeKeyFromRole(role, of_, signature));
    }

    function resetRoleKeys(string memory role)
        external 
        nonReentrant 
        whenNotPaused {
        _requireSuccess(_verify(msg.sender, address(this), "resetRoleKeys"));
        _requireSuccess(_resetRoleKeys(role));
    }

    function grantRole(address account, string memory role)
        external 
        nonReentrant 
        whenNotPaused {
        _requireSuccess(_verify(msg.sender, address(this), "grantRole"));
        _requireSuccess(_grantRole(account, role));
    }

    function revokeRole(address account, string memory role)
        external 
        nonReentrant 
        whenNotPaused {
        _requireSuccess(_verify(msg.sender, address(this), "revokeRole"));
        _requireSuccess(_revokeRole(account, role));
    }

    function pause()
        external 
        nonReentrant {
        _requireSuccess(_verify(msg.sender, address(this), "pause"));
        _pause();
    }

    function unpause()
        external
        nonReentrant {
        _requireSuccess(_verify(msg.sender, address(this), "unpause"));
        _unpause();
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
        require(balance >= 1, "Validator: balance is zero");
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
        require(block.timestamp >= startTimestamp, "Validator: cannot use key before startTimestamp");
        require(block.timestamp <= endTimestamp, "Validator: cannot use key after endTimestamp");
    }

    function _getKeyIndexByContractAndSignature(bytes32 array, address of_, string memory signature)
        internal view
        returns (bool, uint) {

        uint index;
        bool success;
        bytes memory emptyBytes;
        bytes[] memory bytesArray = storage_.getBytesArray(array);

        for (uint i = 0; i < bytesArray.length; i++) {
            bytes memory key = bytesArray[i];

            // decode
            if (!_isMatchingBytes(key, emptyBytes)) {
                (address of_2, string memory signature2, , , ,) = _decodeKey(key);
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

    function _requireNoDuplicateKey(bytes32 array, bytes memory key)
        internal view { 
        
        (address of_, string memory signature, , , ,) = _decodeKey(key);
        
        bytes memory emptyBytes;
        bytes[] memory bytesArray = storage_.getBytesArray(array);
        for (uint i = 0; i < bytesArray.length; i++) {
            bytes memory key2 = bytesArray[i];
            
            // decode
            if (!_isMatchingBytes(key2, emptyBytes)) {
                (address of_2, string memory signature2, , , ,) = _decodeKey(key2);
                bool isMatching = _isMatchingKeyContractAndSignature(of_, signature, of_2, signature2);
                require(!isMatching, "Hub: matching contract & address to an already existing key");
            }
        }
    }

    function _tryPushKeyToEmptyBytes(bytes32 array, bytes memory key)
        internal 
        returns (bool) {

        bool success;
        bytes memory emptyBytes;
        bytes[] memory bytesArray = storage_.getBytesArray(array);
        
        for (uint i = 0; i < bytesArray.length; i++) {
            bytes memory key2 = bytesArray[i];

            // check
            if (_isMatchingBytes(key2, emptyBytes)) {
                
                // only if empty
                storage_.setIndexBytesArray(array, i, key);
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
        _requireNotAddressZero(account);
        _requireNotAddressZero(of_);

        bytes memory key = abi.encode(of_, signature, type_, startTimestamp, endTimestamp, balance);
        bytes32 keys = _account(account, "keys");

        _requireNoDuplicateKey(keys, key);
        success = _tryPushKeyToEmptyBytes(keys, key);

        // no empty bytes were found
        if (!success) {
            storage_.pushBytesArray(keys, key);
            success = true;
        }

        return success;
    }

    function _revokeKey(address account, address of_, string memory signature)
        internal 
        returns (bool) {
        
        bool success;

        _requireNotAddressZero(account);
        _requireNotAddressZero(of_);
        
        bytes32 keys = _account(account, "keys");
        (bool gotIndex, uint index) = _getKeyIndexByContractAndSignature(keys, of_, signature);
        _requireSuccess(gotIndex);

        bytes memory emptyBytes;
        storage_.setIndexBytesArray(keys, index, emptyBytes);

        success = true;
        return success;
    }

    function _resetKeys(address account)
        internal
        returns (bool) {
        
        bool success;

        _requireNotAddressZero(account);

        bytes32 keys = _account(account, "keys");
        storage_.deleteBytesArray(keys);

        success = true;
        return success;
    }

    function _verify(address account, address of_, string memory signature)
        internal 
        returns (bool) {
        
        // does not revert just returns if true or false use external access verify for revert
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
        _requireNotAddressZero(of_);

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

        _requireNotAddressZero(of_);

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