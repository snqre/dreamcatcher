// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/slots/NonReentrantSlot.sol";
import "contracts/polygon/diamonds/facets/slots/AnyoneSlot.sol";

/// modifiers cant be done within a component so they must be built in facet
contract NonReentrantFacet is NonReentrantSlot, AnyoneSlot {
    using NonReentrantComponent for NonReentrantComponent.NonReentrant;

    error Reentrant();

    modifier nonReentrant_() {
        if (nonReentrant().locked()) { revert Reentrant(); }
        nonReentrant().lock(anyone());
        _;
        nonReentrant().unlock(anyone());
    }
}