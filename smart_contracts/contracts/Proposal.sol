// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Authenticator.sol";
import "smart_contracts/libraries/Math.sol";
import "smart_contracts/libraries/Meta.sol";
import "smart_contracts/contracts/TimeLock.sol";

// messy still in the works **
contract Proposal is Authenticator {
    uint256 minDuration;
    uint256 maxDuration;
    uint256 minFunding;
    uint256 maxFunding;
    mapping (address => bool) isBlackListed;
    mapping (address => bool) isWhiteListed;
    function updateProposalLaws(_minDuration, _maxDuration, _minFunding, _maxFunding) internal virtual {
        minDuration = _minDuration;
        maxDuration = _maxDuration;
        minFunding = _minFunding;
        maxFunding = _maxFunding;
    }

    event WhiteListGranted(address payable indexed _account);
    event WhiteListRevoked(address payable indexed _account);
    event BlackListGranted(address payable indexed _account);
    event BlackListRevoked(address payable indexed _account);

    function grantWhiteList(address payable _account) internal virtual {
        require(isBlackListed[_account] == false, "The address is black listed please revoke that status first");
        require(isWhiteListed[_account] == false, "The address is already white listed");
        isWhiteListed[_account] = true;
        emit WhiteListGranted(_account);
    }

    function revokeWhiteList(address payable _account) internal virtual {
        require(isWhiteListed[_account] == true, "The address is not white listed");
        isWhiteListed[_account] = false;
        emit WhiteListRevoked(_account);
    }

    function grantBlackList(address payable _account) internal virtual {
        require(isWhiteListed[_account] == false, "The address is white listed please revoke that status first");
        require(isBlackListed[_account] == false, "The address is already black listed");
        isBlackListed[_account] = true;
        emit BlackListGranted(_account);
    }
    
    function revokeBlackList(address payable _account) internal virtual {
        require(isBlackListed[_account] == true, "The address is not black listed");
        isBlackListed[_account] = false;
        emit BlackListRevoked(_account);
    }

    struct Prop {
        uint256 id;                     // id is caption
        string caption;                 // id and title
        string description;             // description of the propsoal
        address creator;                // address who proposed
        uint256 duration;               // amount of time for the vote
        uint256 fundingRequested;       // amount of eth requested to execute this plan
        address payable funding;        // account payable for the proposal
        uint256 voteSkew;               // negative means against, positive means for
        uint256 quorum;                 // % total amount for proposa vs. total possible
        uint256 uniqueVotes;            // unique addresses who voted for this proposal
        uint256 totalVotes;             // total amount of votes for this proposal
        uint256 totalGlobalVotes;       // total amount of possible votes in existence
        bool isActive;                  // is the proposal currently active
        bool executed;                  // has it been executed (passed)?
    }

    mapping(string => Prop) internal proposals;

    event ProposalSubmitted(
        string _caption,
        string _description,
        address _creator,
        uint256 _duration,
        address _funding,
        uint256 _fundingRequested,
        uint256 _voteSkew,
        uint256 _quorum,
        uint256 _uniqueVotes;
        uint256 _totalVotes;
        uint256 _totalGlobalVotes;
        bool _isActive,
        bool executed
    );

    /*
    submit a proposal internal virtual is meant to be overriden
    not public function
     */
    function submitProposal(
        string memory _caption,
        string memory _description,
        uint256 _duration,
        address payable _funding,
        uint256 _fundingRequested,
        uint256 _voteSkew,
        uint256 _quorum,
        uint256 _uniqueVotes,
        uint256 _totalVotes,
        uint256 _totalGlobalVotes,
        bool _isActive,
        bool _executed
    )
        internal
        virtual
        // this will be overriden with the governor
        returns (bool)
    {
        // check if there is a proposal already named with that
        require(proposals[_caption] == null, "There is already a proposal with that caption");
        require(_duration < minDuration, "Duration is less that the minimum allowed duration");
        require(_duration > maxDuration, "Duration is more that the maximum allowed duration");
        require(isBlackListed[_funding] == false, "The funding address is black listed");
        require(_fundingRequested > minFunding, "The amount requested is lower than the allowed minimum");
        require(_fundingRequested < maxFunding, "The amount requested is greater than the allowed maximum");

        // built the proposal
        Prop proposal;
        proposal.id = _caption;
        proposal.caption = _caption;
        proposal.description = _description;
        proposal.creator = msg.sender;
        proposal.duration = _duration;
        proposal.funding = _funding;
        proposal.fundingRequested = _fundingRequested;
        proposal.voteSkew = 0;
        proposal.quorum = 0;
        proposal.totalVotes = 0;
        proposal.totalGlobalVotes = ;
        proposal.isActive = true;
        proposal.executed = false;
        // save the proposal
        proposals[proposal.id] = proposal;
        // trigger event
        ProposalSubmitted(
            _caption,
            _description,
            msg.sender,
            _duration,
            _funding,
            _fundingRequest,
            proposal.voteSkew,
            proposal.isActive,
            proposal.executed
        );
        return true;
    }

    function submitVote(string memory _caption, string memory _side, uint256 _amount, uint256 _totalAccountVotes, bool _hasVoted, uint256 _totalGlobalVotes) internal virtual {
        require(_totalAccountVotes >= _amount, "Insufficient votes");
        require(_amount > 0, "Zero votes not supported");
        require(_hasVoted == false, "Your vote has already been registered");
        if (_side == "for") {
            proposals[_caption].voteSkew += _amount;

        } else if (_side == "against") {
            proposals[_caption].voteSkew -= _amount;
        }
        else {
            // invalid input
        }
        proposals[_caption].uniqueVotes ++;
        proposals[_caption].totalVotes += _amount;
        proposals[_caption].totalGlobalVotes = _totalGlobalVotes;
        uint256 a = proposals[_caption].totalVotes;
        uint256 b = proposals[_caption].totalGlobalVotes;
        uint256 c = Math.div(a, b);
        uin256 d = Math.mul(c, 100);
        proposals[_caption].quorum = d;
    }

    function vote(
        uint256 _id,
        uint256 _amount,
        address _account,
        uint256 _balance,
        uint256 _votes
    ) internal virtual reentrancyLock onlyMembers(msg.sender) {
        require(_balance >= _amount, "Insufficient balance");
        require(_amount > 0, "Non zero vote not supported");
        uint256 amount = _amount;
        if (Math.checkSkew(amount) == true) {
            proposals[_id].voteSkew += amount;
        } else if (Math.checkSkew(amount) == false) {
            proposals[_id].voteSkew -= amount;
        }
    }

    function veto() external onlyAdmins {
        // cannot execute but can deny
        // only for the starting process to make sure no one blows up the project
    }

    function execute() internal {
        // set time lock for when a proposal is passed
    }
}
