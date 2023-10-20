// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract ExecutableLite is StorageLite {
    
    event Approved();

    event Executed();

    function approved() public view virtual returns (bool) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____approved()]) == keccak256(emptyBytes)) {
            return false;
        }
        return abi.decode(_bytes[____approved()], (bool));
    }

    function executed() public view virtual returns (bool) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____executed()]) == keccak256(emptyBytes)) {
            return false;
        }
        return abi.decode(_bytes[____executed()], (bool));
    }

    function ____approved() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("APPROVED"));
    }

    function ____executed() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("EXECUTED"));
    }

    function _mustBeApproved() internal view virtual {
        require(approved(), "ExecutableLite: must be approved");
    }

    function _mustNotBeApproved() internal view virtual {
        require(!approved(), "ExecutableLite: must not be approved");
    }

    function _mustBeExecuted() internal view virtual {
        require(executed(), "ExecutableLite: must be executed");
    }

    function _mustNotBeExecuted() internal view virtual {
        require(!executed(), "ExecutableLite: must not be executed");
    }

    function _approve() internal virtual {
        _mustNotBeApproved();
        _bytes[____approved()] = abi.encode(true);
        emit Approved();
    }

    function _execute() internal virtual {
        _mustBeApproved();
        _mustNotBeExecuted();
        _bytes[____executed()] = abi.encode(true);
        emit Executed();
    }
}