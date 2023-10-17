// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* terminalKey => address
* multiSigProposalFactoryKey => address
* referendumProposalFactorykey => address
 */
interface IAddressBook {

    /**
    * @dev Returns the key used to store the terminal address.
    * @return bytes32 The key for the terminal in keccak256 hash.
    */
    function terminalKey() external pure returns (bytes32);

    /**
    * @dev Returns the key used to store the MultiSigProposalFactory address.
    * @return bytes32 The key for the MultiSigProposalFactory in keccak256 hash.
    */
    function multiSigProposalFactoryKey() external pure returns (bytes32);

    /**
    * @dev Returns the key used to store the ReferendumProposalFactory address.
    * @return bytes32 The key for the ReferendumProposalFactory in keccak256 hash.
    */
    function referendumProposalFactoryKey() external pure returns (bytes32);

    /**
    * @dev Retrieves the address of the terminal associated with the MultiSigProposalFactory.
    * @return address The address of the terminal.
    */
    function terminal() external view returns (address);

    /**
    * @dev Retrieves the address of the MultiSigProposalFactory associated with the MultiSigProposalFactory.
    * @return address The address of the MultiSigProposalFactory.
    */
    function multiSigProposalFactory() external view returns (address);

    /**
    * @dev Retrieves the address of the ReferendumProposalFactory associated with the MultiSigProposalFactory.
    * @return address The address of the ReferendumProposalFactory.
    */
    function referendumProposalFactory() external view returns (address);
}