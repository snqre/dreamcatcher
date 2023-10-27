// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* ownerKey => address
 */
interface IOwnable {

    /**
    * @dev Emitted when ownership of the contract is transferred.
    * @param oldOwner The address of the old owner.
    * @param newOwner The address of the new owner.
    */
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /**
    * @dev Returns the key for the owner in the storage mapping.
    * @return The key for the owner.
    */
    function ownerkey() external pure returns (bytes32);

    /**
    * @dev Returns the current owner of the contract.
    * @return The address of the current owner.
    */
    function owner() external view returns (address);

    /**
    * @dev Renounces ownership, leaving the contract without an owner.
    */
    function renounceOwnership() external;

    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOwnership(address newOwner) external;
}