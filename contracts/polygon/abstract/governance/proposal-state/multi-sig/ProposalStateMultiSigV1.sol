// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/governance/proposal-state/multi-sig-settings/ProposalStateMultiSigSettingsV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/multi-sig-proposals/ProposalStateMultiSigProposalsV2.sol";
import "contracts/polygon/libraries/proposal/multi-sig/MultiSigV1.sol";
import "contracts/polygon/libraries/bytes-array/BytesArrayV1.sol";

abstract contract ProposalStateMultiSigV1 is ProposalStateMultiSigSettingsV1, ProposalStateMultiSigProposalsV2 {
    
    /**
    * @dev Import the `MultiSigV1` contract and use it for MultiSig functionality.
    */
    using MultiSigV1 for MultiSigV1.MultiSig;

    /**
    * @dev Import the `BytesArrayV1` contract and use it for handling arrays of bytes.
    */
    using BytesArrayV1 for bytes[];

    function _createMultiSigProposal() internal virtual {
        MultiSigV1.MultiSig memory newProposal;
        newProposal.setCaption(caption);
        newProposal.setMessage(message);
        newProposal.setDuration(defaultMultiSigProposalsDuration());
        newProposal.setRequiredQuorum(defaultMultiSigProposalsRequiredQuorum());
        newProposal.setStartTimestamp(block.timestamp);
        for (uint256 i = 0; i < defaultMultiSigProposalsSignersLength(); i++) {
            newProposal.addSigner(defaultMultiSigProposalsSigners(i));
        }
        bytes[] storage proposals = _bytesArray[multiSigProposalsKey()];
        proposals.tryPushToEmptyFirst(abi.encode(newProposal));
        uint256 id = proposals.length - 1;
        _setMultiSigProposalCreator(id, msg.sender);
    }

    function _executeMultiSigProposal(uint256 id) internal virtual override {
        /** ... @dev Replace with execution logic ... */
        super._executeMultiSigProposal(id);
    }
}