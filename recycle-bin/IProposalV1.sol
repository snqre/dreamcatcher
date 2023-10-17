// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
* @dev Override _execute function to perform action after the proposal
*      has finished and successfully passed its lifecyle.
*      Modify as required.
 */
interface IProposalV1 {

    /**
    * @enum Phase
    * @notice An enumeration representing the different phases that a proposal can go through in a governance system.
    * @dev Proposals typically progress through PRIVATE, PUBLIC, and PASSED phases.
    *
    * Enum Values:
    * - PRIVATE: Indicates the initial phase where a proposal is in a private or pre-voting stage.
    * - PUBLIC: Indicates the phase when a proposal becomes public and open for voting by the community.
    * - PASSED: Indicates that a proposal has successfully passed the voting and approval process.
    *
    * This enum is commonly used in governance contracts to track and communicate the current phase of a proposal's lifecycle.
    */
    enum Phase { PRIVATE, PUBLIC, PASSED }

    /**
    * @enum Side
    * @notice An enumeration representing the different sides or positions that voters can take in a proposal.
    * @dev Voters can choose to SUPPORT, AGAINST, or ABSTAIN from a proposal.
    *
    * Enum Values:
    * - SUPPORT: Indicates a positive stance or support for the proposal.
    * - AGAINST: Indicates a negative stance or opposition to the proposal.
    * - ABSTAIN: Indicates a neutral stance, neither supporting nor opposing the proposal.
    *
    * This enum is commonly used in governance systems to capture the various positions
    * that voters can take during the voting phase of a proposal.
    */
    enum Side { SUPPORT, AGAINST, ABSTAIN }

    /**
    * @dev Emitted when the start timestamp of the Multi-Signature (MSig) period is set to a new value.
    * @param value The new start timestamp of the MSig period.
    * 
    * This event signals that the start timestamp of the MSig period for the proposal has been updated to a new value.
    */
    event MSigStartTimestampSetTo(uint64 indexed value);

    /**
    * @dev Emitted when the end timestamp of the Multi-Signature (MSig) period is set to a new value.
    * @param value The new end timestamp of the MSig period.
    * 
    * This event signals that the end timestamp of the MSig period for the proposal has been updated to a new value.
    */
    event MSigEndTimestampSetTo(uint64 indexed value);

    /**
    * @dev Emitted when the duration of the Multi-Signature (MSig) period is set to a new value.
    * @param value The new duration of the MSig period.
    * 
    * This event signals that the duration of the MSig period for the proposal has been updated to a new value.
    */
    event MSigDurationSetTo(uint64 indexed value);

    /**
    * @dev Emitted when the Multi-Signature (MSig) timer has been set.
    * 
    * This event signals that the MSig timer for the proposal has been successfully toggled, indicating that it has been set.
    */
    event MSigTimerHasBeenSetToggled();

    /**
    * @dev Emitted when the Multi-Signature (MSig) timer is initialized.
    * @param startTimestamp The start timestamp of the MSig period.
    * @param endTimestamp The end timestamp of the MSig period.
    * @param duration The duration of the MSig period.
    * 
    * This event signals that the MSig timer for the proposal has been successfully initialized.
    */
    event MSigTimerInitialized(uint64 indexed startTimestamp, uint64 indexed endTimestamp, uint64 indexed duration);

    /**
    * @dev Emitted when the start timestamp of the Public Signature (PSig) period is set to a new value.
    * @param value The new start timestamp of the PSig period.
    * 
    * This event signals that the start timestamp of the PSig period for the proposal has been updated to a new value.
    */
    event PSigStartTimestampSetTo(uint64 indexed value);

    /**
    * @dev Emitted when the end timestamp of the Public Signature (PSig) period is set to a new value.
    * @param value The new end timestamp of the PSig period.
    * 
    * This event signals that the end timestamp of the PSig period for the proposal has been updated to a new value.
    */
    event PSigEndTimestampSetTo(uint64 indexed value);

