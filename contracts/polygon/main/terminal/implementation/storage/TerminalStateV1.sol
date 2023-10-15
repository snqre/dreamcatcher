// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/libraries/security/role/DynamicRole.sol";

contract TerminalStateV1 is StateV1 {
    using DynamicRole for DynamicRole.Role;

    Role defaultAdminRole;

    function _initialize() internal {
        defaultAdminRole.setDefaultAdmin({boolean: true});
        defaultAdminRole.setName({text: "Default Admin Role"});
        defaultAdminRole.name();
        defaultAdminRole.setMaxMembersLength({length: 600});
    }

    function getRole() external returns (string memory) {
        return defaultAdminRole.description();

        multisig.sign();
    }

}