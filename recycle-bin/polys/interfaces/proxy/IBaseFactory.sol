// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IBaseFactory {

    /**
    * @dev Emitted when ownership of the contract is transferred.
    * @param previousOwner The previous owner's address.
    * @param newOwner The new owner's address.
    */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * Emitted when a new Base contract is deployed.
    * @param newBase The address of the newly deployed Base contract.
    */
    event Deployed(address indexed newBase);

    /**
    * @dev Returns the current owner of the contract.
    * @return The address of the owner.
    */
    function owner() external view returns (address);

    /**
    * @dev Returns the address of the default implementation.
    * @return The address of the default implementation.
    */
    function defaultImplementation() external view returns (address);

    /**
    * @dev Returns the address of the deployed contract at the specified index.
    * @param deployedId The index of the deployed contract.
    * @return The address of the deployed contract.
    */
    function addressDeployedTo(uint256 deployedId) external view returns (address);

    /**
    * @dev Deploys a new Base contract and returns its address.
    * @return The address of the newly deployed Base contract.
    */
    function deploy() external returns (address);

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    */
    function renounceOwnership() external;

    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOwnership(address newOwner) external;
}