    /**
    * @dev Emitted when the duration of the Public Signature (PSig) period is set to a new value.
    * @param value The new duration of the PSig period.
    * 
    * This event signals that the duration of the PSig period for the proposal has been updated to a new value.
    */
    event PSigDurationSetTo(uint64 indexed value);

    /**
    * @dev Emitted when the Public Signature (PSig) timer has been set.
    * 
    * This event signals that the PSig timer for the proposal has been successfully toggled, indicating that it has been set.
    */
    event PSigTimerHasBeenSetToggled();

    /**
    * @dev Emitted when the Public Signature (PSig) timer is initialized.
    * @param startTimestamp The start timestamp of the PSig period.
    * @param endTimestamp The end timestamp of the PSig period.
    * @param duration The duration of the PSig period.
    * 
    * This event signals that the PSig timer for the proposal has been successfully initialized.
    */
    event PSigTimerInitialized(uint64 indexed startTimestamp, uint64 indexed endTimestamp, uint64 indexed duration);

    /**
    * @dev Emitted when the start timestamp of the timelock period is set to a new value.
    * @param value The new start timestamp of the timelock period.
    * 
    * This event signals that the start timestamp of the timelock period for the proposal has been updated to a new value.
    */
    event TimelockStartTimestampSetTo(uint64 indexed value);

    /**
    * @dev Emitted when the end timestamp of the timelock period is set to a new value.
    * @param value The new end timestamp of the timelock period.
    * 
    * This event signals that the end timestamp of the timelock period for the proposal has been updated to a new value.
    */
    event TimelockEndTimestampSetTo(uint64 indexed value);

    /**
    * @dev Emitted when the timelock duration is set to a new value.
    * @param value The new duration of the timelock period.
    * 
    * This event signals that the duration of the timelock period for the proposal has been updated to a new value.
    */
    event TimelockDurationSetTo(uint64 indexed value);

    /**
    * @dev Emitted when the timelock timer has been set.
    * 
    * This event signals that the timelock timer for the proposal has been successfully toggled, indicating that it has been set.
    */
    event TimelockTimerHasBeenSetToggled();

    /**
    * @dev Emitted when the timelock timer is initialized.
    * @param startTimestamp The start timestamp of the timelock period.
    * @param endTimestamp The end timestamp of the timelock period.
    * @param duration The duration of the timelock period.
    * 
    * This event signals that the timelock timer for the proposal has been successfully initialized.
    */
    event TimelockTimerInitialized(uint64 indexed startTimestamp, uint64 indexed endTimestamp, uint64 indexed duration);

    /**
    * @dev Emitted when the caption text is set to a new value.
    * @param text The new caption text.
    * 
    * This event signals that the caption text for the proposal has been updated to a new value.
    */
    event CaptionSetTo(string indexed text);

    /**
    * @dev Emitted when the message text is set to a new value.
    * @param text The new message text.
    * 
    * This event signals that the message text for the proposal has been updated to a new value.
    */
    event MessageSetTo(string indexed text);

    /**
    * @dev Emitted when the creator address is set to a new value.
    * @param account The new address of the creator.
    * 
    * This event signals that the creator address for the proposal has been updated to a new value.
    */
    event CreatorSetTo(address indexed account);

    /**
    * @dev Emitted when the voting ERC20 token address is set to a new value.
    * @param account The new address of the voting ERC20 token.
    * 
    * This event signals that the voting ERC20 token for the proposal has been updated to a new address.
    */
    event VotingERC20SetTo(address indexed account);

    /**
    * @dev Emitted when a new signer is added to the multi-signature process.
    * @param account The address of the new signer added to the process.
    * 
    * This event signals that a new signer has been included in the multi-signature process for the proposal.
    */
    event SignerAdded(address indexed account);

    /**
    * @dev Emitted when a signer adds their signature to the proposal.
    * @param account The address of the signer who added their signature.
    * 
    * This event signals that a signer has participated in the signature process for the proposal.
    */
    event Signed(address indexed account);

    /**
    * @dev Emitted when a voter casts a vote in the proposal.
    * @param account The address of the voter who cast a vote.
    * 
    * This event signals that a voter has participated in the voting process for the proposal.
    */
    event Voted(address indexed account);

