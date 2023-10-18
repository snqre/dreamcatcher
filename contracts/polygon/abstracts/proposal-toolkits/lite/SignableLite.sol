// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract SignableLite is StorageLite {

    event SignerAdded(address indexed account);

    event Signed(address indexed signer);

    /**
    * @dev Empty bytes would throw an error if decoded into boolean so
    *      if no value has been assigned to the storage location it should be
    *      interpreted as false. There's too many possible accounts to try to
    *      initialize them all.
     */
    function isSigner(address account) public view virtual returns (bool) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____isSigner(account)]) == keccak256(emptyBytes)) {
            return false;
        } else {
            return abi.decode(_bytes[____isSigner(account)], (bool));
        }
    }

    function hasSigned(address account) public view virtual returns (bool) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____hasSigned(account)]) == keccak256(emptyBytes)) {
            return false;
        } else {
            return abi.decode(_bytes[____hasSigned(account)], (bool));
        }
    }

    function signersCount() public view virtual returns (uint) {
        return abi.decode(_bytes[____signersCount()], (uint));
    }

    function signaturesCount() public view virtual returns (uint) {
        return abi.decode(_bytes[____signaturesCount()], (uint));
    }

    function ____isSigner(address account) internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("IS_SIGNER", account));
    }

    function ____hasSigned(address account) internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("HAS_SIGNED", account));
    }

    function ____signersCount() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("SIGNERS_COUNT"));
    }

    function ____signaturesCount() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("SIGNATURES_COUNT"));
    }

    function _initialize() internal virtual {
        _bytes[____signersCount()] = abi.encode(0);
        _bytes[____signaturesCount()] = abi.encode(0);
    }

    function _addSigner(address account) internal virtual {
        require(!isSigner(account), "SignableLite: cannot add signer again");
        _raiseCount(____signersCount());
        _bytes[____isSigner(account)] = abi.encode(true);
        emit SignerAdded(account);
    }

    function _sign() internal virtual {
        require(isSigner(msg.sender), "SignableLite: only signers can sign");
        require(!hasSigned(msg.sender), "SignableLite: cannot be signed again");
        _raiseCount(____signaturesCount());
        _bytes[____hasSigned(msg.sender)] = abi.encode(true);
        emit Signed(msg.sender);
    }

    function _raiseCount(bytes32 counter) internal virtual {
        uint count = abi.decode(_bytes[counter], (uint));
        count += 1;
        _bytes[counter] = abi.encode(count);
    }
}