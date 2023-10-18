// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract ExecutableLite is StorageLite {
    
    event Approved();

    event Executed();

    function approved() public view virtual returns (bool) {
        return abi.decode(_bytes[____approved()], (bool));
    }

    function executed() public view virtual returns (bool) {
        return abi.decode(_bytes[____executed()], (bool));
    }

    function ____approved() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("APPROVED"));
    }

    function ____executed() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("EXECUTED"));
    }

    function _initialize() internal virtual {
        _bytes[____approved()] = abi.encode(false);
        _bytes[____executed()] = abi.encode(false);
    }

    function _approve() internal virtual {
        _bytes[____approved()] = abi.encode(true);
        emit Approved();
    }

    function _execute() internal virtual {
        _bytes[____executed()] = abi.encode(true);
        emit Executed();
    }
}