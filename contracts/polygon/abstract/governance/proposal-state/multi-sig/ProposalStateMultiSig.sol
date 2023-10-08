// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/libraries/multi-sig/MultiSigV1.sol";
import "contracts/polygon/libraries/bytes-array/BytesArrayV1.sol";

abstract contract ProposalStateMultiSigV1 is StateV1 {
    using MultiSigV1 for MultiSigV1.MultiSig;
    using BytesArrayV1 for bytes[];

    event MultiSigWaitingDurationSetTo(uint256 indexed seconds_);

    error OutOfBounds(uint256 min, uint256 max, uint256 value);

    function multiSigWaitingDurationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_WAITING_DURATION"));
    }

    function multiSigDurationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_DURATION"));
    }

    function multiSigRequiredQuorumKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_REQUIRED_QUORUM"));
    }

    function multiSigWaitingDuration() public view virtual returns (uint256) {
        return _uint256[multiSigWaitingDurationKey()];
    }

    function multiSigDuration() public view virtual returns (uint256) {
        return _uint256[multiSigDurationKey()];
    }

    function multiSigRequiredQuorum() public view virtual returns (uint256) {
        return _uint256[multiSigRequiredQuorumKey()];
    }

    function _onlyInBp(uint256 value) internal view {
        if (bp >= 10000) { revert OutOfBounds(0, 10000, value); }
    }

    function _setMultiSigWaitingDuration(uint256 seconds_) internal virtual {
        _uint256[multiSigWaitingDurationKey()] = seconds_;
    }

    function _setMultiSigDuration(uint256 seconds_) internal virtual {
        _uint256[multiSigDurationKey()] = seconds_;
    }

    function _setMultiSigRequiredQuorum(uint256 bp) internal virtual {
        _onlyInBp(bp);
        _uint256[multiSigRequiredQuorumKey()] = bp;
    }

    function _generateMultiSigProposal(string memory caption, string memory message)
}