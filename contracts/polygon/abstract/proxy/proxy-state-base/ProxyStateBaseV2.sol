// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state-base/ProxyStateBaseV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/multi-sig/ProposalStateMultiSigV1.sol";
import "contracts/polygon/abstract/governance/proposal-state/referendum/ProposalStateReferendumV1.sol";

abstract contract ProxyStateBaseV2 is ProxyStateBaseV1, ProposalStateMultiSigV1, ProposalStateReferendumV1 {

    /** Initialize */

    /**
    * @dev Internal function to initialize the contract, granting the PROPOSER_ROLE to the message sender.
    * @param implementation The address of the implementation contract.
    */
    function _initialize(address implementation) internal virtual override {
        _grantRole(roleKey(hash("PROPOSER_ROLE")), msg.sender);
        super._initialize(implementation);
    }

    /** ProposalStateMultiSigV1 */

    /**
    * @notice Creates a new proposal with specified details.
    * @param caption The caption or title of the proposal.
    * @param message The detailed message or description of the proposal.
    * @param target The target address affected by the proposal.
    * @param data Additional data associated with the proposal.
    * @return The unique identifier of the created proposal.
    */
    function createProposal(string memory caption, string memory message, address target, bytes memory data) public virtual returns (uint256) {
        requireRole(hash("PROPOSER_ROLE"), msg.sender);
        return _createMultiSigProposal(caption, message, creator, target, data);
    }

    /**
    * @notice Executes a multi-signature proposal and creates a new referendum proposal based on its details.
    * @param id The unique identifier of the multi-signature proposal to be executed.
    * @return The unique identifier of the created referendum proposal.
    */
    function executeMultiSigProposal(uint256 id) public virtual returns (uint256) {
        _executeMultiSigProposal(id);
        return _createReferendumProposal(multiSigProposalCaption(id), multiSigProposalMessage(id), multiSigProposalCreator(id), multiSigProposalTarget(id), multiSigProposalData(id));
    }

    /**
    * @notice Executes a referendum proposal and triggers the associated target contract's function.
    * @param id The unique identifier of the referendum proposal to be executed.
    */
    function executeReferendumProposal(uint256 id) public virtual {
        _executeReferendumProposal(id);
        (bool success,) = address(referendumProposalTarget(id)).call(referendumProposalData(id));
        require(success, "ProxyStateBaseV2: failed to execute referendum proposal");
    }

    /** RoleStateV1 */

    /**
    * @dev Internal function to grant a role to an account, with special handling for the PROPOSER_ROLE.
    * @param role The identifier of the role to be granted.
    * @param account The address to be granted the role.
    */
    function _grantRole(bytes32 role, address account) internal virtual override {
        if (role == hash("PROPOSER_ROLE")) {
            _addDefaultMultiSigSigner(account);
            super._grantRole(role, account);
        }
        else {
            super._grantRole(role, account);
        }
    }

    /**
    * @dev Internal function to revoke a role from an account, with special handling for the PROPOSER_ROLE.
    * @param role The identifier of the role to be revoked.
    * @param account The address from which the role is to be revoked.
    */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        if (role == hash("PROPOSER_ROLE")) {
            _removeDefaultMultiSigSigner(account);
            super._revokeRole(role, account);
        }
        else {
            super._grantRole(role, account);
        }
    }
}