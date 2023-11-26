// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library NonReentrantComponent {
    struct NonReentrant {
        bool _locked;
    }

    function locked(NonReentrant storage nonReentrant) internal view returns (bool) {
        return nonReentrant._locked;
    }

    function lock(NonReentrant storage nonReentrant) internal returns (bool) {
        nonReentrant._locked = true;
        return true;
    }

    function unlock(NonReentrant storage nonReentrant) internal returns (bool) {
        nonReentrant._locked = false;
        return true;
    }
}