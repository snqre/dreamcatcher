// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library ErrorsV1 {
    error IsAlreadyInSet(address account);

    error IsNotInSet(address account);

    error IsMatchingValue();

    error OutOfBounds(uint256 min, uint256 max, uint256 value);

    /** Multi Sig */



    error AlreadyHasRole(address account);

    error DoesNotHaveRole(address account);

    error TooManyRoleMembers();
}