// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Authenticator.sol";
import "smart_contracts/libraries/Math.sol";
// messy still in the works **
contract Proposal is Authenticator {
    struct Prop {
        uint256 id;
        string caption;
        string description;
        address creator;
        address payable funding;
        uint256 voteSkew;// for votes are positive, against votes are negative :: 0 means tie
        uint256 quorum;// % of total supply supply that is voting for this
        bool isActive;
        bool executed;
    }

    mapping(uint256 => Prop) public proposals;
    Meta.Quorum internal quorum;

    event ProposalSubmitted(string _caption, string _description, address _creator, address _projectAccount);
    event VoteCast(address voter, uint256 proposalId);

    function submit(string memory _caption, string memory _description, address payable _funding)
        public
        onlySyndicates(msg.sender)
        onlyCustodians(msg.sender)
        returns (bool)
    {
        string memory caption = _caption;
        string memory description = _description;
        address creator = msg.sender;
        address funding = _funding;
        quorum.proposalCount++;
        proposals[quorum.proposalCount] = Prop ({
            id: quorum.proposalCount,
            caption: _caption,
            description: _description,
            creator: msg.sender,
            funding: _funding,
            isActive: true,
            executed: false,
            quorum: 0,
            voteSkew: 0

        });
        emit ProposalSubmitted(caption, description, creator, funding);
        return true;
    }

    function vote(uint256 _id, uint256 _amount, address _account, uint256 _balance, uint256 _votes) internal virtual reentrancyLock onlyMembers(msg.sender) {
        require(_balance >= _amount, "Insufficient balance");
        require(_amount > 0, "Non zero vote not supported");
        uint256 amount = _amount;
        if (Math.checkSkew(amount) == true) {
            proposals[_id].voteSkew += amount;
        }
        else if (Math.checkSkew(amount) == false) {
            proposals[_id].voteSkew -= amount;
        }
    }

    function execute() internal {}
}
