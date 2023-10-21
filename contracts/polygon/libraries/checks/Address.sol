// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import "contracts/polygon/interfaces/tokens/erc20/IGovernanceToken.sol";
import "contracts/polygon/interfaces/governance/proposals/lite/IMultiSigProposalImplementationLite.sol";
import "contracts/polygon/interfaces/governance/proposals/lite/IReferendumProposalImplementationLite.sol";

library Address {
    /** Call erc20 functions if non present they should revert. */
    function mustBeERC20(address self) public view {
        IERC20Metadata token = IERC20Metadata(self);
        token.name();
        token.symbol();
        token.decimals();
        token.totalSupply();
        token.balanceOf(msg.sender);
        token.allowance(msg.sender, address(this));
    }

    function mustBeGovernanceToken(address self) public view {
        mustBeERC20(self);
        IGovernanceToken token = IGovernanceToken(self);
        token.getCurrentSnapshotId();
        uint i = token.snapshot();
        token.balanceOfAt(msg.sender, i);
        token.totalSupplyAt(i);
    }

    function mustBeMultiSigProposalImplementationLite(address self) public view {
        IMultiSigProposalImplementationLite proposal = IMultiSigProposalImplementationLite(self);
        proposal.approved();
        proposal.creator();
        proposal.data();
        proposal.duration();
        proposal.ended();
        proposal.endTimestamp();
        proposal.executed();
        proposal.governanceToken();
        proposal.hasSigned(msg.sender);
        proposal.initialized();
        proposal.isSigner(msg.sender);
        proposal.lastResponse();
        proposal.name();
        proposal.note();
        proposal.owner();
        proposal.requiredQuorum();
        proposal.requiredSignaturesCount();
        proposal.requiredThreshold();
        proposal.secondsLeft();
        proposal.signaturesCount();
        proposal.signersCount();
        proposal.snapshotId();
        proposal.started();
        proposal.startTimestamp();
        proposal.sufficientSignaturesCount();
        proposal.target();
        proposal.ticking();
    }
}