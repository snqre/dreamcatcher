// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/components/TokenComponent.sol";

/// shares object used for tokenized vault
contract SharesSlot {
    bytes32 internal constant _SHARES = keccak256("slot.shares");

    function shares() internal pure returns (TokenComponent.Token storage s) {
        bytes32 location = _SHARES;
        assembly {
            s.slot := location
        }
    }
}