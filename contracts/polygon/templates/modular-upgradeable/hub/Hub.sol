// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Role.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Timelock.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Link.sol";

contract Hub is Role, Timelock, Link {
    constructor()
        Role() {
        /// ... Role: set maxKeyPerRole to 30
        
        address to = address(this);
        _grant(to, address(this), "revoke", 2, 0, 0, 0);
        _grant(to, address(this), "grant", 2, 0, 0, 0);
        _grant(to, address(this), "revokeKeyFromRole", 2, 0, 0, 0);
        _grant(to, address(this), "grantKeyToRole", 2, 0, 0, 0);
        _grant(to, address(this), "grantRole", 2, 0, 0, 0);
        _grant(to, address(this), "revokeRole", 2, 0, 0, 0);

        to = msg.sender;
        _grant(to, address(this), "revoke", 2, 0, 0, 0);
        _grant(to, address(this), "grant", 2, 0, 0, 0);
        _grant(to, address(this), "revokeKeyFromRole", 2, 0, 0, 0);
        _grant(to, address(this), "grantKeyToRole", 2, 0, 0, 0);
        _grant(to, address(this), "grantRole", 2, 0, 0, 0);
        _grant(to, address(this), "revokeRole", 2, 0, 0, 0);
    }
}