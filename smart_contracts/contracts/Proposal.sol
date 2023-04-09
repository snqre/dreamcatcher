// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Authenticator.sol";
import "smart_contracts/libraries/Meta.sol"
// messy still in the works **
contract Proposal is Authenticator {
    struct Prop {
        uint256 id;
        string caption;
        string description;
        address creator;
        address payable projectAccount;
        uint256 voteSkew;// for votes are positive, against votes are negative :: 0 means tie
        uint256 quorum;// % of total supply supply that is voting for this
        bool isActive;
        bool executed;
    }

    mapping(uint256 => Prop) public proposals;
    Meta.Quorum internal quorum;

    event ProposalSubmitted(string _caption, string _description, address _creator, address _projectAccount);
    event VoteCast(address voter, uint256 proposalId);

    function submit(string memory _caption, string memory _description, address payable _projectAccount)
        public
        onlySyndicates
        onlyCustodians
        returns (bool)
    {
        quorum.proposalCount++;
        proposals[quorum.proposalCount] = Prop ({
            id: quorum.proposalCount;
            caption: _caption;
            description: _description;
            creator: msg.sender;
            projectAccount: _projectAccount;
            isActive: true;
        })

        emit ProposalSubmitted(_caption, _description, _creator, _projectAccount);
        return true;
    }

    function vote(uint256 _id, string memory _side, uint256 _amount, address _account, uint256 _balance, uint256 _votes) internal virtual reentrancyLock onlyMembers(msg.sender) {
        require(_balance >= _amount, "Insufficient balance");
        if (_side == "For") {
            proposals[_id].voteSkew += amount;
        }
        else if (_side == "Against") {
            proposals[_id].voteSkew -= amount;
        }
    }

    function execute() internal {}
}
