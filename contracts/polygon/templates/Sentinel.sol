// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";
import "contracts/polygon/templates/modular-upgradeable/hubv1-eternal-storage/Dreamcatcher.sol";

enum Class {
    SOURCE,
    STANDARD,
    CONSUMABLE,
    TIMED
}

struct Timestamp {
    uint granted;
    uint expiration;
}

struct Settings {
    bool transferable;
    bool clonable;
}

struct Key {
    address logic;
    string signature;
    Timestamp timestamp;
    Class class;
    Settings settings;
    uint balance;
    bytes data;
}

library SentinelToolkit {
    function verifyKeyInput(Key memory key)
    external view {
        bool success;
        require(key.logic != address(0), "SentinelToolkit: Invalid key input");
        bytes memory emptyBytes;

        if (key.class == Class.SOURCE) {
            require(
                key.timestamp.granted == 0 
                && key.timestamp.expiration == 0
                && key.balance == 0
                && key.settings.transferable
                && key.settings.clonable
                && key.data == emptyBytes,
                "SentinelToolkit: Invalid key input"
            );

            success = true;
        }

        else if (key.class == Class.STANDARD) {
            require(
                key.timestamp.granted == 0
                && key.timestamp.expiration == 0
                && key.balance == 0,
                "SentinelToolkit: Invalid key input"
            );

            success = true;
        }

        else if (key.class == Class.TIMED) {
            require(
                block.timestamp >= key.timestamp.granted
                && key.timestamp.granted < key.timestamp.expiration
                && key.balance == 0,
                "SentinelToolkit: Invalid key input"
            );

            success = true;
        }

        else if (key.class == Class.CONSUMABLE) {
            require(
                key.timestamp.granted == 0
                && key.timestamp.expiration == 0
                && key.balance >= 1,
                "SentinelToolkit: Invalid key input"
            );

            success = true;
        }

        else {
            revert("SentinelToolkit: Invalid key input");
            success = false;
        }

        require(success, "SentinelToolkit: Invalid key input");
    }
    

    function getIndexLogSigBytesArray(IRepository repository, bytes32 variable, address logic, string memory signature) 
    external view
    returns (bool success, uint index, Key memory key) {
        bytes memory emptyBytes;
        bytes[] memory encodedKeys = repository.getBytesArray(variable);

        for (uint i = 0; i < keys.length; i++) {

            if (keccak256(keys[i]) != keccak256(emptyBytes)) {
                key = abi.decode(keys[i], (Key));

                if (logic == key.logic && keccak256(abi.encode(signature)) == keccak256(abi.encode(key.signature))) {
                    index = i;
                    success = true;
                    break;
                }
            }
        }

        return (success, index, key);
    }

    function getIndexEmptyBytesBytesArray(IRepository repository, bytes32 variable) 
    external view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes[] memory keys = repository.getBytesArray(variable);

        for (uint i = 0; i < keys.length; i++) {

            if (keccak256(keys[i]) == keccak256(emptyBytes)) {

                success = true;
                index = i;
                break;
            }
        }

        return (success, index);
    }

    function verify(IRepository repository, address account, uint index, Key memory key)
    external 
    returns (bool success) {

        if (key.class == Class.SOURCE) {
            // ... TODO: Source requirements

        }

        else if (key.class == Class.STANDARD) {
            success = true;
        }

        else if (key.class == Class.TIMED) {
            require(
                block.timestamp >= key.timestamp.granted
                && block.timestamp < key.timestamp.expiration,
                "SentinelToolkit: Failed verification"
            );

            success = true;
        }

        else if (key.class == Class.CONSUMABLE) {
            require(key.balance >= 1, "SentinelToolkit: Insufficient balance");
            key.balance -= 1;
            repository.setIndexBytesArray(keccak256(abi.encode(account, "keys")), index, abi.encode(key));
            success = true;
        }

        else {
            revert("SentinelToolkit: Unable to verify");
        }
    }

}


contract Sentinel {
    IRepository private _repository;
    address private _deployer;
    bool private _initialized;

    modifier onlyWhenInitialized() {
        _mustBeInitialized();
        _;
    }

    constructor(address repository) {
        repo = IRepository(repository);
        _deployer = msg.sender;
        _initialized = false;
    }

    function getKeys(address account) 
    external view
    onlyWhenInitialized
    returns (bytes[] memory) {
        return _repository.getBytesArray(keccak256(abi.encode(account, "keys")));
    }

    function getRoleKeys(string memory role) 
    external view
    onlyWhenInitialized
    returns (bytes[] memory) {
        return _repository.getBytesArray(keccak256(abi.encode(role, "keys")));
    }

    function getRoleMembers(string memory role) 
    external view
    onlyWhenInitialized
    returns (address[] memory) {
        return _repository.getAddressSet(keccak256(abi.encode(role, "keys")));
    }

    function getRoleSize(string memory role) 
    external view
    onlyWhenInitialized
    returns (uint) {
        return _repository.lengthAddressSet(keccak256(abi.encode(role, "keys")));
    }

    function _mustBeInitialized() 
    internal view {
        require(
            _initialized, 
            "Sentinel: Sentinel has not been initialized"
        );
    }

    function _mustNotBeInitialized() 
    internal view {
        require(
            !_initialized, 
            "Sentinel: Sentinel has been initialized"
        );
    }

    function _verifyKeyInput(Key memory key)
    external view {

        // require logic is not address zero
        require(
            key.logic != address(0),
            "Sentinel: key.logic is address zero"
        );
        
        // for standard keys
        if (key.class == Class.STANDARD) {
            require(
                key.timestamp.granted == 0,
                "Sentinel: key.timestamp.granted != 0"
            );
            
            require(
                key.timestamp.expiration == 0,
                "Sentinel: key.timestamp.expiration != 0"
            );

            require(
                key.balance == 0,
                "Sentinel: key.balance != 0"
            );
        }

        else if (key.class == Class.TIMED) {
            require(
                block.timestamp <= key.timestamp.granted,
                "Sentinel: block.timestamp > key.timestamp.granted"
            );

            require(
                key.timestamp.expiration > key.timestamp.granted,
                "Sentinel: key.timestamp.expiration <= key.timestamp.granted"
            );


        }
    }

}