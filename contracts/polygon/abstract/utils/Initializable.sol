// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";

abstract contract Initializable is Storage {

    /**
    * @dev Returns the key for checking if the contract has been initialized.
    */
    function initializedKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("INITIALIZED"));
    }

    /**
    * @dev Checks if the contract has been initialized.
    */
    function initialized() public view virtual returns (bool) {
        return _bool[initializedKey()];
    }

    /**
    * @dev Internal function to set the initialized state.
    */
    function _initialize() internal virtual {
        require(!initialized(), "Initializable: initialized()");
        _bool[initializedKey()] = true;
    }
}