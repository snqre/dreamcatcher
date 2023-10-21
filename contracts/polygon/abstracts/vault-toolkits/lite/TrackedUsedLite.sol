// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract TrackedUsedLite is StorageLite {

    event TokenTracked(address indexed token);

    event TokenUntracked(address indexed token);

    function tracked(uint i) public view virtual returns (address) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____tracked()]) == keccak256(emptyBytes)) {
            return address(0);
        }
        address[] memory set = new address[](size());
        set = abi.decode(_bytes[____tracked()], (address[]));
        return set[i];
    }

    function size() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____size()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____size()], (uint));
    }

    function ____tracked() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("TRACKED"));
    }

    function ____size() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("SIZE"));
    }

    function _addTracked(address token) internal virtual {
        bool success;
        bytes memory emptyBytes;
        address[] memory set = new address[](size());
        if (keccak256(_bytes[____tracked()]) != keccak256(emptyBytes)) {
            set = abi.decode(_bytes[____tracked()], (address[]));
        }
        for (uint i = 0; i < size() + 1; i++) {
            if (set[i] == address(0)) {
                set[i] = token;
                success = true;
                break;
            }
        }
        require(success, "TrackedUsedLite: size limit exceeded");
        _bytes[____tracked()] = abi.encode(set);
        emit TokenTracked(token);
    }

    function _subTracked(address token) internal virtual {
        bool success;
        bool empty;
        bytes memory emptyBytes;
        address[] memory set = new address[](size());
        if (keccak256(_bytes[____tracked()]) != keccak256(emptyBytes)) {
            set = abi.decode(_bytes[____tracked()], (address[]));
        } else {
            empty = true;
        }
        require(!empty, "TrackedUsedLite: is empty");
        for (uint i = 0; i < size() + 1; i++) {
            if (set[i] == token) {
                set[i] = address(0);
                success = true;
                break;
            }
        }
        require(success, "TrackedUsedLite: token not found");
        _bytes[____tracked()] = abi.encode(set);
        emit TokenUntracked(token);
    }
}