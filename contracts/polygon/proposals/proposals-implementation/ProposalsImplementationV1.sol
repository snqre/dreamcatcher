// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/governance/proposal-state/ProposalStateV1.sol";

contract ProposalsImplementation is ProposalStateV1 {
    
    function _initialize(
        address governor,
        address implementation
    ) internal virtual override {
        super._initialize({
            governor: governor,
            implementation: implementation
        });
        _setDefaultMultiSigDuration({seconds_: 0 seconds});
        _setDefaultMultiSigRequiredQuorum({bp: 0});
        _setDefaultReferendumProposalDuration({seconds_: 0 seconds});
        _setDefaultReferendumProposalMinBalanceToVote({amount: 0});
        _setDefaultReferendumProposalRequiredQuorum({bp: 0});
        _setReferendumProposalRequiredThreshold({id: id, bp: 0});
        _setReferendumProposalVotingERC20({id: id, erc20: 0xC5C23B6c3B8A15340d9BB99F07a1190f16Ebb125});
    }

/**
            _setDefaultMultiSigDuration(2000 seconds);
        _setDefaultMultiSigRequiredQuorum(bp);
        _setDefaultReferendumProposalDuration(seconds_);
        _setDefaultReferendumProposalMinBalanceToVote(amount);
        _setDefaultReferendumProposalRequiredQuorum(bp);
        _setDefaultReferendumProposalRequiredThreshold(bp);
        _setDefaultReferendumProposalVotingERC20(erc20);
    */
}