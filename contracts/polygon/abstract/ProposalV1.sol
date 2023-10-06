// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/external/openzeppelin/access/Ownable.sol";

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

    event MSigStartTimestampSetTo(uint64 indexed value);

    event MSigEndTimestampSetTo(uint64 indexed value);

    event MSigDurationSetTo(uint64 indexed value);

    event MSigTimerHasBeenSetToggled();

    event MSigTimerInitialized(uint64 indexed startTimestamp, uint64 indexed endTimestamp, uint64 indexed duration);

    event PSigStartTimestampSetTo(uint64 indexed value);

    event PSigEndTimestampSetTo(uint64 indexed value);

    event PSigDurationSetTo(uint64 indexed value);

    event PSigTimerHasBeenSetToggled();

    event PSigTimerInitialized(uint64 indexed startTimestamp, uint64 indexed endTimestamp, uint64 indexed duration);

    event TimelockStartTimestampSetTo(uint64 indexed value);

    event TimelockEndTimestampSetTo(uint64 indexed value);

    event TimelockDurationSetTo(uint64 indexed value);

    event TimelockTimerHasBeenSetToggled();

    event TimelockTimerInitialized(uint64 indexed startTimestamp, uint64 indexed endTimestamp, uint64 indexed duration);

    event CaptionSetTo(string indexed text);

    event MessageSetTo(string indexed text);

    event CreatorSetTo(address indexed account);

    event VotingERC20SetTo(address indexed account);

    event SignerAdded(address indexed account);

    event Signed(address indexed account);

    event Voted(address indexed account);

    event PhaseSetTo(Phase indexed phase);

    error DuplicateSigner(address account);

    error DuplicateSignature(address account);

    error DuplicateVoter(address account);

    /**
    * @notice Initializes a new Proposal with provided metadata and phase durations.
    * @dev This constructor sets up a Proposal with a specified caption, message, and creator address.
    * It also configures the durations for the MultiSig, Public Signature, and Timelock phases.
    * The initial phase is set to PRIVATE.
    * @param caption The caption associated with the Proposal.
    * @param message The detailed message or description of the Proposal.
    * @param creator The address of the Proposal creator.
    * @param mSigDuration Duration of the MultiSig phase in seconds.
    * @param pSigDuration Duration of the Public Signature phase in seconds.
    * @param timelockDuration Duration of the Timelock phase in seconds.
    */
    constructor(string memory caption, string memory message, address creator, uint64 mSigDuration, uint64 pSigDuration, uint64 timelockDuration) {
        _setPhaseToMSig();
        _setCaption(caption);
        _setMessage(message);
        _setCreator(creator);
        _setVotingERC20(0xC5C23B6c3B8A15340d9BB99F07a1190f16Ebb125);
        _setMSigDuration(mSigDuration);
        _setPSigDuration(pSigDuration);
        _setTimelockDuration(timelockDuration);
        _initMSigTimer();
    }

    function votingERC20() public pure returns (address) {
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
            return mSigEndTimestamp() - block.timestamp;
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
            return pSigEndTimestamp() - block.timestamp;
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
            return timelockEndTimestamp() - block.timestamp;
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
    function threshold() public view returns (uint16) {
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

    /** Setters. */

    /** Flags. */

    /**
    * @dev Modifier to restrict a function's execution to the MSig (Multi-Signature) phase of a governance proposal.
    * @notice This modifier ensures that the current phase of the proposal is PRIVATE, indicating the MSig phase,
    * and raises an error if not, preventing execution in other phases.
    */
    function _onlyWhenMSig() internal view {
        require(phase() == Phase.PRIVATE, "ProposalV1: phase() != Phase.PRIVATE");
    }

    /**
    * @dev Modifier to restrict a function's execution to the PSig (Public Signature) phase of a governance proposal.
    * @notice This modifier ensures that the current phase of the proposal is PUBLIC, indicating the PSig phase,
    * and raises an error if not, preventing execution in other phases.
    */
    function _onlyWhenPSig() internal view {
        require(phase() == Phase.PUBLIC, "ProposalV1: phase() != Phase.PUBLIC");
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
        emit MSigEndTimestampSetTo(value)
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
        emit CreatorSetTo(text);
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

    function _addSigner(address account) internal {
        if (isSigner(account)) { revert DuplicateSigner(account); }
        _proposal.mSig.signers.add(account);
        emit SignerAdded(account);
    }

    function _addSignature(address account) internal {
        if (hasSigned(account)) { revert DuplicateSignature(account); }
        _proposal.mSig.signatures.add(account);
        emit Signed(account);
    }

    function _addVoter(address account) internal {
        if (hasVoted(account)) { revert DuplicateVoter(account); }
        _proposal.pSig.voters.add(account);
        emit Voted(account);
    }
}