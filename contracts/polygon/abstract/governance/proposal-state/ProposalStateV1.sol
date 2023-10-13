// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state-module/ProxyStateModuleV2.sol";
import "contracts/polygon/abstract/governance/proposal-state/multi-sig/ProposalStateMultiSigV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/referendum/ProposalStateReferendumV1.sol";

abstract contract ProposalStateV1 is ProxyStateModuleV2, ProposalStateMultiSigV1, ProposalStateReferendumV1 {

    function createProposal(
        string memory caption,
        string memory message,
        address target,
        bytes memory data
    ) public virtual {
        _createMultiSigProposal({
            caption: caption,
            message: message,
            creator: msg.sender,
            target: target,
            data: data
        });
    }

    function executeMultiSigProposal(uint256 id) public virtual returns (uint256) {
        _executeMultiSigProposal({id: id});
        _createReferendumProposal({
            caption: multiSigProposalCaption({id: id}),
            message: multiSigProposalMessage({id: id}),
            creator: multiSigProposalCreator({id: id}),
            target: multiSigProposalTarget({id: id}),
            data: multiSigProposalData({id: id})
        });
    }

    function executeReferendumProposal(uint256 id) public virtual {
        _executeReferendumProposal({id: id});
        (
            bool success,
            bytes memory response
        )
        = address(referendumProposalTarget({id: id}))
        .call(referendumProposalData({id: id}));
        require(success, "ProposalStateV1: !success");
    }

    function _initialize(governor, implementation) internal virtual {
        super._initialize({governor: governor, implementation: implementation});
    }
}