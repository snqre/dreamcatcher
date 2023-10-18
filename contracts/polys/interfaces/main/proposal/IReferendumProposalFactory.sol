// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/proxy/IBaseFactory.sol";

interface IReferendumProposalFactory is IBaseFactory {
    
    /**
    * @dev Emitted when the default required quorum for a multi-signature proposal factory is set.
    * @param bp The new default required quorum expressed in basis points (0 to 10000).
    */
    event DefaultRequiredQuorumSet(uint256 indexed bp);

    /**
    * @dev Emitted when the default required threshold for a multi-signature proposal factory is set.
    * @param bp The new default required threshold expressed in basis points (0 to 10000).
    */
    event DefaultRequiredThresholdSet(uint256 indexed bp);

    /**
    * @dev Emitted when the default voting ERC-20 token address for a multi-signature proposal factory is set.
    * @param erc20 The address of the ERC-20 token contract to be used for voting.
    */
    event DefaultVotingERC20Set(address indexed erc20);

    /**
    * @dev Emitted when the default duration for a multi-signature proposal factory is set.
    * @param seconds_ The duration in seconds for which a proposal is open for voting.
    */
    event DefaultDurationSet(uint256 indexed seconds_);

    /**
    * @dev Emitted when the address of the multi-signature proposal factory is set.
    * @param account The address of the multi-signature proposal factory contract.
    */
    event MultiSigProposalFactorySet(address indexed account);

    /**
    * @dev Emitted when the address of the terminal is set.
    * @param account The address of the terminal contract.
    */
    event TerminalSet(address indexed account);

    /**
    * @dev Returns the default required quorum percentage for ReferendumProposal instances.
    * @return The default required quorum percentage.
    */
    function defaultRequiredQuorum() external view returns (uint256);

    /**
    * @dev Returns the default required threshold percentage for ReferendumProposal instances.
    * @return The default required threshold percentage.
    */
    function defaultRequiredThreshold() external view returns (uint256);

    /**
    * @dev Returns the default voting ERC20 token address for ReferendumProposal instances.
    * @return The default voting ERC20 token address.
    */
    function defaultVotingERC20() external view returns (address);

    /**
    * @dev Returns the default duration for ReferendumProposal instances.
    * @return The default duration in seconds.
    */
    function defaultDuration() external view returns (uint256);

    /**
    * @dev Returns the address of the MultiSigProposalFactory contract associated with this ReferendumProposalFactory.
    * @return The address of the MultiSigProposalFactory contract.
    */
    function multiSigProposalFactory() external view returns (address);

    /**
    * @dev Returns the address of the terminal associated with this ReferendumProposalFactory.
    * @return The address of the terminal.
    */
    function terminal() external view returns (address);

    /**
    * @dev Creates a new ReferendumProposal with the specified parameters.
    * @param caption The caption or title of the proposal.
    * @param message The detailed message or description of the proposal.
    * @param target The address of the target contract for the proposal.
    * @param data The encoded data payload for the proposal.
    * @return The address of the newly created ReferendumProposal.
    */
    function createReferendumProposal(string memory caption, string memory message, address target, bytes memory data) external returns (address);

    /**
    * @dev Sets the default required quorum percentage for newly created ReferendumProposals.
    * @param bp The new quorum percentage in basis points (0-10000).
    */
    function setDefaultRequiredQuorum(uint256 bp) external;

    /**
    * @dev Sets the default required threshold percentage for newly created ReferendumProposals.
    * @param bp The new threshold percentage in basis points (0-10000).
    */
    function setDefaultRequiredThreshold(uint256 bp) external;

    /**
    * @dev Sets the default voting ERC20 token address for newly created ReferendumProposals.
    * @param erc20 The address of the ERC20 token to be used for voting.
    */
    function setDefaultVotingERC20(address erc20) external;

    /**
    * @dev Sets the default duration (in seconds) for newly created ReferendumProposals.
    * @param seconds_ The duration of the proposal in seconds.
    */
    function setDefaultDuration(uint256 seconds_) external;

    /**
    * @dev Sets the address of the MultiSigProposalFactory contract that will be used for creating MultiSigProposals.
    * @param account The address of the MultiSigProposalFactory contract.
    */
    function setMultiSigProposalFactory(address account) external;

    /**
    * @dev Sets the address of the terminal contract that will be used in the ReferendumProposal implementation.
    * @param account The address of the terminal contract.
    */
    function setTerminal(address account) external;

    /**
    * @dev Deprecated function. Instead, use the `createReferendumProposal` function to deploy a new ReferendumProposal.
    * @return Always reverts with the deprecation message.
    */
    function deploy() external returns (address);
}