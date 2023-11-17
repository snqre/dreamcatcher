// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract TagLite is StorageLite {

    event NameUpdated(string indexed previousName, string indexed newName);

    event NoteUpdated(string indexed previousNote, string indexed newNote);

    event CreatorUpdated(address indexed previousCreator, address indexed newCreator);

    function name() public view virtual returns (string memory) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____name()]) == keccak256(emptyBytes)) {
            string memory emptyString;
            return emptyString;
        }
        return abi.decode(_bytes[____name()], (string));
    }

    function note() public view virtual returns (string memory) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____note()]) == keccak256(emptyBytes)) {
            string memory emptyString;
            return emptyString;
        }
        return abi.decode(_bytes[____note()], (string));
    }

    function creator() public view virtual returns (address) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____creator()]) == keccak256(emptyBytes)) {
            return address(0);
        }
        return abi.decode(_bytes[____creator()], (address));
    }

    function ____name() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("NAME"));
    }

    function ____note() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("NOTE"));
    }

    function ____creator() internal pure virtual returns (bytes32) {
        /** @dev Because the deployer may not be equal to the creator. */
        return keccak256(abi.encode("CREATOR"));
    }

    function _setName(string memory newName) internal virtual {
        string memory previousName = name();
        _bytes[____name()] = abi.encode(newName);
        emit NameUpdated(previousName, newName);
    }

    function _setNote(string memory newNote) internal virtual {
        string memory previousNote = note();
        _bytes[____note()] = abi.encode(newNote);
        emit NoteUpdated(previousNote, newNote);
    }

    function _setCreator(address newCreator) internal virtual {
        address previousCreator = creator();
        _bytes[____creator()] = abi.encode(newCreator);
        emit CreatorUpdated(previousCreator, newCreator);
    }
}