// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/structs/Structs.sol";

// ---------
// UNIVERSAL.
// ---------



// -----------------
// LIB AUTHENTICATOR.
// -----------------

error KeyIsNotOfType(Key memory key);
error KeyIsNotOwned(Key memory key);
error KeyAccessPremature(Key memory key, uint currentTimestamp);
error KeyAccessExpired(Key memory key, uint currentTimestamp);
error KeyAccessZero(Key memory key);

// --------
// TERMINAL.
// --------

error ModuleIsNotEmpty(Module memory module);
error ModuleIsEmpty(Module memory module);
error ModuleIsNotUpgradeable(Module memory module);