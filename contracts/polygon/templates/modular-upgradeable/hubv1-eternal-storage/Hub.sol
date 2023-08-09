// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

contract Database is Storage {}

/**

    #purpose
    1) manage roles
    2) manage access to individual functions
    3) act as a universal access to bypass validation
    4) timelock

 */

library Match {
    function isMatchingBytes(bytes memory bytesA, bytes memory bytesB)
    external pure
    returns (bool isMatch) {
        return keccak256(bytesA) ==keccak256(bytesB);
    }

    function isMatchingString(string memory stringA, string memory stringB)
    external pure
    returns (bool isMatch) {
        return keccak256(abi.encodePacked(stringA)) ==keccak256(abi.encodePacked(stringB));
    }
}



library Utils {
    function convertToWei(uint value)
    external pure
    returns (uint) {
        return value * (10**18);
    }

    function requireSuccess(bool success)
    external pure {
        require(success, "Utils: !success");
    }
}



library Encoder {
    function encodeKey(address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external pure
    returns (bytes memory key) {
        return abi.encode(contract_, signature, type_, startTimestamp, endTimestamp, balance);
    }

    function decodeKey(bytes memory key)
    external pure
    returns (address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) {
        return abi.decode(key, (address,string,uint,uint,uint,uint));
    }

    function account(address account, string memory property)
    external pure
    returns (bytes32 variable) {
        return keccak256(abi.encode(account, property));
    }

    function role(string memory role, string memory property)
    external pure
    returns (bytes32 variable) {
        return keccak256(abi.encode(role, property));
    }
}



library ValidatorMatch {
    function isMatchingKeyContractAndSignature(address contractA, address contractB, string memory signatureA, string memory signatureB)
    external pure
    returns (bool isMatch) {
        bool sameContract =contractA ==contractB;
        bool sameString =Match.isMatchingString({stringA: signatureA, stringB: signatureB});
        return sameContract && sameString;
    }
}



library ValidatorToolkit {
    function getKeyIndexByContractAndSignature(IStorage db, bytes32 array, address contract_, string memory signature)
    external view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes[] memory bytesArray =db.getBytesArray({key: array});
        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory key =bytesArray[i];
            if (!Match.isMatchingBytes({bytesA: key, bytesB: emptyBytes})) {
                (address contract_B, string memory signatureB, , , ,) = Encoder.decodeKey({key: key});
                if (ValidatorMatch.isMatchingKeyContractAndSignature({contractA: contract_, contractB: contract_B, signatureA: signature, signatureB: signatureB})) {
                    index =i;
                    success =true;
                    break;
                }
            }
        }
        return (success, index);
    }

    function getKeyIndexByEmptyBytes(IStorage db, bytes32 array)
    external view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes[] memory bytesArray =db.getBytesArray({key: array});
        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory key =bytesArray[i];
            if (Match.isMatchingBytes({bytesA: key, bytesB: emptyBytes})) {
                success =true;
                index =i;
                break;
            }
        }
        return (success, index);
    }

    function requireInput(uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external view {
        if (type_ ==0) {
            require(startTimestamp ==0, "ValidatorToolkit: startTimestamp must be zero");
            require(endTimestamp ==0, "ValidatorToolkit: endTimestamp must be zero");
            require(balance ==0, "ValidatorToolkit: balance must be zero");
        } else if (type_ ==1) {
            require(block.timestamp <=startTimestamp, "ValidatorToolkit: cannot grant in the past");
            require(endTimestamp >=startTimestamp, "ValidatorToolkit: cannot expire before granted");
            require(balance ==0, "Validator: balance must be zero");
        } else if (type_ ==2) {
            require(startTimestamp ==0, "ValidatorToolkit: startTimestamp must be zero");
            require(endTimestamp ==0, "ValidatorToolkit: endTimestamp must be zero");
            require(balance >= 1, "ValidatorToolkit: balance is less than one");
        }
    }
}



