// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state-module/ProxyStateModuleV2.sol";
import "contracts/polygon/abstract/governance/proposal-state/multi-sig/ProposalStateMultiSigV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/referendum/ProposalStateReferendumV1.sol";

abstract contract ProposalStateV1 is ProxyStateModuleV2, ProposalStateMultiSigV1, ProposalStateReferendumV1 {

    function createProposal(string memory caption, string memory message, address target, bytes memory data) public virtual {
        _createMultiSigProposal(caption, message, msg.sender, target, data);
    }

    function executeMultiSigProposal() public virtual returns (uint256) {
        _executeMultiSigProposal(id);
        _createReferendumProposal(caption, message, creator, target, data);
    }

    function executeReferendumProposal() public virtual {
        
    }
}