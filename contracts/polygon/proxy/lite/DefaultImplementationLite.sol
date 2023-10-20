// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";
import "contracts/polygon/abstracts/utils/lite/InitializableLite.sol";

/**
* Reserved functions that wont make it to implementation but will be called at
* the proxy level are implementation(), and configure(). These functions will
* not trigger the fallback on proxy and therefore should not be used.
* The configuration logic is removed as it should only be needed in the proxy
* but the key is rewritten here to make sure it comes up and @dev knows that it
* is reserved. Implementation key is also reserved to refer to implementation
* and both can be used to modify the respective storage slots if required.
* When using this as base for other implementations remember to create an upgrade
* public function and lock it behind access control. If this is not intended to be
* an upgradeable implementation then simply do not create an upgrade function or
* override the _upgrade() function to revert.
*
* Keys include ____implementation, ____configured, ____initialized.
 */
contract DefaultImplementationLite is StorageLite, InitializableLite {
    
    event Upgraded(address indexed previousImplementation, address indexed newImplementation);

    /** Key used by proxy storage */
    function ____implementation() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("IMPLEMENTATION"));
    }

    /** Key used by proxy storage */
    function ____configured() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("CONFIGURED"));
    }

    /** Upgrade function */
    function _upgrade(address newImplementation) internal virtual {
        address previousImplementation = abi.decode(_bytes[____implementation()], (address));
        _bytes[____implementation()] = abi.encode(newImplementation);
        emit Upgraded(previousImplementation, newImplementation);
    }
}