    /**
    * @dev Emitted when the phase of the proposal is set to a new value.
    * @param phase The new phase of the proposal (Private, Public, Passed).
    * 
    * This event signals a change in the phase of the proposal.
    */
    event PhaseSetTo(Phase indexed phase);

    /**
    * @dev Emitted when the number of support votes changes.
    * @param oldSupport The previous number of support votes.
    * @param newSupport The updated number of support votes.
    * 
    * This event signals a change in the count of support votes for the proposal.
    */
    event Supported(uint256 indexed oldSupport, uint256 indexed newSupport);

    /**
    * @dev Emitted when the number of against votes changes.
    * @param oldAgainst The previous number of against votes.
    * @param newAgainst The updated number of against votes.
    * 
    * This event signals a change in the count of against votes for the proposal.
    */
    event Rejected(uint256 indexed oldAgainst, uint256 indexed newAgainst);

    /**
    * @dev Emitted when the number of abstain votes changes.
    * @param oldAbstain The previous number of abstain votes.
    * @param newAbstain The updated number of abstain votes.
    * 
    * This event signals a change in the count of abstain votes for the proposal.
    */
    event Abstained(uint256 indexed oldAbstain, uint256 indexed newAbstain);

    /**
    * @dev Emitted when the required quorum for the multi-signature process is set to a new value.
    * @param value The new required quorum percentage for the multi-signature process.
    * 
    * This event signals that the required quorum percentage for the multi-signature process
    * in the proposal has been updated to a new value.
    */
    event MSigRequiredQuorumSetTo(uint256 indexed value);

    /**
    * @dev Emitted when the required quorum for the public signature process is set to a new value.
    * @param value The new required quorum percentage for the public signature process.
    * 
    * This event signals that the required quorum percentage for the public signature process
    * in the proposal has been updated to a new value.
    */
    event PSigRequiredQuorumSetTo(uint256 indexed value);

    /**
    * @dev Emitted when the voting threshold is set to a new value.
    * @param value The new voting threshold.
    * 
    * This event signals that the voting threshold for the proposal has been updated to a new value.
    */
    event ThresholdSetTo(uint256 indexed value);

    /**
    * @dev Emitted when the snapshot index is set to a new value.
    * @param value The new snapshot index.
    * 
    * This event signals that the snapshot index for the proposal has been updated to a new value.
    */
    event SnapshotIndexSetTo(uint256 indexed value);

    /**
    * @dev Emitted when the snapshot timestamp is set to a new value.
    * @param timestamp The new snapshot timestamp.
    * 
    * This event signals that the snapshot timestamp for the proposal has been updated to a new value.
    */
    event SnapshotTimestampSetTo(uint64 indexed timestamp);

    /**
    * @dev Emitted when a snapshot of the voting parameters is taken.
    * @param votingERC20 The address of the ERC20 token used for voting.
    * @param index The snapshot index.
    * @param timestamp The timestamp at which the snapshot is taken.
    * 
    * This event signals that a snapshot of the voting parameters, including the ERC20 token,
    * snapshot index, and timestamp, has been successfully taken for the proposal.
    */
    event Snapshotted(address indexed votingERC20, uint256 indexed index, uint64 indexed timestamp);

    /**
    * @dev Emitted when the proposal has successfully passed the Timelock phase and execution occurs.
    * 
    * This event indicates that the proposal has completed all necessary phases, including passing
    * both the Private Signature (MSig) and Public Signature (PSig) phases, and any required timelock period.
    */
    event Executed();

    /**
    * @dev Emitted when the TerminalV2 address in the metadata of a proposal is successfully set to a new value.
    *
    * This event provides a record of changes to the TerminalV2 address associated with a proposal. It is emitted
    * when the `_setTerminalV2` function is called, signifying that the TerminalV2 address in the metadata has been updated.
    *
    * @param account The new TerminalV2 address that has been set in the metadata.
    */
    event TerminalV2SetTo(address indexed account);

