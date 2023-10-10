// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state-base/ProxyStateBaseV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/multi-sig/ProposalStateMultiSigV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/referendum/ProposalStateReferendumV1.sol";

abstract contract ProxyStateBaseV2 is 
    ProxyStateBaseV1,
    ProposalStateMultiSigV1,
    ProposalStateReferendumV1 {

    function _initialize(address implementation) internal virtual override {
        super._initialize(implementation);
        _grantRole(hash("PROPOSER_ROLE"), msg.sender);
    }

    /** ProposalStateMultiSigV1 */

    function createProposal(
        string memory caption,
        string memory message,
        address target,
        bytes memory data
    )
        public virtual returns (uint256) {
        requireRole(hash("PROPOSER_ROLE"), msg.sender);
        return _createMultiSigProposal(
            caption,
            message,
            msg.sender,
            target,
            data
        );
    }
    
    function executeMultiSigProposal(uint256 id) public virtual returns (uint256) {
        _executeMultiSigProposal(id);
        return _createReferendumProposal(
            multiSigProposalCaption(id), 
            multiSigProposalMessage(id), 
            multiSigProposalCreator(id), 
            multiSigProposalTarget(id), 
            multiSigProposalData(id)
        );
    }

    function executeReferendumProposal(uint256 id) public virtual {
        _executeReferendumProposal(id);
        (bool success,) = address(referendumProposalTarget(id)).call(referendumProposalData(id));
        require(success, "ProxyStateBaseV2: failed to execute referendum proposal");
    }

    /** RoleStateV1 */

    function _grantRole(bytes32 role, address account) 
        internal virtual override {
        if (role == hash("PROPOSER_ROLE")) {
            _addDefaultMultiSigSigner(account);
            super._grantRole(role, account);
        }
        else {
            super._grantRole(role, account);
        }
    }

    function _revokeRole(bytes32 role, address account) 
        internal virtual {
        if (role == hash("PROPOSER_ROLE")) {
            _removeDefaultMultiSigSigner(account);
            super._revokeRole(role, account);
        }
        else {
            super._grantRole(role, account);
        }
    }
}