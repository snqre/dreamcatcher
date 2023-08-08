// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";

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

    function isMatchingKeyContractAndSignature(address contractA, address contractB, string memory signatureA, string memory signatureB)
    external pure
    returns (bool isMatch) {
        return contractA ==contractB && Match.isMatchingString({stringA: signatureA, stringB: signatureB});
    }
}



library Utils {
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



library ValidatorToolkit {
    function getKeyIndexByContractAndSignature(address database, bytes32 array, address contract_, string memory signature)
    external view
    returns (bool success, uint index) {
        IStorage db =IStorage(database);
        bytes memory emptyBytes;
        bytes[] memory bytesArray =db.getBytesArray({key: array});
        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory key =bytesArray[i];
            //decode
            if (!Match.isMatchingBytes({bytesA: key, bytesB: emptyBytes})) {
                (address contract_B, string memory signatureB, , , ,) = Encoder.decodeKey({key: key});
                if (Match.isMatchingKeyContractAndSignature({contractA: contract_, contractB: contract_B, signatureA: signature, signatureB: signatureB})) {
                    index =i;
                    success =true;
                    break;
                }
            }
        }
        return (success, index);
    }

    function requireNoDuplicateKey(address database, bytes32 array, bytes memory key)
    external view {
        IStorage db =IStorage(database);
        (address contract_, string memory signature, , , ,) =Encoder.decodeKey({key: key});
        bytes memory emptyBytes;
        bytes[] memory bytesArray =db.getBytesArray({key: array});
        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory keyB =bytesArray[i];
            //decode
            if (!Match.isMatchingBytes({bytesA: keyB, bytesB: emptyBytes})) {
                (address contract_B, string memory signatureB, , , ,) = Encoder.decodeKey({key: key});
                require(Match.isMatchingKeyContractAndSignature({contractA: contract_, contractB: contract_B, signatureA: signature, signatureB: signatureB}), "ValidatorToolkit: matching contract and address");
            }
        }    
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
    function grantKey(address database, address account, address contract_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
    external
    returns (bool success) {
        ValidatorToolkit.requireInput({type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        require(database !=address(0), "Validator: database is address zero");
        require(account !=address(0), "Validator: account is address zero");
        require(contract_ !=address(0), "Validator: contract_ is address zero");
        IStorage db =IStorage(database);
        bytes memory key =Encoder.encodeKey({contract_: contract_, signature: signature, type_: type_, startTimestamp: startTimestamp, endTimestamp: endTimestamp, balance: balance});
        bytes32 keys =Encoder.account({account: account, property: "keys"});
        ValidatorToolkit.requireNoDuplicateKey({database: database, array: keys, key: key});
        // try to push key to empty bytes
        bytes memory emptyBytes;
        bytes[] memory bytesArray =db.getBytesArray({key: array});
        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory keyB =bytesArray[i];
            //decode
            if (Match.isMatchingBytes({bytesA: keyB, bytesB: emptyBytes})) {
                db.setIndexBytesArray({key: keys, index: i, value: key});
                success =true;
                break;
            }
        }
        if (!success) {
            db.pushBytesArray({key: keys, value: key});
            success =true;
        }
        Utils.requireSuccess({success: success});
        return success;
    }

    function revokeKey(address database, address account, address contract_, string memory signature)
    external
    returns (bool success) {

    }

    

    

    function _tryPushKeyToEmptyBytes(address db_, bytes32 array, bytes memory key)
    internal
    returns (bool success) {
        IStorage db =IStorage(db_);
        bytes memory emptyBytes;
        bytes[] memory bytesArray =db.getBytesArray({key: array});
        for (uint i =0; i <bytesArray.length; i++) {
            bytes memory keyB =bytesArray[i];
            //decode
            if (!Match.isMatchingBytes({bytesA: keyB, bytesB: emptyBytes})) {
                db.setIndexBytesArray({key: array, index: i, value: key});
                success =true;
                break;
            }
        }
        return success;
    }

}


contract Hub {
    bool internal _init;
    address internal _deployer;
    IStorage internal _db;

    constructor(address db) { db =_db; }



}