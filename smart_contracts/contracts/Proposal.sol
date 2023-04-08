// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Authenticator.sol";
// messy still in the words
contract Proposal is Authenticator {
    struct ProposalData {
        string name;
        string description;
        uint256 voteCount;
        bool isActive;
    }

    mapping(uint256 => ProposalData) public Proposals;

    uint256 public proposalCount;

    event ProposalCreated(string name, string description, uint256 proposalId);
    event VoteCast(address voter, uint256 proposalId);

    function createProposal(string memory _name, string memory _description) external onlySyndicate onlyCustodian {
        proposalCount++;
        proposals[proposalCount] = ProposalData({
            description: _description,
            voteCount: 0,
            isActive: true
        });

        emit ProposalCreated(_name, _description, proposalCount);
    }
}