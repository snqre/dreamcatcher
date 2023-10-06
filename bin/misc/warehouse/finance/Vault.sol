// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/Authenticator.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

interface IVault {
    /// vault-transfer
    function transfer(address target, address to, uint amount_)
    external
    returns (bool);

    /// vault-transfer-from
    function transferFrom(address target, address from, address to, uint amount_)
    external
    returns (bool);

    function deposit()
    external payable
    returns (bool);

    /// vault-withdraw
    function withdraw(address to, uint value)
    external
    returns (bool);

    event Transfer(address target, address from, address to, uint amount);
    event BudgetCreated(string reason, address[] indexed contracts, uint[] indexed amounts, uint indexed amount, address[] payees, uint startTimestamp, uint duration);

    error UnableToMakeTransfer(address target, address from, address to, uint amount);
    error InsufficientBalance(address target, address from, address to, uint amount);
}

contract Vault is IVault {
    using EnumerableSet for EnumerableSet.AddressSet;
    IAuthenticator public authenticator;

    /// accounting.
    mapping(address => uint) public amounts;
    uint public amount;

    constructor(address authenticator_) {
        authenticator = IAuthenticator(authenticator_);
    }

    /// ---------------
    /// BASIC UTILITIES.
    /// ---------------

    function transfer(address target, address to, uint amount_)
        public
        returns (bool) {
        /// check balance.
        if (IERC20(target).balanceOf(address(this)) < amount_) {
            revert InsufficientBalance(target, address(this), to, amount_);
        }

        authenticator.authenticate(msg.sender, "vault-transfer", true, true);
        bool success = IERC20(target).transfer(to, amount_);
        if (!success) { revert UnableToMakeTransfer(target, address(this), to, amount_); }
        
        /// update
        amounts[target] = IERC20(target).balanceOf(address(this));

        emit Transfer(target, address(this), to, amount_);
        return success;
    }

    function transferFrom(address target, address from, address to, uint amount_)
        public
        returns (bool) {
        /// check balance.
        if (IERC20(target).balanceOf(from) < amount_) {
            revert InsufficientBalance(target, from, to, amount_);
        }
        
        authenticator.authenticate(msg.sender, "vault-transfer-from", true, true);
        bool success = IERC20(target).transferFrom(from, to, amount_);
        if (!success) { revert UnableToMakeTransfer(target, from, to, amount_); }

        /// update
        amounts[target] = IERC20(target).balanceOf(address(this));

        emit Transfer(target, from, to, amount_);
        return success;
    }

    function deposit()
        external payable
        returns (bool) {
        amount += msg.value;
        return true;
    }

    function withdraw(address to, uint value)
        external
        returns (bool) {
        authenticator.authenticate(msg.sender, "vault-withdraw", true, true);
        amount -= value;
        address payable recipient = payable(to);
        recipient.transfer(value);
        return true;
    }
}

