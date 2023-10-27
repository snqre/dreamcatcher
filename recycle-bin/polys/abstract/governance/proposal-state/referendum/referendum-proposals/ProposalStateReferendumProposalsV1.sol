// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/token/dream/IDream.sol";
import "contracts/polygon/libraries/flags/uint256/Uint256FlagsV1.sol";
import "contracts/polygon/libraries/flags/address/AddressFlagsV1.sol";
import "contracts/polygon/libraries/flags/string/StringFlagsV1.sol";
import "contracts/polygon/libraries/flags/bytes/BytesFlagsV1.sol";

/**
 * @title ProposalStateReferendumProposalsV1
 */
abstract contract ProposalStateReferendumProposalsV1 is StateV1 {

    /**
    * @dev Imports and extends the functionality of the `EnumerableSet` library for the `EnumerableSet.AddressSet` type.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @dev Imports and extends the functionality of the `Uint256FlagsV1` library for the `uint256` type.
    */
    using Uint256FlagsV1 for uint256;

    /**
    * @dev Imports and extends the functionality of the `AddressFlagsV1` library for the `address` type.
    */
    using AddressFlagsV1 for address;

    /**
    * @dev Imports and extends the functionality of the `StringFlagsV1` library for the `string` type.
    */
    using StringFlagsV1 for string;

    /**
    * @dev Imports and extends the functionality of the `BytesFlagsV1` library for the `bytes` type.
    */
    using BytesFlagsV1 for bytes;

    /** Conditions */

    /**
    * @notice Checks if an account has a sufficient balance at the specified snapshot to participate in voting.
    * @param id The unique identifier of the Referendum Proposal.
    * @param account The address of the account to check.
    * @return True if the account has a sufficient balance, otherwise false.
    */
    function hasSufficientBalanceAtSnapshotToVote(uint256 id, address account) public view virtual returns (bool) {
        uint256 accountBalance = IDream(referendumProposalVotingERC20(id)).balanceOfAt(account, referendumProposalSnapshotId(id));
        if (accountBalance >= referendumProposalMinBalanceToVote(id)) { return true; }
        else { return false; }
    }

    /**
    * @notice Checks if a Referendum Proposal has a sufficient quorum to proceed.
    * @param id The unique identifier of the Referendum Proposal.
    * @return True if the quorum is sufficient, otherwise false.
    */
    function referendumProposalHasSufficientQuorum(uint256 id) public view virtual returns (bool) {
        return referendumProposalQuorum(id) >= referendumProposalRequiredVotes(id);
    }

    /**
    * @notice Checks if an account is eligible to vote for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param account The address of the account to check.
    * @return True if the account can vote, otherwise false.
    */
    function canVoteForReferendumProposal(uint256 id, address account) public view virtual returns (bool) {
        IDream votingERC20 = IDream(referendumProposalVotingERC20(id));
        uint256 balance = votingERC20.balanceOfAt(account, referendumProposalSnapshotId(id));
        if (balance >= referendumProposalMinBalanceToVote(id)) {
            return true;
        }
        else {
            return false;
        }
    }

    /** Voters */

    /**
    * @notice Emits when a new vote is cast for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param account The address of the account casting the vote.
    */
    event ReferendumProposalNewVote(uint256 indexed id, address indexed account);

    /**
    * @notice Generates a unique key representing an account's vote for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param account The address of the account.
    * @return A unique key for the specified Referendum Proposal and account.
    */
    function hasVotedForReferendumProposalKey(uint256 id, address account) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_VOTERS", id, account));
    }

    /**
    * @notice Checks if an account has voted for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param account The address of the account.
    * @return True if the account has voted, otherwise false.
    */
    function hasVotedForReferendumProposal(uint256 id, address account) public view virtual returns (bool) {
        return _bool[hasVotedForReferendumProposalKey(id, account)];
    }

    /**
    * @dev Internal function to toggle the voting status for a specific Referendum Proposal and account.
    * @param id The unique identifier of the Referendum Proposal.
    * @param account The address of the account.
    */
    function _toggleHasVotedForReferendumProposal(uint256 id, address account) internal virtual {
        _bool[hasVotedForReferendumProposalKey(id, account)] = true;
        emit ReferendumProposalNewVote(id, account);
    }

    /**
    * @dev Internal function to handle the voting process for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param side The voting side: 0 for abstain, 1 for against, 2 for support.
    */
    function _voteOnReferendumProposal(uint256 id, uint256 side) internal virtual {
        require(!hasVotedForReferendumProposal(id, msg.sender), "ProposalStateReferendumProposalsV1: hasVotedForReferendumProposal(id,msg.sender)");
        require(canVoteForReferendumProposal(id, msg.sender), "ProposalStateReferendumProposalsV1: !canVoteForReferendumProposal(id,msg.sender)");
        require(referendumProposalHasStarted(id), "ProposalStateReferendumProposalsV1: !referendumProposalHasStarted(id)");
        require(!referendumProposalHasEnded(id), "ProposalStateReferendumProposalsV1: referendumProposalHasEnded(id)");
        uint256 votes = IDream(referendumProposalVotingERC20(id)).balanceOfAt(msg.sender, referendumProposalSnapshotId(id));
        _toggleHasVotedForReferendumProposal(id, msg.sender);
        if (side == 0) {
            _increaseReferendumProposalAbstainVote(id, votes);
        }
        else if (side == 1) {
            _increaseReferendumProposalAgainstVote(id, votes);
        }
        else if (side == 2) {
            _increaseReferendumProposalSupportVote(id, votes);
        }
        else {
            revert("ProposalStateReferendumProposalsV1: invalid input");
        }
        if (referendumProposalHasSufficientQuorum(id) && referendumProposalHasSufficientThreshold(id)) {
            _toggleReferendumProposalHasPassed(id);
        }
    }

    /**
    * @dev Internal function to execute the actions specified in a passed Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal to be executed.
    */
    function _executeReferendumProposal(uint256 id) internal virtual {
        require(referendumProposalHasStarted(id), "ProposalStateReferendumProposalsV1: !referendumProposalHasStarted(id)");
        require(!referendumProposalHasEnded(id), "ProposalStateReferendumProposalsV1: referendumProposalHasEnded(id)");
        require(referendumProposalHasPassed(id), "ProposalStateReferendumProposalsV1: !referendumProposalHasPassed(id)");
        _toggleReferendumProposalHasBeenExecuted(id);
    }

    /** Caption */

    /**
    * @notice Emits when the caption of a Referendum Proposal is successfully updated.
    * @param id The unique identifier of the Referendum Proposal.
    * @param caption The updated caption of the Referendum Proposal.
    */
    event ReferendumProposalCaptionSetTo(uint256 indexed id, string indexed caption);

    /**
    * @notice Generates a unique key representing the caption of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal caption.
    */
    function referendumProposalCaptionKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_CAPTION", id));
    }

    /**
    * @notice Gets the caption of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The caption of the Referendum Proposal.
    */
    function referendumProposalCaption(uint256 id) public view virtual returns (string memory) {
        return _string[referendumProposalCaptionKey(id)];
    }

    /**
    * @dev Internal function to set the caption of a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param caption The new caption to be set.
    */
    function _setReferendumProposalCaption(uint256 id, string memory caption) internal virtual {
        string memory emptyString;
        caption.onlynotMatchingValue(emptyString);
        _string[referendumProposalCaptionKey(id)].onlynotMatchingValue(caption);
        _string[referendumProposalCaptionKey(id)] = caption;
        emit ReferendumProposalCaptionSetTo(id, caption);
    }

    /** Message */

    /**
    * @notice Emits when the message of a Referendum Proposal is successfully updated.
    * @param id The unique identifier of the Referendum Proposal.
    * @param message The updated message of the Referendum Proposal.
    */
    event ReferendumProposalMessageSetTo(uint256 indexed id, string indexed message);

    /**
    * @notice Generates a unique key representing the message of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal message.
    */
    function referendumProposalMessageKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_MESSAGE", id));
    }

    /**
    * @notice Gets the message of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The message of the Referendum Proposal.
    */
    function referendumProposalMessage(uint256 id) public view virtual returns (string memory) {
        return _string[referendumProposalMessageKey(id)];
    }

    /**
    * @dev Internal function to set the message of a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param message The new message to be set.
    */
    function _setReferendumProposalMessage(uint256 id, string memory message) internal virtual {
        string memory emptyString;
        message.onlynotMatchingValue(emptyString);
        _string[referendumProposalMessageKey(id)].onlynotMatchingValue(message);
        _string[referendumProposalMessageKey(id)] = message;
        emit ReferendumProposalMessageSetTo(id, message);
    }

    /** Creator */

    /**
    * @notice Emits when the creator address of a Referendum Proposal is successfully updated.
    * @param id The unique identifier of the Referendum Proposal.
    * @param creator The updated creator address of the Referendum Proposal.
    */
    event ReferendumProposalCreatorSetTo(uint256 indexed id, address indexed creator);

    /**
    * @notice Generates a unique key representing the creator address of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal creator address.
    */
    function referendumProposalCreatorKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_CREATOR", id));
    }

    /**
    * @notice Gets the creator address of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The creator address of the Referendum Proposal.
    */
    function referendumProposalCreator(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalCreatorKey(id)];
    }

    /**
    * @dev Internal function to set the creator address of a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param creator The new creator address to be set.
    */
    function _setReferendumProposalCreator(uint256 id, address creator) internal virtual {
        _address[referendumProposalCreatorKey(id)].onlynotAddress(creator);
        _address[referendumProposalCreatorKey(id)] = creator;
        emit ReferendumProposalCreatorSetTo(id, creator);
    }

    /** Start Timestamp */

    /**
    * @notice Emits when the start timestamp of a Referendum Proposal is successfully updated.
    * @param id The unique identifier of the Referendum Proposal.
    * @param timestamp The updated start timestamp of the Referendum Proposal.
    */
    event ReferendumProposalStartTimestampSetTo(uint256 indexed id, uint256 indexed timestamp);

    /**
    * @notice Generates a unique key representing the start timestamp of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal start timestamp.
    */
    function referendumProposalStartTimestampKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_START_TIMESTAMP", id));
    }

    /**
    * @notice Gets the start timestamp of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The start timestamp of the Referendum Proposal.
    */
    function referendumProposalStartTimestamp(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalStartTimestampKey(id)];
    }

    /**
    * @dev Internal function to set the start timestamp of a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param timestamp The new start timestamp to be set.
    */
    function _setReferendumProposalStartTimestamp(uint256 id, uint256 timestamp) internal virtual {
        _uint256[referendumProposalStartTimestampKey(id)].onlynotMatchingValue(timestamp);
        _uint256[referendumProposalStartTimestampKey(id)] = timestamp;
        emit ReferendumProposalStartTimestampSetTo(id, timestamp);
    }

    /**
    * @notice Gets the end timestamp of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The end timestamp of the Referendum Proposal.
    */
    function referendumProposalEndTimestamp(uint256 id) public view virtual returns (uint256) {
        return referendumProposalStartTimestamp(id) + referendumProposalDuration(id);
    }

    /** Duration */

    /**
    * @notice Emits when the duration of a Referendum Proposal is successfully updated.
    * @param id The unique identifier of the Referendum Proposal.
    * @param seconds_ The updated duration of the Referendum Proposal in seconds.
    */
    event ReferendumProposalDurationSetTo(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @notice Generates a unique key representing the duration of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal duration.
    */
    function referendumProposalDurationKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_DURATION", id));
    }

    /**
    * @notice Gets the duration of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The duration of the Referendum Proposal in seconds.
    */
    function referendumProposalDuration(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalDurationKey(id)];
    }

    /**
    * @dev Internal function to set the duration of a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param seconds_ The new duration to be set in seconds.
    */
    function _setReferendumProposalDuration(uint256 id, uint256 seconds_) internal virtual {
        _uint256[referendumProposalDurationKey(id)].onlynotMatchingValue(seconds_);
        _uint256[referendumProposalDurationKey(id)] = seconds_;
        emit ReferendumProposalDurationSetTo(id, seconds_);
    }

    /** Timestamp */

    /**
    * @notice Checks if a Referendum Proposal has started.
    * @param id The unique identifier of the Referendum Proposal.
    * @return True if the Referendum Proposal has started, otherwise false.
    */
    function referendumProposalHasStarted(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= referendumProposalStartTimestamp(id);
    }

    /**
    * @notice Checks if a Referendum Proposal has ended.
    * @param id The unique identifier of the Referendum Proposal.
    * @return True if the Referendum Proposal has ended, otherwise false.
    */
    function referendumProposalHasEnded(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= referendumProposalEndTimestamp(id);
    }

    /**
    * @notice Gets the remaining seconds for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The remaining seconds if the Referendum Proposal is ongoing, otherwise 0.
    */
    function referendumProposalSecondsLeft(uint256 id) public view virtual returns (uint256) {
        if (referendumProposalHasStarted(id) && !referendumProposalHasEnded(id)) {
            return (referendumProposalStartTimestamp(id) + referendumProposalDuration(id)) - block.timestamp;
        }
        else if (!referendumProposalHasStarted(id)) {
            return referendumProposalDuration(id);
        }
        else {
            return 0;
        }
    }

    /** Required Quorum */

    /**
    * @notice Emits when the required quorum for a Referendum Proposal is successfully updated.
    * @param id The unique identifier of the Referendum Proposal.
    * @param bp The updated required quorum in basis points (0.01%).
    */
    event ReferendumProposalRequiredQuorumSetTo(uint256 indexed id, uint256 indexed bp);

    /**
    * @notice Generates a unique key representing the required quorum of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal required quorum.
    */
    function referendumProposalRequiredQuorumKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_REQUIRED_QUORUM", id));
    }

    /**
    * @notice Gets the required quorum for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The required quorum in basis points (0.01%).
    */
    function referendumProposalRequiredQuorum(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalRequiredQuorumKey(id)];
    }

    /**
    * @dev Internal function to set the required quorum for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param bp The new required quorum to be set in basis points (0.01%).
    */
    function _setReferendumProposalRequiredQuorum(uint256 id, uint256 bp) internal virtual {
        bp.onlyBetween(0, 10000);
        _uint256[referendumProposalRequiredQuorumKey(id)].onlynotMatchingValue(bp);
        _uint256[referendumProposalRequiredQuorumKey(id)] = bp;
        emit ReferendumProposalRequiredQuorumSetTo(id, bp);
    }

    /** Required Threshold */

    /**
    * @notice Emits when the required threshold for a Referendum Proposal is successfully updated.
    * @param id The unique identifier of the Referendum Proposal.
    * @param bp The updated required threshold in basis points (0.01%).
    */
    event ReferendumProposalRequiredThresholdSetTo(uint256 indexed id, uint256 indexed bp);

    /**
    * @notice Generates a unique key representing the required threshold of a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal required threshold.
    */
    function referendumProposalRequiredThresholdKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_REQUIRED_THRESHOLD", id));
    }

    /**
    * @notice Gets the required threshold for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The required threshold in basis points (0.01%).
    */
    function referendumProposalRequiredThreshold(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalRequiredThresholdKey(id)];
    }

    /**
    * @dev Internal function to set the required threshold for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param bp The new required threshold to be set in basis points (0.01%).
    */
    function _setReferendumProposalRequiredThreshold(uint256 id, uint256 bp) internal virtual {
        bp.onlyBetween(0, 10000);
        _uint256[referendumProposalRequiredThresholdKey(id)].onlynotMatchingValue(bp);
        _uint256[referendumProposalRequiredThresholdKey(id)] = bp;
        emit ReferendumProposalRequiredThresholdSetTo(id, bp);
    }

    /**
    * @notice Calculates the current threshold for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The current threshold in basis points (0.01%).
    */
    function referendumProposalThreshold(uint256 id) public view virtual returns (uint256) {
        return (referendumProposalSupportVote(id) * 10000) / referendumProposalQuorum(id);
    }

    /**
    * @notice Checks if a Referendum Proposal has a sufficient threshold.
    * @param id The unique identifier of the Referendum Proposal.
    * @return True if the Referendum Proposal has sufficient threshold, otherwise false.
    */
    function referendumProposalHasSufficientThreshold(uint256 id) public view virtual returns (bool) {
        return referendumProposalThreshold(id) >= referendumProposalRequiredThreshold(id);
    }

    /** Has Passed */

    /**
    * @notice Emits when a Referendum Proposal has successfully passed.
    * @param id The unique identifier of the Referendum Proposal.
    */
    event ReferendumProposalHasPassed(uint256 indexed id);

    /**
    * @notice Generates a unique key representing whether a Referendum Proposal has passed.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal has passed status.
    */
    function referendumProposalHasPassedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_HAS_PASSED", id));
    }

    /**
    * @notice Checks if a Referendum Proposal has passed.
    * @param id The unique identifier of the Referendum Proposal.
    * @return True if the Referendum Proposal has passed, otherwise false.
    */
    function referendumProposalHasPassed(uint256 id) public view virtual returns (bool) {
        return _bool[referendumProposalHasPassedKey(id)];
    }

    /**
    * @dev Internal function to toggle the status of a Referendum Proposal to "has passed."
    * @param id The unique identifier of the Referendum Proposal.
    */
    function _toggleReferendumProposalHasPassed(uint256 id) internal virtual {
        _bool[referendumProposalHasPassedKey(id)] = true;
        emit ReferendumProposalHasPassed(id);
    }

    /** Is Executed */

    /**
    * @notice Emits when a Referendum Proposal has been successfully executed.
    * @param id The unique identifier of the Referendum Proposal.
    */
    event ReferendumProposalHasBeenExecuted(uint256 indexed id);

    /**
    * @notice Generates a unique key representing whether a Referendum Proposal has been executed.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal executed status.
    */
    function referendumProposalIsExecutedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_IS_EXECUTED", id));
    }

    /**
    * @notice Checks if a Referendum Proposal has been executed.
    * @param id The unique identifier of the Referendum Proposal.
    * @return True if the Referendum Proposal has been executed, otherwise false.
    */
    function referendumProposalIsExecuted(uint256 id) public view virtual returns (bool) {
        return _bool[referendumProposalIsExecutedKey(id)];
    }

    /**
    * @dev Internal function to toggle the status of a Referendum Proposal to "has been executed."
    * @param id The unique identifier of the Referendum Proposal.
    */
    function _toggleReferendumProposalHasBeenExecuted(uint256 id) internal virtual {
        _bool[referendumProposalIsExecutedKey(id)] = true;
        emit ReferendumProposalHasBeenExecuted(id);
    }

    /** Min Balance To Vote */

    /**
    * @notice Emits when the minimum balance required to vote on a Referendum Proposal is successfully updated.
    * @param id The unique identifier of the Referendum Proposal.
    * @param amount The updated minimum balance to vote.
    */
    event ReferendumProposalMinBalanceToVoteSetTo(uint256 indexed id, uint256 indexed amount);

    /**
    * @notice Generates a unique key representing the minimum balance to vote for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal minimum balance to vote.
    */
    function referendumProposalMinBalanceToVoteKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_MIN_BALANCE_TO_VOTE", id));
    }

    /**
    * @notice Gets the minimum balance required to vote for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The minimum balance to vote for the specified Referendum Proposal.
    */
    function referendumProposalMinBalanceToVote(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalMinBalanceToVoteKey(id)];
    }

    /**
    * @dev Internal function to set the minimum balance required to vote for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param amount The new minimum balance to vote to be set.
    */
    function _setReferendumProposalMinBalanceToVote(uint256 id, uint256 amount) internal virtual {
        uint256 totalSupplyAt = IDream(referendumProposalVotingERC20(id)).totalSupplyAt(referendumProposalSnapshotId(id));
        amount.onlyBetween(0, totalSupplyAt);
        _uint256[referendumProposalMinBalanceToVoteKey(id)].onlynotMatchingValue(amount);
        _uint256[referendumProposalMinBalanceToVoteKey(id)] = amount;
        emit ReferendumProposalMinBalanceToVoteSetTo(id, amount);
    }

    /** Support */

    /**
    * @notice Emits when support votes are gained for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param amount The amount of support votes gained.
    */
    event ReferendumProposalSupportVoteGained(uint256 indexed id, uint256 indexed amount);

    /**
    * @notice Generates a unique key representing the support votes for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal support votes.
    */
    function referendumProposalSupportVoteKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_SUPPORT_VOTE", id));
    }

    /**
    * @notice Gets the amount of support votes for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The amount of support votes for the specified Referendum Proposal.
    */
    function referendumProposalSupportVote(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalSupportVoteKey(id)];
    }

    /**
    * @dev Internal function to increase the amount of support votes for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param amount The amount by which to increase the support votes.
    */
    function _increaseReferendumProposalSupportVote(uint256 id, uint256 amount) internal virtual {
        _uint256[referendumProposalSupportVoteKey(id)] += amount;
        emit ReferendumProposalSupportVoteGained(id, amount);
    }

    /** Against */

    /**
    * @notice Emits when against votes are gained for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param amount The amount of against votes gained.
    */
    event ReferendumProposalAgainstVoteGained(uint256 indexed id, uint256 indexed amount);

    /**
    * @notice Generates a unique key representing the against votes for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal against votes.
    */
    function referendumProposalAgainstVoteKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_AGAINST_VOTE", id));
    }

    /**
    * @notice Gets the amount of against votes for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The amount of against votes for the specified Referendum Proposal.
    */
    function referendumProposalAgainstVote(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalAgainstVoteKey(id)];
    }

    /**
    * @dev Internal function to increase the amount of against votes for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param amount The amount by which to increase the against votes.
    */
    function _increaseReferendumProposalAgainstVote(uint256 id, uint256 amount) internal virtual {
        _uint256[referendumProposalAgainstVoteKey(id)] += amount;
        emit ReferendumProposalAgainstVoteGained(id, amount);
    }

    /** Abstain */

    /**
    * @notice Emits when abstain votes are gained for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param amount The amount of abstain votes gained.
    */
    event ReferendumProposalAbstainVoteGained(uint256 indexed id, uint256 indexed amount);

    /**
    * @notice Generates a unique key representing the abstain votes for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal abstain votes.
    */
    function referendumProposalAbstainVoteKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_ABSTAIN_VOTE", id));
    }

    /**
    * @notice Gets the amount of abstain votes for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The amount of abstain votes for the specified Referendum Proposal.
    */
    function referendumProposalAbstainVote(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalAbstainVoteKey(id)];
    }

    /**
    * @dev Internal function to increase the amount of abstain votes for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param amount The amount by which to increase the abstain votes.
    */
    function _increaseReferendumProposalAbstainVote(uint256 id, uint256 amount) internal virtual {
        _uint256[referendumProposalAbstainVoteKey(id)] += amount;
        emit ReferendumProposalAbstainVoteGained(id, amount);
    }

    /** Snapshot ID */

    /**
    * @notice Emits when the snapshot ID is set for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param snapshotId The snapshot ID set for the Referendum Proposal.
    */
    event ReferendumProposalSnapshotIdSetTo(uint256 indexed id, uint256 indexed snapshotId);

    /**
    * @notice Generates a unique key representing the snapshot ID for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal snapshot ID.
    */
    function referendumProposalSnapshotIdKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_SNAPSHOT_ID", id));
    }

    /**
    * @notice Gets the snapshot ID for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The snapshot ID for the specified Referendum Proposal.
    */
    function referendumProposalSnapshotId(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalSnapshotIdKey(id)];
    }

    /**
    * @dev Internal function to set the snapshot ID for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param snapshotId The snapshot ID to set for the Referendum Proposal.
    */
    function _setReferendumProposalSnapshotId(uint256 id, uint256 snapshotId) internal virtual {
        _uint256[referendumProposalSnapshotIdKey(id)].onlynotMatchingValue(snapshotId);
        _uint256[referendumProposalSnapshotIdKey(id)] = snapshotId;
    }

    /** Voting ERC20 */

    /**
    * @notice Emits when the voting ERC20 contract is set for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param erc20 The address of the voting ERC20 contract set for the Referendum Proposal.
    */
    event ReferendumProposalVotingERC20SetTo(uint256 indexed id, address indexed erc20);

    /**
    * @notice Generates a unique key representing the voting ERC20 contract for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal voting ERC20 contract.
    */
    function referendumProposalVotingERC20Key(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_VOTING_ERC20", id));
    }

    /**
    * @notice Gets the address of the voting ERC20 contract for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The address of the voting ERC20 contract for the specified Referendum Proposal.
    */
    function referendumProposalVotingERC20(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalVotingERC20Key(id)];
    }

    /**
    * @dev Internal function to set the voting ERC20 contract for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param erc20 The address of the voting ERC20 contract to set for the Referendum Proposal.
    */
    function _setReferendumProposalVotingERC20(uint256 id, address erc20) internal virtual {
        erc20.onlyGovernanceERC20();
        _address[referendumProposalVotingERC20Key(id)].onlynotAddress(erc20);
        _address[referendumProposalVotingERC20Key(id)] = erc20;
        emit ReferendumProposalVotingERC20SetTo(id, erc20);
    }

    /** Target */

    /**
    * @notice Emits when the target address is set for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param target The address of the target contract set for the Referendum Proposal.
    */
    event ReferendumProposalTargetSetTo(uint256 indexed id, address indexed target);

    /**
    * @notice Generates a unique key representing the target address for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal target address.
    */
    function referendumProposalTargetKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_TARGET", id));
    }

    /**
    * @notice Gets the address of the target contract for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The address of the target contract for the specified Referendum Proposal.
    */
    function referendumProposalTarget(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalTargetKey(id)];
    }

    /**
    * @dev Internal function to set the target address for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param target The address of the target contract to set for the Referendum Proposal.
    */
    function _setReferendumProposalTarget(uint256 id, address target) internal virtual {
        _address[referendumProposalTargetKey(id)].onlynotAddress(target);
        _address[referendumProposalTargetKey(id)] = target;
        emit ReferendumProposalTargetSetTo(id, target);
    }

    /** Data */

    /**
    * @notice Emits when the data payload is set for a Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param data The data payload set for the Referendum Proposal.
    */
    event ReferendumProposalDataSetTo(uint256 indexed id, bytes indexed data);

    /**
    * @notice Generates a unique key representing the data payload for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return A unique key for the specified Referendum Proposal data payload.
    */
    function referendumProposalDataKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_DATA", id));
    }

    /**
    * @notice Retrieves the data payload for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @return The data payload associated with the specified Referendum Proposal.
    */
    function referendumProposalData(uint256 id) public view virtual returns (bytes memory) {
        return _bytes[referendumProposalDataKey(id)];
    }

    /**
    * @notice Sets the data payload for a specific Referendum Proposal.
    * @param id The unique identifier of the Referendum Proposal.
    * @param data The data payload to be set for the Referendum Proposal.
    */
    function _setReferendumProposalData(uint256 id, bytes memory data) internal virtual {
        _bytes[referendumProposalDataKey(id)].onlynotMatchingValue(data);
        _bytes[referendumProposalDataKey(id)] = data;
        emit ReferendumProposalDataSetTo(id, data);
    }

    /** Count */

    /**
    * @notice Event emitted when the count of Referendum Proposals is incremented.
    * @param id The unique identifier of the newly created Referendum Proposal.
    */
    event ReferendumProposalsCountIncremented(uint256 indexed id);

    /**
    * @notice Retrieves the key for storing the count of Referendum Proposals.
    * @return The key for storing the count of Referendum Proposals.
    */
    function referendumProposalsCountKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSALS_COUNT"));
    }

    /**
    * @notice Retrieves the current count of Referendum Proposals.
    * @return The current count of Referendum Proposals.
    */
    function referendumProposalsCount() public view virtual returns (uint256) {
        return _uint256[referendumProposalsCountKey()];
    }

    /**
    * @notice Increments the count of Referendum Proposals and emits an event.
    */
    function _incrementReferendumProposalsCount() internal virtual returns (uint256) {
        _uint256[referendumProposalsCountKey()] += 1;
        emit ReferendumProposalsCountIncremented(_uint256[referendumProposalsCountKey()]);
        return _uint256[referendumProposalsCountKey()];
    }

    /** Math */

    /**
    * @notice Calculates the total quorum for a Referendum Proposal.
    * @param id The ID of the Referendum Proposal.
    * @return The total quorum.
    */
    function referendumProposalQuorum(uint256 id) public view virtual returns (uint256) {
        return referendumProposalSupportVote(id) + referendumProposalAgainstVote(id) + referendumProposalAbstainVote(id);
    }

    /**
    * @notice Calculates the required number of votes for a Referendum Proposal based on quorum.
    * @param id The ID of the Referendum Proposal.
    * @return The required number of votes.
    */
    function referendumProposalRequiredVotes(uint256 id) public view virtual returns (uint256) {
        IDream votingERC20 = IDream(referendumProposalVotingERC20(id));
        uint256 totalSupplyAt = votingERC20.totalSupplyAt(referendumProposalSnapshotId(id));
        return (totalSupplyAt * referendumProposalRequiredQuorum(id)) / 10000;
    }
}