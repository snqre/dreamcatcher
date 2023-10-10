// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/token/dream/IDream.sol";

abstract contract ProposalStateReferendumProposalsV1 is StateV1 {

    /**
    * @dev Use the `EnumerableSet` library to provide additional functionality for handling sets of addresses.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

    event ReferendumProposalIncremented(uint256 indexed id);

    event ReferendumProposalExecuted(uint256 indexed id);

    event ReferendumProposalVote(uint256 indexed id, uint256 indexed side, address indexed voter);

    /** Keys. */

    function referendumProposalVotersKey(uint256 id) public pure virtual returns (bytes32) {
        /** @dev Accounts that votes. */
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_VOTERS", id));
    }

    function referendumProposalCaptionKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_CAPTION", id));
    }

    function referendumProposalMessageKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_MESSAGE", id));
    }

    function referendumProposalCreatorKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_CREATOR", id));
    }

    function referendumProposalStartTimestampKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_START_TIMESTAMP", id));
    }

    function referendumProposalDurationKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_DURATION", id));
    }

    function referendumProposalRequiredQuorumKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_REQUIRED_QUORUM", id));
    }

    function referendumProposalRequiredThresholdKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_REQUIRED_THRESHOLD", id));
    }

    function referendumProposalHasPassedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_HAS_PASSED", id));
    }

    function referendumProposalExecutedKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_EXECUTED", id));
    }

    function referendumProposalMinBalanceToVoteKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_MIN_BALANCE_TO_VOTE", id));
    }

    function referendumProposalSupportKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_SUPPORT", id));
    }

    function referendumProposalAgainstKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_AGAINST", id));
    }

    function referendumProposalAbstainKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_ABSTAIN", id));
    }

    function referendumProposalSnapshotIdKey(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_SNAPSHOT_ID"));
    }

    function referendumProposalVotingERC20Key(uint256 id) public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSAL_VOTING_ERC20", id));
    }

    function referendumProposalCountKey() public view virtual returns (bytes32) {
        return keccak256(abi.encode("REFERENDUM_PROPOSALS_COUNT"));
    }

    /** Getters. */

    function referendumProposalSupport(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalSupportKey(id)];
    }

    function referendumProposalAgainst(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalAgainstKey(id)];
    }

    function referendumProposalAbstain(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalAbstainKey(id)];
    }

    function referendumProposalQuorum(uint256 id) public view virtual returns (uint256) {
        return referendumProposalSupport(id) + referendumProposalAgainst(id) + referendumProposalAbstain(id);
    }

    function referendumProposalRequiredVotes(uint256 id) public view virtual returns (uint256) {
        IDream votingERC20 = IDream(referendumProposalVotingERC20(id));
        return (votingERC20.totalSupplyAt(referendumProposalSnapshotId(id)) * referendumProposalRequiredQuorum(id)) / 10000;
    }

    function referendumProposalHasSufficientQuorum(uint256 id) public view virtual returns (bool) {
        return referendumProposalQuorum(id) >= referendumProposalRequiredVotes(id);
    }

    function referendumProposalRequiredThreshold(uint256 id) public view returns (uint256) {
        return _uint256[referendumProposalRequiredThresholdKey(id)];
    }

    function referendumProposalThreshold(uint256 id) public view returns (uint256) {
        return (referendumProposalSupport(id) * 10000) / referendumProposalQuorum(id);
    }

    function referendumProposalHasSufficientThreshold(uint256 id) public view returns (bool) {
        return referendumProposalThreshold(id) >= referendumProposalRequiredThreshold(id);
    }

    function referendumProposalVoters(uint256 id, uint256 voterId) public view virtual returns (address) {
        return _addressSet[referendumProposalVotersKey(id)].at(voterId);
    }

    function referendumProposalVotersLength(uint256 id) public view virtual returns (uint256) {
        return _addressSet[referendumProposalVotersKey(id)].length();
    }

    function isReferendumProposalVoter(uint256 id, address account) public view returns (bool) {
        return _addressSet[referendumProposalVotersKey(id)].contains(account);
    }

    function referendumProposalCaption(uint256 id) public view virtual returns (string memory) {
        return _string[referendumProposalCaptionKey(id)];
    }

    function referendumProposalMessage(uint256 id) public view virtual returns (string memory) {
        return _string[referendumProposalMessageKey(id)];
    }

    function referendumProposalCreator(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalCreatorKey(id)];
    }

    function referendumProposalStartTimestamp(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalStartTimestampKey(id)];
    }

    function referendumProposalEndTimestamp(uint256 id) public view virtual returns (uint256) {
        return referendumProposalStartTimestamp(id) + referendumProposalDuration(id);
    }

    function referendumProposalDuration(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalDurationKey(id)];
    }

    function referendumProposalHasPassed(uint256 id) public view virtual returns (bool) {
        return _bool[referendumProposalHasPassedKey(id)];
    }

    function referendumProposalExecuted(uint256 id) public view virtual returns (bool) {
        return _bool[referendumProposalExecutedKey(id)];
    }

    function referendumProposalHasStarted(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= referendumProposalStartTimestamp(id);
    }

    function referendumProposalHasEnded(uint256 id) public view virtual returns (bool) {
        return block.timestamp >= referendumProposalEndTimestamp(id);
    }

    function referendumProposalMinBalanceToVote(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalMinBalanceToVote(id)];
    }

    function referendumProposalSnapshotId(uint256 id) public view virtual returns (uint256) {
        return _uint256[referendumProposalSnapshotIdKey(id)];
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

    function referendumProposalVotingERC20(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalVotingERC20Key(id)];
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

    function referendumProposalTarget(uint256 id) public view virtual returns (address) {
        return _address[referendumProposalTargetKey(id)];
    }

    function referendumProposalData(uint256 id) public view virtual returns (bytes memory) {
        return _bytes[referendumProposalDataKey(id)];
    }

    function _voteOnReferendumProposal(uint256 id, uint256 side) internal virtual {
        require(
            !isReferendumProposalVoter(msg.sender),
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
            emit ReferendumProposalHasPassed();
        }
    }

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

    function _setReferendumProposalRequiredThreshold(uint256 id, uint256 bp) internal virtual {
        require(
            bp < 10000,
            "ProposalStateReferendumProposalsV1: value is out of bounds | max: 10000"
        );
        _uint256[referendumProposalRequiredThresholdKey(id)] = bp;
        emit ReferendumProposalRequiredThresholdSetTo(id, bp);
    }

    function _setReferendumProposalCaption(uint256 id, string memory caption) internal virtual {
        _string[referendumProposalCaptionKey(id)] = caption;
        emit ReferendumProposalCaptionSetTo(id, caption);
    }

    function _setReferendumProposalMessage(uint256 id, string memory message) internal virtual {
        _string[referendumProposalMessageKey(id)] = message;
    }

    function _setReferendumProposalCreator(uint256 id, address creator) internal virtual {
        _address[referendumProposalCreatorKey(id)] = creator;
    }

    function _setReferendumProposalStartTimestamp(uint256 id, uint256 timestamp) internal virtual {
        _uint256[referendumProposalStartTimestampKey(id)] = timestamp;
    }

    function _setReferendumProposalDuration(uint256 id, uint256 seconds_) internal virtual {
        _uint256[referendumProposalDurationKey(id)] = seconds_;
    }

    function _setReferendumProposalMinBalanceToVote(uint256 id, uint256 minBalance) internal virtual {
        _uint256[referendumProposalMinBalanceToVoteKey(id)] = minBalance;
    }

    function _setReferendumProposalVotingERC20(uint256 id, address erc20) internal virtual {
        _address[referendumProposalVotingERC20Key(id)] = erc20;
    }

    function _setReferendumProposalSnapshotId(uint256 id, uint256 snapshotId) internal virtual {
        _uint256[referendumProposalSnapshotIdKey(id)] = snapshotId;
    }

    function _setReferendumProposalTarget(uint256 id, address target) internal virtual {
        _address[referendumProposalTargetKey(id)] = target;
    }

    function _setReferendumProposalData(uint256 id, bytes memory data) internal virtual {
        _bytes[referendumProposalDataKey(id)] = data;
    }

    function _incrementReferendumProposalsCount() internal virtual returns (uint256) {
        _uint256[referendumProposalCountKey()] += 1;
        emit ReferendumProposalIncremented(id);
        return _uint256[referendumProposalsCountKey()];
    }


}