    /**
    * @dev Error indicating an attempt to add a duplicate signer.
    * @param account The address of the signer that already exists.
    * 
    * This error is raised when there is an attempt to add a signer that is already part of the multi-signature process.
    */
    error DuplicateSigner(address account);

    /**
    * @dev Error indicating an attempt to add a duplicate signature.
    * @param account The address of the signer whose signature already exists.
    * 
    * This error is raised when there is an attempt to add a signature from a signer who has already signed the proposal.
    */
    error DuplicateSignature(address account);

    /**
    * @dev Error indicating an attempt to add a duplicate voter.
    * @param account The address of the voter that already exists.
    * 
    * This error is raised when there is an attempt to add a voter that has already voted in the proposal.
    */
    error DuplicateVoter(address account);

    /**
    * @dev Error indicating that a value is outside the allowed bounds.
    * @param min The minimum allowed value.
    * @param max The maximum allowed value.
    * @param value The actual value that caused the error.
    * 
    * This error is typically raised when a value falls outside the acceptable range.
    */
    error OutOfBounds(uint256 min, uint256 max, uint256 value);

    /**
    * @dev Error indicating that the multi-signature quorum is insufficient.
    * @param signaturesLength The number of collected signatures.
    * @param requiredSignaturesLength The required number of signatures.
    * 
    * This error is raised when attempting to proceed with the proposal in the multi-signature phase
    * without meeting the required number of signatures.
    */
    error InsufficientMSigQuorum(uint256 signaturesLength, uint256 requiredSignaturesLength);

    /**
    * @dev Error indicating that the public signature quorum is insufficient.
    * @param quorum The total support, against, and abstain votes.
    * @param requiredQuorum The required quorum for the public signature phase.
    * 
    * This error is raised when attempting to proceed with the proposal in the public signature phase
    * without meeting the required quorum.
    */
    error InsufficientPSigQuorum(uint256 quorum, uint256 requiredQuorum);

    /**
    * @dev Error indicating that the voting threshold is not met.
    * @param requiredThreshold The required voting threshold.
    * @param threshold The actual voting threshold.
    * 
    * This error is raised when attempting to proceed with the proposal without meeting the required voting threshold.
    */
    error InsufficientThreshold(uint256 requiredThreshold, uint256 threshold);

    /**
    * @dev Error indicating unauthorized access or action.
    * @param account The address of the unauthorized account.
    * 
    * This error is raised when an account attempts an action or access that is not permitted.
    */
    error Unauthorized(address account);

    /**
    * @dev Error indicating that the action is only allowed during the Public Signature (PSig) phase.
    * @param phase The current phase of the proposal.
    * 
    * This error is raised when attempting an action that is restricted to the Public Signature (PSig) phase.
    */
    error OnlyDuringPSigPhase(Phase phase);

    /**
    * @dev Error indicating that the action is only allowed during the Multi-Signature (MSig) phase.
    * @param phase The current phase of the proposal.
    * 
    * This error is raised when attempting an action that is restricted to the Multi-Signature (MSig) phase.
    */
    error OnlyDuringMSigPhase(Phase phase);

    /**
    * @dev Error indicating that the account's balance must be positive for the action.
    * @param account The address of the account with the non-positive balance.
    * @param balanceOf The current balance of the account.
    * 
    * This error is raised when attempting an action that requires a positive balance, and the account's balance is non-positive.
    */
    error OnlyPositiveBalance(address account, uint256 balanceOf);

    /**
    * @dev Error thrown when an invalid voting side is provided.
    * 
    * This error is used when attempting to vote with an unsupported or undefined side,
    * such as a side other than Support, Against, or Abstain.
    */
    error InvalidSide(Side side);

    /**
    * @dev Error thrown when the Multi-Signature (MSig) phase timer has expired.
    * 
    * This error is used when attempting to transition from the MSig phase to the PSig phase,
    * but the MSig timer has already reached zero, indicating that the MSig phase has timed out.
    * @param secondsLeft The number of seconds remaining on the MSig timer at the time of the error.
    */
    error MSigTimedout(uint256 secondsLeft);

