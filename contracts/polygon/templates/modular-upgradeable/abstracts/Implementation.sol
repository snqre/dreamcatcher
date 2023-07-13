// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/structs/Structs.sol";

abstract contract ImplementationWrapper {
    error IsDisabled(Implementation implementation);

    // implementation.
    bool enabled;

    // -----------------
    // ENABLE && DISABLE.
    // -----------------

    function _mustBeEnabled()
        internal view virtual {
        if (!enabled) {

            revert IsDisabled(Implementation({
                enabled: enabled
            })); 
        }
    }

    function enable()
        external virtual 
        returns (bool) {
        enabled = true;
        return true;
    }

    function disable()
        external virtual 
        returns (bool) {
        enabled = false;
        return true;
    }
}