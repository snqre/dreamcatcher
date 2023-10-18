// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";

/**
* terminalKey => address
* multiSigProposalFactoryKey => address
* referendumProposalFactorykey => address
 */
abstract contract AddressBook is Storage {

    /**
    * @dev Returns the key used to store the terminal address.
    * @return bytes32 The key for the terminal in keccak256 hash.
    */
    function terminalKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("TERMINAL"));
    }

    /**
    * @dev Returns the key used to store the MultiSigProposalFactory address.
    * @return bytes32 The key for the MultiSigProposalFactory in keccak256 hash.
    */
    function multiSigProposalFactoryKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_PROPOSAL_FACTORY"));
    }

    /**
    * @dev Returns the key used to store the ReferendumProposalFactory address.
    * @return bytes32 The key for the ReferendumProposalFactory in keccak256 hash.
    */
    function referendumProposalFactoryKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_FACTORY"));
    }

    /**
    * @dev Retrieves the address of the terminal associated with the MultiSigProposalFactory.
    * @return address The address of the terminal.
    */
    function terminal() public view virtual returns (address) {
        return _address[terminalKey()];
    }

    /**
    * @dev Retrieves the address of the MultiSigProposalFactory associated with the MultiSigProposalFactory.
    * @return address The address of the MultiSigProposalFactory.
    */
    function multiSigProposalFactory() public view virtual returns (address) {
        return _address[multiSigProposalFactoryKey()];
    }

    /**
    * @dev Retrieves the address of the ReferendumProposalFactory associated with the MultiSigProposalFactory.
    * @return address The address of the ReferendumProposalFactory.
    */
    function referendumProposalFactory() public view virtual returns (address) {
        return _address[referendumProposalFactoryKey()];
    }

    /**
    * @dev Sets the address of the terminal internally using the terminal key.
    * @param account The address of the new terminal.
    */
    function _setTerminal(address account) internal virtual {
        _address[terminalKey()] = account;
    }

    /**
    * @dev Sets the address of the MultiSigProposalFactory internally using the key.
    * @param account The address of the new MultiSigProposalFactory.
    */
    function _setMultiSigProposalFactory(address account) internal virtual {
        _address[multiSigProposalFactoryKey()] = account;
    }

    /**
    * @dev Sets the address of the ReferendumProposalFactory internally using the key.
    * @param account The address of the new ReferendumProposalFactory.
    */
    function _setReferendumProposalFactory(address account) internal virtual {
        _address[referendumProposalFactoryKey()] = account;
    }
}