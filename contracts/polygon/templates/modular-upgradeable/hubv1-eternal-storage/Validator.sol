// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";

/**

    **set as implementation from storage

    # purpose
    - manage roles and permissions of the ecosystem

    **rated 80%
 */

interface IValidator {
    function encodeKey(address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) external pure returns (bytes memory);
    function decodeKey(bytes memory key) external pure returns (address, string memory, uint, uint, uint, uint);
    function getKeys(address account) external view returns (bytes[] memory);
    function getRoleKeys(string memory role) external view returns (bytes[] memory);
    function getRoleMembers(string memory role) external view returns (address[] memory);
    function getRoleSize(string memory role) external view returns (uint);
    function init() external;
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

    bool private _init;
    address public deployer;

    IStorage public storage_;

    modifier verify_(string memory signature) {
        _requireSuccess({success: _verify({account: msg.sender, of_: address(this), signature: signature})});
        _;
    }
    
    constructor(address storage__) {
        storage_ =IStorage(storage__);
        deployer =msg.sender;
    }

    function encodeKey(address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external pure
        returns (bytes memory key) {
        return _encodeKey(of_, signature, type_, startTimestamp, endTimestamp, balance);
    }

    function decodeKey(bytes memory key)
    external pure
        returns (address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) {
        return _decodeKey(key);
    }

    function getKeys(address account)
    external view
        returns (bytes[] memory keys) {
        return storage_.getBytesArray({key: _account({account: account, string_: "keys"})});
    }

    function getRoleKeys(string memory role)
    external view
        returns (bytes[] memory keys) {
        return storage_.getBytesArray({key: _role({role: role, string_: "keys"})});
    }

    function getRoleMembers(string memory role)
    external view
        returns (address[] memory members) {
        return storage_.valuesAddressSet({key: _role({role: role, string_: "members"})});
    }

    function getRoleSize(string memory role)
    external view
        returns (uint size) {
        return storage_.lengthAddressSet({key: _role({role: role, string_: "members"})});
    }

    function init() 
    external 
    nonReentrant 
    whenNotPaused {
        require(msg.sender ==deployer, "Validator: only deployer can init");
        require(!_init, "Validator: !init");
        _grantKeyToRole({role: "validator", of_: address(this), signature: "grantKey(address,address,string,uint,uint,uint,uint)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        _grantKeyToRole({role: "validator", of_: address(this), signature: "revokeKey(address,address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        _grantKeyToRole({role: "validator", of_: address(this), signature: "resetKeys(address)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        _grantKeyToRole({role: "validator", of_: address(this), signature: "grantKeyToRole(string,address,string,uint,uint,uint,uint)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        _grantKeyToRole({role: "validator", of_: address(this), signature: "revokeKeyFromRole(string,address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        _grantKeyToRole({role: "validator", of_: address(this), signature: "resetRoleKeys(string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        _grantKeyToRole({role: "validator", of_: address(this), signature: "grantRole(address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        _grantKeyToRole({role: "validator", of_: address(this), signature: "revokeRole(address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        _grantKeyToRole({role: "validator", of_: address(this), signature: "pause()", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        _grantKeyToRole({role: "validator", of_: address(this), signature: "unpause()", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        _grantRole({account: msg.sender, role: "validator"});
        _init =true;
    }

    function grantKey(address account, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external
    nonReentrant
    whenNotPaused
    verify_("grantKey(address,address,string,uint,uint,uint,uint)") {
        _requireSuccess({success: _grantKey({account: account, of_: of_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance})});
    }

    function revokeKey(address account, address of_, string memory signature)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("revokeKey(address,address,string)") {
        _requireSuccess({success: _revokeKey({account: account, of_: of_, signature: signature})});
    }

    function resetKeys(address account)
    external
    nonReentrant
    whenNotPaused 
    verify_("resetKeys(address)") {
        _requireSuccess({success: _resetKeys({account: account})});
    }

    function verify(address account, address of_, string memory signature)
    external 
    nonReentrant {
        if (!storage_.containsAddressSet({key: _role({role: "universal-key", string_: "members"}), value: msg.sender})) {
            _requireSuccess({success: _verify({account: account, of_: of_, signature: signature})});
        }
    }

    function grantKeyToRole(string memory role, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("grantKeyToRole(string,address,string,uint,uint,uint,uint)") {
        _requireSuccess({success: _grantKeyToRole({role: role, of_: of_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance})});
    }

    function revokeKeyFromRole(string memory role, address of_, string memory signature)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("revokeKeyFromRole(string,address,string)") {
        _requireSuccess({success: _revokeKeyFromRole({role: role, of_: of_, signature: signature})});
    }

    function resetRoleKeys(string memory role)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("resetRoleKeys(string)") {
        _requireSuccess({success: _resetRoleKeys({role: role})});
    }

    function grantRole(address account, string memory role)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("grantRole(address,string)") {
        _requireSuccess({success: _grantRole({account: account, role: role})});
    }

    function revokeRole(address account, string memory role)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("revokeRole(address,string)") {
        _requireSuccess({success: _revokeRole({account: account, role: role})});
    }

    function pause()
    external 
    nonReentrant 
    verify_("pause()") {
        _pause();
    }

    function unpause()
    external
    nonReentrant 
    verify_("unpause()") {
        _unpause();
    }

    function _encode(string memory string_)
    internal pure
    returns (bytes32) {
        return keccak256(abi.encode(string_));
    }

    function _encodeKey(address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    internal pure
    returns (bytes memory key) {
        return abi.encode(of_, signature, type_, startTimestamp, endTimestamp, balance);
    }

    function _decodeKey(bytes memory key)
    internal pure
    returns (address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) {
        return abi.decode(key, (address,string,uint,uint,uint,uint));
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
        require(success, "Validator: !success");
    }

    function _isMatchingBytes(bytes memory pBytes1, bytes memory pBytes2)
    internal pure 
    returns (bool isMatching) {
        return keccak256(pBytes1) == keccak256(pBytes2);
    }

    function _isMatchingString(string memory pString1, string memory pString2)
    internal pure
    returns (bool isMatching) {
        return keccak256(abi.encodePacked(pString1)) == keccak256(abi.encodePacked(pString2));
    }

    function _isMatchingKeyContractAndSignature(address contract1, string memory signature1, address contract2, string memory signature2)
    internal pure
    returns (bool isMatching) {
        return contract1 ==contract2 && _isMatchingString({pString1: signature1, pString2: signature2});
    }

    function _requireStandardKey(uint startTimestamp, uint endTimestamp, uint balance) 
    internal pure {
        require(startTimestamp ==0, "Validator: startTimestamp must be zero");
        require(endTimestamp ==0, "Validator: endTimestamp must be zero");
        require(balance ==0, "Validator: balance must be zero");
    }

    function _requireConsumableKey(uint startTimestamp, uint endTimestamp, uint balance) 
    internal pure {
        require(startTimestamp ==0, "Validator: startTimestamp must be zero");
        require(endTimestamp ==0, "Validator: endTimestamp must be zero");
        require(balance >=1, "Validator: balance is less than 1");
    }

    function _verifyConsumableKey(uint balance)
    internal pure 
    returns (uint) {
        require(balance >=1, "Validator: balance is zero");
        return balance--;
    }

    function _requireNotAddressZero(address account)
    internal pure {
        require(account !=address(0x0), "Validator: address zero");
    }

    function _requireTimedKey(uint startTimestamp, uint endTimestamp, uint balance)
    internal view {
        require(block.timestamp <=startTimestamp, "Validator: startTimestamp cannot be in the past");
        require(endTimestamp >=startTimestamp, "Validator: endTimestamp cannot be before startTimestamp");
        require(balance ==0, "Validator: balance must be zero");
    }

    function _verifyTimedKey(uint startTimestamp, uint endTimestamp)
    internal view {
        require(block.timestamp >=startTimestamp, "Validator: cannot use key before startTimestamp");
        require(block.timestamp <=endTimestamp, "Validator: cannot use key after endTimestamp");
    }

    function _getKeyIndexByContractAndSignature(bytes32 array, address of_, string memory signature)
    internal view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes[] memory bytesArray = storage_.getBytesArray(array);

        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory key = bytesArray[i];

            // decode
            if (!_isMatchingBytes({pBytes1: key, pBytes2: emptyBytes})) {
                (address of_2, string memory signature2, , , ,) = _decodeKey({key: key});
                if (_isMatchingKeyContractAndSignature({contract1: of_, signature1: signature, contract2: of_2, signature2: signature2})) {
                    index =i;
                    success =true;
                    break;
                }
            }
        }
        return (success, index);
    }

    function _requireValidKeyInput(uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    internal view {
        if (type_ ==0) { _requireStandardKey({startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance}); }
        else if (type_ ==1) { _requireTimedKey({startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance}); }
        else if (type_ ==2) { _requireConsumableKey({startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance}); }
        else { revert("Validator: invalid type"); }
    }

    function _requireNoDuplicateKey(bytes32 array, bytes memory key)
    internal view { 
        (address of_, string memory signature, , , ,) = _decodeKey({key: key});
        
        bytes memory emptyBytes;
        bytes[] memory bytesArray = storage_.getBytesArray({key: array});
        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory key2 = bytesArray[i];
            
            // decode
            if (!_isMatchingBytes({pBytes1: key2, pBytes2: emptyBytes})) {
                (address of_2, string memory signature2, , , ,) = _decodeKey({key: key2});
                require(
                    _isMatchingKeyContractAndSignature({contract1: of_, signature1: signature, contract2: of_2, signature2: signature2}),
                    "Validator: matching contract & address to an already existing key"
                );
            }
        }
    }

    function _tryPushKeyToEmptyBytes(bytes32 array, bytes memory key)
    internal 
    returns (bool success) {
        bytes memory emptyBytes;
        bytes[] memory bytesArray = storage_.getBytesArray({key: array});
        
        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory key2 = bytesArray[i];

            // check
            if (_isMatchingBytes({pBytes1: key2, pBytes2: emptyBytes})) {
                storage_.setIndexBytesArray({key: array, index: i, value: key});
                success =true;
                break;
            }
        }

        return success;
    }

    function _grantKey(address account, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    internal 
    returns (bool success) {
        _requireValidKeyInput({type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        _requireNotAddressZero({account: account});
        _requireNotAddressZero({account: of_});

        bytes memory key =abi.encode(of_, signature, type_, startTimestamp, endTimestamp, balance);
        bytes32 keys =_account({account: account, string_: "keys"});

        _requireNoDuplicateKey({array: keys, key: key});
        success =_tryPushKeyToEmptyBytes({array: keys, key: key});

        // no empty bytes were found
        if (!success) {
            storage_.pushBytesArray({key: keys, value: key});
            success =true;
        }

        return success;
    }


    function _revokeKey(address account, address of_, string memory signature)
    internal 
    returns (bool success) {
        _requireNotAddressZero({account: account});
        _requireNotAddressZero({account: of_});
        
        bytes32 keys =_account({account: account, string_: "keys"});
        
        (bool gotIndex, uint index) =_getKeyIndexByContractAndSignature({array: keys, of_: of_, signature: signature});
        _requireSuccess({success: gotIndex});

        bytes memory emptyBytes;
        storage_.setIndexBytesArray({key: keys, index: index, value: emptyBytes});

        success =true;
        return success;
    }

    function _resetKeys(address account)
    internal
    returns (bool success) {
        _requireNotAddressZero({account: account});

        bytes32 keys =_account({account: account, string_: "keys"});
        storage_.deleteBytesArray({key: keys});

        success =true;
        return success;
    }

    function _verify(address account, address of_, string memory signature)
    internal 
    returns (bool success) {
        // does not revert just returns if true or false use external access verify for revert
        
        _requireNotAddressZero({account: account});
        _requireNotAddressZero({account: of_});

        // context
        bytes32 keys = _account({account: account, string_: "keys"});
        bytes[] memory bytesArray = storage_.getBytesArray({key: keys});
        for (uint i =0; i <bytesArray.length; i++) {

            bytes memory key =storage_.indexBytesArray({key: keys, index: i});
            (address of_2, string memory signature2, uint type_, uint startTimestamp, uint endTimestamp, uint balance) =_decodeKey({key: key});

            if (_isMatchingKeyContractAndSignature({contract1: of_, signature1: signature, contract2: of_2, signature2: signature2})) {

                if (type_ ==0) { success =true; }

                if (type_ ==1) {
                    _verifyTimedKey({startTimestamp: startTimestamp, endTimestamp: endTimestamp});
                    success =true;
                }
                
                if (type_ ==2) {
                   uint newBalance =_verifyConsumableKey({balance: balance});
                    
                    require(balance >=1, "Validator: balance is zero");
                
                    bytes memory key2 =_encodeKey({of_: of_2, signature: signature2, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: newBalance});
                    storage_.setIndexBytesArray({key: keys, index: i, value: key2});
                    success =true;
                }

                break;
            }
        }

        return success;
    }

    function _grantKeyToRole(string memory role, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    internal 
    returns (bool success) {
        _requireValidKeyInput({type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        _requireNotAddressZero({account: of_});

        // context
        bytes memory key =_encodeKey({of_: of_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        bytes32 keys =_role({role: role, string_: "keys"});
        
        _requireNoDuplicateKey({array: keys, key: key});
        success =_tryPushKeyToEmptyBytes({array: keys, key: key});

        // no empty bytes were found
        if (!success) {
            storage_.pushBytesArray({key: keys, value: key});
            success =true;
        }

        return success;
    }

    function _revokeKeyFromRole(string memory role, address of_, string memory signature)
    internal
    returns (bool success) {
        _requireNotAddressZero({account: of_});

        // context
        bytes32 keys =_role({role: role, string_: "keys"});
        (bool gotIndex, uint index) =_getKeyIndexByContractAndSignature({array: keys, of_: of_, signature: signature});
        _requireSuccess({success: gotIndex});

        bytes memory emptyBytes;
        storage_.setIndexBytesArray({key: keys, index: index, value: emptyBytes});

        success =true;
        return success;
    }

    function _resetRoleKeys(string memory role)
    internal
    returns (bool success) {
        storage_.deleteBytesArray({key: _role({role: role, string_: "keys"})});

        success =true;
        return success;
    }

    function _grantRole(address account, string memory role)
    internal
    returns (bool success) {
        
        // refresh account before assiging role
        _resetKeys({account: account});

        bytes[] memory bytesArray =storage_.getBytesArray({key: _role({role: role, string_: "keys"})});
        for (uint i =0; i <bytesArray.length; i++) {
            
            bytes memory key =bytesArray[i];
            (address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) = _decodeKey({key: key});
            _grantKey(account, of_, signature, type_, startTimestamp, endTimestamp, balance);
        }

        // add address as member of the role
        storage_.addAddressSet({key: _role({role: role, string_: "members"}), value: account});

        success =true;
        return success;
    }

    function _revokeRole(address account, string memory role)
    internal
    returns (bool success) {
        
        bytes[] memory bytesArray = storage_.getBytesArray({key: _role({role: role, string_: "keys"})});
        for (uint i =0; i <bytesArray.length; i++) {

            bytes memory key = bytesArray[i];
            (address of_, string memory signature, , , ,) = _decodeKey({key: key});
            _revokeKey({account: account, of_: of_, signature: signature});
        }

        // remove address as member of the role
        storage_.removeAddressSet({key: _role({role: role, string_: "members"}), value: account});

        success =true;
        return success;
    }
}