// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/components/PausableComponent.sol";

contract PausableSlot {
    bytes32 internal constant _PAUSABLE = keccak256("slot.pausable");

    function pausable() internal pure returns (PausableComponent.Pausable storage s) {
        bytes32 location = _PAUSABLE;
        assembly {
            s.slot := location
        }
    }
}