// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/components/RoleComponent.sol";

/// do not add members to anyone role : anyone will pass try authentication and allow anyone access a function
contract AnyoneSlot {
    bytes32 internal constant _ANYONE = keccak256("slot.anyone");

    function anyone() internal pure returns (RoleComponent.Role storage s) {
        bytes32 location = _ANYONE;
        assembly {
            s.slot := location
        }
    }
}