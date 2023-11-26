// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/components/NonReentrantComponent.sol";

contract NonReentrantSlot {
    bytes32 internal constant _NON_REENTRANT = keccak256("slot.nonReentrant");

    function nonReentrant() internal pure returns (NonReentrantComponent.NonReentrant storage s) {
        bytes32 location = _NON_REENTRANT;
        assembly {
            s.slot := location
        }
    }
}