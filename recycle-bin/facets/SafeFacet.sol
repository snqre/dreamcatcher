// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/slots/SharesSlot.sol";

contract SafeFacet is SharesSlot {
    using SafeComponent for SafeComponent.Safe;


}