// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/proxy/IBaseFactory.sol";

interface IMultiSigProposalFactory is IBaseFactory {

    /**
    * @dev Emitted when a default signer is added to the contract.
    * @param signer The address of the added default signer.
    */
    event DefaultSignerAdded(address indexed signer);

    /**
    * @dev Emitted when a default signer is removed from the contract.
    * @param signer The address of the removed default signer.
    */
    event DefaultSignerRemoved(address indexed signer);

    /**
    * @dev Emitted when the default required quorum is set for the contract.
    * @param bp The new default required quorum in basis points.
    */
    event DefaultRequiredQuorumSet(uint256 indexed bp);

    /**
    * @dev Emitted when the default duration for multi-signature proposals is set.
    * @param seconds_ The new default duration in seconds.
    */
    event DefaultDurationSet(uint256 indexed seconds_);

    /**
    * @dev Emitted when the ReferendumProposalFactory address is set.
    * @param account The address of the new ReferendumProposalFactory.
    */
    event ReferendumProposalFactorySet(address indexed account);

    /**
    * @dev Emitted when the terminal address is set.
    * @param account The address of the new terminal.
    */
    event TerminalSet(address indexed account);

    /**
    * @dev Retrieves the default required quorum in basis points.
    * @return uint256 The default required quorum.
    */
    function defaultRequiredQuorum() external view returns (uint256);

    /**
    * @dev Retrieves the default duration in seconds for multi-signature proposals.
    * @return uint256 The default duration.
    */
    function defaultDuration() external view returns (uint256);

    /**
    * @dev Retrieves the address of the ReferendumProposalFactory associated with the MultiSigProposalFactory.
    * @return address The address of the ReferendumProposalFactory.
    */
    function referendumProposalFactory() external view returns (address);

    /**
    * @dev Retrieves the address of the terminal associated with the MultiSigProposalFactory.
    * @return address The address of the terminal.
    */
    function terminal() external view returns (address);

    /**
    * @dev Retrieves the address of a default signer based on the provided signer ID.
    * @param signerId The ID of the default signer.
    * @return address The address of the default signer.
    */
    function defaultSigners(uint256 signerId) external view returns (address);

    /**
    * @dev Retrieves the number of default signers.
    * @return uint256 The length of the default signers set.
    */
    function defaultSignersLength() external view returns (uint256);

    /**
    * @dev Checks if the provided account is a default signer.
    * @param account The address to be checked.
    * @return bool True if the account is a default signer, false otherwise.
    */
    function isDefaultSigner(address account) external view returns (bool);

    /**
    * @dev Creates a new multi-signature proposal.
    * Only a default signer can initiate the creation.
    * Deploys a new Base contract, initializes it, and converts it to the IMultiSigProposal interface.
    * Adds default signers, sets caption, message, creator, target, data, start timestamp, duration, and required quorum.
    * Emits a Deployed event with the address of the newly deployed proposal.
    * @param caption The caption for the proposal.
    * @param message The message associated with the proposal.
    * @param target The target address of the proposal.
    * @param data The data payload for the proposal.
    * @return address The address of the newly deployed multi-signature proposal.
    */
    function createMultiSigProposal(string memory caption, string memory message, address target, bytes memory data) external returns (address);

    /**
    * @dev Adds a new address as a default signer.
    * Only the owner is allowed to perform this action.
    * @param account The address of the new default signer.
    */
    function addDefaultSigner(address account) external;

    /**
    * @dev Removes an address from the list of default signers.
    * Only the owner is allowed to perform this action.
    * @param account The address of the default signer to be removed.
    */
    function removeDefaultSigner(address account) external;

    /**
    * @dev Sets a new default required quorum for multi-signature proposals.
    * Only the owner is allowed to perform this action.
    * @param bp The new default required quorum in basis points.
    */
    function setDefaultRequiredQuorum(uint256 bp) external;

    /**
    * @dev Sets a new default duration for multi-signature proposals.
    * Only the owner is allowed to perform this action.
    * @param seconds_ The new default duration in seconds.
    */
    function setDefaultDuration(uint256 seconds_) external;

    /**
    * @dev Sets the address of the ReferendumProposalFactory.
    * Only the owner is allowed to perform this action.
    * @param account The address of the new ReferendumProposalFactory.
    */
    function setReferendumProposalFactory(address account) external;

    /**
    * @dev Sets the address of the terminal associated with the MultiSigProposalFactory.
    * Only the owner is allowed to perform this action.
    * @param account The address of the new terminal.
    */
    function setTerminal(address account) external;

    /**
    * @dev Deprecated function. Use `createMultiSigProposal` for deploying multi-signature proposals.
    * Reverts with an informative message.
    * Calls the parent implementation of the deprecated function.
    * @return address This function always reverts and does not return an address.
    */
    function deploy() external returns (address);
}