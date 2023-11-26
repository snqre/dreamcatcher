// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/slots/.components/RoleComponent.sol";

contract AdminsSlot {
    bytes32 internal constant _ADMINS = keccak256("slot.admins");

    function admins() internal pure returns (RoleComponent.Role storage s) {
        bytes32 location = _ADMINS;
        assembly {
            s.slot := location
        }
    }
}