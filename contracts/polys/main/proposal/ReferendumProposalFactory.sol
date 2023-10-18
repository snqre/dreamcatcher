// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/BaseFactory.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/main/proposal/IReferendumProposalImplementation.sol";
import "contracts/polygon/interfaces/main/terminal/implementation/ITerminalImplementation.sol";

contract ReferendumProposalFactory is BaseFactory {

    /**
    * @dev Using EnumerableSet to manage sets of addresses.
    * This allows efficient and gas-friendly manipulation of address sets.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

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
    * @dev Private variable storing the default required quorum for proposals created by the factory.
    */
    uint256 private _defaultRequiredQuorum;

    /**
    * @dev Private variable storing the default required threshold for proposals created by the factory.
    */
    uint256 private _defaultRequiredThreshold;

    /**
    * @dev Private variable storing the default ERC20 token used for voting in proposals created by the factory.
    */
    address private _defaultVotingERC20;

    /**
    * @dev Private variable storing the default duration, in seconds, for proposals created by the factory.
    */
    uint256 private _defaultDuration;

    /**
    * @dev Private variable storing the address of the MultiSigProposalFactory contract.
    */
    address private _multiSigProposalFactory;

    /**
    * @dev Private variable storing the address of the Terminal contract.
    */
    address private _terminal;

    /**
    * @dev Constructor for the ReferendumProposalFactory contract.
    * @param referendumProposalImplementation The address of the implementation contract for ReferendumProposal instances.
    */
    constructor(address referendumProposalImplementation) BaseFactory(referendumProposalImplementation) {}

    /**
    * @dev Returns the default required quorum percentage for ReferendumProposal instances.
    * @return The default required quorum percentage.
    */
    function defaultRequiredQuorum() public view virtual returns (uint256) {
        return _defaultRequiredQuorum;
    }

    /**
    * @dev Returns the default required threshold percentage for ReferendumProposal instances.
    * @return The default required threshold percentage.
    */
    function defaultRequiredThreshold() public view virtual returns (uint256) {
        return _defaultRequiredThreshold;
    }

    /**
    * @dev Returns the default voting ERC20 token address for ReferendumProposal instances.
    * @return The default voting ERC20 token address.
    */
    function defaultVotingERC20() public view virtual returns (address) {
        return _defaultVotingERC20;
    }

    /**
    * @dev Returns the default duration for ReferendumProposal instances.
    * @return The default duration in seconds.
    */
    function defaultDuration() public view virtual returns (uint256) {
        return _defaultDuration;
    }

    /**
    * @dev Returns the address of the MultiSigProposalFactory contract associated with this ReferendumProposalFactory.
    * @return The address of the MultiSigProposalFactory contract.
    */
    function multiSigProposalFactory() public view virtual returns (address) {
        return _multiSigProposalFactory;
    }

    /**
    * @dev Returns the address of the terminal associated with this ReferendumProposalFactory.
    * @return The address of the terminal.
    */
    function terminal() public view virtual returns (address) {
        return _terminal;
    }

    /**
    * @dev Creates a new ReferendumProposal with the specified parameters.
    * @param caption The caption or title of the proposal.
    * @param message The detailed message or description of the proposal.
    * @param target The address of the target contract for the proposal.
    * @param data The encoded data payload for the proposal.
    * @return The address of the newly created ReferendumProposal.
    */
    function createReferendumProposal(string memory caption, string memory message, address target, bytes memory data) public virtual returns (address) {
        _onlyMultiSigProposal();
        _deployed.push(new Base());
        uint256 id = _deployed.length - 1;
        _deployed[id].setInitialImplementation(defaultImplementation());
        IReferendumProposalImplementation proposal = IReferendumProposalImplementation(address(_deployed[id]));
        proposal.initialize();
        proposal.setCaption(caption);
        proposal.setMessage(message);
        proposal.setCreator(msg.sender);
        proposal.setTarget(target);
        proposal.setData(data);
        proposal.setStartTimestamp(block.timestamp);
        proposal.setDuration(defaultDuration());
        proposal.setRequiredQuorum(defaultRequiredQuorum());
        proposal.setRequiredThreshold(defaultRequiredThreshold());
        proposal.setVotingERC20(defaultVotingERC20());
        proposal.snapshot();
        proposal.setTerminal(terminal());
        proposal.setMultiSigProposalFactory(multiSigProposalFactory());
        proposal.setReferendumProposalFactory(address(this));
        ITerminalImplementation terminal = ITerminalImplementation(terminal());
        terminal.grantRole(terminal.roleKey(terminal.hash("LOW_LEVEL_CALLER_ROLE")), address(proposal));
        emit Deployed(address(_deployed[id]));
        return address(_deployed[id]);
    }

    /**
    * @dev Sets the default required quorum percentage for newly created ReferendumProposals.
    * @param bp The new quorum percentage in basis points (0-10000).
    */
    function setDefaultRequiredQuorum(uint256 bp) public virtual {
        _checkOwner();
        _setDefaultRequiredQuorum(bp);
    }

    /**
    * @dev Sets the default required threshold percentage for newly created ReferendumProposals.
    * @param bp The new threshold percentage in basis points (0-10000).
    */
    function setDefaultRequiredThreshold(uint256 bp) public virtual {
        _checkOwner();
        _setDefaultRequiredThreshold(bp);
    }

    /**
    * @dev Sets the default voting ERC20 token address for newly created ReferendumProposals.
    * @param erc20 The address of the ERC20 token to be used for voting.
    */
    function setDefaultVotingERC20(address erc20) public virtual {
        _checkOwner();
        _setDefaultVotingERC20(erc20);
    }

    /**
    * @dev Sets the default duration (in seconds) for newly created ReferendumProposals.
    * @param seconds_ The duration of the proposal in seconds.
    */
    function setDefaultDuration(uint256 seconds_) public virtual {
        _checkOwner();
        _setDefaultDuration(seconds_);
    }

    /**
    * @dev Sets the address of the MultiSigProposalFactory contract that will be used for creating MultiSigProposals.
    * @param account The address of the MultiSigProposalFactory contract.
    */
    function setMultiSigProposalFactory(address account) public virtual {
        _checkOwner();
        _setMultiSigProposalFactory(account);
    }

    /**
    * @dev Sets the address of the terminal contract that will be used in the ReferendumProposal implementation.
    * @param account The address of the terminal contract.
    */
    function setTerminal(address account) public virtual {
        _checkOwner();
        _setTerminal(account);
    }

    /**
    * @dev Deprecated function. Instead, use the `createReferendumProposal` function to deploy a new ReferendumProposal.
    * @return Always reverts with the deprecation message.
    */
    function deploy() public virtual override returns (address) {
        revert("ReferendumProposalFactory: deprecated use function createReferendumProposal");
        super.deploy();
    }

    /**
    * @dev Modifier that checks if the sender has the required role in the Terminal contract to create a MultiSigProposal.
    * Reverts if the sender does not have the required role.
    */
    function _onlyMultiSigProposal() internal view virtual {
        ITerminalImplementation terminal = ITerminalImplementation(terminal());
        terminal.requireRole(terminal.roleKey(terminal.hash("MULTI_SIG_PROPOSAL_ROLE")), msg.sender);
    }

    /**
    * @dev Sets the default required quorum for ReferendumProposals.
    * Only the contract owner can call this function.
    * @param bp The new default required quorum in basis points (0-10000).
    * Emits a DefaultRequiredQuorumSet event.
    */
    function _setDefaultRequiredQuorum(uint256 bp) internal virtual {
        require(bp <= 10000, "ReferendumProposalFactory: out of bounds");
        _defaultRequiredQuorum = bp;
        emit DefaultRequiredQuorumSet(bp);
    }

    /**
    * @dev Sets the default required threshold for ReferendumProposals.
    * Only the contract owner can call this function.
    * @param bp The new default required threshold in basis points (0-10000).
    * Emits a DefaultRequiredThresholdSet event.
    */
    function _setDefaultRequiredThreshold(uint256 bp) internal virtual {
        require(bp <= 10000, "ReferendumProposalFactory: out of bounds");
        _defaultRequiredThreshold = bp;
        emit DefaultRequiredThresholdSet(bp);
    }

    /**
    * @dev Sets the default voting ERC20 token for ReferendumProposals.
    * Only the contract owner can call this function.
    * @param erc20 The address of the new default voting ERC20 token.
    * Emits a DefaultVotingERC20Set event.
    */
    function _setDefaultVotingERC20(address erc20) internal virtual {
        _defaultVotingERC20 = erc20;
        emit DefaultVotingERC20Set(erc20);
    }

    /**
    * @dev Sets the default duration for ReferendumProposals.
    * Only the contract owner can call this function.
    * @param seconds_ The new default duration in seconds.
    * Emits a DefaultDurationSet event.
    */
    function _setDefaultDuration(uint256 seconds_) internal virtual {
        _defaultDuration = seconds_;
        emit DefaultDurationSet(seconds_);
    }

    /**
    * @dev Sets the address of the MultiSigProposalFactory contract.
    * Only the contract owner can call this function.
    * @param account The address of the MultiSigProposalFactory contract.
    * Emits a MultiSigProposalFactorySet event.
    */
    function _setMultiSigProposalFactory(address account) internal virtual {
        _multiSigProposalFactory = account;
        emit MultiSigProposalFactorySet(account);
    }

    /**
    * @dev Sets the address of the terminal contract.
    * Only the contract owner can call this function.
    * @param account The address of the terminal contract.
    * Emits a TerminalSet event.
    */
    function _setTerminal(address account) internal virtual {
        _terminal = account;
        emit TerminalSet(account);
    }
}