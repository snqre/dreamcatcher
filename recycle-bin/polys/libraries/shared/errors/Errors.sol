// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Errors {

    /** General */

    /**
    * @dev Error thrown when attempting to perform a match check that fails.
    */
    error IsMatchingValue();

    error FailedLowLevelCall(address target, bytes data);

    /** Math */

    /**
    * @dev Error thrown when a value is outside the expected bounds.
    * @param min The minimum allowed value.
    * @param max The maximum allowed value.
    * @param value The actual value that is outside the specified bounds.
    */
    error OutOfBounds(uint256 min, uint256 max, uint256 value);

    /** EnumerableSet */

    /**
    * @dev Error thrown when attempting to add an account to an EnumerableSet.AddressSet where the account is already present.
    * @param account The address that is already in the set.
    */
    error IsAlreadyInEnumerableSetAddressSet(address account);

    /**
    * @dev Error thrown when attempting to remove an account from an EnumerableSet.AddressSet where the account is not present.
    * @param account The address that is not in the set.
    */
    error IsNotInEnumerableSetAddressSet(address account);

    /** Role */

    /**
    * @dev Error thrown when attempting to grant a role to an account that already has the role.
    * @param account The address of the account that already has the role.
    */
    error AlreadyHasRole(address account);

    /**
    * @dev Error thrown when attempting to revoke a role from an account that does not have the role.
    * @param account The address of the account that does not have the role.
    */
    error DoesNotHaveRole(address account);

    /**
    * @dev Error thrown when attempting to grant a role, but the role has reached its maximum allowed number of members.
    */
    error TooManyRoleMembers();

    /** SaferLock */

    error IsLocked();

    error IsNotLocked();

    /** Multi Sig */

    error IsAlreadySigner(address account);

    error IsNotSigner(address account);

    error HasAlreadySigned(address account);

    error HasAlreadyBeenExecuted();

    error HasNotBeenApproved();

    /** Referendum */

    error MinBalanceCannotBeLargerThanTotalSupply();

    error InsufficientBalanceToVote();

    error HasAlreadyVoted(address account);
}