    /**
    * @dev Error thrown when the Public Signature (PSig) phase timer has expired.
    * 
    * This error is used when attempting to transition from the PSig phase to the Timelock phase,
    * but the PSig timer has already reached zero, indicating that the PSig phase has timed out.
    * @param secondsLeft The number of seconds remaining on the PSig timer at the time of the error.
    */
    error PSigTimedout(uint256 secondsLeft);

    /**
    * @dev Error thrown when the Timelock phase timer has not yet expired.
    * 
    * This error is used when attempting to progress to the next phase after the Timelock phase,
    * but the Timelock timer still has seconds remaining, indicating that the Timelock phase is not yet completed.
    * @param secondsLeft The number of seconds remaining on the Timelock timer at the time of the error.
    */
    error Timelock(uint256 secondsLeft);

    /**
    * @notice Retrieves the address of the ERC20 token used for voting in the proposal.
    * @dev This function returns the address stored in the metadata of the proposal,
    * representing the ERC20 token used for voting.
    * @return The address of the ERC20 token used for voting in the proposal.
    */
    function votingERC20() external view returns (address);

    /**
    * @dev Retrieves the current phase of the proposal.
    * @return The current phase of the proposal, represented as a {Phase} enum.
    */
    function phase() external view returns (Phase);

    /**
    * @dev Retrieves the caption associated with the proposal.
    * @return The caption of the proposal as a string.
    */
    function caption() external view returns (string memory);

    /**
    * @dev Retrieves the message associated with the proposal.
    * @return The message of the proposal as a string.
    */
    function message() external view returns (string memory);

    /**
    * @dev Retrieves the address of the creator of the proposal.
    * @return The address of the creator.
    */
    function creator() external view returns (address);

    /**
    * @dev Retrieves the addresses of signers who have participated in the multi-signature of the proposal.
    * @return An array containing the addresses of the signers.
    */
    function signers() external view returns (address[] memory);

    /**
    * @dev Retrieves the total number of signers who have participated in the multi-signature of the proposal.
    * @return The number of signers.
    */
    function signersLength() external view returns (uint256);

    /**
    * @dev Checks if a given address is a signer who has participated in the multi-signature of the proposal.
    * @param account The address to be checked.
    * @return True if the address is a signer, otherwise false.
    */
    function isSigner(address account) external view returns (bool);

    /**
    * @dev Retrieves the addresses of accounts that have provided signatures for the proposal.
    * @return An array containing the addresses of the signatories.
    */
    function signatures() external view returns (address[] memory);

    /**
    * @dev Retrieves the total number of signatures provided for the proposal.
    * @return The number of signatures.
    */
    function signaturesLength() external view returns (uint256);

    /**
    * @dev Calculates the number of required signatures for the multi-signature process.
    * 
    * This function computes the required number of signatures based on the length of signers
    * and the specified multi-signature required quorum percentage. The result represents the
    * minimum number of signatures needed for the proposal to proceed in the multi-signature phase.
    * 
    * @return The calculated number of required signatures.
    */
    function requiredSignaturesLength() external view returns (uint256);

    /**
    * @dev Checks if the multi-signature quorum has been met.
    * 
    * This function determines whether the number of collected signatures
    * in the multi-signature process is sufficient to meet the required quorum.
    * 
    * @return True if the multi-signature quorum is met, false otherwise.
    */
    function sufficientMSigQuorum() external view returns (bool);

    /**
    * @dev Checks if a given address has provided a signature for the proposal.
    * @param account The address to be checked.
    * @return True if the address has signed the proposal, otherwise false.
    */
    function hasSigned(address account) external view returns (bool);

    /**
    * @dev Retrieves the addresses of voters who have participated in the proposal signature.
    * @return An array containing the addresses of the voters.
    */
    function voters() external view returns (address[] memory);

    /**
    * @dev Retrieves the total number of voters who have participated in the proposal signature.
    * @return The number of voters.
    */
    function votersLength() external view returns (uint256);

    /**
    * @dev Checks if a given address has participated in voting for the proposal.
    * @param account The address to be checked.
    * @return True if the address has voted, otherwise false.
    */
    function hasVoted(address account) external view returns (bool);

