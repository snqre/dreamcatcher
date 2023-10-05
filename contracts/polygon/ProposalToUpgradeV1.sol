// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/external/openzeppelin/access/Ownable.sol";
import "contracts/polygon/interfaces/IDream.sol";
import "contracts/polygon/interfaces/ITerminalV1.sol";

contract ProposalToUpgradeV1 is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @dev Metadata strings for the proposal.
    */
    string private _name;
    string private _caption;
    string private _message;

    /**
    * @dev Addresses related to the creator and governance ERC-20 token.
    */
    address private _creator;
    address private _governanceERC20;

    /**
    * @dev Parameters and metadata to govern the behavior of the upgrade proposal.
    */
    uint256 private _version;
    uint256 private _startTimestamp;
    uint256 private _endTimestamp;
    uint256 private _startPhasePublic;
    uint256 private _startPhaseTimelock;
    uint256 private _durationSignatureTimeout;
    uint256 private _durationTimeout;
    uint256 private _durationPublicSigVote;
    uint256 private _durationTimelock;
    uint256 private _requiredSignatureQuorum;
    uint256 private _requiredQuorum;
    uint256 private _basisToPass;

    /**
    * @dev Sets to manage the addresses of signers and collected signatures for the proposal.
    */
    EnumerableSet.AddressSet private _signers;
    EnumerableSet.AddressSet private _signatures;

    /**
    * @dev Private variables tracking the voting statistics for the proposal.
    */
    uint256 private _quorum;
    uint256 private _for;
    uint256 private _against;
    uint256 private _abstain;

    /**
    * @dev Private state variable storing the name of the proxy associated with the proposal.
    */
    string private _proxyName;

    /**
    * @dev Private state variable representing the Ethereum address of the proposed implementation contract.
    */
    address private _proposedImplementation;

    /**
    * @dev Private state variable indicating whether the contract has been initialized.
    */
    bool private _initialized;

    /**
    * @dev The unique identifier associated with the snapshot, allowing retrieval of historical balances at the time of the snapshot.
    */
    uint256 private _snapshotId;

    /**
    * @dev The timestamp associated with the snapshot ID, indicating the time at which the snapshot was taken.
    */
    uint256 private _snapshotIdTimestamp;

    /**
    * @dev A set of addresses representing voters who have participated in the current proposal.
    */
    EnumerableSet.AddressSet private _voted;

    /**
    * @dev Represents the current phase of the contract.
    */
    Phase private _phase;

    /**
    * @dev Represents the current state of a proposal.
    */
    State private _state;

    /**
    * @dev Enum representing different phases of the contract.
    * - `PRIVATE`: The contract is in the private phase.
    * - `PUBLIC`: The contract is in the public phase.
    * - `LOCKED`: The contract is in the locked phase.
    * - `EXECUTED`: The contract has been executed.
    */
    enum Phase { PRIVATE, PUBLIC, LOCKED, EXECUTED }

    /**
    * @dev Enum representing different states for proposals.
    * - `QUEUED`: The proposal is in the queued state.
    * - `REJECTED`: The proposal has been rejected.
    * - `APPROVED`: The proposal has been approved.
    * - `EXECUTED`: The proposal has been executed.
    */
    enum State { QUEUED, REJECTED, APPROVED, EXECUTED }

    /**
    * @dev Enumeration representing different voting options in a proposal.
    * - `FOR`: Indicates a vote in favor of the proposal.
    * - `AGAINST`: Indicates a vote against the proposal.
    * - `ABSTAIN`: Indicates an abstention from voting on the proposal.
    */
    enum Side { FOR, AGAINST, ABSTAIN }

    /**
    * @dev Modifier to ensure that the current phase is set to PRIVATE.
    * @notice Reverts if the current phase is not PRIVATE.
    */
    modifier onlyWhenPrivate() {
        _onlyWhenPrivate();
        _;
    }

    /**
    * @dev Modifier to ensure that the current phase is set to PUBLIC.
    * @notice Reverts if the current phase is not PUBLIC.
    */
    modifier onlyWhenPublic() {
        _onlyWhenPublic();
        _;
    }

    /**
    * @dev Modifier to ensure that the current phase is set to LOCKED.
    * @notice Reverts if the current phase is not LOCKED.
    */
    modifier onlyWhenLocked() {
        _onlyWhenLocked();
        _;
    }

    /**
    * @dev Modifier to check if the proposal is in the 'QUEUED' state.
    * @notice Throws an error if the proposal is not in the 'QUEUED' state.
    */
    modifier onlyWhenQueued() {
        _onlyWhenQueued();
        _;
    }

    /**
    * @dev Modifier to check if the proposal is in the 'REJECTED' state.
    * @notice Throws an error if the proposal is not in the 'REJECTED' state.
    */
    modifier onlyWhenRejected() {
        _onlyWhenRejected();
        _;
    }

    /**
    * @dev Modifier to check if the proposal is in the 'APPROVED' state.
    * @notice Throws an error if the proposal is not in the 'APPROVED' state.
    */
    modifier onlyWhenPassed() {
        _onlyWhenPassed();
        _;
    }

    /**
    * @dev Modifier to enforce that a function can only be executed when the number of collected signatures meets the required signature quorum.
    * @notice Throws an error if the required signature quorum is set to an invalid value or if the collected signatures are below the required threshold.
    */
    modifier onlyWhenEnoughSignatureQuorum() {
        _onlyWhenEnoughSignatureQuorum();
        _;
    }

    /**
    * @dev Modifier to enforce that a function can only be executed when the governance quorum is met.
    * @notice Throws an error if the required quorum is set to an invalid value or if the governance quorum is below the required threshold.
    */
    modifier onlyWhenEnoughQuorum() {
        _onlyWhenEnoughQuorum();
        _;
    }

    /**
    * @dev Modifier to enforce that a function can only be executed when the required number of votes is met.
    * @notice Throws an error if the required votes or the total votes are set to invalid values, or if the total votes are below the required threshold.
    */
    modifier onlyWhenEnoughVotes() {
        _onlyWhenEnoughVotes();
        _;
    }

    /**
    * @dev Modifier to restrict access to only signers of the proposal.
    */
    modifier onlySigner() {
        _onlySigner();
        _;
    }

    /**
    * @dev Modifier to allow execution only if the sender has signed the proposal.
    */
    modifier onlySigned() {
        _onlySigned();
        _;
    }

    /**
    * @dev Modifier to allow execution only if the sender has not signed the proposal.
    */
    modifier onlynotSigned() {
        _onlynotSigned();
        _;
    }

    /**
    * @dev Modifier to check that the current action is allowed only when the signature timeout has not occurred.
    * The signature timeout is the period during which signers can submit their signatures. This modifier ensures
    * that the current action is not performed after the signature timeout has passed.
    */
    modifier onlynotSignatureTimedout() {
        _onlynotSignatureTimedout();
        _;
    }

    /**
    * @dev Modifier that checks if the current phase has not timed out.
    * Requirements:
    * - The current phase must not have timed out based on the specified timeout duration.
    */
    modifier onlynotTimedout() {
        _onlynotTimedout();
        _;
    }

    /**
    * @dev Modifier that checks if the current phase is after the timelock period.
    * Requirements:
    * - The current phase must be after the timelock period.
    */
    modifier onlyAfterTimelock() {
        _onlyAfterTimelock();
        _;
    }

    /**
    * @dev Modifier that checks if the sender has not voted in the current proposal.
    * Requirements:
    * - The sender must not have voted in the current proposal.
    */
    modifier onlynotVoted() {
        _onlynotVoted();
        _;
    }

    /**
    * @dev Modifier to ensure that the function can only be called when the contract is not yet initialized.
    * @notice Reverts if the contract is already initialized.
    */
    modifier onlynotInitialized() {
        _onlynotInitialized();
        _;
    }

    /**
    * @dev Modifier to ensure that the function can only be called when the contract is already initialized.
    * @notice Reverts if the contract is not yet initialized.
    */
    modifier onlyWhenInitialized() {
        _onlyWhenInitialized();
        _;
    }

    /**
    * @dev Emitted when a signer successfully adds their signature to the proposal.
    * @param signer The address of the account that signed the proposal.
    */
    event Signed(address indexed signer);
    
    /**
    * @dev Emitted when a proposal transitions to a new phase, marking the initialization of that phase.
    * The event provides information about the newly initialized phase.
    * - `phase`: The newly initialized phase, represented by the `Phase` enum.
    */
    event PhaseInitialized(Phase indexed phase);

    /**
    * @dev Emitted when a proposal is successfully executed, resulting in an upgrade of the specified proxy to the proposed implementation.
    * The event provides information about the executed proposal.
    * - `proxyName`: The name of the proxy that underwent the upgrade.
    * - `proposedImplementation`: The address of the proposed implementation contract that was executed.
    */
    event ProposalExecuted(string indexed proxyName, address proposedImplementation);

    /**
    * @notice Emitted when a new signer is added to the list of signers.
    * @dev This event is emitted when the `_addSigner` function successfully adds a signer.
    * @param signer The address of the added signer.
    * @dev Example usage:
    * ```
    * emit SignerAdded(signerAddress);
    * ```
    */
    event SignerAdded(address indexed signer);

    /**
    * @notice Emitted when a voter casts their votes on a proposal.
    * @dev This event is emitted when the `_vote` function is successfully executed.
    * @param voter The address of the voter.
    * @param votes The number of votes cast by the voter.
    * @param side The side of the vote (e.g., For, Against).
    * @dev Example usage:
    * ```
    * emit Voted(voterAddress, numberOfVotes, Side.For);
    * ```
    */
    event Voted(address indexed voter, uint256 indexed votes, Side indexed side);

    /**
    * @dev Contract constructor to initialize the proposal with essential parameters.
    * @param caption The caption associated with the proposal.
    * @param message The message associated with the proposal.
    * @param creator The address of the creator/initiator of the proposal.
    * @param proxyName The name of the proxy associated with this proposal.
    * @param proposedImplementation The proposed implementation address associated with this proposal.
    */
    constructor(string memory caption, string memory message, address creator, string memory proxyName, address proposedImplementation, address[] memory signers) Ownable(msg.sender) {
        _phase = Phase.PRIVATE;
        _state = State.QUEUED;
        _governanceERC20 = 0xC5C23B6c3B8A15340d9BB99F07a1190f16Ebb125;
        _snapshotId = IDream(governanceERC20()).snapshot();
        _snapshotIdTimestamp = block.timestamp;
        _caption = caption;
        _message = message;
        _creator = creator;
        _proxyName = proxyName;
        _proposedImplementation = proposedImplementation;
        for (uint256 i = 0; i < signers.length; i++) {
            _addSigner(signers[i]);
        }
    }

    /**
    * @dev Retrieves the address of the governance ERC-20 token.
    * @return The address of the governance ERC-20 token.
    */
    function governanceERC20() public view returns (address) {
        return _governanceERC20;
    }

    /**
    * @dev Retrieves the current phase of the contract.
    * @return The current phase (PRIVATE, PUBLIC, LOCKED, or EXECUTED).
    */
    function phase() public view returns (Phase) {
        return _phase;
    }

    /**
    * @dev Retrieves the current state of the contract.
    * @return The current state (QUEUED, REJECTED, APPROVED, or EXECUTED).
    */
    function state() public view returns (State) {
        return _state;
    }

    /**
    * @dev Retrieves the required signature quorum percentage for private phase proposals.
    * @return The required signature quorum percentage.
    *
    * NOTE 100% => 10000.
    */
    function requiredSignatureQuorum() public view returns (uint256) {
        return _requiredSignatureQuorum;
    }

    /**
    * @dev Retrieves the array of addresses representing signers in the proposal.
    * @return An array of signer addresses.
    */
    function signers() public view returns (address[] memory) {
        return _signers.values();
    }

    /**
    * @dev Retrieves the number of signers in the proposal.
    * @return The number of signers.
    */
    function signersLength() public view returns (uint256) {
        return _signers.length();
    }

    /**
    * @dev Checks whether an account is a signer for the proposal.
    * @param account The address of the account to check.
    * @return A boolean indicating whether the account is a signer.
    */
    function isSigner(address account) public view returns (bool) {
        return _signers.contains(account);
    }

    /**
    * @dev Retrieves the addresses of signers who have provided their signatures for the proposal.
    * @return An array of signer addresses.
    */
    function signatures() public view returns (address[] memory) {
        return _signatures.values();
    }

    /**
    * @dev Retrieves the number of signers who have provided their signatures for the proposal.
    * @return The length of the signers array.
    */
    function signaturesLength() public view returns (uint256) {
        return _signatures.length();
    }

    /**
    * @dev Checks whether an account has already signed the proposal.
    * @param account The address to check.
    * @return A boolean indicating whether the account has signed.
    */
    function hasSigned(address account) public view returns (bool) {
        return _signatures.contains(account);
    }

    /**
    * @dev Retrieves the required quorum percentage for the proposal to be considered valid.
    * @return The required quorum percentage.
    */
    function requiredQuorum() public view returns (uint256) {
        return _requiredQuorum;
    }

    /**
    * @dev Retrieves the total number of votes cast for the proposal.
    * @return The total number of votes, including those for, against, and abstaining.
    */
    function quorum() public view returns (uint256) {
        return _quorum;
    }

    /**
    * @dev Retrieves the total number of votes in favor of the proposal.
    * @return The number of votes cast in favor.
    */
    function for_() public view returns (uint256) {
        return _for;
    }

    /**
    * @dev Retrieves the total number of votes against the proposal.
    * @return The number of votes cast against.
    */
    function against() public view returns (uint256) {
        return _against;
    }

    /**
    * @dev Retrieves the total number of abstain votes for the proposal.
    * @return The number of abstain votes cast.
    */
    function abstain() public view returns (uint256) {
        return _abstain;
    }

    /**
    * @dev Retrieves the basis (percentage) required for the proposal to pass.
    * @return The required basis to pass the proposal.
    *
    * NOTE 100% => 10000.
    */
    function basisToPass() public view returns (uint256) {
        return _basisToPass;
    }

    /**
    * @dev Calculates and retrieves the basis (percentage) of support for the proposal.
    * @return The basis of support for the proposal.
    */
    function basis() public view returns (uint256) {
        IDream dream = IDream(governanceERC20());
        uint256 required
        = (dream.totalSupplyAt(snapshotId()) * requiredQuorum()) / 10000;
        return (for_() * 10000) / dream.totalSupplyAt(snapshotId());
    }

    /**
    * @dev Returns the timestamp when the proposal was started.
    * @return The timestamp indicating when the proposal was initiated.
    */
    function startTimestamp() public view returns (uint256) {
        return _startTimestamp;
    }

    /**
    * @dev Returns the timestamp when the proposal is scheduled to end.
    * @return The timestamp indicating when the proposal is expected to conclude.
    */
    function endTimestamp() public view returns (uint256) {
        return _endTimestamp;
    }

    /**
    * @dev Returns the duration of the signature timeout for the proposal.
    * @return The duration, in seconds, for which signatures are accepted after the proposal starts.
    */
    function durationSignatureTimeout() public view returns (uint256) {
        return _durationSignatureTimeout;
    }

    /**
    * @dev Returns the total duration of the private signature voting phase.
    * @return The total duration, in seconds, from the start of the proposal to its end.
    */
    function durationTimeout() public view returns (uint256) {
        return _durationTimeout;
    }

    /**
    * @dev Returns the duration of the public signature voting phase.
    * @return The duration, in seconds, during which the public can vote by signing the proposal.
    */
    function durationPublicSigVote() public view returns (uint256) {
        return _durationPublicSigVote;
    }

    /**
    * @dev Retrieves the name of the proxy associated with this proposal.
    * @return The name of the proxy.
    */
    function proxyName() public view returns (string memory) {
        return _proxyName;
    }

    /**
    * @dev Retrieves the proposed implementation address associated with this proposal.
    * @return The proposed implementation address.
    */
    function proposedImplementation() public view returns (address) {
        return _proposedImplementation;
    }

    /**
    * @dev Retrieves the timestamp when the public phase of the proposal was initialized.
    * @return The timestamp when the public phase started.
    */
    function startPhasePublic() public view returns (uint256) {
        return _startPhasePublic;
    }

    /**
    * @dev Retrieves the timestamp when the timelock phase of the proposal was initialized.
    * @return The timestamp when the timelock phase started.
    */
    function startPhaseTimelock() public view returns (uint256) {
        return _startPhaseTimelock;
    }

    /**
    * @dev Retrieves the version number associated with the proposal.
    * @return The version number of the proposal.
    */
    function version() public view returns (uint256) {
        return _version;
    }

    /**
    * @dev Retrieves the caption associated with the proposal.
    * @return The caption string of the proposal.
    */
    function caption() public view returns (string memory) {
        return _caption;
    }

    /**
    * @dev Retrieves the message associated with the proposal.
    * @return The message string of the proposal.
    */
    function message() public view returns (string memory) {
        return _message;
    }

    /**
    * @dev Retrieves the address of the creator/initiator of the proposal.
    * @return The address of the proposal creator.
    */
    function creator() public view returns (address) {
        return _creator;
    }

    /**
    * @dev Retrieves the snapshot ID associated with the proposal.
    * @return The unique snapshot ID for tracking state at the time of proposal creation.
    */
    function snapshotId() public view returns (uint256) {
        return _snapshotId;
    }

    /**
    * @dev Retrieves the timestamp associated with the snapshot used for the proposal.
    * @return The Unix timestamp when the snapshot was taken for tracking state at the time of proposal creation.
    */
    function snapshotIdTimestamp() public view returns (uint256) {
        return _snapshotIdTimestamp;
    }

    /**
    * @notice Retrieves the addresses of all accounts that have voted in the current proposal.
    * @return An array of addresses representing accounts that have participated in the voting.
    */
    function voted() public view returns (address[] memory) {
        return _voted.values();
    }

    /**
    * @notice Checks whether a specific account has already voted in the current proposal.
    * @param account The address of the account to check for voting status.
    * @return A boolean indicating whether the account has voted in the current proposal.
    */
    function hasVoted(address account) public view returns (bool) {
        return _voted.contains(account);
    }

    /**
    * @notice Checks whether the upgrade proposal has been initialized.
    * @return A boolean indicating whether the proposal has been initialized.
    * @dev Once the proposal is initialized, certain configuration parameters are set,
    *      and further initialization attempts will be rejected.
    */
    function initialized() public view returns (bool) {
        return _initialized;
    }

    /**
    * @dev Retrieves the duration of the timelock phase.
    * @return uint256 Duration of the timelock phase.
    */
    function durationTimelock() public view returns (uint256) {
        return _durationTimelock();
    }

    /**
    * @dev Calculates the remaining seconds until the signature timeout.
    * @return uint256 Remaining seconds until signature timeout.
    */
    function secondsUntilSignatureTimeout() public view returns (uint256) {
        return (startTimestamp() + durationSignatureTimeout()) - block.timestamp;
    }

    /**
    * @dev Calculates the remaining seconds until the timeout.
    * @return uint256 Remaining seconds until timeout.
    */
    function secondsUntilTimeout() public view returns (uint256) {
        return (startPhasePublic() + durationTimeout()) - block.timestamp;
    }

    /**
    * @dev Calculates the remaining seconds until the end of the timelock phase.
    * @return uint256 Remaining seconds until the end of the timelock phase.
    */
    function secondsUntilEndTimelock() public view returns (uint256) {
        return (startPhaseTimelock() + durationTimelock()) - block.timestamp;
    }

    /** Initialize */

    /**
    * @notice Initializes the upgrade proposal with specified parameters.
    * @dev This function is restricted to the contract owner and can only be called once during the contract's initialization.
    * @param durationSignatureTimeout The duration, in seconds, allowed for collecting required signatures.
    * @param durationTimeout The overall duration, in seconds, for the entire proposal process.
    * @param durationPublicSigVote The duration, in seconds, for the public voting phase.
    * @param durationTimelock The duration, in seconds, for the timelock phase after successful execution.
    * @param requiredSignatureQuorum The minimum percentage of required signatures for the proposal to be valid (<= 10000).
    * @param requiredQuorum The minimum percentage of total votes needed to pass the proposal (<= 10000).
    * @param basisToPass The percentage basis required for the proposal to pass (<= 10000).
    * @dev The sum of requiredSignatureQuorum, requiredQuorum, and basisToPass should not exceed 10000.
    * @dev After initialization, this function cannot be called again.
    */
    function initialize(uint256 durationSignatureTimeout, uint256 durationTimeout, uint256 durationPublicSigVote, uint256 durationTimelock, uint256 requiredSignatureQuorum, uint256 requiredQuorum, uint256 basisToPass) public onlyOwner() onlynotInitialized() {
        require(
            requiredSignatureQuorum <= 10000,
            "ProposalToUpgradeV1: requiredSignatureQuorum > 10000"
        );
        require(
            requiredQuorum <= 10000,
            "ProposalToUpgradeV1: requiredQuorum > 10000"
        );
        require(
            basisToPass <= 10000,
            "ProposalToUpgradeV1: basisToPass > 10000"
        );
        _durationSignatureTimeout = durationSignatureTimeout;
        _durationTimeout = durationTimeout;
        _durationPublicSigVote = durationPublicSigVote;
        _durationTimelock = durationTimelock;
        _requiredSignatureQuorum = requiredSignatureQuorum;
        _requiredQuorum = requiredQuorum;
        _basisToPass = basisToPass;
        _startTimestamp = block.timestamp;
        _initialized = true;
    }

    /** Multi Sig Interactions. */

    /**
    * @dev Allows a signer to add their signature to the proposal.
    * Emits a `Signed` event upon successful signature.
    * Requirements:
    * - Sender must be a signer.
    * - Sender must not have already signed the proposal.
    * - Proposal must be in the "Queued" and "Private" phase.
    */
    function sign() public onlySigner() onlynotSigned() onlyWhenQueued() onlyWhenPrivate() onlyWhenInitialized() {
        _signatures.add(msg.sender);
        emit Signed(msg.sender);
    }

    /** Public Sig Interactions. */

    /**
    * @dev Allows a token holder to cast their vote on the proposal during the public voting phase.
    * @param side The vote side (FOR, AGAINST, or ABSTAIN) chosen by the voter.
    * Requirements:
    * - The proposal must be in the public voting phase.
    * - The public voting phase must not have timed out.
    * - The voter has not voted before.
    */
    function vote(Side side) public onlyWhenQueued() onlyWhenPublic() onlynotTimedout() onlynotVoted() onlyWhenInitialized() {
        _voted.add(msg.sender);
        IDream dream = IDream(governanceERC20());
        uint256 balance
        = dream.balanceOfAt(msg.sender, snapshotId());
        require(balance >= 1, "ProposalToUpgradeV1: insufficient balance at snapshot");
        _quorum += balance;
        if (side == Side.FOR) { _for += balance; }
        else if (side == Side.AGAINST) { _against += balance; }
        else if (side == Side.ABSTAIN) { _abstain += balance; }
        else { revert("ProposalToUpgradeV1: invalid input"); }
        emit Voted(msg.sender, balance, side);
    }

    /** Executions. */

    /**
    * @dev Public function to initialize the transition from the private phase to the public phase of the proposal.
    * It checks the necessary conditions for the transition, including the minimum signature quorum and the absence
    * of a timeout in the private phase. If conditions are met, it sets the proposal phase to PUBLIC and records the
    * start timestamp for the public phase.
    * Emits a `PhaseUpdated` event to signal the state change and a `PhaseInitialized` event with the updated phase.
    */
    function initializePhasePublic() public onlyWhenQueued() onlyWhenPrivate() onlyWhenEnoughSignatureQuorum() onlynotSignatureTimedout() onlyWhenInitialized() {
        _phase = Phase.PUBLIC;
        _startPhasePublic = block.timestamp;
        emit PhaseInitialized(phase());
    }

    /**
    * @dev Public function to finalize the proposal, transitioning it from the public phase to the locked phase.
    * It checks the necessary conditions for the transition, including the minimum quorum and votes. If conditions are met,
    * it sets the proposal state to APPROVED, the phase to LOCKED, and records the start timestamp for the timelock phase.
    * Emits a `PhaseUpdated` event to signal the state change and a `PhaseInitialized` event with the updated phase.
    */
    function initializePhaseTimelock() public onlyWhenQueued() onlyWhenPublic() onlyWhenEnoughQuorum() onlyWhenEnoughVotes() onlynotTimedout() onlyWhenInitialized() {
        _state = State.APPROVED;
        _phase = Phase.LOCKED;
        _startPhaseTimelock = block.timestamp;
        emit PhaseInitialized(phase());
    }

    /**
    * @dev Public function to finalize the proposal, transitioning it from the locked phase to the executed phase.
    * It checks the necessary conditions for the transition, including the passage of time beyond the timelock duration.
    * If conditions are met, it sets the proposal state to EXECUTED, the phase to EXECUTED, and records the end timestamp.
    * Additionally, it triggers the upgrade of the associated proxy to the proposed implementation.
    * Emits a `ProposalExecuted` event with details about the executed proposal.
    */
    function initializePhaseExecuted() public onlyWhenPassed() onlyWhenLocked() onlyAfterTimelock() onlyWhenInitialized() {
        _state = State.EXECUTED;
        _phase = Phase.EXECUTED;
        _endTimestamp = block.timestamp;
        ITerminalV1(0xd59431E364531e9f627c4B8065Ed13b62326810b).upgradeTo(proxyName(), proposedImplementation());
        emit ProposalExecuted(proxyName(), proposedImplementation());
    }

    /** Flags. */

    /**
    * @dev Modifier to ensure that the current phase is set to PRIVATE.
    * @notice Reverts if the current phase is not PRIVATE.
    */
    function _onlyWhenPrivate() internal view {
        require(
            phase() == Phase.PRIVATE,
            "ProposalToUpgradeV1: phase() !PRIVATE"
        );
    }

    /**
    * @dev Modifier to ensure that the current phase is set to PUBLIC.
    * @notice Reverts if the current phase is not PUBLIC.
    */
    function _onlyWhenPublic() internal view {
        require(
            phase() == Phase.PUBLIC,
            "ProposalToUpgradeV1: phase() !PUBLIC"
        );
    }

    /**
    * @dev Modifier to ensure that the current phase is set to LOCKED.
    * @notice Reverts if the current phase is not LOCKED.
    */
    function _onlyWhenLocked() internal view {
        require(
            phase() == Phase.LOCKED,
            "ProposalToUpgradeV1: phase() !LOCKED"
        );
    }

    /**
    * @dev Modifier to check if the proposal is in the 'QUEUED' state.
    * @notice Throws an error if the proposal is not in the 'QUEUED' state.
    */
    function _onlyWhenQueued() internal view {
        require(
            state() == State.QUEUED,
            "ProposalToUpgradeV1: state() !QUEUED"
        );
    }

    /**
    * @dev Modifier to check if the proposal is in the 'REJECTED' state.
    * @notice Throws an error if the proposal is not in the 'REJECTED' state.
    */
    function _onlyWhenRejected() internal view {
        require(
            state() == State.REJECTED,
            "ProposalToUpgradeV1: state() !REJECTED"
        );
    }

    /**
    * @dev Modifier to check if the proposal is in the 'APPROVED' state.
    * @notice Throws an error if the proposal is not in the 'APPROVED' state.
    */
    function _onlyWhenPassed() internal view {
        require(
            state() == State.APPROVED,
            "ProposalToUpgradeV1: state() !APPROVED"
        );
    }

    /**
    * @dev Internal function to check if the number of collected signatures meets the required quorum.
    * @notice Throws an error if the required signature quorum is set to an invalid value or if the number of signatures is below the required quorum.
    */
    function _onlyWhenEnoughSignatureQuorum() internal view {
        require(requiredSignatureQuorum() <= 10000, "ProposalToUpgradeV1: _requiredSignatureQuorum > 10000");
        uint256 required
        = (signersLength() * requiredSignatureQuorum()) / 10000;
        require(
            signaturesLength() >= required,
            "ProposalToUpgradeV1: signaturesLength() insufficient"
        );
    }

    /**
    * @dev Internal function to check if the current quorum meets the required threshold.
    * @notice Throws an error if the required quorum threshold is set to an invalid value or if the current quorum is below the required threshold.
    */
    function _onlyWhenEnoughQuorum() internal view {
        require(requiredQuorum() <= 10000, "ProposalToUpgradeV1: _requiredQuorum > 10000");
        IDream dream = IDream(governanceERC20());
        uint256 required
        = (dream.totalSupply() * requiredQuorum()) / 10000;
        require(
            quorum() >= required,
            "ProposalToUpgradeV1: quorum() insufficient"
        );
    }

    /**
    * @dev Checks whether the current voting basis meets the required basis to pass the proposal.
    * @dev Throws an error if the basis is insufficient.
    */
    function _onlyWhenEnoughVotes() internal view onlyWhenEnoughQuorum() {
        require(
            basis() >= basisToPass(),
            "ProposalToUpgradeV1: basis() insufficient"
        );
    }

    /**
    * @dev Modifier to restrict access to only signers of the proposal.
    */
    function _onlySigner() internal view {
        require(isSigner(msg.sender), "ProposalToUpgradeV1: msg.sender !signer");
    }

    /**
    * @dev Modifier to allow execution only if the sender has signed the proposal.
    */
    function _onlySigned() internal view {
        require(hasSigned(msg.sender), "ProposalToUpgradeV1: msg.sender !hasSigned");
    }

    /**
    * @dev Modifier to allow execution only if the sender has not signed the proposal.
    */
    function _onlynotSigned() internal view {
        require(!hasSigned(msg.sender), "ProposalToUpgradeV1: msg.sender hasSigned");
    }

    /**
    * @dev Internal function used as a modifier to ensure that the current action is allowed only when
    * the signature timeout has not occurred during the private phase of the proposal. It checks whether
    * the current block timestamp is within the allowed duration for signers to submit their signatures.
    * Throws an error if the private phase has timed out.
    */
    function _onlynotSignatureTimedout() internal view onlyWhenQueued() onlyWhenPrivate() {
        require(
            block.timestamp < startTimestamp() + durationSignatureTimeout(),
            "ProposalToUpgradeV1: private phase timedout"
        );
    }

    /**
    * @dev Internal function used as a modifier to ensure that the current action is allowed only when
    * the timeout has not occurred during the public phase of the proposal. It checks whether the current
    * block timestamp is within the allowed duration for the public phase. Throws an error if the public
    * phase has timed out.
    */
    function _onlynotTimedout() internal view onlyWhenQueued() onlyWhenPublic() {
        require(
            block.timestamp < startPhasePublic() + durationTimeout(),
            "ProposalToUpgradeV1: public phase timedout"
        );
    }

    /**
    * @dev Internal function used as a modifier to ensure that the current action is allowed only after
    * the timelock has passed following the successful execution of the proposal. It checks whether the
    * current block timestamp is greater than the calculated end timestamp for the timelock. Throws an
    * error if the proposal is still within the timelock period.
    */
    function _onlyAfterTimelock() internal view onlyWhenPassed() onlyWhenLocked() {
        require(
            block.timestamp > startPhaseTimelock() + _durationTimelock,
            "ProposalToUpgradeV1: timelocked"
        );
    }

    /**
    * @dev Modifier that checks if the caller has not voted in the current voting phase.
    * Requirements:
    * - The caller must not have voted before in the current voting phase.
    */
    function _onlynotVoted() internal view {
        require(!hasVoted(msg.sender), "ProposalToUpgradeV1: msg.sender hasVoted()");
    }

    /**
    * @dev Internal function modifier to ensure that the proposal has not been initialized yet.
    * Throws an error if the proposal has already been initialized.
    */
    function _onlynotInitialized() internal view {
        require(!initialized(), "ProposalToUpgradeV1: !initialized()");
    }

    /**
    * @dev Internal function modifier to ensure that the proposal has been initialized.
    * Throws an error if the proposal has not been initialized.
    */
    function _onlyWhenInitialized() internal view {
        require(initialized(), "ProposalToUpgradeV1: initialized()");
    }

    /** Internal. */

    /**
    * @dev Adds a new signer to the proposal.
    * @param account The address of the signer to be added.
    * @dev Throws an error if the signer is already added.
    */
    function _addSigner(address account) internal {
        require(!isSigner(account), "ProposalToUpgradeV1: duplicate signer");
        _signers.add(account);
        emit SignerAdded(account);
    }
}