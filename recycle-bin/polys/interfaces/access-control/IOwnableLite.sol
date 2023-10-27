// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IOwnableLite {

    /**
    * @notice Event emitted when ownership of the contract is transferred.
    * @param sender The address triggering the event.
    * @param oldOwner The address of the previous owner.
    * @param newOwner The address of the new owner.
    */
    event OwnershipTransferred(address indexed sender, address indexed oldOwner, address indexed newOwner);

    /**
    * @notice Returns the address of the current owner.
    * @return The address of the owner.
    */
    function owner() external view returns (address);

    /**
    * @notice Renounces ownership, making the contract ownerless.
    */
    function renounceOwnership() external;

    /**
    * @notice Transfers ownership of the contract to a new address.
    * @param newOwner The address of the new owner.
    */
    function transferOwnership(address newOwner) external;
}