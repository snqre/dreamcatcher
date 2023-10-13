// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @dev Library `ProxyPayloadV1` containing functions to work with a `ProxyPayload` struct in a proxy contract.
 */
library ProxyPayloadV1 {

    /**
    * @dev Struct `ProxyPayload` representing a payload for proxy contract with an `_implementation` address.
    */
    struct ProxyPayload {
        address _implementation;
        
    }

    /**
    * @dev Public pure function to get the implementation address from a `ProxyPayload`.
    * @param self The `ProxyPayload` struct.
    * @return address representing the implementation address.
    */
    function implementation(ProxyPayload memory self) public pure returns (address) {
        return self._implementation;
    }

    /**
    * @dev Public function to set the implementation address in a `ProxyPayload`.
    * @param self The storage reference to the `ProxyPayload` struct.
    * @param implementation The new implementation address to set.
    */
    function upgrade(ProxyPayload storage self, address implementation) public {
        self._implementation = implementation;
    }

    /**
    * @dev Internal function to delegate the call to the implementation address in a `ProxyPayload`.
    * @param self The storage reference to the `ProxyPayload` struct.
    */
    function _fallback(ProxyPayload storage self) internal {
        _delegate(self, implementation(self));
    }

    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(ProxyPayload storage self, address implementation) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}