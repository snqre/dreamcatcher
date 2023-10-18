// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/governance/proposal/IMultiSigProposal.sol";
import "contracts/polygon/interfaces/utils/IAddressBook.sol";

interface IMultiSigProposalImplementation is IMultiSigProposal, IAddressBook {
    
    /**
    * @dev Emitted when the terminal address is set.
    * @param account The address of the new terminal.
    */
    event TerminalSet(address indexed account);

    /**
    * @dev Emitted when the MultiSigProposalFactory address is set.
    * @param account The address of the new MultiSigProposalFactory.
    */
    event MultiSigProposalFactorySet(address indexed account);

    /**
    * @dev Emitted when the ReferendumProposalFactory address is set.
    * @param account The address of the new ReferendumProposalFactory.
    */
    event ReferendumProposalFactorySet(address indexed account);

    /**
    * @dev Executes the MultiSigProposal and triggers additional actions.
    * Calls the internal _execute function to mark the proposal as executed.
    * Emits an Executed event.
    * TODO: Create another referendum proposal using the ReferendumProposalFactory.
    */
    function execute() external returns (address);

    /**
    * @dev Sets the address of the terminal associated with the MultiSigProposalFactory.
    * Only the owner is allowed to perform this action.
    * @param account The address of the new terminal.
    */
    function setTerminal(address account) external;

    /**
    * @dev Sets the address of the MultiSigProposalFactory associated with the MultiSigProposalFactory.
    * Only the owner is allowed to perform this action.
    * @param account The address of the new MultiSigProposalFactory.
    */
    function setMultiSigProposalFactory(address account) external;

    /**
    * @dev Sets the address of the ReferendumProposalFactory associated with the MultiSigProposalFactory.
    * Only the owner is allowed to perform this action.
    * @param account The address of the new ReferendumProposalFactory.
    */
    function setReferendumProposalFactory(address account) external;
}