// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/access/AccessControlDefaultAdminRules.sol";

import "contracts/polygon/external/openzeppelin/access/AccessControlEnumerable.sol";

import "contracts/polygon/abstract/Implementation.sol";

/** @dev This inheritance adds storage to the implementation */
abstract contract ImplementationAccessControl is Implementation, AccessControlDefaultAdminRules {
    constructor(uint48 initialDelay, address initialDefaultAdmin) AccessControlDefaultAdminRules(initialDelay, initialDefaultAdmin) {}
}