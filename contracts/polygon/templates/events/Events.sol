// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/structs/Structs.sol";
import "contracts/polygon/templates/errors/Errors.sol";

event ModuleAquired(string indexed name, Module indexed module);
event ModuleUpgraded(string indexed name, Module indexed module);
