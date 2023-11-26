// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/components/RoleComponent.sol";

library PausableComponent {
    using RoleComponent for RoleComponent.Role;

    error Paused();
    error Unpaused();

    struct Pausable {
        bool _paused;
    }

    function paused(Pausable storage pausable) internal view returns (bool) {
        return pausable._paused;
    }

    function whenPaused(Pausable storage pausable) internal view {
        if (paused({pausable: pausable})) {
            revert Unpaused();
        }
    }

    function whenUnpaused(Pausable storage pausable) internal view {
        if (!paused({pausable: pausable})) {
            revert Paused();
        }
    }

    function pause(Pausable storage pausable, RoleComponent.Role storage role) internal {
        role.tryAuthenticate();
        pausable._paused = true;
    }

    function unpause(Pausable storage pausable, RoleComponent.Role storage role) internal {
        role.tryAuthenticate();
        pausable._paused = false;
    }
}