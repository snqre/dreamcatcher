// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/components/RoleComponent.sol";

library NonReentrantComponent {
    using RoleComponent for RoleComponent.Role;

    struct NonReentrant {
        bool _locked;
    }

    function locked(NonReentrant storage nonReentrant) internal view returns (bool) {
        return nonReentrant._locked;
    }

    function lock(NonReentrant storage nonReentrant, RoleComponent.Role storage role) internal {
        role.tryAuthenticate();
        nonReentrant._locked = true;
    }

    function unlock(NonReentrant storage nonReentrant, RoleComponent.Role storage role) internal {
        role.tryAuthenticate();
        nonReentrant._locked = false;
    }
}