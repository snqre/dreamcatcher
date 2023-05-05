// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "smart_contracts/contracts/Proposal.sol";



import "smart_contracts/contracts/Conduit.sol";
import "smart_contracts/contracts/Token.sol";
//import "@openzeppelin/contracts/governance/Governor.sol";
//import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
//import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
//import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
//import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
//import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "./BaseERC20.sol";
import "smart_contracts/contracts/Vault.sol";
import "smart_contracts/libraries/Settings.sol";

//import "./TimelockController.sol";

contract DreamcatcherG is Proposal { // the real governance starts here

    meta.vault;
    meta.totalVotes;
    meta.totalStaked;

    struct Member {
        address memberAddress;
        uint memberSince;
        uint tokenBalance;
    }

    address[] public members;
    mapping(address => Member) public memberInfo;
    mapping(address => mapping(uint => bool)) public votes;
    Proposal[] public proposals;

    uint public totalSupply;
    mapping(address => uint) public availableVotes;

    event ProposalCreated(uint indexed proposalId, string description);
    event VoteCast(address indexed voter, uint indexed proposalId, uint tokenAmount);

    address votingTokenAddress;

    function addVotingToken(address _votingTokenAddress) public {
        votingTokenAddress = _votingTokenAddress;
    }

    function countVotesOf(address _member) public {
        require(memberInfo[_member].memberAddress == address(0), "Member already exists");
        memberInfo[_member] = Member({
            memberAddress: _member,
            memberSince: block.timestamp,
            tokenBalance: Token(votingTokenAddress).balanceOf(_member)
        });
        members.push(_member);
        availableVotes[_member] = Token(votingTokenAddress).balanceOf(_member);
    }

    function createProposal(string memory _description) public {
        proposals.push(Proposal({
            description: _description,
            voteCount: 0,
            executed: false
        }));
        emit ProposalCreated(proposals.length - 1, _description);
    }

    function vote(uint _proposalId, uint _tokenAmount) public {
        require(memberInfo[msg.sender].memberAddress != address(0), "Only members can vote");
        require(balances[msg.sender] >= _tokenAmount, "Not enough tokens to vote");
        require(votes[msg.sender][_proposalId] == false, "You have already voted for this proposal");
        votes[msg.sender][_proposalId] = true;
        memberInfo[msg.sender].tokenBalance -= _tokenAmount;
        proposals[_proposalId].voteCount += _tokenAmount;
        emit VoteCast(msg.sender, _proposalId, _tokenAmount);
    }

    function executeProposal(uint _proposalId) public {
        require(proposals[_proposalId].executed == false, "Proposal has already been executed");
        require(proposals[_proposalId].voteCount > totalSupply / 2, "Proposal has not been approved by majority vote");
        proposals[_proposalId].executed = true;
        // execute proposal here
    }


    /**
    I know it is not common convention to have a run function in a loop, but we can delay the loop so it doesnt run every second but loops through importat things every week or month
    We should have enough money to run a loop every week or month especially if we are holding millions of value
     */
    // experimental
    uint256 delay;
    bool isRunning;
    function run() private {
        while (isRunning == true) {
            // delay 1 week or month
        }
    }

    // experimental 
    // basically emergency functions are very expensive but if something goes wrong, we can revert the whole ecosystem back to a certain period of time
    function emergencyFunction() {}
}

contract State {

}

interface INativeToken {

    // =.=.=.=.= PUBLIC
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    // =.=.=.=.= EVENTS
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // =.=.=.=.= PUBLIC
    function stake(uint256 _value) external returns (bool);
    function unstake(uint256 _value) external returns (bool);
    function release(string memory _caption) external returns (bool);
    function updateSettings(uint256 _bpFeeBurn, uint256 _bpFeeBank) external returns (bool);
    function totalVotes() external view returns (uint256);
    function totalStaked() external view returns (uint256);
    function maxSupply() external view returns (uint256);
    function mintable() external view returns (uint256);
    function stakeOf(address _owner) external view returns (uint256);
    function votesOf(address _owner) external view returns (uint256);
    // =.=.=.=.= ADMIN ONLY
    function mint(address _to, uint256 _value) external returns (bool);
    function mintWithVesting(address _to, uint256 _value, uint256 _duration, string memory _caption) returns (bool);
    function burn(uint256 _value) external returns (bool);
    function fetchSettings() external returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    );
    function updateSettings(uint256 _bpFeeBurn, uint256 _bpFeeBank) external returns (bool);
    function update(address _vault) external returns (bool);
    // =.=.=.=.= EVENTS
    event UpdateToSettings(uint256 _bpFeeBurn, uint256 _bpFeeBank);
    event Update(address indexed _vault);
}

contract Dreamcatcher is INativeToken, State {
    
}
