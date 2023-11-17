// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* @title ERC-173 Contract Ownership Standard.
*
* https://eips.ethereum.org/EIPS/eip-173.
*
* ABSTRACT This specification defines standard functions for owning or
*          controlling a contract.
*
*          An implementation allows reading the current owner
*          { owner() returns (address) } and transfering ownership
*          { transferOwnership(address newOwner) } along with a
*          standardized event for when ownership is changed
*          { OwnershipTransferred(address indexed previousOwner,
*          address indexed newOwner) }.
 */
abstract contract ERC173 {

    /**
    * @dev This emits when ownership of a contract changes.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @notice Get the address of the { owner }.
    *
    * @return The address of the { owner }.
    *
    * # Security Considerations
    *
    * @dev If the address returned by { owner } is an externally owned account
    *      then its private key must not be lost or compromised.
     */
    function owner() public view virtual returns (address);

    /**
    * @notice Set the address of the new owner of the contract.
    *
    * @dev Set { newOwner } to address(0) to renounce any ownership.
    *
    * @param newOwner The address of the new owner of the contract.
     */
    function transferOwnership(address newOwner) public virtual;
}