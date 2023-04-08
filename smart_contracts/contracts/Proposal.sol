// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Authenticator.sol";

// messy still in the words
contract Proposal is Authenticator {
    struct Prop {
        string caption;
        string description;
        uint256 voteCount;
        bool isActive;
    }

    mapping(uint256 => Prop) public proposals;

    uint256 public proposalCount;

    event ProposalSubmitted(string name, string description);
    event VoteCast(address voter, uint256 proposalId);

    function submit(string memory _name, string memory _description)
        public
        onlySyndicates
        onlyCustodians
    {
        proposalCount++;
        proposals[proposalCount] = ProposalData({
            description: _description,
            voteCount: 0,
            isActive: true
        });

        emit ProposalSubmitted(_name, _description, proposalCount);
    }

    function vote() internal virtual reentrancyLock onlyMembers(msg.sender) {
        // vote
        address account = msg.sender;
        uint256 balance;
    }

    function execute() internal {}
}
