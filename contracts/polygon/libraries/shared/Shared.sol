// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

/**
 * @dev Importing and enabling the use of the EnumerableSet library for the AddressSet type.
 * @dev This allows instances of the AddressSet type to benefit from the functionalities provided by the EnumerableSet library,
 * such as adding, removing, and querying unique addresses efficiently.
 */
using EnumerableSet for EnumerableSet.AddressSet;

/**
 * @dev Implementation Address Is Zero Error
 * @dev Custom error indicating that the implementation address is set to zero during contract execution.
 *
 * This error is typically used in the context of proxy contracts to signal that the implementation address
 * is not set before attempting to delegate to the implementation contract. It helps developers identify and
 * handle scenarios where the implementation address is unexpectedly zero.
 */
error ImplementationAddressIsZero();

/**
 * @dev ProposalV1 Struct
 * @dev Represents a proposal with various parameters and configurations for voting and signature collection.
 * @param caption A string providing a brief description or title for the proposal.
 * @param message A string containing detailed information or the content of the proposal.
 * @param creator The address of the account that initiated the proposal.
 * @param votingERC20 The address of the ERC-20 token used for voting.
 * @param governor The address associated with the governance contract managing the proposal.
 * @param signers A set of addresses representing entities authorized to sign the proposal.
 * @param signatures A set of addresses indicating entities that have signed the proposal.
 * @param voters A set of addresses representing entities eligible to vote on the proposal.
 * @param support The count of votes in favor of the proposal.
 * @param against The count of votes against the proposal.
 * @param abstain The count of abstentions on the proposal.
 * @param signatureStartTimestamp The timestamp when signature collection starts.
 * @param signatureEndTimestamp The timestamp when signature collection ends.
 * @param signatureDuration The duration, in seconds, allocated for signature collection.
 * @param signatureTimerSet A boolean indicating whether the signature timer is set.
 * @param voteStartTimestamp The timestamp when voting starts.
 * @param voteEndTimestamp The timestamp when voting ends.
 * @param voteDuration The duration, in seconds, allocated for the voting process.
 * @param voteTimerSet A boolean indicating whether the voting timer is set.
 * @param lockStartTimestamp The timestamp when token lock starts.
 * @param lockEndTimestamp The timestamp when token lock ends.
 * @param lockDuration The duration, in seconds, for which tokens are locked after voting.
 * @param lockTimerSet A boolean indicating whether the token lock timer is set.
 * @param signatureRequiredQuorum The minimum number of required signatures for the proposal.
 * @param voteRequiredQuorum The minimum number of required votes for the proposal.
 * @param requiredThreshold The threshold percentage required for the proposal to pass.
 * @param snapshotIndex The index used to retrieve voting snapshots.
 * @param snapshotTimestamp The timestamp indicating when the voting snapshot was taken.
 */
struct ProposalV1 {
    string caption;
    string message;
    address creator;
    address votingERC20;
    address governor;
    EnumerableSet.AddressSet signers;
    EnumerableSet.AddressSet signatures;
    EnumerableSet.AddressSet voters;
    uint256 support;
    uint256 against;
    uint256 abstain;
    uint256 signatureStartTimestamp;
    uint256 signatureEndTimestamp;
    uint256 signatureDuration;
    bool signatureTimerSet;
    uint256 voteStartTimestamp;
    uint256 voteEndTimestamp;
    uint256 voteDuration;
    bool voteTimerSet;
    uint256 lockStartTimestamp;
    uint256 lockEndTimestamp;
    uint256 lockDuration;
    bool lockTimerSet;
    uint256 signatureRequiredQuorum;
    uint256 voteRequiredQuorum;
    uint256 requiredThreshold;
    uint256 snapshotIndex;
    uint256 snapshotTimestamp;
    ProposalPhaseV1 phase;
}

/**
 * @dev ProposalPhaseV1 Enum
 * @dev Represents the different phases that a proposal can go through.
 * @dev - PRIVATE: The initial phase where the proposal is being created and signatures are collected.
 * @dev - PUBLIC: The phase where the proposal is open for public voting.
 * @dev - LOCK: The phase where proposal is locked after the voting period.
 * @dev - EXECUTE: The final phase where the proposal is executed if it has passed the required thresholds.
 */
enum ProposalPhaseV1 {
    PRIVATE,
    PUBLIC,
    LOCK,
    EXECUTE
}

/**
 * @dev ProposalVoteForV1 Enum
 * @dev Represents the different choices for voting on a proposal.
 * @dev - SUPPORT: Indicates a vote in favor of the proposal.
 * @dev - AGAINST: Indicates a vote against the proposal.
 * @dev - ABSTAIN: Indicates an abstention or neutral vote on the proposal.
 */
enum ProposalVoteForV1 {
    SUPPORT,
    AGAINST,
    ABSTAIN
}