library Validator {
    function getKeys(IStorage db, address account)
    external view
    returns (bytes[] memory) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 keys =Encoder.account({account: account, property: "keys"});
        return db.getBytesArray({key: keys});
    }

    function getRoleKeys(IStorage db, string memory role)
    external view
    returns (bytes[] memory) {
        bytes32 keys =Encoder.role({role: role, property: "keys"});
        return db.getBytesArray({key: keys});
    }

    function getRoleMembers(IStorage db, string memory role)
    external view
    returns (address[] memory) {
        bytes32 members =Encoder.role({role: role, property: "members"});
        return db.valuesAddressSet({key: members});
    }

    function getRoleSize(IStorage db, string memory role)
    external view
    returns (uint) {
        bytes32 members =Encoder.role({role: role, property: "members"});
        return db.lengthAddressSet({key: members});
    }

    function grantKey(IStorage db, address account, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external
    returns (bool success, uint index) {
        ValidatorToolkit.requireInput({type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        require(account !=address(0), "Validator: account is address zero");
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes memory key =Encoder.encodeKey({contract_: contract_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        bytes32 keys =Encoder.account({account: account, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({db: db, array: keys, contract_: contract_, signature: signature});
        require(!success, "Validator: matching contract and address");
        (success, index) =ValidatorToolkit.getKeyIndexByEmptyBytes({db: db, array: keys});
        if (success) { db.setIndexBytesArray({key: keys, index: index, value: key}); }
        else {
            db.pushBytesArray({key: keys, value: key});
            index =db.lengthBytesArray({key: keys}) -1;
            success =true;
        }
        Utils.requireSuccess({success: success});
        return (success, index);
    }

    function revokeKey(IStorage db, address account, address contract_, string memory signature)
    external
    returns (bool success, uint index) {
        require(account !=address(0), "Validator: account is address zero");
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes32 keys =Encoder.account({account: account, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({db: db, array: keys, contract_: contract_, signature: signature});
        require(success, "Validator: unable to find matching contract and address");
        bytes memory emptyBytes;
        db.setIndexBytesArray({key: keys, index: index, value: emptyBytes});
        success =true;
        return (success, index);
    }

    function resetKeys(IStorage db, address account)
    external
    returns (bool success) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 keys =Encoder.account({account: account, property: "keys"});
        db.deleteBytesArray({key: keys});
        success =true;
        return success;
    }

    function verify(IStorage db, address account, address contract_, string memory signature)
    external
    returns (bool success, uint index) {
        require(account !=address(0), "Validator: account is address zero");
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes32 keys =Encoder.account({account: account, property: "keys"});
        bytes[] memory bytesArray =db.getBytesArray({key: keys});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({db: db, array: keys, contract_: contract_, signature: signature});
        require(success, "Validator: unable to find matching contract and address");
        bytes memory key =db.indexBytesArray({key: keys, index: index});
        (address contract_B, string memory signatureB, uint type_, uint startTimestamp, uint endTimestamp, uint balance) =Encoder.decodeKey({key: key});
        if (type_ ==0) { success =true; }
        else if (type_ ==1) {
            require(block.timestamp >=startTimestamp, "Validator: cannot use key before granted");
            require(block.timestamp <=endTimestamp, "Validator: expired");
            success =true;
        }
        else if (type_ ==2) {
            require(balance >=1, "Validator: insufficient balance");
            balance--;
            bytes memory keyB =Encoder.encodeKey({contract_: contract_B, signature: signatureB, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
            db.setIndexBytesArray({key: keys, index: index, value: keyB});
            success =true;
        }
        Utils.requireSuccess({success: success});
        return (success, index);
    }

    function grantKeyToRole(IStorage db, string memory role, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external
    returns (bool success, uint index) {
        ValidatorToolkit.requireInput({type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes memory key =Encoder.encodeKey({contract_: contract_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        bytes32 keys =Encoder.role({role: role, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({db: db, array: keys, contract_: contract_, signature: signature});
        require(!success, "Validator: matching contract and address");
        (success, index) =ValidatorToolkit.getKeyIndexByEmptyBytes({db: db, array: keys});
        if (success) { db.setIndexBytesArray({key: keys, index: index, value: key}); }
        else {
            db.pushBytesArray({key: keys, value: key});
            index =db.lengthBytesArray({key: keys}) -1;
            success =true;
        }
        Utils.requireSuccess({success: success});
        return (success, index);
    }

    function revokeKeyFromRole(IStorage db, string memory role, address contract_, string memory signature)
    external
    returns (bool success, uint index) {
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        bytes32 keys =Encoder.role({role: role, property: "keys"});
        (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({db: db, array: keys, contract_: contract_, signature: signature});
        require(success, "Validator: unable to find matching contract and address");
        bytes memory emptyBytes;
        db.setIndexBytesArray({key: keys, index: index, value: emptyBytes});
        success =true;
        return (success, index);
    }

    function resetRoleKeys(IStorage db, string memory role)
    external
    returns (bool success) {
        bytes32 keys =Encoder.role({role: role, property: "keys"});
        db.deleteBytesArray({key: keys});
        success =true;
        return success;
    }

    function grantRole(IStorage db, address account, string memory role)
    external
    returns (bool success) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 keysA =Encoder.role({role: role, property: "keys"});
        bytes32 keysB =Encoder.account({account: account, property: "keys"});
        db.deleteBytesArray({key: keysB});
        bytes[] memory roleKeysArray =db.getBytesArray({key: keysA});
        for (uint i =0; i <roleKeysArray.length; i++) {
            success =false;
            (address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) =Encoder.decodeKey({key: roleKeysArray[i]});
            ValidatorToolkit.requireInput(type_, startTimestamp, endTimestamp, balance);
            db.pushBytesArray({key: keysB, value: roleKeysArray[i]});
        }
        bytes32 members =Encoder.role({role: role, property: "members"});
        db.addAddressSet({key: members, value: account});
        success =true;
        return success;
    }

    function revokeRole(IStorage db, address account, string memory role)
    external
    returns (bool success, uint index) {
        require(account !=address(0), "Validator: account is address zero");
        bytes32 keys =Encoder.role({role: role, property: "keys"});
        bytes32 keysB =Encoder.account({account: account, property: "keys"});
        bytes[] memory roleKeysArray =db.getBytesArray({key: keys});
        bytes memory emptyBytes;
        for (uint i =0; i <roleKeysArray.length; i++) {
            (address contract_, string memory signature, , , ,) =Encoder.decodeKey({key: roleKeysArray[i]});
            success =false;
            index =0;
            (success, index) =ValidatorToolkit.getKeyIndexByContractAndSignature({db: db, array: keys, contract_: contract_, signature: signature});
            if (success) { db.setIndexBytesArray({key: keysB, index: index, value: emptyBytes}); }
        }
        success =true;
        return (success, index);
    }
}



interface ISentinel {
    function init() external;
    function getKeys(address account) external view returns (bytes[] memory);
    function getRoleKeys(string memory role) external view returns (bytes[] memory);
    function getRoleMembers(string memory role) external view returns (address[] memory);
    function getRoleSize(string memory role) external view returns (uint);
    function verify(address account, address contract_, string memory signature) external;
    function grantKey(address account, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) external;
    function revokeKey(address account, address contract_, string memory signature) external;
    function resetKeys(address account) external;
    function grantKeyToRole(string memory role, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance) external;
    function revokeKeyFromRole(string memory role, address contract_, string memory signature) external;
    function resetRoleKeys(string memory role) external;
    function grantRole(address account, string memory role) external;
    function revokeRole(address account, string memory role) external;
}



contract Sentinel is Pausable, ReentrancyGuard {
    bool internal _init;
    address internal _deployer;
    IStorage db;

    modifier verify_(string memory signature) {
        Validator.verify({db: db, account: msg.sender, contract_: address(this), signature: signature});
        _;
    }

    constructor(address database) {
        _deployer =msg.sender;
        db =IStorage(database);
    }

    function init()
    external {
        require(msg.sender ==_deployer, "Terminal: only _deployer can call");
        require(!_init, "Sentienl: _init");
        bool isImplementation;
        address[] memory implementations =db.getImplementations();
        for (uint i =0; i <implementations.length; i++) {
            if (msg.sender ==implementations[i]) { isImplementation =true; }
        }
        require(isImplementation, "Sentinel: cannot init without setting as implementation first");
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "grantKey(address,address,string,uint256,uint256,uint256,uint256)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "revokeKey(address,address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "resetKeys(address)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "grantKeyToRole(string,address,string,uint256,uint256,uint256,uint256)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "revokeKeyFromRole(string,address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "resetRoleKeys(string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "grantRole(address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantKeyToRole({db: db, role: "validator", contract_: address(this), signature: "revokeRole(address,string)", type_: 0, startTimestamp: 0, endTimestamp: 0, balance: 0});
        Validator.grantRole({db: db, account: msg.sender, role: "validator"});
        _init =true;
    }

    function getKeys(address account)
    external view
    returns (bytes[] memory) {
        return Validator.getKeys({db: db, account: account});
    }

    function getRoleKeys(string memory role)
    external view
    returns (bytes[] memory) {
        return Validator.getRoleKeys({db: db, role: role});
    }

    function getRoleMembers(string memory role)
    external view
    returns (address[] memory) {
        return Validator.getRoleMembers({db: db, role: role});
    }

    function getRoleSize(string memory role)
    external view
    returns (uint) {
        return Validator.getRoleSize({db: db, role: role});
    }

    function verify(address account, address contract_, string memory signature)
    external 
    nonReentrant {
        Validator.verify({db: db, account: account, contract_: contract_, signature: signature});
    }

    function grantKey(address account, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("grantKey(address,address,string,uint256,uint256,uint256,uint256)") {
        Validator.grantKey({db: db, account: account, contract_: contract_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
    }

    function revokeKey(address account, address contract_, string memory signature)
    external
    nonReentrant
    whenNotPaused 
    verify_("revokeKey(address,address,string)") {
        Validator.revokeKey({db: db, account: account, contract_: contract_, signature: signature});
    }

    function resetKeys(address account)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("resetKeys(address)") {
        Validator.resetKeys({db: db, account: account});
    }

    function grantKeyToRole(string memory role, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external 
    nonReentrant
    whenNotPaused
    verify_("grantKeyToRole(string,address,string,uint256,uint256,uint256,uint256)") {
        Validator.grantKeyToRole({db: db, role: role, contract_: contract_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
    }

    function revokeKeyFromRole(string memory role, address contract_, string memory signature)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("revokeKeyFromRole(string,address,string)") {
        Validator.revokeKeyFromRole({db: db, role: role, contract_: contract_, signature: signature});
    }

    function resetRoleKeys(string memory role)
    external 
    nonReentrant
    whenNotPaused
    verify_("resetRoleKeys(string)") {
        Validator.resetRoleKeys({db: db, role: role});
    }

    function grantRole(address account, string memory role)
    external 
    nonReentrant 
    whenNotPaused 
    verify_("grantRole(address,string)") {
        Validator.grantRole({db: db, account: account, role: role});
    }

    function revokeRole(address account, string memory role)
    external 
    nonReentrant
    whenNotPaused
    verify_("revokeRole(address,string)") {
        Validator.revokeRole({db: db, account: account, role: role});
    }
}



library Timelock {

}



contract Key {

}



interface IDreamToken {
    function maxSupply() external view returns (uint);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function getCurrentSnapshotId() external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function snapshot() external returns (uint);
    function burn(uint amount) external;
    function burnFrom(address account, uint amount) external;
}



contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    uint public cap;
    IStorage db;
    ISentinel sn;

    modifier verify(string memory signature) {
        sn.verify({account: msg.sender, contract_: address(this), signature: signature});
        _;
    }

    constructor(address database, address sentinel)
    ERC20("DreamToken", "DREAM")
    ERC20Permit("DreamToken") {
        cap =Utils.convertToWei({value: 200000000});
        _mint({account: msg.sender, amount: cap});
        db =IStorage(database);
        sn =ISentinel(sentinel);
    }

    function maxSupply()
    external view
    returns (uint) {
        return cap;
    }

    function getCurrentSnapshotId()
    external view
    returns (uint) {
        return _getCurrentSnapshotId();
    }

    function allowance(address owner, address spender) 
    public view override 
    returns (uint) {
        return super.allowance({owner: owner, spender: spender});
    }

    function snapshot()
    external
    verify("snapshot()")
    returns (uint) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function _beforeTokenTransfer(address from, address to, uint amount)
    internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer({from: from, to: to, amount: amount});
    }

    function _afterTokenTransfer(address from, address to, uint amount)
    internal override {
        bytes32 balanceA =Encoder.account({account: to, property: "dreamTokenBalance"});
        bytes32 balanceB =Encoder.account({account: from, property: "dreamTokenBalance"});
        uint balanceFrom =db.getUint({key: Encoder.account({account: from, property: "dreamTokenBalance"})});
        uint balanceTo =db.getUint({key: Encoder.account({account: to, property: "dreamTokenBalance"})});
        if (from !=address(0)) { balanceFrom -=amount; }
        if (to !=address(0)) { balanceTo +=amount; }
        super._afterTokenTransfer({from: from, to: to, amount: amount});
    }

    function _mint(address account, uint amount)
    internal override {
        super._mint({account: account, amount: amount});
    }

    function _burn(address account, uint amount)
    internal override {
        cap -= amount;
        super._burn({account: account, amount: amount});
    }
}



interface IEmberToken {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function getCurrentSnapshotId() external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function mint(address to, uint amount) external;
    function snapshot() external returns (uint);
    function burn(uint amount) external;
    function burnFrom(address account, uint amount) external;
}



contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    IStorage db;
    ISentinel sn;

    constructor(address database, address sentinel)
    ERC20("EmberToken", "EMBER")
    ERC20Permit("EmberToken") {
        db =IStorage(database);
        sn =ISentinel(sentinel);
    }

    function getCurrentSnapshotId()
    external view
    returns (uint) {
        return _getCurrentSnapshotId();
    }

    function mint(address account, uint amount)
    external
    onlyOwner {
        _mint({account: account, amount: amount});
    }

    function snapshot()
    external
    onlyOwner
    returns (uint) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function _beforeTokenTransfer(address from, address to, uint amount)
    internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer({from: from, to: to, amount: amount});
    }

    function _afterTokenTransfer(address from, address to, uint amount)
    internal override {
        super._afterTokenTransfer({from: from, to: to, amount: amount});
    }

    function _transfer(address from, address to, uint amount)
    internal override {
        revert("EmberToken: transfer disabled by design");
    }

    function _mint(address account, uint amount)
    internal override {
        super._mint({account: account, amount: amount});
    }

    function _burn(address account, uint amount)
    internal override {
        super._burn({account: account, amount: amount});
    }
}