    /**
    * @dev Retrieves the total level of support for the proposal.
    * @return The total support for the proposal, represented as a uint256.
    */
    function support() external view returns (uint256);

    /**
    * @dev Retrieves the total level of opposition against the proposal.
    * @return The total opposition against the proposal, represented as a uint256.
    */
    function against() external view returns (uint256);

    /**
    * @dev Retrieves the total number of abstentions for the proposal.
    * @return The total number of abstentions, represented as a uint256.
    */
    function abstain() external view returns (uint256);

    /**
    * @dev Retrieves the total number of participants considered for the quorum calculation.
    * @return The sum of supporters, opponents, and abstentions, representing the total participants.
    */
    function quorum() external view returns (uint256);

    /**
    * @notice Calculates and retrieves the required voting quorum for a proposal.
    * @dev This function calculates the required quorum by multiplying the total supply of the
    * voting ERC20 token at the snapshot index with the percentage quorum required for the proposal.
    * The result is divided by 10000 to obtain the quorum percentage as a fraction of the total supply.
    * @return The calculated required quorum for the proposal.
    */
    function requiredQuorum() external view returns (uint256);

    /**
    * @dev Checks if the public signature quorum has been met.
    * 
    * This function determines whether the total support, against, and abstain votes
    * collectively reach or exceed the required quorum for the public signature phase.
    * 
    * @return True if the public signature quorum is met, false otherwise.
    */
    function sufficientPSigQuorum() external view returns (bool);

    /**
    * @dev Retrieves the timestamp when the multi-signature process for the proposal started.
    * @return The start timestamp of the multi-signature process, represented as a uint64.
    */
    function mSigStartTimestamp() external view returns (uint64);

    /**
    * @dev Retrieves the timestamp when the multi-signature process for the proposal ended.
    * @return The end timestamp of the multi-signature process, represented as a uint64.
    */
    function mSigEndTimestamp() external view returns (uint64);

    /**
    * @dev Retrieves the duration of the multi-signature process for the proposal.
    * @return The duration of the multi-signature process, represented as a uint64.
    */
    function mSigDuration() external view returns (uint64);

    /**
    * @dev Checks if the timer for the multi-signature process is set.
    * @return True if the timer is set, otherwise false.
    */
    function mSigTimerSet() external view returns (uint64);

    /**
    * @dev Retrieves the remaining seconds left for the multi-signature process, if the timer is set.
    * @return The remaining seconds as a uint64. Returns 0 if the timer is not set.
    */
    function mSigSecondsLeft() external view returns (uint64);

    /**
    * @dev Retrieves the timestamp when the proposal signature process started.
    * @return The start timestamp of the proposal signature process, represented as a uint64.
    */
    function pSigStartTimestamp() external view returns (uint64);

    /**
    * @dev Retrieves the timestamp when the proposal signature process ended.
    * @return The end timestamp of the proposal signature process, represented as a uint64.
    */
    function pSigEndTimestamp() external view returns (uint64);

    /**
    * @dev Retrieves the duration of the proposal signature process.
    * @return The duration of the proposal signature process, represented as a uint64.
    */
    function pSigDuration() external view returns (uint64);

    /**
    * @dev Checks if the timer for the proposal signature process is set.
    * @return True if the timer is set, otherwise false.
    */
    function pSigTimerSet() external view returns (bool);

    /**
    * @dev Retrieves the remaining seconds left for the proposal signature process, if the timer is set.
    * @return The remaining seconds as a uint64. Returns 0 if the timer is not set.
    */
    function pSigSecondsLeft() external view returns (uint64);

    /**
    * @dev Retrieves the timestamp when the timelock period for the proposal started.
    * @return The start timestamp of the timelock period, represented as a uint64.
    */
    function timelockStartTimestamp() external view returns (uint64);

    /**
    * @dev Retrieves the timestamp when the timelock period for the proposal ended.
    * @return The end timestamp of the timelock period, represented as a uint64.
    */
    function timelockEndTimestamp() external view returns (uint64);

