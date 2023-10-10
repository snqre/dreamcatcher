// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state-base/ProxyStateBaseV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/multi-sig/ProposalStateMultiSigV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/referendum/ProposalStateReferendumV1.sol";

abstract contract ProxyStateBaseV2 is 
    ProxyStateBaseV1,
    ProposalStateMultiSigV1,
    ProposalStateReferendumV1 {
    
    
}