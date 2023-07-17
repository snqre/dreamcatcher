// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Validator.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Timelock.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Link.sol";

contract Hub is Validator, Timelock, Link {

}