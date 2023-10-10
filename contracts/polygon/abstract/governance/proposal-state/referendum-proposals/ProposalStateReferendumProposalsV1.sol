// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/token/dream/IDream.sol";

/**
 * @title ProposalStateReferendumProposalsV1
 */
abstract contract ProposalStateReferendumProposalsV1 is StateV1 {

    /**
    * @dev Use the `EnumerableSet` library to provide additional functionality for handling sets of addresses.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @dev Emitted when a referendum proposal is successfully executed.
    * 
    * {id} is the unique identifier of the executed proposal.
    */
    event ReferendumProposalExecuted(uint256 indexed id);

    /**
    * @dev Emitted when a vote is cast on a referendum proposal.
    * 
    * {id} is the unique identifier of the proposal being voted on.
    * {side} represents the chosen side of the vote (e.g., in favor, against).
    * {voter} is the address of the participant who cast the vote.
    */
    event ReferendumProposalVote(uint256 indexed id, uint256 indexed side, address indexed voter);

    /**
    * @dev Emitted when a referendum proposal has successfully passed.
    * 
    * {id} is the unique identifier of the passed proposal.
    */
    event ReferendumProposalHasPassed(uint256 indexed id);

    /**
    * @dev Emitted when the required voting threshold for a referendum proposal is set or updated.
    * 
    * {id} is the unique identifier of the proposal.
    * {bp} represents the new threshold in basis points.
    */
    event ReferendumProposalRequiredThresholdSetTo(uint256 indexed id, uint256 indexed bp);

    /**
    * @dev Emitted when the caption for a referendum proposal is set or updated.
    * 
    * {id} is the unique identifier of the proposal.
    * {caption} is the new caption describing the proposal.
    */
    event ReferendumProposalCaptionSetTo(uint256 indexed id, string indexed caption);

    /**
    * @dev Emitted when the message for a referendum proposal is set or updated.
    * 
    * {id} is the unique identifier of the proposal.
    * {message} is the new message associated with the proposal.
    */
    event ReferendumProposalMessageSetTo(uint256 indexed id, string indexed message);

    /**
    * @dev Emitted when the creator of a referendum proposal is set or updated.
    * 
    * {id} is the unique identifier of the proposal.
    * {creator} is the address of the new creator of the proposal.
    */
    event ReferendumProposalCreatorSetTo(uint256 indexed id, address indexed creator);

    /**
    * @dev Emitted when the start timestamp for a referendum proposal is set or updated.
    * 
    * {id} is the unique identifier of the proposal.
    * {timestamp} is the new start timestamp for the proposal.
    */
    event ReferendumProposalStartTimestampSetTo(uint256 indexed id, uint256 indexed timestamp);

    /**
    * @dev Emitted when the duration for a referendum proposal is set or updated.
    * 
    * {id} is the unique identifier of the proposal.
    * {seconds_} is the new duration for the proposal in seconds.
    */
    event ReferendumProposalDurationSetTo(uint256 indexed id, uint256 indexed seconds_);

    /**
    * @dev Emitted when the minimum balance required to vote on a referendum proposal is set or updated.
    * 
    * {id} is the unique identifier of the proposal.
    * {minBalance} is the new minimum balance required for voting on the proposal.
    */
    event ReferendumProposalMinBalanceToVoteSetTo(uint256 indexed id, uint256 indexed minBalance);

    /**
    * @dev Emitted when the ERC-20 token used for voting on a referendum proposal is set or updated.
    * 
    * {id} is the unique identifier of the proposal.
    * {erc20} is the address of the ERC-20 token used for voting on the proposal.
    */
    event ReferendumProposalVotingERC20SetTo(uint256 indexed id, address indexed erc20);

    /**
    * @dev Emitted when the snapshot ID for a referendum proposal is set or updated.
    * 
    * {id} is the unique identifier of the proposal.
    * {snapshotId} is the new snapshot ID associated with the proposal.
    */
    event ReferendumProposalSnapshotIdSetTo(uint256 indexed id, uint256 indexed snapshotId);

    /**
    * @dev Emitted when the target address for a referendum proposal is set or updated.
    * 
    * {id} is the unique identifier of the proposal.
    * {target} is the new target address associated with the proposal.
    */
    event ReferendumProposalTargetSetTo(uint256 indexed id, address indexed target);

    /**
    * @dev Emitted when the data for a referendum proposal is set or updated.
    * 
    * {id} is the unique identifier of the proposal.
    * {data} is the new data associated with the proposal.
    */
    event ReferendumProposalDataSetTo(uint256 indexed id, bytes indexed data);

    /**
    * @dev Emitted when a referendum proposal is incremented.
    * 
    * {id} is the unique identifier of the incremented proposal.
    */
    event ReferendumProposalIncremented(uint256 indexed id);

    /**
    * @notice Emits when the quorum set for a Referendum Proposal is required to be set to a specific value.
    * @param id The unique identifier of the Referendum Proposal.
    * @param bp The new quorum set value, represented as a percentage with 18 decimals.
    */
    event ReferendumProposalRequiredQuorumSetTo(uint256 indexed id, uint256 indexed bp);

    /** Keys. */

    /**
    * @dev Generates a unique key for storing the accounts that voted on a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal voters storage.
    */
    function referendumProposalVotersKey(uint256 id) public pure virtual returns (bytes32) {
        /** 
        * @dev Accounts that voted on the specified referendum proposal.
        */
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_VOTERS", id));
    }

    /**
    * @dev Generates a unique key for storing the caption of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal caption storage.
    */
    function referendumProposalCaptionKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_CAPTION", id));
    }

    /**
    * @dev Generates a unique key for storing the message of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal message storage.
    */
    function referendumProposalMessageKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_MESSAGE", id));
    }

    /**
    * @dev Generates a unique key for storing the creator of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal creator storage.
    */
    function referendumProposalCreatorKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_CREATOR", id));
    }

    /**
    * @dev Generates a unique key for storing the start timestamp of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal start timestamp storage.
    */
    function referendumProposalStartTimestampKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_START_TIMESTAMP", id));
    }

    /**
    * @dev Generates a unique key for storing the duration of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal duration storage.
    */
    function referendumProposalDurationKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_DURATION", id));
    }

    /**
    * @dev Generates a unique key for storing the required quorum of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal required quorum storage.
    */
    function referendumProposalRequiredQuorumKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_REQUIRED_QUORUM", id));
    }

    /**
    * @dev Generates a unique key for storing the required voting threshold of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal required threshold storage.
    */
    function referendumProposalRequiredThresholdKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_REQUIRED_THRESHOLD", id));
    }

    /**
    * @dev Generates a unique key for storing the status of whether a specific referendum proposal has passed.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal has passed status storage.
    */
    function referendumProposalHasPassedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_HAS_PASSED", id));
    }

    /**
    * @dev Generates a unique key for storing the status of whether a specific referendum proposal has been executed.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal executed status storage.
    */
    function referendumProposalExecutedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_EXECUTED", id));
    }

    /**
    * @dev Generates a unique key for storing the minimum balance required to vote on a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal minimum balance to vote storage.
    */
    function referendumProposalMinBalanceToVoteKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_MIN_BALANCE_TO_VOTE", id));
    }

    /**
    * @dev Generates a unique key for storing the support data of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal support data storage.
    */
    function referendumProposalSupportKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_SUPPORT", id));
    }

    /**
    * @dev Generates a unique key for storing the against data of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal against data storage.
    */
    function referendumProposalAgainstKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_AGAINST", id));
    }

    /**
    * @dev Generates a unique key for storing the abstain data of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal abstain data storage.
    */
    function referendumProposalAbstainKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_ABSTAIN", id));
    }

    /**
    * @dev Generates a unique key for storing the snapshot ID of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal snapshot ID storage.
    */
    function referendumProposalSnapshotIdKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_SNAPSHOT_ID", id));
    }

    /**
    * @dev Generates a unique key for storing the ERC-20 token used for voting on a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal voting ERC-20 token storage.
    */
    function referendumProposalVotingERC20Key(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_VOTING_ERC20", id));
    }

    /**
    * @dev Generates a unique key for storing the total count of referendum proposals.
    * 
    * @return bytes32 A unique key for the referendum proposals count storage.
    */
    function referendumProposalCountKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSALS_COUNT"));
    }

    /**
    * @dev Generates a unique key for storing the target address of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal target address storage.
    */
    function referendumProposalTargetKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_TARGET"));
    }

    /**
    * @dev Generates a unique key for storing the data of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes32 A unique key for the referendum proposal data storage.
    */
    function referendumProposalDataKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_DATA"));
    }

    /** Getters. */

    /**
    * @dev Retrieves the support count for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The number of votes in support of the proposal.
    */
    function referendumProposalSupport(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalSupportKey(id)];
    }

    /**
    * @dev Retrieves the against count for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The number of votes against the proposal.
    */
    function referendumProposalAgainst(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalAgainstKey(id)];
    }

    /**
    * @dev Retrieves the abstain count for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The number of abstain votes on the proposal.
    */
    function referendumProposalAbstain(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalAbstainKey(id)];
    }

    /**
    * @dev Calculates the total number of votes (quorum) for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The total number of votes, including support, against, and abstain votes.
    */
    function referendumProposalQuorum(uint256 id) public view virtual returns (uint256) {
        return referendumProposalSupport(id) + referendumProposalAgainst(id) + referendumProposalAbstain(id);
    }

    /**
    * @dev Retrieves the required quorum for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The required quorum for the proposal.
    */
    function referendumProposalRequiredQuorum(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalRequiredQuorumKey(id)];
    }

    /**
    * @dev Calculates the required number of votes for a specific referendum proposal based on the quorum percentage.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The required number of votes for the proposal.
    */
    function referendumProposalRequiredVotes(uint256 id) public view virtual returns (uint256) {
        IDream votingERC20 = IDream(referendumProposalVotingERC20(id));
        return (votingERC20.totalSupplyAt(referendumProposalSnapshotId(id)) * referendumProposalRequiredQuorum(id)) / 10000;
    }

    /**
    * @dev Checks if a specific referendum proposal has obtained sufficient quorum.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bool True if the proposal has sufficient quorum, otherwise false.
    */
    function referendumProposalHasSufficientQuorum(uint256 id) public view virtual returns (bool) {
        return referendumProposalQuorum(id) >= referendumProposalRequiredVotes(id);
    }

    /**
    * @dev Retrieves the required voting threshold for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The required voting threshold for the proposal.
    */
    function referendumProposalRequiredThreshold(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalRequiredThresholdKey(id)];
    }

    /**
    * @dev Calculates the current voting threshold for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The current voting threshold for the proposal.
    */
    function referendumProposalThreshold(uint256 id) public view virtual returns (uint256) {
        return (referendumProposalSupport(id) * 10000) / referendumProposalQuorum(id);
    }

    /**
    * @dev Checks if a specific referendum proposal has obtained sufficient voting threshold.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bool True if the proposal has sufficient voting threshold, otherwise false.
    */
    function referendumProposalHasSufficientThreshold(uint256 id) public view virtual returns (bool) {
        return referendumProposalThreshold(id) >= referendumProposalRequiredThreshold(id);
    }

    /**
    * @dev Retrieves the address of a voter for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param voterId The index of the voter in the set of voters for the proposal.
    * @return address The address of the voter.
    */
    function referendumProposalVoters(uint256 id, uint256 voterId) public view virtual returns (address) {
        return _addressSet[referendumProposalVotersKey(id)].at(voterId);
    }

    /**
    * @dev Retrieves the total number of voters for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The total number of voters for the proposal.
    */
    function referendumProposalVotersLength(uint256 id) public view virtual returns (uint256) {
        return _addressSet[referendumProposalVotersKey(id)].length();
    }

    /**
    * @dev Checks if an account is a voter for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param account The address of the account to check.
    * @return bool True if the account is a voter, otherwise false.
    */
    function isReferendumProposalVoter(uint256 id, address account) public view virtual returns (bool) {
        return _addressSet[referendumProposalVotersKey(id)].contains(account);
    }

    /**
    * @dev Retrieves the caption of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return string The caption of the proposal.
    */
    function referendumProposalCaption(uint256 id) public view virtual returns (string memory) {
        return _string[referendumProposalCaptionKey(id)];
    }

    /**
    * @dev Retrieves the message of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return string The message associated with the proposal.
    */
    function referendumProposalMessage(uint256 id) public view virtual returns (string memory) {
        return _string[referendumProposalMessageKey(id)];
    }

    /**
    * @dev Retrieves the creator address of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return address The address of the creator of the proposal.
    */
    function referendumProposalCreator(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalCreatorKey(id)];
    }

    /**
    * @dev Retrieves the start timestamp of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The start timestamp of the proposal.
    */
    function referendumProposalStartTimestamp(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalStartTimestampKey(id)];
    }

    /**
    * @dev Calculates the end timestamp of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The end timestamp of the proposal.
    */
    function referendumProposalEndTimestamp(uint256 id) public view virtual returns (uint256) {
        return referendumProposalStartTimestamp(id) + referendumProposalDuration(id);
    }

    /**
    * @dev Retrieves the duration of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The duration of the proposal in seconds.
    */
    function referendumProposalDuration(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalDurationKey(id)];
    }

    /**
    * @dev Checks if a specific referendum proposal has passed.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bool True if the proposal has passed, otherwise false.
    */
    function referendumProposalHasPassed(uint256 id) public view virtual returns (bool) {
        return _bool[referendumProposalHasPassedKey(id)];
    }

    /**
    * @dev Checks if a specific referendum proposal has been executed.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bool True if the proposal has been executed, otherwise false.
    */
    function referendumProposalExecuted(uint256 id) public view virtual returns (bool) {
        return _bool[referendumProposalExecutedKey(id)];
    }

    /**
    * @dev Checks if a specific referendum proposal has started.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bool True if the proposal has started, otherwise false.
    */
    function referendumProposalHasStarted(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= referendumProposalStartTimestamp(id);
    }

    /**
    * @dev Checks if a specific referendum proposal has ended.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bool True if the proposal has ended, otherwise false.
    */
    function referendumProposalHasEnded(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= referendumProposalEndTimestamp(id);
    }

    /**
    * @dev Retrieves the minimum balance required to vote on a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The minimum balance required for voting on the proposal.
    */
    function referendumProposalMinBalanceToVote(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalMinBalanceToVoteKey(id)];
    }

    /**
    * @dev Retrieves the snapshot ID of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The snapshot ID associated with the proposal.
    */
    function referendumProposalSnapshotId(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalSnapshotIdKey(id)];
    }

    /**
    * @dev Calculates the remaining seconds for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return uint256 The remaining seconds for the proposal.
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

    /**
    * @dev Retrieves the ERC-20 token address used for voting on a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return address The address of the ERC-20 token used for voting on the proposal.
    */
    function referendumProposalVotingERC20(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalVotingERC20Key(id)];
    }

    /**
    * @dev Checks if an account is eligible to vote for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param account The address of the account to check.
    * @return bool True if the account can vote, otherwise false.
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

    /**
    * @dev Retrieves the target address of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return address The target address of the proposal.
    */
    function referendumProposalTarget(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalTargetKey(id)];
    }

    /**
    * @dev Retrieves the data of a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @return bytes The data associated with the proposal.
    */
    function referendumProposalData(uint256 id) public view virtual returns (bytes memory) {
        return _bytes[referendumProposalDataKey(id)];
    }

    /**
    * @dev Internal function to handle voting on a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param side The voting side (0 for abstain, 1 for against, 2 for support).
    */
    function _voteOnReferendumProposal(uint256 id, uint256 side) internal virtual {
        require(
            !isReferendumProposalVoter(id, msg.sender),
            "ProposalStateReferendumProposalsV1: cannot vote because sender has already voted"
        );
        require(
            canVoteForReferendumProposal(id, msg.sender),
            "ProposalStateReferendumProposalV1: cannot vote because balance at snapshot was insufficient"
        );
        require(
            referendumProposalHasStarted(id),
            "ProposalStateReferendumProposalV1: cannot vote because referendum has not begun yet"
        );
        require(
            !referendumProposalHasEnded(id),
            "ProposalStateReferendumProposalV1: cannot vote because referendum has ended"
        );
        uint256 votes = IDream(referendumProposalVotingERC20(id)).balanceOfAt(msg.sender, referendumProposalSnapshotId(id));
        _addressSet[referendumProposalVotersKey(id)].add(msg.sender);
        if (side == 0) {
            _uint256[referendumProposalAbstainKey(id)] += votes;
        }
        else if (side == 1) {
            _uint256[referendumProposalAgainstKey(id)] += votes;
        }
        else if (side == 2) {
            _uint256[referendumProposalSupportKey(id)] += votes;
        }
        else {
            revert("Invalid input");
        }
        emit ReferendumProposalVote(id, side, msg.sender);
        if (referendumProposalHasSufficientQuorum(id) && referendumProposalHasSufficientThreshold(id)) {
            _bool[referendumProposalHasPassedKey(id)] = true;
            emit ReferendumProposalHasPassed(id);
        }
    }

    /**
    * @dev Internal function to execute a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    */
    function _executeReferendumProposal(uint256 id) internal virtual {
        require(
            referendumProposalHasStarted(id),
            "ProposalStateReferendumProposalV1: cannot execute because referendum has not begun yet"
        );
        require(
            !referendumProposalHasEnded(id),
            "ProposalStateReferendumProposalV1: cannot execute because referendum has ended"
        );
        require(
            referendumProposalHasPassed(id),
            "ProposalStateReferendumProposalV1: cannot execute because referendum has not passed"
        );
        _bool[referendumProposalExecutedKey(id)] = true;
        emit ReferendumProposalExecuted(id);
    }

    /**
    * @dev Internal function to set the required voting threshold for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param bp The new value for the required voting threshold in basis points.
    */
    function _setReferendumProposalRequiredThreshold(uint256 id, uint256 bp) internal virtual {
        require(
            bp <= 10000,
            "ProposalStateReferendumProposalsV1: value is out of bounds | max: 10000"
        );
        _uint256[referendumProposalRequiredThresholdKey(id)] = bp;
        emit ReferendumProposalRequiredThresholdSetTo(id, bp);
    }

    /**
    * @dev Internal function to set the required quorum for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param bp The new value for the required quorum in basis points.
    */
    function _setReferendumProposalRequiredQuorum(uint256 id, uint256 bp) internal virtual {
        require(
            bp <= 10000,
            "ProposalStateReferendumProposalsV1: value is out of bounds | max: 10000"
        );
        _uint256[referendumProposalRequiredQuorumKey(id)] = bp;
        emit ReferendumProposalRequiredQuorumSetTo(id, bp);
    }

    /**
    * @dev Internal function to set the caption for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param caption The new caption for the proposal.
    */
    function _setReferendumProposalCaption(uint256 id, string memory caption) internal virtual {
        _string[referendumProposalCaptionKey(id)] = caption;
        emit ReferendumProposalCaptionSetTo(id, caption);
    }

    /**
    * @dev Internal function to set the message for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param message The new message for the proposal.
    */
    function _setReferendumProposalMessage(uint256 id, string memory message) internal virtual {
        _string[referendumProposalMessageKey(id)] = message;
        emit ReferendumProposalMessageSetTo(id, message);
    }

    /**
    * @dev Internal function to set the creator address for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param creator The new creator address for the proposal.
    */
    function _setReferendumProposalCreator(uint256 id, address creator) internal virtual {
        _address[referendumProposalCreatorKey(id)] = creator;
        emit ReferendumProposalCreatorSetTo(id, creator);
    }

    /**
    * @dev Internal function to set the start timestamp for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param timestamp The new start timestamp for the proposal.
    */
    function _setReferendumProposalStartTimestamp(uint256 id, uint256 timestamp) internal virtual {
        _uint256[referendumProposalStartTimestampKey(id)] = timestamp;
        emit ReferendumProposalStartTimestampSetTo(id, timestamp);
    }

    /**
    * @dev Internal function to set the duration for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param seconds_ The new duration for the proposal in seconds.
    */
    function _setReferendumProposalDuration(uint256 id, uint256 seconds_) internal virtual {
        _uint256[referendumProposalDurationKey(id)] = seconds_;
        emit ReferendumProposalDurationSetTo(id, seconds_);
    }

    /**
    * @dev Internal function to set the minimum balance required to vote for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param minBalance The new minimum balance required for voting on the proposal.
    */
    function _setReferendumProposalMinBalanceToVote(uint256 id, uint256 minBalance) internal virtual {
        _uint256[referendumProposalMinBalanceToVoteKey(id)] = minBalance;
        emit ReferendumProposalMinBalanceToVoteSetTo(id, minBalance);
    }

    /**
    * @dev Internal function to set the ERC-20 token for voting on a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param erc20 The new address of the ERC-20 token for voting on the proposal.
    */
    function _setReferendumProposalVotingERC20(uint256 id, address erc20) internal virtual {
        _address[referendumProposalVotingERC20Key(id)] = erc20;
        emit ReferendumProposalVotingERC20SetTo(id, erc20);
    }

    /**
    * @dev Internal function to set the snapshot ID for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param snapshotId The new snapshot ID for the proposal.
    */
    function _setReferendumProposalSnapshotId(uint256 id, uint256 snapshotId) internal virtual {
        _uint256[referendumProposalSnapshotIdKey(id)] = snapshotId;
        emit ReferendumProposalSnapshotIdSetTo(id, snapshotId);
    }

    /**
    * @dev Internal function to set the target address for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param target The new target address for the proposal.
    */
    function _setReferendumProposalTarget(uint256 id, address target) internal virtual {
        _address[referendumProposalTargetKey(id)] = target;
        emit ReferendumProposalTargetSetTo(id, target);
    }

    /**
    * @dev Internal function to set the data for a specific referendum proposal.
    * 
    * @param id The unique identifier of the referendum proposal.
    * @param data The new data for the proposal.
    */
    function _setReferendumProposalData(uint256 id, bytes memory data) internal virtual {
        _bytes[referendumProposalDataKey(id)] = data;
        emit ReferendumProposalDataSetTo(id, data);
    }

    /**
    * @dev Internal function to increment the count of referendum proposals.
    * 
    * @return uint256 The updated count of referendum proposals.
    */
    function _incrementReferendumProposalsCount() internal virtual returns (uint256) {
        _uint256[referendumProposalCountKey()] += 1;
        emit ReferendumProposalIncremented(_uint256[referendumProposalCountKey()]);
        return _uint256[referendumProposalCountKey()];
    }
}