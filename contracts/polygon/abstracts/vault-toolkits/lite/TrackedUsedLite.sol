// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract TrackedUsedLite is StorageLite {

    event MaxTrackedTokensUpdated(uint indexed previousCount, uint indexed newCount);

    event TrackedTokenAdded(address indexed token);

    event TrackedTokenRemoved(address indexed token);

    function trackedToken(uint i) public view virtual returns (address) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____trackedToken(i)]) == keccak256(emptyBytes)) {
            return address(0);
        }
        return abi.decode(_bytes[____trackedToken(i)], (address));
    }

    function trackedTokenCount() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____trackedTokenCount()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____trackedTokenCount()], (uint));
    }

    function maxTrackedTokens() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____maxTrackedTokens()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____maxTrackedTokens()], (uint));
    }

    function ____trackedToken(uint i) internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("TRACKED_TOKEN", i));
    }

    function ____trackedTokenCount() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("TRACKED_TOKEN_COUNT"));
    }

    function ____maxTrackedTokens() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("MAX_TRACKED_TOKENS"));
    }

    function _mustNotBeAboveMaxTrackedTokens() internal view virtual {
        require(trackedTokenCount() <= maxTrackedTokens(), "TrackedUsedLite: is above limit");
    }

    function _initialize() internal virtual {
        _setMaxTrackedTokens(50);
    }

    function _addTrackedToken(address token) internal virtual {
        require(_index(token) > maxTrackedTokens(), "TrackedUsedLite: duplicate entry");
        uint i = _raiseTrackedTokenCount();
        _bytes[____trackedToken(i - 1)] = abi.encode(token);
        _mustNotBeAboveMaxTrackedTokens();
        emit TrackedTokenAdded(token);
    }

    function _subTrackedToken(address token) internal virtual {
        require(_index(token) <= maxTrackedTokens(), "TrackedUsedLite: empty entry");
        _bytes[____trackedToken(_index(token))] = abi.encode(address(0));
        _refresh();
        emit TrackedTokenRemoved(token);
    }

    function _raiseTrackedTokenCount() internal virtual returns (uint) {
        uint count = trackedTokenCount();
        count += 1;
        _bytes[____trackedTokenCount()] = abi.encode(count);
        return count;
    }

    function _setMaxTrackedTokens(uint newCount) internal virtual {
        uint previousCount = maxTrackedTokens();
        _bytes[____maxTrackedTokens()] = abi.encode(newCount);
        emit MaxTrackedTokensUpdated(previousCount, newCount);
    }

    function _index(address token) private view returns (uint) {
        for (uint i = 0; i < trackedTokenCount(); i++) {
            if (trackedToken(i) == token) {
                return i;
            }
        }
        return 9000000000000000;
    }

    function _refresh() private {
        address[] memory set;
        set = new address[](trackedTokenCount());
        uint count;
        for (uint i = 0; i < trackedTokenCount(); i++) {
            if (trackedToken(i) != address(0)) {
                set[count] = trackedToken(i);
                _bytes[____trackedToken(i)] = abi.encode(address(0));
            }
        }
        for (uint i = 0; i < set.length; i++) {
            _bytes[____trackedToken(i)] = abi.encode(set[i]);
        }
    }
}