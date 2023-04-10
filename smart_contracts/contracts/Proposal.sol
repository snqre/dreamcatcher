// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Authenticator.sol";
import "smart_contracts/libraries/Math.sol";
import "smart_contracts/libraries/Meta.sol";
import "smart_contracts/contracts/TimeLock.sol";

// messy still in the works **
contract Proposal is Authenticator {
    mapping(string => uint256) settingsProposal;

    function setVar(string memory _var, uint256 _newValue) internal {
        settingsProposal[_var] = _newValue;
    }

    function initProposalModule() internal {
        /*
        minQuorum %
        maxQuorum %
        minFundingPerProposal eth
        maxFundingPerProposal eth
        minSkewToExecute % above 50%
         */
        setVar("minQuorum", 5);
        setVar("maxQuorum", 100);
        setVar("minFundingPerProposal", 0);
        setVar("maxFundingPerProposal", 1);
        setVar("minSkewToExecute", 60);
    }

    // hacks, bugs, existential threats, its a short notice but thats what syndicates are for, in critical the only accesible actions are Pausing the token contract
    uint256 minCriticalProposalVotingPeriod = 1 days;
    uint256 maxCriticalProposalVotingPeriod = 7 days;
    uint256 minQuorumForCriticalProposal = 0.25;
    uint256 skewToPassCriticalProposal = 0.60;
    // your standard planning, marketing, business venture
    uint256 minBaseProposalVotingPeriod = 1 weeks;
    uint256 maxBaseProposalVotingPeriod = 2 weeks;
    uint256 minQuorumForBaseProposal = 0.50;
    uint256 skewToPassBaseProposal = 0.60;
    // this is for upgrading the code itself, we give as much time to members to understand whats going on
    uint256 minHighStakeProposalVotingPeriod = 4 weeks;
    uint256 maxHighStakeProposalVotingPeriod = 1 years;
    uint256 minQuorumForHighStakeProposal = 0.95;
    uint256 skewToPassHighStakeProposal = 0.95;

    struct Prop {
        uint256 id;
        string caption;
        string description;
        address creator;
        uint256 duration;
        uint256 fundingRequested;
        address payable funding;
        uint256 voteSkew;
        uint256 quorum;
        bool isActive;
        bool executed;
    }

    mapping(uint256 => Prop) internal proposals;
    Meta.Quorum internal quorum;

    event ProposalSubmitted(
        string _caption,
        string _description,
        address _creator,
        address _projectAccount
    );
    event VoteCast(address voter, uint256 proposalId);

    bool isACriticalProposal;

    function submitProposal(
        string memory _caption,
        string memory _description,
        address payable _funding,
        bool _isACriticalProposal
    )
        internal
        virtual
        // this will be overriden with the governor
        onlySyndicates(msg.sender)
        onlyCustodians(msg.sender)
        returns (bool)
    {
        string memory caption = _caption;
        string memory description = _description;
        uint256 duration;
        if (isACriticalProposal == true) {
            // ie. need to pause/ or there's been a hack whatever existential threat level
            duration = 0.5 days;
        } else if (isACriticalProposal == false) {
            // standard 4 weeks to vote, 4 weeks to pass proposal
            duration = 4 weeks;
        }

        address creator = msg.sender;
        address funding = _funding;
        quorum.proposalCount++;
        proposals[quorum.proposalCount] = Prop({
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

        // set time lock for the duration of the proposal
        newTimeLock(_caption, 2 weeks);
        emit ProposalSubmitted(caption, description, creator, funding);
        return true;
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

    function execute() internal {
        // set time lock for when a proposal is passed
    }
}