    /**
    * @dev Retrieves the duration of the timelock period for the proposal.
    * @return The duration of the timelock period, represented as a uint64.
    */
    function timelockDuration() external view returns (uint64);

    /**
    * @dev Checks if the timer for the timelock period is set.
    * @return True if the timer is set, otherwise false.
    */
    function timelockTimerSet() external view returns (bool);

    /**
    * @dev Retrieves the remaining seconds left for the timelock period, if the timer is set.
    * @return The remaining seconds as a uint64. Returns 0 if the timer is not set.
    */
    function timelockSecondsLeft() external view returns (uint64);

    /**
    * @dev Retrieves the required quorum percentage for the multi-signature process.
    * @return The required quorum percentage as a uint256.
    */
    function mSigRequiredQuorum() external view returns (uint256);

    /**
    * @dev Retrieves the required quorum percentage for the proposal signature process.
    * @return The required quorum percentage as a uint256.
    */
    function pSigRequiredQuorum() external view returns (uint256);

    /**
    * @dev Retrieves the threshold percentage for the proposal.
    * @return The threshold percentage as a uint16.
    * 
    * Note: The threshold is represented as a percentage with 100% equivalent to 10000.
    */
    function threshold() external view returns (uint256);

    /**
    * @notice Checks if the current voting threshold is sufficient for the proposal.
    * @dev This function calculates the required quorum based on the minimum signature
    * quorum specified for the proposal. It then compares the current threshold with
    * the required quorum and returns true if the current threshold is equal to or
    * greater than the required quorum.
    * @return A boolean indicating whether the current voting threshold is sufficient.
    */
    function sufficientThreshold() external view returns (bool);

    /**
    * @dev Retrieves the index of the snapshot associated with the proposal.
    * @return The index of the snapshot as a uint256.
    */
    function snapshotIndex() external view returns (uint256);

    /**
    * @dev Retrieves the timestamp of the snapshot associated with the proposal.
    * @return The timestamp of the snapshot as a uint64.
    */
    function snapshotTimestamp() external view returns (uint64);

    /**
    * @notice Retrieves the current TerminalV2 address stored in the metadata of the proposal.
    * @dev This function provides read-only access to the TerminalV2 address associated with the proposal.
    * @return The current TerminalV2 address stored in the metadata.
    */
    function terminalV2() external view returns (address);

    /**
    * @dev Calculates the current approval threshold percentage based on the support and quorum.
    * @return The current approval threshold as a percentage multiplied by 10000.
    */
    function currThreshold() external view returns (uint256);

    /**
    * @dev Allows a designated signer to add their signature during the Multi-Signature (MSig) phase.
    * 
    * This function can only be called by an authorized signer (`onlySigner`) and is only executable during the MSig phase (`onlyWhenMSig`).
    * The signer's address is added to the list of signatures for the proposal.
    */
    function sign() external;

    /**
    * @dev Allows a token holder to cast their vote during the Public Signature (PSig) phase.
    * @param side The side of the vote (Support, Against, Abstain).
    * 
    * This function can only be called by an account with a positive balance (`onlyPositiveBalance`) and is only executable during the PSig phase (`onlyWhenPSig`).
    * The voter's address is added to the list of voters, and the vote is categorized based on the specified side (Support, Against, Abstain).
    */
    function vote(Side side) external;

    /**
    * @dev Progresses the proposal through its lifecycle based on the current phase.
    * 
    * During the Private Signature (MSig) phase, this function checks if the required MSig quorum is met (`sufficientMSigQuorum`),
    * if the MSig timer has expired (`MSigTimedout`), and transitions to the Public Signature (PSig) phase if the timer is set.
    * 
    * During the Public Signature (PSig) phase, this function checks if the required PSig quorum is met (`sufficientPSigQuorum`),
    * if the PSig timer has expired (`PSigTimedout`), and transitions to the Timelock phase if the timer is set.
    * 
    * During the Timelock phase, this function checks if the timelock timer has expired (`Timelock`) and performs any necessary actions.
    */
    function forward() external;
}