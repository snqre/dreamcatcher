// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/components/RoleComponent.sol";

contract CommitteeSlot {
    bytes32 internal constant _COMMITTEE = keccak256("slot.committee");

    function committee() internal pure returns (RoleComponent.Role storage s) {
        bytes32 location = _COMMITTEE;
        assembly {
            s.slot := location
        }
    }
}