// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

abstract contract ProposalV1 {

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
        uint256 threashold;
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
        _proposal.metadata.caption = caption;
        _proposal.metadata.message = message;
        _proposal.metadata.creator = creator;
        _proposal.mSigTimestamps.duration = mSigDuration;
        _proposal.pSigTimestamps.duration = pSigDuration;
        _proposal.timelockTimestamps.duration = timelockDuration;
        _proposal.phase = Phase.PRIVATE;
        _initMSigTimer();
    }

    /**
    * @notice Returns the address of the governance token required for voting.
    * @dev This function provides the Ethereum address of the governance token that is necessary for voting on proposals.
    * Users need to hold and use this specific token to participate in the decision-making process.
    * @return The Ethereum address of the governance token.
    */
    function dream() public pure returns (address) {
        return 0xC5C23B6c3B8A15340d9BB99F07a1190f16Ebb125;
    }

    function phase() public view returns (Phase) {
        return _proposal.phase;
    }

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
    * @notice Initializes the MultiSig (MSig) phase timer.
    * @dev This internal function sets the start and end timestamps for the MultiSig (MSig) phase,
    * allowing precise tracking of the time period during which signers can contribute their signatures.
    * The duration is assumed to be pre-set in the `_proposal.mSigTimestamps.duration` variable.
    */
    function _initMSigTimer() internal {
        // Set the start timestamp to the current block timestamp.
        _proposal.mSigTimestamps.startTimestamp = uint64(block.timestamp);

        // Calculate and set the end timestamp based on the pre-defined duration.
        _proposal.mSigTimestamps.endTimestamp = _proposal.mSigTimestamps.startTimestamp + _proposal.mSigTimestamps.duration;
    }

    /**
    * @notice Initializes the Public Signature (PSig) phase timer.
    * @dev This internal function sets the start and end timestamps for the Public Signature (PSig) phase,
    * allowing precise tracking of the time period during which voters can cast their public votes.
    * The duration is assumed to be pre-set in the `_proposal.pSigTimestamps.duration` variable.
    */
    function _initPSigTimer() internal {
        // Set the start timestamp to the current block timestamp.
        _proposal.pSigTimestamps.startTimestamp = uint64(block.timestamp);

        // Calculate and set the end timestamp based on the pre-defined duration.
        _proposal.pSigTimestamps.endTimestamp = _proposal.pSigTimestamps.startTimestamp + _proposal.pSigTimestamps.duration;
    }

    function _initTimelockTimer() internal {

    }




}