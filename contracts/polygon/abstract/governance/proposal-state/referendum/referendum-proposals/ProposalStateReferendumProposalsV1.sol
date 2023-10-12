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
    using EnumerableSet for EnumerableSet.AddressSet;

    using Uint256FlagsV1 for uint256;

    using AddressFlagsV1 for address;

    using StringFlagsV1 for string;

    using BytesFlagsV1 for bytes;

    /** Conditions */

    function hasSufficientBalanceAtSnapshotToVote(uint256 id, address account) public view virtual returns (bool) {
        accountBalance = IDream(referendumProposalVotingERC20(id)).balanceOfAt(account, referendumProposalSnapshotId(id));
        if (accountBalance >= referendumProposalMinBalanceToVote(id)) { return true; }
        else { return false; }
    }

    function referendumProposalHasSufficientQuorum(uint256 id) public view virtual returns (bool) {
        return referendumProposalQuorum(id) >= referendumProposalRequiredVotes(id);
    }

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

    event ReferendumProposalNewVote(uint256 indexed id, address indexed account);

    function hasVotedForReferendumProposalKey(uint256 id, address account) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_VOTERS", id, account));
    }

    function hasVotedForReferendumProposal(uint256 id, address account) public view virtual returns (bool) {
        _bool[referendumProposalHasVotedKey(id, account)];
    }

    function _toggleHasVotedForReferendumProposal(uint256 id, address account) internal virtual {
        _bool[referendumProposalHasVotedKey(id, account)] = true;
        emit ReferendumProposalNewVote(id, account);
    }

    function _voteOnReferendumProposal(uint256 id, uint256 side) internal virtual {
        require(!hasVotedForReferendumProposal(id, msg.sender), "ProposalStateReferendumProposalsV1: hasVotedForReferendumProposal(id,msg.sender)");
        require(canVoteForReferendumProposal(id, msg.sender), "ProposalStateReferendumProposalsV1: !canVoteForReferendumProposal(id,msg.sender)");
        require(referendumProposalHasStarted(id), "ProposalStateReferendumProposalsV1: !referendumProposalHasStarted(id)");
        require(!referendumProposalHasEnded(id), "ProposalStateReferendumProposalsV1: referendumProposalHasEnded(id)");
        uint256 votes = IDream(referendumProposalVotingERC20(id).balanceOfAt(msg.sender, referendumProposalSnapshotId(id)));
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

    function _executeReferendumProposal(uint256 id) internal virtual {
        require(referendumProposalHasStarted(id), "ProposalStateReferendumProposalsV1: !referendumProposalHasStarted(id)");
        require(!referendumProposalHasEnded(id), "ProposalStateReferendumProposalsV1: referendumProposalHasEnded(id)");
        require(referendumProposalHasPassed(id), "ProposalStateReferendumProposalsV1: !referendumProposalHasPassed(id)");
        _toggleReferendumProposalHasBeenExecuted(id);
    }

    /** Caption */

    event ReferendumProposalCaptionSetTo(uint256 indexed id, string indexed caption);

    function referendumProposalCaptionKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_CAPTION", id));
    }

    function referendumProposalCaption(uint256 id) public view virtual returns (string memory) {
        return _string[referendumProposalCaptionKey(id)];
    }

    function _setReferendumProposalCaption(uint256 id, string memory caption) internal virtual {
        string memory emptyString;
        caption.onlynotMatchingValue(emptyString);
        _string[referendumProposalCaptionKey(id)].onlynotMatchingValue(caption);
        _string[referendumProposalCaptionKey(id)] = caption;
        emit ReferendumProposalCaptionSetTo(id, caption);
    }

    /** Message */

    event ReferendumProposalMessageSetTo(uint256 indexed id, string indexed message);

    function referendumProposalMessageKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_MESSAGE", id));
    }

    function referendumProposalMessage(uint256 id) public view virtual returns (string memory) {
        return _string[referendumProposalMessageKey(id)];
    }

    function _setReferendumProposalMessage(uint256 id, string memory message) internal virtual {
        string memory emptyString;
        message.onlynotMatchingValue(emptyString);
        _string[referendumProposalMessageKey(id)].onlynotMatchingValue(message);
        _string[referendumProposalMessageKey(id)] = message;
        emit ReferendumProposalMessageSetTo(id, message);
    }

    /** Creator */

    event ReferendumProposalCreatorSetTo(uint256 indexed id, address indexed creator);

    function referendumProposalCreatorKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_CREATOR", id));
    }

    function referendumProposalCreator(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalCreatorKey(id)];
    }

    function _setReferendumProposalCreator(uint256 id, address creator) internal virtual {
        _address[referendumProposalCreatorKey(id)].onlynotAddress(creator);
        _address[referendumProposalCreatorKey(id)] = creator;
        emit ReferendumProposalCreatorSetTo(id, creator);
    }

    /** Start Timestamp */

    event ReferendumProposalStartTimestampSetTo(uint256 indexed id, uint256 indexed timestamp);

    function referendumProposalStartTimestampKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_START_TIMESTAMP", id));
    }

    function referendumProposalStartTimestamp(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalStartTimestampKey(id)];
    }

    function _setReferendumProposalStartTimestamp(uint256 id, uint256 timestamp) internal virtual {
        _uint256[referendumProposalStartTimestampKey(id)].onlynotMatchingValue(timestamp);
        _uint256[referendumProposalStartTimestampKey(id)] = timestamp;
        emit ReferendumProposalStartTimestampSetTo(id, timestamp);
    }

    function referendumProposalEndTimestamp(uint256 id) public view virtual returns (uint256) {
        return referendumProposalStartTimestamp(id) + referendumProposalDuration(id);
    }

    /** Duration */

    event ReferendumProposalDurationSetTo(uint256 indexed id, uint256 indexed seconds_);

    function referendumProposalDurationKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_DURATION", id));
    }

    function referendumProposalDuration(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalDurationKey(id)];
    }

    function _setReferendumProposalDuration(uint256 id, uint256 seconds_) internal virtual {
        _uint256[referendumProposalDurationKey(id)].onlynotMatchingValue(seconds_);
        _uint256[referendumProposalDurationKey(id)] = seconds_;
        emit ReferendumProposalDurationSetTo(id, seconds_);
    }

    /** Timestamp */

    function referendumProposalHasStarted(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= referendumProposalStartTimestamp(id);
    }

    function referendumProposalHasEnded(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= referendumProposalEndTimestamp(id);
    }

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

    event ReferendumProposalRequiredQuorumSetTo(uint256 indexed id, uint256 indexed bp);

    function referendumProposalRequiredQuorumKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_REQUIRED_QUORUM", id));
    }

    function referendumProposalRequiredQuorum(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalRequiredQuorumKey(id)];
    }

    function _setReferendumProposalRequiredQuorum(uint256 id, uint256 bp) internal virtual {
        bp.onlyBetween(0, 10000);
        _uint256[referendumProposalRequiredQuorumKey(id)].onlynotMatchingValue(bp);
        _uint256[referendumProposalRequiredQuorumKey(id)] = bp;
        emit ReferendumProposalRequiredQuorumSetTo(id, bp);
    }

    /** Required Threshold */
    
    event ReferendumProposalRequiredThresholdSetTo(uint256 indexed id, uint256 indexed bp);

    function referendumProposalRequiredThresholdKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_REQUIRED_THRESHOLD", id));
    }

    function referendumProposalRequiredThreshold(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalRequiredThresholdKey(id)];
    }

    function _setReferendumProposalRequiredThreshold(uint256 id, uint256 bp) internal virtual {
        bp.onlyBetween(0, 10000);
        _uint256[referendumProposalRequiredThresholdKey(id)].onlynotMatchingValue(bp);
        _uint256[referendumProposalRequiredThresholdKey(id)] = bp;
        emit ReferendumProposalRequiredThresholdSetTo(id, bp);
    }

    function referendumProposalThreshold(uint256 id) public view virtual returns (uint256) {
        return (referendumProposalSupportVote(id) * 10000) / referendumProposalQuorum(id);
    }

    function referendumProposalHasSufficientThreshold(uint256 id) public view virtual returns (uint256) {
        return referendumProposalThreshold(id) >= referendumProposalRequiredThreshold(id);
    }

    /** Has Passed */

    event ReferendumProposalHasPassed(uint256 indexed id);
    
    function referendumProposalHasPassedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_HAS_PASSED", id));
    }

    function referendumProposalHasPassed(uint256 id) public view virtual returns (bool) {
        return _bool[referendumProposalHasPassedKey(id)];
    }

    function _toggleReferendumProposalHasPassed(uint256 id) internal virtual {
        _bool[referendumProposalHasPassedKey(id)] = true;
        emit ReferendumProposalHasPassed(id);
    }

    /** Is Executed */

    event ReferendumProposalHasBeenExecuted(uint256 indexed id);

    function referendumProposalIsExecutedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_IS_EXECUTED", id));
    }

    function referendumProposalIsExecuted(uint256 id) public view virtual returns (bool) {
        _bool[referendumProposalIsExecutedKey(id)];
    }

    function _toggleReferendumProposalHasBeenExecuted(uint256 id) internal virtual {
        _bool[referendumProposalIsExecutedKey(id)] = true;
        emit ReferendumProposalHasBeenExecuted(id);
    }

    /** Min Balance To Vote */

    event ReferendumProposalMinBalanceToVoteSetTo(uint256 indexed id, uint256 indexed amount);

    function referendumProposalMinBalanceToVoteKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_MIN_BALANCE_TO_VOTE", id));
    }

    function referendumProposalMinBalanceToVote(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalMinBalanceToVoteKey(id)];
    }

    function _setReferendumProposalMinBalanceToVote(uint256 id, uint256 amount) internal virtual {
        uint256 totalSupplyAt = IDream(referendumProposalVotingERC20(id)).totalSupplyAt(referendumProposalSnapshotId(id));
        amount.onlyBetween(0, totalSupplyAt);
        _uint256[referendumProposalMinBalanceToVoteKey(id)].onlynotMatchingValue(amount);
        _uint256[referendumProposalMinBalanceToVoteKey(id)] = amount;
        emit ReferendumProposalMinBalanceToVoteSetTo(id, amount);
    }

    /** Support */

    event ReferendumProposalSupportVoteGained(uint256 indexed id, uint256 indexed amount);

    function referendumProposalSupportVoteKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_SUPPORT_VOTE", id));
    }

    function referendumProposalSupportVote(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalSupportVoteKey(id)];
    }

    function _increaseReferendumProposalSupportVote(uint256 id, uint256 amount) internal virtual {
        _uint256[referendumProposalSupportVoteKey(id)] += amount;
        emit ReferendumProposalSupportVoteGained(id, amount);
    }

    /** Against */

    event ReferendumProposalAgainstVoteGained(uint256 indexed id, uint256 indexed amount);

    function referendumProposalAgainstVoteKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_AGAINST_VOTE", id));
    }

    function referendumProposalAgainstVote(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalAgainstVoteKey(id)];
    }

    function _increaseReferendumProposalAgainstVote(uint256 id, uint256 amount) internal virtual {
        _uint256[referendumProposalAgainstVoteKey(id)] += amount;
        emit ReferendumProposalAgainstVoteGained(id, amount);
    }

    /** Abstain */

    event ReferendumProposalAbstainVoteGained(uint256 indexed id, uint256 indexed amount);

    function referendumProposalAbstainVoteKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_ABSTAIN_VOTE", id));
    }

    function referendumProposalAbstainVote(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalAbstainVoteKey(id)];
    }

    function _increaseReferendumProposalAbstainVote(uint256 id, uint256 amount) internal virtual {
        _uint256[referendumProposalAbstainVoteKey(id)] += amount;
        emit ReferendumProposalAbstainVoteGained(id, amount);
    }

    /** Snapshot ID */

    event ReferendumProposalSnapshotIdSetTo(uint256 indexed id, uint256 indexed snapshotId);

    function referendumProposalSnapshotIdKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_SNAPSHOT_ID, id"));
    }

    function referendumProposalSnapshotId(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalSnapshotIdKey(id)];
    }

    function _setReferendumProposalSnapshotId(uint256 id, uint256 snapshotId) internal virtual {
        _uint256[referendumProposalSnapshotIdKey(id)].onlynotMatchingValue(snapshotid);
        _uint256[referendumProposalSnapshotIdKey(id)] = snapshotId;
    }

    /** Voting ERC20 */

    event ReferendumProposalVotingERC20SetTo(uint256 indexed id, address indexed erc20);

    function referendumProposalVotingERC20Key(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_VOTING_ERC20", id));
    }

    function referendumProposalVotingERC20(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalVotingERC20Key(id)];
    }

    function _setReferendumProposalVotingERC20(uint256 id, address erc20) internal virtual {
        erc20.onlyGovernanceERC20();
        _address[referendumProposalVotingERC20Key(id)].onlynotAddress(erc20);
        _address[referendumProposalVotingERC20Key(id)] = erc20;
        emit ReferendumProposalVotingERC20SetTo(id, erc20);
    }

    /** Target */

    event ReferendumProposalTargetSetTo(uint256 indexed id, address indexed target);

    function referendumProposalTargetKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_TARGET", id));
    }

    function referendumProposalTarget(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalTargetKey(id)];
    }

    function _setReferendumProposalTarget(uint256 id, address target) internal virtual {
        _address[referendumProposalTargetKey(id)].onlynotAddress(target);
        _address[referendumProposalTargetKey(id)] = target;
        emit ReferendumProposalTargetSetTo(id, target);
    }

    /** Data */

    event ReferendumProposalDataSetTo(uint256 indexed id, bytes indexed data);

    function referendumProposalDataKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_DATA", id));
    }

    function referendumProposalData(uint256 id) public view virtual returns (bytes memory) {
        return _bytes[referendumProposalDataKey(id)];
    }

    function _setReferendumProposalData(uint256 id, bytes memory data) internal virtual {
        _bytes[referendumProposalDataKey(id)].onlynotMatchingValue(data);
        _bytes[referendumProposalDataKey(id)] = data;
        emit ReferendumProposalDataSetTo(id, data);
    }

    /** Count */

    event ReferendumProposalsCountIncremented(uint256 indexed id);

    function referendumProposalsCountKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSALS_COUNT"));
    }

    function referendumProposalsCount() public view virtual returns (uint256) {
        return _uint256[referendumProposalsCountKey()];
    }

    function _incrementReferendumProposalsCount() internal virtual {
        _uint256[referendumProposalsCountKey()] += 1;
        emit ReferendumProposalsCountIncremented(_uint256[referendumProposalsCountKey()]);
    }

    /** Math */

    function referendumProposalQuorum(uint256 id) public view virtual returns (uint256) {
        return referendumProposalSupportVote(id) + referendumProposalAgainstVote(id) + referendumProposalAbstainVote(id);
    }

    function referendumProposalRequiredVotes(uint256 id) public view virtual returns (uint256) {
        IDream votingERC20 = IDream(referendumProposalVotingERC20(id));
        uint256 totalSupplyAt = votingERC20.totalSupplyAt(referendumProposalSnapshotId(id));
        return (totalSupplyAt * referendumProposalRequiredQuorum(id)) / 10000;
    }
}