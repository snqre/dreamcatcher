// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/StorageLite.sol";

abstract contract InitializableLite is StorageLite {

    function ____initialized() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("INITIALIZED"));
    }

    function initialized() public view virtual returns (bool) {
        return abi.decode(_bytes[____initialized()], (bool));
    }

    function _mustNotBeInitialized() internal view virtual {
        require(!initialized(), "InitializableLite: initialized()");
    }

    function _initialize() internal virtual {
        _mustNotBeInitialized();
        _bytes[____initialized()] = abi.encode(true);
    }
}