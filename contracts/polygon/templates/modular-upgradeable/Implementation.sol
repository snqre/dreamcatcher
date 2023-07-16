// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

/// light weight wrapper
contract Implementation {
    address router;
    bool enabled;
    uint version;

    error IMPLEMENTATION_IS_DISABLED();
    
    constructor() {}

    function enable()
        external virtual {
        enabled = true;
    }

    function disable()
        external virtual {
        enabled = false;
    }

    function _mustBeEnabled()
        internal view virtual {
        if (!enabled) {
            revert IMPLEMENTATION_IS_DISABLED();
        }
    }
}