// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library ErrorsV1 {
    error IsAlreadyInSet(address account);

    error IsNotInSet(address account);

    error IsMatchingValue();
}