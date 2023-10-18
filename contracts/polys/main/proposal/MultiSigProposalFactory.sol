// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/BaseFactory.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/main/proposal/IMultiSigProposalImplementation.sol";
import "contracts/polygon/interfaces/main/terminal/implementation/ITerminalImplementation.sol";

/**
* function deploy is deprecated in this factory and should not be used.
 */
contract MultiSigProposalFactory is BaseFactory {

    /**
    * @dev Using EnumerableSet to manage sets of addresses.
    * This allows efficient and gas-friendly manipulation of address sets.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

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
    * @dev Private set containing addresses of signers.
    * Used for efficient membership checks and manipulation of signers.
    */
    EnumerableSet.AddressSet private _signers;

    /**
    * @dev Private variable storing the default required quorum in basis points.
    * Represents the minimum percentage of signatures required for certain actions.
    */
    uint256 private _defaultRequiredQuorum;

    /**
    * @dev Private variable storing the default duration in seconds for multi-signature proposals.
    */
    uint256 private _defaultDuration;

    /**
    * @dev Private variable storing the address of the ReferendumProposalFactory.
    * Used to reference the factory for creating ReferendumProposal instances.
    */
    address private _referendumProposalFactory;

    /**
    * @dev Private variable storing the address of the terminal.
    * Represents the terminal contract associated with the MultiSigProposalFactory.
    */
    address private _terminal;

    /**
    * @dev Constructor for the contract.
    * Initializes the contract with the provided MultiSigProposal implementation address.
    * Inherits from BaseFactory and Ownable, setting the deployer as the owner.
    * @param multiSigProposalImplementation The address of the MultiSigProposal implementation.
    */
    constructor(address multiSigProposalImplementation) BaseFactory(multiSigProposalImplementation){
        _transferOwnership(msg.sender);
    }

    /**
    * @dev Retrieves the default required quorum in basis points.
    * @return uint256 The default required quorum.
    */
    function defaultRequiredQuorum() public view virtual returns (uint256) {
        return _defaultRequiredQuorum;
    }

    /**
    * @dev Retrieves the default duration in seconds for multi-signature proposals.
    * @return uint256 The default duration.
    */
    function defaultDuration() public view virtual returns (uint256) {
        return _defaultDuration;
    }

    /**
    * @dev Retrieves the address of the ReferendumProposalFactory associated with the MultiSigProposalFactory.
    * @return address The address of the ReferendumProposalFactory.
    */
    function referendumProposalFactory() public view virtual returns (address) {
        return _referendumProposalFactory;
    }

    /**
    * @dev Retrieves the address of the terminal associated with the MultiSigProposalFactory.
    * @return address The address of the terminal.
    */
    function terminal() public view virtual returns (address) {
        return _terminal;
    }

    /**
    * @dev Retrieves the address of a default signer based on the provided signer ID.
    * @param signerId The ID of the default signer.
    * @return address The address of the default signer.
    */
    function defaultSigners(uint256 signerId) public view virtual returns (address) {
        return _signers.at(signerId);
    }

    /**
    * @dev Retrieves the number of default signers.
    * @return uint256 The length of the default signers set.
    */
    function defaultSignersLength() public view virtual returns (uint256) {
        return _signers.length();
    }

    /**
    * @dev Checks if the provided account is a default signer.
    * @param account The address to be checked.
    * @return bool True if the account is a default signer, false otherwise.
    */
    function isDefaultSigner(address account) public view virtual returns (bool) {
        return _signers.contains(account);
    }

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
    function createMultiSigProposal(string memory caption, string memory message, address target, bytes memory data) public virtual returns (address) {
        _onlySigner();
        _deployed.push(new Base());
        uint256 id = _deployed.length - 1;
        _deployed[id].setInitialImplementation(defaultImplementation());
        IDefaultImplementation newBaseInterface = IDefaultImplementation(address(_deployed[id]));
        newBaseInterface.initialize();
        IMultiSigProposalImplementation proposal = IMultiSigProposalImplementation(address(newBaseInterface));
        for (uint256 i = 0; i < defaultSignersLength(); i++) {
            proposal.addSigner(defaultSigners(i));
        }
        proposal.setCaption(caption);
        proposal.setMessage(message);
        proposal.setCreator(msg.sender);
        proposal.setTarget(target);
        proposal.setData(data);
        proposal.setStartTimestamp(block.timestamp);
        proposal.setDuration(defaultDuration());
        proposal.setRequiredQuorum(defaultRequiredQuorum());
        proposal.setTerminal(terminal());
        proposal.setMultiSigProposalFactory(address(this));
        proposal.setReferendumProposalFactory(referendumProposalFactory());
        ITerminalImplementation terminal = ITerminalImplementation(terminal());
        terminal.grantRole(terminal.roleKey(terminal.hash("MULTI_SIG_PROPOSAL_ROLE")), address(proposal));
        emit Deployed(address(_deployed[id]));
        return address(_deployed[id]);
    }

    /**
    * @dev Adds a new address as a default signer.
    * Only the owner is allowed to perform this action.
    * @param account The address of the new default signer.
    */
    function addDefaultSigner(address account) public virtual {
        _checkOwner();
        _addDefaultSigner(account);
    }

    /**
    * @dev Removes an address from the list of default signers.
    * Only the owner is allowed to perform this action.
    * @param account The address of the default signer to be removed.
    */
    function removeDefaultSigner(address account) public virtual {
        _checkOwner();
        _removeDefaultSigner(account);
    }

    /**
    * @dev Sets a new default required quorum for multi-signature proposals.
    * Only the owner is allowed to perform this action.
    * @param bp The new default required quorum in basis points.
    */
    function setDefaultRequiredQuorum(uint256 bp) public virtual {
        _checkOwner();
        _setDefaultRequiredQuorum(bp);
    }

    /**
    * @dev Sets a new default duration for multi-signature proposals.
    * Only the owner is allowed to perform this action.
    * @param seconds_ The new default duration in seconds.
    */
    function setDefaultDuration(uint256 seconds_) public virtual {
        _checkOwner();
        _setDefaultDuration(seconds_);
    }

    /**
    * @dev Sets the address of the ReferendumProposalFactory.
    * Only the owner is allowed to perform this action.
    * @param account The address of the new ReferendumProposalFactory.
    */
    function setReferendumProposalFactory(address account) public virtual {
        _checkOwner();
        _setReferendumProposalFactory(account);
    }

    /**
    * @dev Sets the address of the terminal associated with the MultiSigProposalFactory.
    * Only the owner is allowed to perform this action.
    * @param account The address of the new terminal.
    */
    function setTerminal(address account) public virtual {
        _checkOwner();
        _setTerminal(account);
    }

    /**
    * @dev Deprecated function. Use `createMultiSigProposal` for deploying multi-signature proposals.
    * Reverts with an informative message.
    * Calls the parent implementation of the deprecated function.
    * @return address This function always reverts and does not return an address.
    */
    function deploy() public virtual override returns (address) {
        revert("MultiSigProposalFactory: deprecated use function createMultiSigProposal");
        super.deploy();
    }

    /**
    * @dev Modifier: Ensures that the sender is a default signer.
    * Reverts if the sender is not a default signer.
    */
    function _onlySigner() internal view virtual {
        require(isDefaultSigner(msg.sender), "MultiSigProposalFactory: only default signer");
    }

    /**
    * @dev Adds a new address as a default signer internally.
    * Reverts if the address is already a default signer.
    * Emits a DefaultSignerAdded event upon successful addition.
    * @param account The address of the new default signer.
    */
    function _addDefaultSigner(address account) internal virtual {
        require(!_signers.contains(account), "MultiSigProposalFactory: _signers.contains(account)");
        _signers.add(account);
        emit DefaultSignerAdded(account);
    }

    /**
    * @dev Removes an address from the list of default signers internally.
    * Reverts if the address is not a default signer.
    * Emits a DefaultSignerRemoved event upon successful removal.
    * @param account The address of the default signer to be removed.
    */
    function _removeDefaultSigner(address account) internal virtual {
        require(_signers.contains(account), "MultiSigProposalFactory: !_signers.contains(account)");
        _signers.remove(account);
        emit DefaultSignerRemoved(account);
    }

    /**
    * @dev Sets a new default required quorum for multi-signature proposals internally.
    * Reverts if the provided value is out of bounds.
    * Emits a DefaultRequiredQuorumSet event upon successful update.
    * @param bp The new default required quorum in basis points.
    */
    function _setDefaultRequiredQuorum(uint256 bp) internal virtual {
        require(bp <= 10000, "MultiSigProposalFactory: out of bounds");
        _defaultRequiredQuorum = bp;
        emit DefaultRequiredQuorumSet(bp);
    }

    /**
    * @dev Sets a new default duration for multi-signature proposals internally.
    * Emits a DefaultDurationSet event upon successful update.
    * @param seconds_ The new default duration in seconds.
    */
    function _setDefaultDuration(uint256 seconds_) internal virtual {
        _defaultDuration = seconds_;
        emit DefaultDurationSet(seconds_);
    }

    /**
    * @dev Sets the address of the ReferendumProposalFactory internally.
    * Emits a ReferendumProposalFactorySet event upon successful update.
    * @param account The address of the new ReferendumProposalFactory.
    */
    function _setReferendumProposalFactory(address account) internal virtual {
        _referendumProposalFactory = account;
        emit ReferendumProposalFactorySet(account);
    }

    /**
    * @dev Sets the address of the terminal internally.
    * Emits a TerminalSet event upon successful update.
    * @param account The address of the new terminal.
    */
    function _setTerminal(address account) internal virtual {
        _terminal = account;
        emit TerminalSet(account);
    }
}