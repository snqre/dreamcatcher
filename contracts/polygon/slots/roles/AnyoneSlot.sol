// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/slots/.components/RoleComponent.sol";

contract AnyoneSlot {
    bytes32 internal constant _ANYONE = keccak256("slot.anyone");

    function anyone() internal pure returns (RoleComponent.Role storage s) {
        bytes32 location = _ANYONE;
        assembly {
            s.slot := location
        }
    }
}