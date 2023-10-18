// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/libraries/flags/uint256/Uint256FlagsV1.sol";
import "contracts/polygon/libraries/flags/address/AddressFlagsV1.sol";
import "contracts/polygon/interfaces/token/dream/IDream.sol";

abstract contract ProposalStateReferendumSettingsV1 is StateV1 {

    /**
    * @dev Imports and extends the functionality of the `Uint256FlagsV1` library for the `uint256` type.
    */
    using Uint256FlagsV1 for uint256;

    /**
    * @dev Imports and extends the functionality of the `AddressFlagsV1` library for the `address` type.
    */
    using AddressFlagsV1 for address;
    
    /** Default Required Threshold */

    /**
    * @dev Emitted when the default required threshold for referendum proposals is set.
    * 
    * @param bp The new default required threshold in basis points.
    */
    event DefaultReferendumProposalRequiredThresholdSetTo(uint256 indexed bp);

    /**
    * @dev Returns the storage key for the default required threshold for referendum proposals.
    * 
    * @return bytes32 The storage key for the default required threshold for referendum proposals.
    */
    function defaultReferendumProposalRequiredThresholdKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_REFERENDUM_PROPOSAL_REQUIRED_THRESHOLD"));
    }

    /**
    * @dev Retrieves the default required threshold for referendum proposals.
    * 
    * @return uint256 The default required threshold for referendum proposals in basis points.
    */
    function defaultReferendumProposalRequiredThreshold() public view virtual returns (uint256) {
        return _uint256[defaultReferendumProposalRequiredThresholdKey()].onlyBetween(0, 10000);
    }

    /**
    * @dev Internal function to set the default required threshold for referendum proposals.
    * 
    * @param bp The new default value for the required threshold in basis points.
    */
    function _setDefaultReferendumProposalRequiredThreshold(uint256 bp) internal virtual {
        bp.onlyBetween(0, 10000);
        _uint256[defaultReferendumProposalRequiredThresholdKey()].onlynotMatchingValue(bp);
        _uint256[defaultReferendumProposalRequiredThresholdKey()] = bp;
        emit DefaultReferendumProposalRequiredThresholdSetTo(bp);
    }

    /** Default Required Quorum */

    /**
    * @dev Emitted when the default required quorum for referendum proposals is set.
    * 
    * @param bp The new default required quorum in basis points.
    */
    event DefaultReferendumProposalRequiredQuorumSetTo(uint256 indexed bp);

    /**
    * @dev Returns the storage key for the default required quorum for referendum proposals.
    * 
    * @return bytes32 The storage key for the default required quorum for referendum proposals.
    */
    function defaultReferendumProposalRequiredQuorumKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_REFERENDUM_PROPOSAL_REQUIRED_QUORUM"));
    }

    /**
    * @dev Retrieves the default required quorum for referendum proposals.
    * 
    * @return uint256 The default required quorum for referendum proposals in basis points.
    */
    function defaultReferendumProposalRequiredQuorum() public view virtual returns (uint256) {
        return _uint256[defaultReferendumProposalRequiredQuorumKey()].onlyBetween(0, 10000);
    }

    /**
    * @dev Internal function to set the default required quorum for referendum proposals.
    * 
    * @param bp The new default value for the required quorum in basis points.
    */
    function _setDefaultReferendumProposalRequiredQuorum(uint256 bp) internal virtual {
        bp.onlyBetween(0, 10000);
        _uint256[defaultReferendumProposalRequiredQuorumKey()].onlynotMatchingValue(bp);
        _uint256[defaultReferendumProposalRequiredQuorumKey()] = bp;
        emit DefaultReferendumProposalRequiredQuorumSetTo(bp);
    }

    /** Default Duration */

    /**
    * @dev Emitted when the default duration for referendum proposals is set.
    * 
    * @param seconds_ The new default duration for referendum proposals in seconds.
    */
    event DefaultReferendumProposalDurationSetTo(uint256 indexed seconds_);

    /**
    * @dev Returns the storage key for the default duration of referendum proposals.
    * 
    * @return bytes32 The storage key for the default duration of referendum proposals.
    */
    function defaultReferendumProposalDurationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_REFERENDUM_PROPOSAL_DURATION"));
    }

    /**
    * @dev Retrieves the default duration for referendum proposals.
    * 
    * @return uint256 The default duration for referendum proposals in seconds.
    */
    function defaultReferendumProposalDuration() public view virtual returns (uint256) {
        return _uint256[defaultReferendumProposalDurationKey()];
    }

    /**
    * @dev Internal function to set the default duration for referendum proposals.
    * 
    * @param seconds_ The new default duration for referendum proposals in seconds.
    */
    function _setDefaultReferendumProposalDuration(uint256 seconds_) internal virtual {
        _uint256[defaultReferendumProposalDurationKey()].onlynotMatchingValue(seconds_);
        _uint256[defaultReferendumProposalDurationKey()] = seconds_;
        emit DefaultReferendumProposalDurationSetTo(seconds_);
    }

    /** Default Min Balance To Vote */

    /**
    * @dev Emitted when the default minimum balance required to vote on referendum proposals is set.
    * 
    * @param amount The new default minimum balance required for voting.
    */
    event DefaultReferendumProposalMinBalanceToVote(uint256 indexed amount);

    /**
    * @dev Returns the storage key for the default minimum balance required to vote on referendum proposals.
    * 
    * @return bytes32 The storage key for the default minimum balance to vote.
    */
    function defaultReferendumProposalMinBalanceToVoteKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_REFERENDUM_PROPOSAL_MIN_BALANCE_TO_VOTE"));
    }

    /**
    * @dev Retrieves the default minimum balance required to vote on referendum proposals.
    * 
    * @return uint256 The default minimum balance required for voting.
    */
    function defaultReferendumProposalMinBalanceToVote() public view virtual returns (uint256) {
        return _uint256[defaultReferendumProposalMinBalanceToVoteKey()];
    }

    /**
    * @dev Internal function to set the default minimum balance required to vote on referendum proposals.
    * 
    * @param amount The new default minimum balance required for voting.
    */
    function _setDefaultReferendumProposalMinBalanceToVote(uint256 amount) internal virtual {
        IDream votingERC20 = IDream(defaultReferendumProposalVotingERC20());
        amount.onlyBetween(0, votingERC20.totalSupply());
        _uint256[defaultReferendumProposalMinBalanceToVoteKey()].onlynotMatchingValue(amount);
        _uint256[defaultReferendumProposalMinBalanceToVoteKey()] = amount;
        emit DefaultReferendumProposalMinBalanceToVote(amount);
    }

    /** Default Voting ERC20 */

    /**
    * @dev Emitted when the default ERC-20 token for voting on referendum proposals is set.
    * 
    * @param erc20 The new address of the default ERC-20 token.
    */
    event DefaultReferendumProposalVotingERC20SetTo(address indexed erc20);

    /**
    * @dev Returns the storage key for the default ERC-20 token used for voting on referendum proposals.
    * 
    * @return bytes32 The storage key for the default ERC-20 token.
    */
    function defaultReferendumProposalVotingERC20Key() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("DEFAULT_REFERENDUM_PROPOSAL_VOTING_ERC20"));
    }

    /**
    * @dev Retrieves the default ERC-20 token for voting on referendum proposals.
    * 
    * @return address The address of the default ERC-20 token for voting.
    */
    function defaultReferendumProposalVotingERC20() public view virtual returns (address) {
        return _address[defaultReferendumProposalVotingERC20Key()];
    }

    /**
    * @dev Internal function to set the default ERC-20 token for voting on referendum proposals.
    * 
    * @param erc20 The new address of the default ERC-20 token for voting.
    */
    function _setDefaultReferendumProposalVotingERC20(address erc20) internal virtual {
        erc20.onlyGovernanceERC20();
        _address[defaultReferendumProposalVotingERC20Key()].onlynotAddress(erc20);
        _address[defaultReferendumProposalVotingERC20Key()] = erc20;
        emit DefaultReferendumProposalVotingERC20SetTo(erc20);
    }
}