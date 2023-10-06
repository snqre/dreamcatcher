// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/external/openzeppelin/access/Ownable.sol";
import "contracts/polygon/interfaces/IDream.sol";

/**
* @dev Override _execute function to perform action after the proposal
*      has finished and successfully passed its lifecyle.
*      Modify as required.
 */
abstract contract ProposalV1 is Ownable {

    /**
    * @title Importing EnumerableSet library for AddressSet
    * @notice The EnumerableSet library is imported and used for managing sets of unique addresses.
    * @dev The `using` statement allows convenient access to the AddressSet functionality provided by the EnumerableSet library.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    Proposal private _proposal;

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
    * @title Proposal
    * @notice A data structure representing a governance proposal.
    * @dev This struct encapsulates various components and settings associated with a governance proposal.
    *
    * Components:
    * - Metadata: Information about the proposal such as its caption and message.
    * - MSig: Multi-signature component for the proposal.
    * - PSig: Public signature component for the proposal.
    * - MSigTimestamps: Timestamps related to the multi-signature component.
    * - PSigTimestamps: Timestamps related to the public signature component.
    * - TimelockTimestamps: Timestamps related to the timelock of the proposal.
    * - MSigSettings: Settings specific to the multi-signature component.
    * - PSigSettings: Settings specific to the public signature component.
    * - Settings: General settings applicable to the proposal.
    * - Snapshot: A snapshot of the governance system's state at the time of proposal creation.
    * - Phase: The current phase of the proposal (PRIVATE, QUEUED, etc.).
    *
    * Each of these components contributes to the overall functionality and governance process.
    * It provides a comprehensive view of the proposal's state, signatures, timestamps, and settings.
    */
    struct Proposal {
        Metadata metadata;
        MSig mSig;
        PSig pSig;
        MSigTimestamps mSigTimestamps;
        PSigTimestamps pSigTimestamps;
        TimelockTimestamps timelockTimestamps;
        MSigSettings mSigSettings;
        PSigSettings pSigSettings;
        Settings settings;
        Snapshot snapshot;
        Phase phase;
    }

    /**
    * @struct Metadata
    * @notice A data structure representing metadata associated with a governance proposal.
    * @dev Metadata typically includes descriptive information about the proposal, such as a caption, message, and the creator's address.
    *
    * Struct Fields:
    * - caption: A string providing a short and descriptive title or caption for the proposal.
    * - message: A string containing additional details or a message associated with the proposal.
    * - creator: The Ethereum address of the creator or proposer of the governance proposal.
    *
    * This struct is commonly used as part of a larger proposal data structure in governance contracts.
    */
    struct Metadata {
        string caption;
        string message;
        address creator;
        address votingERC20;
    }

    /**
    * @struct MSig
    * @notice A data structure representing a Multi-Signature (MSig) component of a governance proposal.
    * @dev MSig is used to manage signers and signatures in the context of multi-signature transactions.
    *
    * Struct Fields:
    * - signers: An address set containing the Ethereum addresses of signers authorized to approve the proposal.
    * - signatures: An address set representing the Ethereum addresses that have provided signatures for the proposal.
    *
    * The MSig component is often employed in governance contracts where multiple signatures are required for proposal approval.
    */
    struct MSig {
        EnumerableSet.AddressSet signers;
        EnumerableSet.AddressSet signatures;
    }

    /**
    * @struct PSig
    * @notice A data structure representing a Public Signature (PSig) component of a governance proposal.
    * @dev PSig is used to manage voters and their votes (support, against, abstain) in the context of a public vote using tokens.
    *
    * Struct Fields:
    * - voters: An address set containing the Ethereum addresses of voters participating in the public vote.
    * - support: The count of votes in favor of the proposal.
    * - against: The count of votes against the proposal.
    * - abstain: The count of abstaining votes in the proposal.
    *
    * The PSig component is commonly employed in governance contracts for transparent public voting using tokens.
    */
    struct PSig {
        EnumerableSet.AddressSet voters;
        uint256 support;
        uint256 against;
        uint256 abstain;
    }

    /**
    * @struct MSigTimestamps
    * @notice A data structure representing the timestamp-related information for a Multi-Signature (MSig) component of a governance proposal.
    * @dev MSigTimestamps is used to manage the start timestamp, end timestamp, and duration of a multi-signature phase in a governance proposal.
    *
    * Struct Fields:
    * - startTimestamp: The Unix timestamp marking the start of the multi-signature phase.
    * - endTimestamp: The Unix timestamp marking the end of the multi-signature phase.
    * - duration: The duration of the multi-signature phase in seconds.
    *
    * The MSigTimestamps component is commonly employed in governance contracts to define time-related parameters for multi-signature phases.
    */
    struct MSigTimestamps {
        uint64 startTimestamp;
        uint64 endTimestamp;
        uint64 duration;
        bool set;
    }

    /**
    * @struct PSigTimestamps
    * @notice A data structure representing the timestamp-related information for a Public Signature (PSig) component of a governance proposal.
    * @dev PSigTimestamps is used to manage the start timestamp, end timestamp, and duration of a public signature phase in a governance proposal.
    *
    * Struct Fields:
    * - startTimestamp: The Unix timestamp marking the start of the public signature phase.
    * - endTimestamp: The Unix timestamp marking the end of the public signature phase.
    * - duration: The duration of the public signature phase in seconds.
    *
    * The PSigTimestamps component is commonly employed in governance contracts to define time-related parameters for public signature phases.
    */
    struct PSigTimestamps {
        uint64 startTimestamp;
        uint64 endTimestamp;
        uint64 duration;
        bool set;
    }

    /**
    * @struct TimelockTimestamps
    * @notice A data structure representing the timestamp-related information for a Timelock component of a governance proposal.
    * @dev TimelockTimestamps is used to manage the start timestamp, end timestamp, and duration of a timelock phase in a governance proposal.
    *
    * Struct Fields:
    * - startTimestamp: The Unix timestamp marking the start of the timelock phase.
    * - endTimestamp: The Unix timestamp marking the end of the timelock phase.
    * - duration: The duration of the timelock phase in seconds.
    *
    * The TimelockTimestamps component is commonly employed in governance contracts to define time-related parameters for timelock phases.
    */
    struct TimelockTimestamps {
        uint64 startTimestamp;
        uint64 endTimestamp;
        uint64 duration;
        bool set;
    }

    /**
    * @struct MSigSettings
    * @notice A data structure representing the settings specific to a Multi-Signature (MSig) component of a governance proposal.
    * @dev MSigSettings is utilized to configure parameters related to multi-signature requirements.
    *
    * Struct Fields:
    * - requiredQuorum: The minimum number of signatures required to achieve quorum in the Multi-Signature component.
    *
    * The MSigSettings component is commonly employed in governance contracts to define quorum-related settings for multi-signature phases.
    */
    struct MSigSettings {
        uint256 requiredQuorum;
    }

    /**
    * @struct PSigSettings
    * @notice A data structure representing the settings specific to a Public Signature (PSig) component of a governance proposal.
    * @dev PSigSettings is utilized to configure parameters related to public signature requirements.
    *
    * Struct Fields:
    * - requiredQuorum: The minimum number of votes required to achieve quorum in the Public Signature component.
    *
    * The PSigSettings component is commonly employed in governance contracts to define quorum-related settings for public signature phases.
    */
    struct PSigSettings {
        uint256 requiredQuorum;
    }

    /**
    * @struct Settings
    * @notice A data structure representing general settings applicable to a governance proposal.
    * @dev Settings encapsulate various configuration parameters that influence the behavior of a governance proposal.
    *
    * Struct Fields:
    * - threashold: A numerical threshold value used for decision-making or validation within the governance proposal.
    *
    * The Settings struct is commonly employed in governance contracts to store and manage general configuration parameters.
    */
    struct Settings {
        uint256 threshold;
    }
    
    /**
    * @struct Snapshot
    * @notice A data structure representing a snapshot of a particular state within the governance system.
    * @dev Snapshots are used to capture specific moments in time for reference and historical tracking purposes.
    *
    * Struct Fields:
    * - index: An integer index associated with the snapshot, serving as a unique identifier.
    * - timestamp: A timestamp indicating the moment when the snapshot was taken.
    *
    * The Snapshot struct is commonly utilized in governance contracts to record and reference the state of the system at specific points in time.
    */
    struct Snapshot {
        uint256 index;
        uint64 timestamp;
    }

    /**
    * @dev Modifier that checks if the function is called during the Multi-Signature (MSig) phase.
    * 
    * This modifier ensures that the function can only be executed when the proposal is in the MSig phase.
    */
    modifier onlyWhenMSig() {
        _onlyWhenMSig();
        _;
    }

    /**
    * @dev Modifier that checks if the function is called during the Public Signature (PSig) phase.
    * 
    * This modifier ensures that the function can only be executed when the proposal is in the PSig phase.
    */
    modifier onlyWhenPSig() {
        _onlyWhenPSig();
        _;
    }

    /**
    * @dev Modifier that checks if the caller is a signer.
    * 
    * This modifier ensures that the function can only be executed by an account designated as a signer.
    */
    modifier onlySigner() {
        _onlySigner();
        _;
    }

    /**
    * @dev Modifier that checks if the caller has a positive balance.
    * 
    * This modifier ensures that the function can only be executed by an account with a positive balance.
    */
    modifier onlyPositiveBalance() {
        _onlyPositiveBalance();
        _;
    }

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
    error Unauthorized(address indexed account);

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
    * @dev Constructor for initializing a new proposal.
    * @param caption The caption for the proposal.
    * @param message The message associated with the proposal.
    * @param creator The address of the proposal creator.
    * @param mSigDuration The duration for the multi-signature phase.
    * @param pSigDuration The duration for the public signature phase.
    * @param timelockDuration The duration for the timelock phase.
    * @param signers The initial array of signers for the multi-signature process.
    * @param mSigRequiredQuorum The required quorum percentage for the multi-signature process.
    * @param pSigRequiredQuorum The required quorum percentage for the public signature process.
    * @param threshold The voting threshold percentage for the proposal.
    */
    constructor(string memory caption, string memory message, address creator, uint64 mSigDuration, uint64 pSigDuration, uint64 timelockDuration, address[] memory signers, uint256 mSigRequiredQuorum, uint256 pSigRequiredQuorum, uint256 threshold) {
        _setPhaseToMSig();
        _setVotingERC20(0xC5C23B6c3B8A15340d9BB99F07a1190f16Ebb125);
        _snapshot();
        for (uint256 i = 0; i < signers.length; i++) {
            _addSigner(signers[i]);
        }
        _setMSigRequiredQuorum(mSigRequiredQuorum);
        _setPSigRequiredQuorum(pSigRequiredQuorum);
        _setThreshold(threshold);
        _setCaption(caption);
        _setMessage(message);
        _setCreator(creator);
        _setMSigDuration(mSigDuration);
        _setPSigDuration(pSigDuration);
        _setTimelockDuration(timelockDuration);
        _initMSigTimer();
    }

    function votingERC20() public view returns (address) {
        return _proposal.metadata.votingERC20;
    }

    /**
    * @dev Retrieves the current phase of the proposal.
    * @return The current phase of the proposal, represented as a {Phase} enum.
    */
    function phase() public view returns (Phase) {
        return _proposal.phase;
    }

    /**
    * @dev Retrieves the caption associated with the proposal.
    * @return The caption of the proposal as a string.
    */
    function caption() public view returns (string memory) {
        return _proposal.metadata.caption;
    }

    /**
    * @dev Retrieves the message associated with the proposal.
    * @return The message of the proposal as a string.
    */
    function message() public view returns (string memory) {
        return _proposal.metadata.message;
    }

    /**
    * @dev Retrieves the address of the creator of the proposal.
    * @return The address of the creator.
    */
    function creator() public view returns (address) {
        return _proposal.metadata.creator;
    }

    /**
    * @dev Retrieves the addresses of signers who have participated in the multi-signature of the proposal.
    * @return An array containing the addresses of the signers.
    */
    function signers() public view returns (address[] memory) {
        return _proposal.mSig.signers.values();
    }

    /**
    * @dev Retrieves the total number of signers who have participated in the multi-signature of the proposal.
    * @return The number of signers.
    */
    function signersLength() public view returns (uint256) {
        return _proposal.mSig.signers.length();
    }

    /**
    * @dev Checks if a given address is a signer who has participated in the multi-signature of the proposal.
    * @param account The address to be checked.
    * @return True if the address is a signer, otherwise false.
    */
    function isSigner(address account) public view returns (bool) {
        return _proposal.mSig.signers.contains(account);
    }

    /**
    * @dev Retrieves the addresses of accounts that have provided signatures for the proposal.
    * @return An array containing the addresses of the signatories.
    */
    function signatures() public view returns (address[] memory) {
        return _proposal.mSig.signatures.values();
    }

    /**
    * @dev Retrieves the total number of signatures provided for the proposal.
    * @return The number of signatures.
    */
    function signaturesLength() public view returns (uint256) {
        return _proposal.mSig.signatures.length();
    }

    /**
    * @dev Calculates the number of required signatures for the multi-signature process.
    * 
    * This function computes the required number of signatures based on the length of signers
    * and the specified multi-signature required quorum percentage. The result represents the
    * minimum number of signatures needed for the proposal to proceed in the multi-signature phase.
    * 
    * @return The calculated number of required signatures.
    */
    function requiredSignaturesLength() public view returns (uint256) {
        return (signersLength() * mSigRequiredQuorum()) / 10000;
    }

    /**
    * @dev Checks if the multi-signature quorum has been met.
    * 
    * This function determines whether the number of collected signatures
    * in the multi-signature process is sufficient to meet the required quorum.
    * 
    * @return True if the multi-signature quorum is met, false otherwise.
    */
    function sufficientMSigQuorum() public view returns (bool) {
        return signaturesLength() >= requiredSignaturesLength();
    }

    /**
    * @dev Checks if a given address has provided a signature for the proposal.
    * @param account The address to be checked.
    * @return True if the address has signed the proposal, otherwise false.
    */
    function hasSigned(address account) public view returns (bool) {
        return _proposal.mSig.signatures.contains(account);
    }

    /**
    * @dev Retrieves the addresses of voters who have participated in the proposal signature.
    * @return An array containing the addresses of the voters.
    */
    function voters() public view returns (address[] memory) {
        return _proposal.pSig.voters.values();
    }

    /**
    * @dev Retrieves the total number of voters who have participated in the proposal signature.
    * @return The number of voters.
    */
    function votersLength() public view returns (uint256) {
        return _proposal.pSig.voters.length();
    }

    /**
    * @dev Checks if a given address has participated in voting for the proposal.
    * @param account The address to be checked.
    * @return True if the address has voted, otherwise false.
    */
    function hasVoted(address account) public view returns (bool) {
        return _proposal.pSig.voters.contains(account);
    }

    /**
    * @dev Retrieves the total level of support for the proposal.
    * @return The total support for the proposal, represented as a uint256.
    */
    function support() public view returns (uint256) {
        return _proposal.pSig.support;
    }

    /**
    * @dev Retrieves the total level of opposition against the proposal.
    * @return The total opposition against the proposal, represented as a uint256.
    */
    function against() public view returns (uint256) {
        return _proposal.pSig.against;
    }

    /**
    * @dev Retrieves the total number of abstentions for the proposal.
    * @return The total number of abstentions, represented as a uint256.
    */
    function abstain() public view returns (uint256) {
        return _proposal.pSig.abstain;
    }

    /**
    * @dev Retrieves the total number of participants considered for the quorum calculation.
    * @return The sum of supporters, opponents, and abstentions, representing the total participants.
    */
    function quorum() public view returns (uint256) {
        return support() + against() + abstain();
    }

    function requiredQuorum() public view returns (uint256) {
        return (IDream(votingERC20()).totalSupplyAt(snapshotIndex()) * pSigRequiredQuorum()) / 10000;
    }

    /**
    * @dev Checks if the public signature quorum has been met.
    * 
    * This function determines whether the total support, against, and abstain votes
    * collectively reach or exceed the required quorum for the public signature phase.
    * 
    * @return True if the public signature quorum is met, false otherwise.
    */
    function sufficientPSigQuorum() public view returns (bool) {
        return quorum() >= requiredQuorum();
    }

    /**
    * @dev Retrieves the timestamp when the multi-signature process for the proposal started.
    * @return The start timestamp of the multi-signature process, represented as a uint64.
    */
    function mSigStartTimestamp() public view returns (uint64) {
        return _proposal.mSigTimestamps.startTimestamp;
    }

    /**
    * @dev Retrieves the timestamp when the multi-signature process for the proposal ended.
    * @return The end timestamp of the multi-signature process, represented as a uint64.
    */
    function mSigEndTimestamp() public view returns (uint64) {
        return _proposal.mSigTimestamps.endTimestamp;
    }

    /**
    * @dev Retrieves the duration of the multi-signature process for the proposal.
    * @return The duration of the multi-signature process, represented as a uint64.
    */
    function mSigDuration() public view returns (uint64) {
        return _proposal.mSigTimestamps.duration;
    }

    /**
    * @dev Checks if the timer for the multi-signature process is set.
    * @return True if the timer is set, otherwise false.
    */
    function mSigTimerSet() public view returns (bool) {
        return _proposal.mSigTimestamps.set;
    }

    /**
    * @dev Retrieves the remaining seconds left for the multi-signature process, if the timer is set.
    * @return The remaining seconds as a uint64. Returns 0 if the timer is not set.
    */
    function mSigSecondsLeft() public view returns (uint64) {
        if (mSigTimerSet()) {
            return uint64(mSigEndTimestamp() - block.timestamp);
        }
        else {
            return 0;
        }
    }

    /**
    * @dev Retrieves the timestamp when the proposal signature process started.
    * @return The start timestamp of the proposal signature process, represented as a uint64.
    */
    function pSigStartTimestamp() public view returns (uint64) {
        return _proposal.pSigTimestamps.startTimestamp;
    }

    /**
    * @dev Retrieves the timestamp when the proposal signature process ended.
    * @return The end timestamp of the proposal signature process, represented as a uint64.
    */
    function pSigEndTimestamp() public view returns (uint64) {
        return _proposal.pSigTimestamps.endTimestamp;
    }

    /**
    * @dev Retrieves the duration of the proposal signature process.
    * @return The duration of the proposal signature process, represented as a uint64.
    */
    function pSigDuration() public view returns (uint64) {
        return _proposal.pSigTimestamps.duration;
    }

    /**
    * @dev Checks if the timer for the proposal signature process is set.
    * @return True if the timer is set, otherwise false.
    */
    function pSigTimerSet() public view returns (bool) {
        return _proposal.pSigTimestamps.set;
    }

    /**
    * @dev Retrieves the remaining seconds left for the proposal signature process, if the timer is set.
    * @return The remaining seconds as a uint64. Returns 0 if the timer is not set.
    */
    function pSigSecondsLeft() public view returns (uint64) {
        if (pSigTimerSet()) {
            return uint64(pSigEndTimestamp() - block.timestamp);
        }
        else {
            return 0;
        }
    }

    /**
    * @dev Retrieves the timestamp when the timelock period for the proposal started.
    * @return The start timestamp of the timelock period, represented as a uint64.
    */
    function timelockStartTimestamp() public view returns (uint64) {
        return _proposal.timelockTimestamps.startTimestamp;
    }

    /**
    * @dev Retrieves the timestamp when the timelock period for the proposal ended.
    * @return The end timestamp of the timelock period, represented as a uint64.
    */
    function timelockEndTimestamp() public view returns (uint64) {
        return _proposal.timelockTimestamps.endTimestamp;
    }

    /**
    * @dev Retrieves the duration of the timelock period for the proposal.
    * @return The duration of the timelock period, represented as a uint64.
    */
    function timelockDuration() public view returns (uint64) {
        return _proposal.timelockTimestamps.duration;
    }

    /**
    * @dev Checks if the timer for the timelock period is set.
    * @return True if the timer is set, otherwise false.
    */
    function timelockTimerSet() public view returns (bool) {
        return _proposal.timelockTimestamps.set;
    }

    /**
    * @dev Retrieves the remaining seconds left for the timelock period, if the timer is set.
    * @return The remaining seconds as a uint64. Returns 0 if the timer is not set.
    */
    function timelockSecondsLeft() public view returns (uint64) {
        if (timelockTimerSet()) {
            return uint64(timelockEndTimestamp() - block.timestamp);
        }
        else {
            return 0;
        }
    }

    /**
    * @dev Retrieves the required quorum percentage for the multi-signature process.
    * @return The required quorum percentage as a uint256.
    */
    function mSigRequiredQuorum() public view returns (uint256) {
        /**
        * 100% => 10000.
         */
        return _proposal.mSigSettings.requiredQuorum;
    }

    /**
    * @dev Retrieves the required quorum percentage for the proposal signature process.
    * @return The required quorum percentage as a uint256.
    */
    function pSigRequiredQuorum() public view returns (uint256) {
        /**
        * 100% => 10000.
         */
        return _proposal.pSigSettings.requiredQuorum;
    }

    /**
    * @dev Retrieves the threshold percentage for the proposal.
    * @return The threshold percentage as a uint16.
    * 
    * Note: The threshold is represented as a percentage with 100% equivalent to 10000.
    */
    function threshold() public view returns (uint256) {
        /**
        * 100% => 10000.
         */
        return _proposal.settings.threshold;
    }

    /**
    * @dev Retrieves the index of the snapshot associated with the proposal.
    * @return The index of the snapshot as a uint256.
    */
    function snapshotIndex() public view returns (uint256) {
        return _proposal.snapshot.index;
    }

    /**
    * @dev Retrieves the timestamp of the snapshot associated with the proposal.
    * @return The timestamp of the snapshot as a uint64.
    */
    function snapshotTimestamp() public view returns (uint64) {
        return _proposal.snapshot.timestamp;
    }

    /** Multi Sig Control. */

    /**
    * @dev Allows a designated signer to add their signature during the Multi-Signature (MSig) phase.
    * 
    * This function can only be called by an authorized signer (`onlySigner`) and is only executable during the MSig phase (`onlyWhenMSig`).
    * The signer's address is added to the list of signatures for the proposal.
    */
    function sign() public onlySigner() onlyWhenMSig() {
        _addSignature(msg.sender);
    }

    /** Public Sig Control. */

    /**
    * @dev Allows a token holder to cast their vote during the Public Signature (PSig) phase.
    * @param side The side of the vote (Support, Against, Abstain).
    * 
    * This function can only be called by an account with a positive balance (`onlyPositiveBalance`) and is only executable during the PSig phase (`onlyWhenPSig`).
    * The voter's address is added to the list of voters, and the vote is categorized based on the specified side (Support, Against, Abstain).
    */
    function vote(Side side) public onlyPositiveBalance() onlyWhenPSig() {
        uint256 balanceOf = IDREAM(votingERC20()).balanceOfAt(msg.sender, snapshotIndex());
        if (side == Side.SUPPORT) { _addSupport(balanceOf) }
        else if (side == Side.AGAINST) { _addAgainst(balanceOf); }
        else if (side == Side.ABSTAIN) { _addAbstain(balanceOf); }
        else { revert InvalidSide(side); }
        _addVoter(msg.sender);
    }

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
    function forward() public {
        if (phase() == Phase.PRIVATE) {
            if (!sufficientMSigQuorum()) { revert InsufficientMSigQuorum(signaturesLength(), requiredSignaturesLength()); }
            if (mSigSecondsLeft() == 0 && mSigTimerSet()) { revert MSigTimedout(mSigSecondsLeft()); }
            if (mSigTimerSet()) {
                _setPhaseToPSig();
            }
        }
        if (phase() == Phase.PUBLIC) {
            if (!sufficientPSigQuorum()) { revert InsufficientPSigQuorum(quorum(), requiredQuorum()); }
            if (pSigSecondsLeft() == 0 && pSigTimerSet()) { revert PSigTimedout(pSigSecondsLeft()); }
            if (pSigTimerSet()) {
                _setPhaseToTimelock();
            }
        }
        if (phase() == Phase.PASSED) {
            if (timelockSecondsLeft() > 0 && timelockTimerSet()) { revert Timelock(timelockSecondsLeft()); }
            if (timelockTimerSet()) {
                _execute();
            }
        }
    }

    /** Flags. */

    /**
    * @dev Modifier to restrict a function's execution to the MSig (Multi-Signature) phase of a governance proposal.
    * @notice This modifier ensures that the current phase of the proposal is PRIVATE, indicating the MSig phase,
    * and raises an error if not, preventing execution in other phases.
    */
    function _onlyWhenMSig() internal view {
        if (phase() != Phase.PRIVATE) { revert OnlyDuringMSigPhase(phase()); }
    }

    /**
    * @dev Modifier to restrict a function's execution to the PSig (Public Signature) phase of a governance proposal.
    * @notice This modifier ensures that the current phase of the proposal is PUBLIC, indicating the PSig phase,
    * and raises an error if not, preventing execution in other phases.
    */
    function _onlyWhenPSig() internal view {
        if (phase() != Phase.PUBLIC) { revert OnlyDuringPSigPhase(phase()); }
    }

    /**
    * @dev Internal function to ensure that a value is within a specified range.
    * @param min The minimum allowed value.
    * @param max The maximum allowed value.
    * @param value The value to be checked.
    * 
    * This function checks if the provided value is within the specified range (inclusive).
    * If the value is outside the range, it reverts with an `OutOfBounds` error containing details of the range and the actual value.
    */
    function _onlyBetween(uint256 min, uint256 max, uint256 value) internal view {
        if (value < min || value > max) { revert OutOfBounds(min, max, value); }
    }

    /**
    * @dev Internal function to ensure that the caller is a designated signer.
    * 
    * This function checks if the transaction sender (msg.sender) is a designated signer.
    * If the sender is not a signer, it reverts with an `Unauthorized` error.
    */
    function _onlySigner() internal view {
        if (!isSigner(msg.sender)) { revert Unauthorized(); }
    }

    /**
    * @dev Internal function to ensure that the caller has a positive balance at the snapshot.
    * 
    * This function checks if the transaction sender (msg.sender) has a positive balance
    * of the voting ERC20 token at the specified snapshot index.
    * If the balance is not positive, it reverts with an `OnlyPositiveBalance` error.
    */
    function _onlyPositiveBalance() internal view {
        uint256 balanceOf =
        IDream(votingERC20()).balanceOfAt(msg.sender, snapshotIndex());
        if (balanceOf < 1) { revert OnlyPositiveBalance()}
    }

    /** Internal. */

    /**
    * @dev Initializes the timer for the multi-signature process.
    * 
    * This function sets the start and end timestamps for the multi-signature process,
    * toggles the timer as being set, and emits an event with the initialized timestamps and duration.
    */
    function _initMSigTimer() internal {
        _setMSigStartTimestamp(uint64(block.timestamp));
        _setMSigEndTimestamp(mSigStartTimestamp() + mSigDuration());
        _toggleMSigTimerHasBeenSet();
        emit MSigTimerInitialized(mSigStartTimestamp(), mSigEndTimestamp(), mSigDuration());
    }

    /**
    * @dev Initializes the timer for the proposal signature process.
    * 
    * This function sets the start and end timestamps for the proposal signature process,
    * toggles the timer as being set, and emits an event with the initialized timestamps and duration.
    */
    function _initPSigTimer() internal {
        _setPSigStartTimestamp(uint64(block.timestamp));
        _setPSigEndTimestamp(pSigStartTimestamp() + pSigDuration());
        _togglePSigTimerHasBeenSet();
        emit PSigTimerInitialized(pSigStartTimestamp(), pSigEndTimestamp(), pSigDuration());
    }

    /**
    * @dev Initializes the timer for the timelock period.
    * 
    * This function sets the start and end timestamps for the timelock period,
    * toggles the timer as being set, and emits an event with the initialized timestamps and duration.
    */
    function _initTimelockTimer() internal {
        _setTimelockStartTimestamp(uint64(block.timestamp));
        _setTimelockEndTimestamp(timelockStartTimestamp() + timelockDuration());
        _toggleTimelockTimerHasBeenSet();
        emit TimelockTimerInitialized(timelockStartTimestamp(), timelockEndTimestamp(), timelockDuration());
    }

    /**
    * @dev Internal function to capture a snapshot of the current state.
    * 
    * This function captures the current state by setting the snapshot index and timestamp based on the voting ERC20 token.
    * Emits a `Snapshotted` event with details of the snapshot.
    */
    function _snapshot() internal {
        _setSnapshotIndex(IDream(votingERC20()).snapshot());
        _setSnapshotTimestamp(uint64(block.timestamp));
        emit Snapshotted(votingERC20(), snapshotIndex(), snapshotTimestamp());
    }

    /**
    * @dev Internal virtual function to execute actions after the proposal has passed and the timelock is over.
    * 
    * This function is meant for any actions that need to be performed once the proposal has successfully passed
    * the Timelock phase. Override this function in derived contracts to implement specific post-proposal execution logic.
    */
    function _execute() internal virtual {
        /**
        * @dev Any thing that happens after proposal has passed and
        *      timelock is over.
         */
    }

    /** Internal Setters. */

    /**
    * @dev Sets the start timestamp for the multi-signature process.
    * @param value The new start timestamp value to be set.
    * 
    * Emits an event with the updated start timestamp.
    */
    function _setMSigStartTimestamp(uint64 value) internal {
        _proposal.mSigTimestamps.startTimestamp = value;
        emit MSigStartTimestampSetTo(value);
    }

    /**
    * @dev Sets the end timestamp for the multi-signature process.
    * @param value The new end timestamp value to be set.
    * 
    * Emits an event with the updated end timestamp.
    */
    function _setMSigEndTimestamp(uint64 value) internal {
        _proposal.mSigTimestamps.endTimestamp = value;
        emit MSigEndTimestampSetTo(value);
    }

    /**
    * @dev Sets the duration for the multi-signature process.
    * @param value The new duration value to be set.
    * 
    * Emits an event with the updated duration.
    */
    function _setMSigDuration(uint64 value) internal {
        _proposal.mSigTimestamps.duration = value;
        emit MSigDurationSetTo(value);
    }

    /**
    * @dev Toggles the flag indicating that the timer for the multi-signature process has been set.
    * 
    * Emits an event signaling the toggle.
    */
    function _toggleMSigTimerHasBeenSet() internal {
        _proposal.mSigTimestamps.set = true;
        emit MSigTimerHasBeenSetToggled();
    }

    /**
    * @dev Sets the start timestamp for the proposal signature process.
    * @param value The new start timestamp value to be set.
    * 
    * Emits an event with the updated start timestamp.
    */
    function _setPSigStartTimestamp(uint64 value) internal {
        _proposal.pSigTimestamps.startTimestamp = value;
        emit PSigStartTimestampSetTo(value);
    }

    /**
    * @dev Sets the end timestamp for the proposal signature process.
    * @param value The new end timestamp value to be set.
    * 
    * Emits an event with the updated end timestamp.
    */
    function _setPSigEndTimestamp(uint64 value) internal {
        _proposal.pSigTimestamps.endTimestamp = value;
        emit PSigEndTimestampSetTo(value);
    }

    /**
    * @dev Sets the duration for the proposal signature process.
    * @param value The new duration value to be set.
    * 
    * Emits an event with the updated duration.
    */
    function _setPSigDuration(uint64 value) internal {
        _proposal.pSigTimestamps.duration = value;
        emit PSigDurationSetTo(value);
    }

    /**
    * @dev Toggles the flag indicating that the timer for the proposal signature process has been set.
    * 
    * This internal function sets the `set` flag to true, indicating that the timer for the proposal
    * signature process has been initialized. It emits an event to signal the toggle.
    */
    function _togglePSigTimerHasBeenSet() internal {
        _proposal.pSigTimestamps.set = true;
        emit PSigTimerHasBeenSetToggled();
    }

    /**
    * @dev Sets the start timestamp for the timelock period.
    * @param value The new start timestamp value to be set.
    * 
    * Emits an event with the updated start timestamp.
    */
    function _setTimelockStartTimestamp(uint64 value) internal {
        _proposal.timelockTimestamps.startTimestamp = value;
        emit TimelockStartTimestampSetTo(value);
    }

    /**
    * @dev Sets the end timestamp for the timelock period.
    * @param value The new end timestamp value to be set.
    * 
    * Emits an event with the updated end timestamp.
    */
    function _setTimelockEndTimestamp(uint64 value) internal {
        _proposal.timelockTimestamps.endTimestamp = value;
        emit TimelockEndTimestampSetTo(value);
    }

    /**
    * @dev Sets the duration for the timelock period.
    * @param value The new duration value to be set.
    * 
    * Emits an event with the updated duration.
    */
    function _setTimelockDuration(uint64 value) internal {
        _proposal.timelockTimestamps.duration = value;
        emit TimelockDurationSetTo(value);
    }

    /**
    * @dev Toggles the flag indicating that the timer for the timelock period has been set.
    * 
    * This internal function sets the `set` flag to true, indicating that the timer for the timelock
    * period has been initialized. It emits an event to signal the toggle.
    */
    function _toggleTimelockTimerHasBeenSet() internal {
        _proposal.timelockTimestamps.set = true;
        emit TimelockTimerHasBeenSetToggled();
    }

    /**
    * @dev Sets the caption for the proposal.
    * @param text The new caption text to be set.
    * 
    * This internal function updates the proposal's metadata with the provided caption and emits an event
    * to signal that the caption has been set to the specified text.
    */
    function _setCaption(string memory text) internal {
        _proposal.metadata.caption = text;
        emit CaptionSetTo(text);
    }

    /**
    * @dev Sets the message for the proposal.
    * @param text The new message text to be set.
    * 
    * This internal function updates the proposal's metadata with the provided message and emits an event
    * to signal that the message has been set to the specified text.
    */
    function _setMessage(string memory text) internal {
        _proposal.metadata.message = text;
        emit MessageSetTo(text);
    }

    /**
    * @dev Sets the creator address for the proposal.
    * @param account The new creator address to be set.
    * 
    * This internal function updates the proposal's metadata with the provided creator address
    * and emits an event to signal that the creator has been set to the specified address.
    */
    function _setCreator(address account) internal {
        _proposal.metadata.creator = account;
        emit CreatorSetTo(account);
    }

    /**
    * @dev Sets the address of the ERC20 token used for voting in the proposal.
    * @param account The new ERC20 token address to be set.
    * 
    * This internal function updates the proposal's metadata with the provided ERC20 token address
    * and emits an event to signal that the voting ERC20 token has been set to the specified address.
    */
    function _setVotingERC20(address account) internal {
        _proposal.metadata.votingERC20 = account;
        emit VotingERC20SetTo(account);
    }

    /**
    * @dev Sets the phase of the proposal to the multi-signature phase.
    * 
    * This internal function updates the proposal's phase to the multi-signature phase and emits an event
    * to signal that the phase has been set to the corresponding value.
    */
    function _setPhaseToMSig() internal {
        _proposal.phase = Phase.PRIVATE;
        emit PhaseSetTo(phase());
    }

    /**
    * @dev Sets the phase of the proposal to the public signature phase.
    * 
    * This internal function updates the proposal's phase to the public signature phase and emits an event
    * to signal that the phase has been set to the corresponding value.
    */
    function _setPhaseToPSig() internal {
        _proposal.phase = Phase.PUBLIC;
        emit PhaseSetTo(phase());
    }

    /**
    * @dev Sets the phase of the proposal to the timelock phase.
    * 
    * This internal function updates the proposal's phase to the timelock phase and emits an event
    * to signal that the phase has been set to the corresponding value.
    */
    function _setPhaseToTimelock() internal {
        _proposal.phase = Phase.PASSED;
        emit PhaseSetTo(phase());
    }

    /**
    * @dev Adds a new signer to the multi-signature process.
    * @param account The address of the signer to be added.
    * 
    * This internal function checks if the signer is already part of the multi-signature process.
    * If the signer is not already a signer, it adds the signer and emits an event to signal the addition.
    * If the signer is already a signer, it reverts with an error indicating a duplicate signer.
    */
    function _addSigner(address account) internal {
        if (isSigner(account)) { revert DuplicateSigner(account); }
        _proposal.mSig.signers.add(account);
        emit SignerAdded(account);
    }

    /**
    * @dev Adds a new signature to the multi-signature process.
    * @param account The address of the signer providing the signature.
    * 
    * This internal function checks if the signer has already provided a signature.
    * If the signer has not already signed, it adds the signature and emits an event to signal the signing.
    * If the signer has already signed, it reverts with an error indicating a duplicate signature.
    */
    function _addSignature(address account) internal {
        if (hasSigned(account)) { revert DuplicateSignature(account); }
        _proposal.mSig.signatures.add(account);
        emit Signed(account);
    }

    /**
    * @dev Adds a new voter to the proposal signature process.
    * @param account The address of the voter to be added.
    * 
    * This internal function checks if the voter has already voted.
    * If the voter has not already voted, it adds the voter and emits an event to signal the voting.
    * If the voter has already voted, it reverts with an error indicating a duplicate voter.
    */
    function _addVoter(address account) internal {
        if (hasVoted(account)) { revert DuplicateVoter(account); }
        _proposal.pSig.voters.add(account);
        emit Voted(account);
    }

    /**
    * @dev Adds support to the proposal.
    * @param value The amount of support to be added.
    * 
    * This internal function increases the support for the proposal by the specified value
    * and emits an event to signal the change in support.
    */
    function _addSupport(uint256 value) internal {
        uint256 oldSupport = _proposal.pSig.support;
        _proposal.pSig.support += value;
        emit Supported(oldSupport, oldSupport + value);
    }

    /**
    * @dev Adds opposition against the proposal.
    * @param value The amount of opposition to be added.
    * 
    * This internal function increases the opposition against the proposal by the specified value
    * and emits an event to signal the change in opposition.
    */
    function _addAgainst(uint256 value) internal {
        uint256 oldAgainst = _proposal.pSig.against;
        _proposal.pSig.against += value;
        emit Rejected(oldAgainst, oldAgainst + value);
    }

    /**
    * @dev Adds abstention to the proposal.
    * @param value The amount of abstention to be added.
    * 
    * This internal function increases the abstention for the proposal by the specified value
    * and emits an event to signal the change in abstention.
    */
    function _addAbstain(uint256 value) internal {
        uint256 oldAbstain = _proposal.pSig.abstain;
        _proposal.pSig.abstain += value;
        emit Abstained(oldAbstain, oldAbstain + value);
    }

    /**
    * @dev Sets the required quorum percentage for the multi-signature process.
    * @param value The new required quorum percentage to be set (scaled from 0 to 10000).
    * 
    * This internal function checks that the provided value is within the valid range of 0 to 10000,
    * then updates the proposal's multi-signature settings with the specified required quorum percentage.
    * It emits an event to signal the change in the required quorum percentage.
    */
    function _setMSigRequiredQuorum(uint256 value) internal {
        _onlyBetween(0, 10000, value);
        _proposal.mSigSettings.requiredQuorum = value;
        emit MSigRequiredQuorumSetTo(value);
    }

    /**
    * @dev Sets the required quorum percentage for the public signature process.
    * @param value The new required quorum percentage to be set (scaled from 0 to 10000).
    * 
    * This internal function checks that the provided value is within the valid range of 0 to 10000,
    * then updates the proposal's public signature settings with the specified required quorum percentage.
    * It emits an event to signal the change in the required quorum percentage.
    */
    function _setPSigRequiredQuorum(uint256 value) internal {
        _onlyBetween(0, 10000, value);
        _proposal.pSigSettings.requiredQuorum = value;
        emit PSigRequiredQuorumSetTo(value);
    }

    /**
    * @dev Sets the voting threshold for the proposal.
    * @param value The new threshold percentage to be set (scaled from 0 to 10000).
    * 
    * This internal function checks that the provided value is within the valid range of 5100 to 10000,
    * then updates the proposal's settings with the specified voting threshold percentage.
    * It emits an event to signal the change in the threshold percentage.
    */
    function _setThreshold(uint256 value) internal {
        _onlyBetween(5100, 10000, value);
        _proposal.settings.threshold = value;
        emit ThresholdSetTo(value);
    }

    /**
    * @dev Sets the snapshot index for the proposal.
    * @param value The new snapshot index to be set.
    * 
    * This internal function updates the proposal's snapshot index with the specified value
    * and emits an event to signal the change in the snapshot index.
    */
    function _setSnapshotIndex(uint256 value) internal {
        _proposal.snapshot.index = value;
        emit SnapshotIndexSetTo(value);
    }

    /**
    * @dev Sets the snapshot timestamp for the proposal.
    * @param timestamp The new snapshot timestamp to be set.
    * 
    * This internal function updates the proposal's snapshot timestamp with the specified value
    * and emits an event to signal the change in the snapshot timestamp.
    */
    function _setSnapshotTimestamp(uint64 timestamp) internal {
        _proposal.snapshot.timestamp = timestamp;
        emit SnapshotTimestampSetTo(timestamp);
    }
}