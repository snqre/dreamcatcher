// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

/**
Common use costum errors.
*/

/** # UNEX
If the currentTimestamp is after expectedTimestamp it is likely we are throwing an error because it is expired.
If the currentTimestamp is before expectedTimestamp it is likely we are throwing an error because it is premature.
 */
error UnseasonedExecution(uint currentTimestamp, uint expectedTimestamp);

// -----------------
// LIB AUTHENTICATOR.
// -----------------

error TimedKeyIsPremature(uint currentTimestamp, uint expectedTimestamp);
error TimedKeyIsExpired(uint currentTimestamp, uint expectedTimestamp);
error ConsumableKeyIsExhausted();
error KeyIsNotOwned();