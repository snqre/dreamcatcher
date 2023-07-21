// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Link.sol";

contract Hub is Link {
    constructor()
        Role() {
        /// ... Role: set maxKeyPerRole to 30
        
        address to = address(this);
        _grant(to, address(this), "revoke", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "grant", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "revokeKeyFromRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "grantKeyToRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "grantRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "revokeRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "approve", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "reject", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "execute", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "executeBatch", __Validator.Class(2), 0, 0, 0);

        /// testing
        to = msg.sender;
        _grant(to, address(this), "revoke", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "grant", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "revokeKeyFromRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "grantKeyToRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "grantRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "revokeRole", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "approve", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "reject", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "execute", __Validator.Class(2), 0, 0, 0);
        _grant(to, address(this), "executeBatch", __Validator.Class(2), 0, 0, 0);
    }
}