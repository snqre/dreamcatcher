// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state/ProxyStateV1.sol";

/**
 * @dev Abstract contract ProxyStateV2 extends ProxyStateV1 and adds implementation-related functions.
 */
abstract contract ProxyStateV2 is ProxyStateV1 {
    
    /**
    * @dev Public view function to retrieve the default implementation address.
    * @return address representing the default implementation address.
    */
    function defaultImplementation() public view virtual returns (address) {
        /** ... @dev Write default implementation here. ... */
        return address(0);
    }

    /**
    * @dev Internal view function to retrieve the current implementation address.
    * @return address representing the current implementation address.
    * @dev This function checks if the contract is initialized and returns the default implementation if not.
    * @dev If initialized, it calls the parent implementation to get the current implementation address.
    */
    function _implementation() internal view virtual override returns (address) {
        if (!_bool[keccak256(abi.encode("INITIALIZED"))]) {
            return defaultImplementation();
        }
        else {
            return super._implementation();
        }
    }
}