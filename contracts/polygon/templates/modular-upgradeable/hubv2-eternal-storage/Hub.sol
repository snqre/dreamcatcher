// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/__Encoder.sol";

contract Hub {
    IStorage storage_;

    // trying to use storage before it has been set as implementation
    constructor(address storage__, uint timelockDuration_, uint timeoutDuration_) {
        storage_ = IStorage(storage__);
        
        bytes32 timelockDuration = __Encoder.encode("timelockDuration");
        bytes32 timeoutDuration = __Encoder.encode("timeoutDuration");
        storage_.setUint(timelockDuration, timelockDuration_);
        storage_.setUint(timeoutDuration, timeoutDuration_);
        
        bytes32 approveAllRequests = __Encoder.encode("approveAllRequests");
        storage_.setBool(approveAllRequests, true);
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

    function encodeRequest(address[] memory targets, string[] memory signatures, bytes[] memory args, address creator, string memory message, bool isApproved, bool isRejected, bool isExecuted, uint startTimestamp, uint endTimestamp, uint timeoutTimestamp)
        external pure
        returns (bytes memory) {
        return _encodeRequest(targets, signatures, args, creator, message, isApproved, isRejected, isExecuted, startTimestamp, endTimestamp, timeoutTimestamp);
    }

    function decodeRequest(bytes memory request)
        external pure
        returns (address[] memory, string[] memory, bytes[] memory, address, string memory, bool, bool, bool, uint, uint, uint) {
        return _decodeRequest(request);
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

    function getRequests()
        external view
        returns (bytes[] memory) {
        bytes32 requests = __Encoder.encode("requests");
        return storage_.getBytesArray(requests);
    }

    function grantKey(address account, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        external {
        bool success = _grantKey(account, of_, signature, type_, startTimestamp, endTimestamp, balance);
        _requireSuccess(success);
    }

    function revokeKey(address account, address of_, string memory signature)
        external {
        bool success = _revokeKey(account, of_, signature);
        _requireSuccess(success);
    }

    function resetKeys(address account)
        external {
        bool success = _resetKeys(account);
        _requireSuccess(success);
    }

    function verify(address account, address of_, string memory signature)
        external {
        bool success = _verify(account, of_, signature);
        _requireSuccess(success);
    }

    function grantKeyToRole(string memory role, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        external {
        bool success = _grantKeyToRole(role, of_, signature, type_, startTimestamp, endTimestamp, balance);
        _requireSuccess(success);
    }

    function revokeKeyFromRole(string memory role, address of_, string memory signature)
        external {
        bool success = _revokeKeyFromRole(role, of_, signature);
        _requireSuccess(success);
    }

    function resetRoleKeys(string memory role)
        external {
        bool success = _resetRoleKeys(role);
        _requireSuccess(success);
    }

    function grantRole(address account, string memory role)
        external {
        bool success = _grantRole(account, role);
        _requireSuccess(success);
    }

    function revokeRole(address account, string memory role)
        external {
        bool success = _revokeRole(account, role);
        _requireSuccess(success);
    }

    function queue(address[] memory targets, string[] memory signatures, bytes[] memory args, address creator, string memory message)
        external 
        returns (uint) {
        (bool success, uint index) = _queue(targets, signatures, args, creator, message);
        _requireSuccess(success);
        return index;
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

    function _encodeRequest(address[] memory targets, string[] memory signatures, bytes[] memory args, address creator, string memory message, bool isApproved, bool isRejected, bool isExecuted, uint startTimestamp, uint endTimestamp, uint timeoutTimestamp)
        internal pure
        returns (bytes memory) {
        return abi.encode(targets, signatures, args, creator, message, isApproved, isRejected, isExecuted, startTimestamp, endTimestamp, timeoutTimestamp);
    }

    function _decodeRequest(bytes memory request)
        internal pure
        returns (address[] memory, string[] memory, bytes[] memory, address, string memory, bool, bool, bool, uint, uint, uint) {
        (address[] memory targets, string[] memory signatures, bytes[] memory args, address creator, string memory message, bool isApproved, bool isRejected, bool isExecuted, uint startTimestamp, uint endTimestamp, uint timeoutTimestamp) = abi.decode(request, (address[], string[], bytes[], address, string, bool, bool, bool, uint, uint, uint));
        return (targets, signatures, args, creator, message, isApproved, isRejected, isExecuted, startTimestamp, endTimestamp, timeoutTimestamp);
    }

    function _requireSuccess(bool success)
        internal pure {
        require(success, "Hub: failed execution");
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
        // **keep an eye on this one
        bool sameContract = contract1 == contract2;
        bool sameSignature = _isMatchingString(signature1, signature2);
        return sameContract && sameSignature;
    }

    function _getKeyIndexByContractAndSignature(bytes32 array, address of_, string memory signature)
        internal view
        returns (bool, uint) {
        uint index;
        bool success;
        bytes memory emptyBytes;
        for (uint i = 0; i < storage_.lengthBytesArray(array); i++) {
            bytes memory encodedKey = storage_.indexBytesArray(array, i);

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
    }

    function _requireNoDuplicateKey(bytes32 array, bytes memory encodedKey)
        internal view { 
        
        (address of_, string memory signature, , , ,) = _decodeKey(encodedKey);
        
        bytes memory emptyBytes;
        for (uint i = 0; i < storage_.lengthBytesArray(array); i++) {
            bytes memory encodedKey2 = storage_.indexBytesArray(array, i);
            
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
        for (uint i = 0; i < storage_.lengthBytesArray(array); i++) {
            bytes memory encodedKey2 = storage_.indexBytesArray(array, i);

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
        _requireValidKeyInput(type_, startTimestamp, endTimestamp, balance);

        require(of_ != address(0x0), "Hub: of_ address is zero");

        bytes memory encodedKey = _encodeKey(of_, signature, type_, startTimestamp, endTimestamp, balance);
        bytes32 roleKeys = __Encoder.encodeWithRole("keys", role);
        
        _requireNoDuplicateKey(roleKeys, encodedKey);
        success = _tryPushKeyToEmptyBytes(roleKeys, encodedKey);

        // no empty bytes were found
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
        (bool gotIndex, uint index) = _getKeyIndexByContractAndSignature(roleKeys, of_, signature);
        _requireSuccess(gotIndex);

        bytes memory emptyBytes;
        storage_.setIndexBytesArray(roleKeys, index, emptyBytes);

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

    // stack too deep
    function _queue(address[] memory targets, string[] memory signatures, bytes[] memory args, address creator, string memory message)
        internal
        returns (bool, uint) {
        
        bool success;

        bytes32 timelockDuration = __Encoder.encode("timelockDuration");
        bytes32 timeoutDuration = __Encoder.encode("timeoutDuration");
        uint timelock = storage_.getUint(timelockDuration);
        uint timeout = storage_.getUint(timeoutDuration);
        uint startTimestamp = block.timestamp;
        uint endTimestamp = startTimestamp + timelock;
        uint timeoutTimestamp = endTimestamp + timeout;
        bytes32 requests = __Encoder.encode("requests");
        bytes memory request = _encodeRequest(targets, signatures, args, creator, message, false, false, false, startTimestamp, endTimestamp, timeoutTimestamp);
        storage_.pushBytesArray(requests, request);
        uint index = storage_.lengthBytesArray(requests) - 1;
        
        success = true;
        return (success, index);
    }
}