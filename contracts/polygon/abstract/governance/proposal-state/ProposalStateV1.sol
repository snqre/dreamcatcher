// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/libraries/multi-sig/MultiSigV1.sol";
import "contracts/polygon/libraries/referendum/ReferendumV1.sol";
import "contracts/polygon/libraries/bytes-array/BytesArrayV1.sol";

abstract contract ProposalStateV1 is StateV1 {
    using MultiSigV1 for MultiSigV1.MultiSig;
    using ReferendumV1 for ReferendumV1.Referendum;
    using BytesArrayV1 for bytes[];

    function waitingDurationKey() public pure returns (bytes32) {
        return keccak256(abi.encode("WAITING_DURATION"));
    }

    function multiSigDurationKey() public pure returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_DURATION"));
    }

    function multiSigRequiredQuorumKey() public pure returns (bytes32) {
        return keccak256(abi.encode("MULTI_SIG_REQUIRED_QUORUM"));
    }

    function multiSigProposalsKey() public pure returns (bytes32) {
        return keccak256(abi.encode("PROPOSALS_MULTISIG"));
    }

    function signers(uint256 id) public view returns (address) {
        return _signers(id);
    }

    function signersLength() public view returns (uint256) {
        return _signersLength();
    }

    function waitingDuration() public view returns (uint256) {
        return _uint256[waitingDurationKey()];
    }

    function multiSigDuration() public view returns (uint256) {
        return _uint256[multiSigDurationKey()];
    }

    function multiSigRequiredQuorum() public view returns (uint256) {
        return _uint256[multiSigRequiredQuorumKey()];
    }

    function multiSigProposalsCaption(uint256 id) public view returns (string memory) {
        bytes[] storage proposals = _bytesArray[multiSigProposalsKey()];
        bytes memory 
    }

    function _signers(uint256 id) internal view virtual returns (address) {
        /** ... @dev Override ... */
        return address(0);
    }

    function _signersLength() internal view virtual returns (uint256) {
        /** ... @dev Override */
        return 0;
    }

    function _createProposal(string memory caption, string memory message, address target, string memory signature, bytes memory args) internal {
        MultiSigV1.MultiSig memory multiSigProposal;
        for (uint256 i = 0; i < signersLength(); i++) {
            multiSigProposal.addSigner(signers[i]);
        }
        multiSigProposal.setStartTimestamp(block.timestamp + waitingDuration());
        multiSigProposal.setDuration(multiSigDuration());
        multiSigProposal.setRequiredQuorum(multiSigRequiredQuorum());
        bytes[] storage multiSigProposals = _bytesArray[multiSigProposalsKey()];
        multiSigProposals.pushToEmpty(abi.encode(caption, message, target, signature, args, multiSigProposal));
    }
}