// TODO test contract
contract Sentinel is Ownable, Pausable, ReentrancyGuard {
    IEternalStorage eternalStorage;

    event Transfer(address indexed from, address indexed to, address logic, string signature, uint granted, uint expiration, bool transferable, bool clonable, uint class, uint balance, bytes data);

    constructor(address eternalStorage_)
    Ownable(msg.sender) {
        eternalStorage = IEternalStorage(eternalStorage_);
    }

    function decodeKey(bytes memory encodedKey)
    external pure
    returns (address, string memory, uint, uint, bool, bool, KeyClass, uint, bytes memory) {
        Key memory key = abi.decode(encodedKey, (Key));
        return (key.logic, key.signature, key.granted, key.expiration, key.transferable, key.clonable, key.class, key.balance, key.data);
    }

    function getKey(address account, uint index)
    external view
    returns (address, string memory, uint, uint, bool, bool, KeyClass, uint, bytes memory) {
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        bytes memory encodedKey = eternalStorage.indexBytesArray(varAccountKeys, index);
        Key memory key = abi.decode(encodedKey, (Key));
        return (key.logic, key.signature, key.granted, key.expiration, key.transferable, key.clonable, key.class, key.balance, key.data);
    }

    function getKeys(address account)
    external view
    returns (bytes[] memory) {
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        return eternalStorage.getBytesArray(varAccountKeys);
    }

    function mint(string memory signature)
    external 
    nonReentrant
    whenNotPaused {
        bytes memory emptyBytes;
        _mint(msg.sender, msg.sender, signature, 0, 0, true, true, KeyClass.SOURCE, 0, emptyBytes);
    }

    function burn(address logic, string memory signature)
    external 
    nonReentrant 
    whenNotPaused {
        _burn(msg.sender, logic, signature);
    }

    function transfer(address to, address logic, string memory signature)
    external
    nonReentrant
    whenNotPaused {
        _transfer(msg.sender, to, logic, signature);
    }

    function grant(address to, address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data)
    external 
    nonReentrant
    whenNotPaused {
        _grant(msg.sender, to, logic, signature, granted, expiration, transferable, clonable, class, balance, data);
    }

    function pause()
    external 
    onlyOwner {
        _pause();
    }

    function unpause()
    external 
    onlyOwner {
        _unpause();
    }

    function verify(address account, address logic, string memory signature)
    external {
        _verify(account, logic, signature);
    }

    function _getIndexEmptyBytes(address account)
    internal view
    returns (bool success, uint index) {
        bytes memory emptyBytes;
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        bytes[] memory encodedKeys = eternalStorage.getBytesArray(varAccountKeys);
        for (uint i = 0; i < encodedKeys.length; i++) {
            if (Match.isMatchingBytes(encodedKeys[i], emptyBytes)) {
                success = true;
                index = i;
                break;
            }
        }
        return (success, index);
    }

    function _getIndexLogSig(address account, address logic, string memory signature)
    internal view
    returns (bool success, uint index, Key memory key) {
        bytes memory emptyBytes;
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        bytes[] memory encodedKeys = eternalStorage.getBytesArray(varAccountKeys);
        for (uint i = 0; i < encodedKeys.length; i++) {
            key = abi.decode(encodedKeys[i], (Key));
            if (!Match.isMatchingBytes(encodedKeys[i], emptyBytes) && Match.isMatchingString(signature, key.signature) && logic == key.logic) {
                success = true;
                index = i;
                break;
            }
        }
        return (success, index, key);
    }

    function _pushKey(address account, Key memory key)
    internal {
        (bool success, uint index,) = _getIndexLogSig(account, key.logic, key.signature);
        require(!success, "Sentinel: cannot push because account already has a key with the given logic and signature");
        (success, index) = _getIndexEmptyBytes(account);
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        if (success) {
            eternalStorage.setIndexBytesArray(varAccountKeys, index, abi.encode(key));
        } else {
            eternalStorage.pushBytesArray(varAccountKeys, abi.encode(key));
        }
    }

    function _pullKey(address account, address logic, string memory signature)
    internal {
        (bool success, uint index,) = _getIndexLogSig(account, logic, signature);
        require(success, "Sentinel: cannot pull because account does not have a key with the given logic and signature");
        bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
        bytes memory emptyBytes;
        eternalStorage.setIndexBytesArray(varAccountKeys, index, emptyBytes);
    }

    function _mint(address account, address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data)
    internal {
        require(msg.sender != address(0), "Sentinel: cannot mint because caller is address zero");
        require(account != address(0), "Sentinel: cannot mint because account is address zero");
        require(logic != address(0), "Sentinel: cannot mint because logic is address zero");
        Key memory key = Key({logic: logic, signature: signature, granted: granted, expiration: expiration, transferable: transferable, clonable: clonable, class: class, balance: balance, data: data});
        _pushKey(account, key);
        emit Transfer(address(0), account, logic, signature, granted, expiration, transferable, clonable, uint(class), balance, data);
    }

    function _burn(address account, address logic, string memory signature)
    internal {
        require(msg.sender != address(0), "Sentinel: cannot mint because caller is address zero");
        require(account != address(0), "Sentinel: cannot mint because account is address zero");
        require(logic != address(0), "Sentinel: cannot mint because logic is address zero");
        _pullKey(account, logic, signature);
        (, , Key memory key) = _getIndexLogSig(account, logic, signature);
        emit Transfer(account, address(0), key.logic, key.signature, key.granted, key.expiration, key.transferable, key.clonable, uint(key.class), key.balance, key.data);
    }

    function _transfer(address from, address to, address logic, string memory signature)
    internal {
        require(from != address(0), "Sentinel: cannot transfer because sender is address zero");
        require(to != address(0), "Sentinel: cannot transfer because recipient is address zero");
        require(logic != address(0), "Sentinel: cannot transfer because logic is address zero");
        require(from != to, "Sentinel: cannot transfer because sender and recipient address is recursive");
        (, , Key memory key) = _getIndexLogSig(from, logic, signature);
        require(key.transferable, "Sentinel: cannot transfer because key is not transferable");
        _pullKey(from, key.logic, key.signature);
        _pushKey(to, key);
        if (key.clonable) {
            _pushKey(from, key);
        }
        emit Transfer(from, to, key.logic, key.signature, key.granted, key.expiration, key.transferable, key.clonable, uint(key.class), key.balance, key.data);
    }
    
    function _grant(address from, address to, address logic, string memory signature, uint granted, uint expiration, bool transferable, bool clonable, KeyClass class, uint balance, bytes memory data)
    internal {
        require(from != address(0), "Sentinel: cannot grant because sender is address zero");
        require(to != address(0), "Sentinel: cannot grant because recipient is address zero");
        require(logic != address(0), "Sentinel: cannot grant because logic is address zero");
        require(from != to, "Sentinel: cannot grant because sender and recipient address is recursive");
        (, , Key memory sourceKey) = _getIndexLogSig(from, logic, signature);
        require(sourceKey.class == KeyClass.SOURCE, "Sentinel: cannot grant because grantor does not have source");
        require(class != KeyClass.SOURCE, "Sentinel: cannot grant because granted version is a source **use transfer for source class");
        Key memory key = Key({logic: logic, signature: signature, granted: granted, expiration: expiration, transferable: transferable, clonable: clonable, class: class, balance: balance, data: data});
        _pushKey(to, key);
        emit Transfer(from, to, key.logic, key.signature, key.granted, key.expiration, key.transferable, key.clonable, uint(key.class), key.balance, key.data);
    }

    function _verify(address account, address logic, string memory signature)
    internal {
        (bool success, uint index, Key memory key) = _getIndexLogSig(account, logic, signature);
        require(success, "Sentinel: unauthorized because account does not have a key with the given logic and signature");
        if (key.class == KeyClass.CONSUMABLE) {
            require(key.balance >= 1, "Sentinel: unauthorized because consumable is depleted");
            key.balance--;
            bytes32 varAccountKeys = keccak256(abi.encode(account, "keys"));
            eternalStorage.setIndexBytesArray(varAccountKeys, index, abi.encode(key));
        } else if (key.class == KeyClass.TIMED) {
            require(block.timestamp >= key.granted, "Sentinel: unauthorized because timed has not been granted yet");
            require(block.timestamp < key.expiration, "Sentinel: unauthorized because key has expired");
        } else if (key.class != KeyClass.SOURCE && key.class != KeyClass.STANDARD && key.class != KeyClass.CONSUMABLE && key.class != Key.TIMED) {
            revert("Sentinel: cannot verify because class is unrecognized");
        }
    }
}