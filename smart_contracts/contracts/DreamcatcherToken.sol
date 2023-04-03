// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
/*
The token max supply is uncapped to allow the governor to raise funds
However, it will require proposals and heavy voting to be able to do such a thing
As holders would not be incetizied to do so, unless the proposal was good
If the DAO is making money then they can also burn tokens too
*/

// snapshot governance voting compatibility
// install 0.0.135 vscode solidity extension because latest one doesnt work for imports
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/security/PullPayment.sol";

contract Dreamcatcher {
    // TOKEN DATA
    struct Token {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 initialSupply;
        // address data
        mapping(address => uint256) balance; //how much each address has of our token
        mapping(address => uint256) vested; // how many of the tokens are locked
        mapping(address => uint256) staked; // how much they are staking
        mapping(address => uint256) votes; //how many votes do they have typically 1:1 with tokens but might change
        mapping(address => mapping(address => uint256)) allowance;
        // state machine
        bool isPausable;
        bool isPaused;
        bool isMintable;
        bool isBurnable;
        bool isTransferable;
        // roles
        mapping(address => bool) isCustodian; //incharge of critical things
        mapping(address => bool) isFounder; //cool to know lets people know the founders account so they can see if we are selling, we want to do things right
        mapping(address => bool) isBoardMember;
        mapping(address => bool) isDirector;
        mapping(address => bool) isMember;
    }

    struct Custodian {
        /* these can all be changed with a proposal -- future proofing the contract */
        uint256 maxBoardMembers;
        uint256 minBoardMembers;
        uint256 minDirectors;
        uint256 maxDirectors;
        uint256 minMember;
        uint256 maxMember;

        uint256 minBalanceToBeBoardMember;
        uint256 maxBalanceToBeBoardMember;
        uint256 minVestedToBeBoardMember;
        uint256 maxVestedToBeBoardMember;
        uint256 minStakedToBeBoardMember;
        uint256 maxStakedToBeBoardMember;
        uint256 minVotesToBeBoardMember;

        uint256 minBalanceToBe



        /* proposals */
        uint256 percentTotalSupplyToPass;



        /* services */
        uint256 percentEarningsDistributed;//how much is 
        uint256 percentEarnignsDistributedThroughBurning;


        bool isPausing;

    }
    // -- MAIN
    Token public dreamcatcherToken;

    constructor() {
        dreamcatcherToken.name = "Dreamcatcher";
        dreamcatcherToken.symbol = "DREAM";
        dreamcatcherToken.decimals = 18;
        dreamcatcherToken.initialSupply = 10000;
        dreamcatcherToken.totalSupply = dreamcatcherToken.initialSupply;
        dreamcatcherToken.isPausable = true;
        dreamcatcherToken.isMintable = true;
        dreamcatcherToken.isBurnable = true;
        dreamcatcherToken.isTransferable = true;

        //by default the launched contract address will be custodian
        dreamcatcherToken.isCustodian[msg.sender] = true;

        //instructions on deploy
        //send 20% to team wallet
        //send x% for private funding
        //keep x amount on contract as the contract will be the one selling directly
    }

    // -- FUNCTIONALITY AND FEATURES
    /* events */
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    modifier onlyCustodian() {
        //note im not sure if all account roles start with false yet
        /* check if address is custodian */
        require(
            dreamcatcherToken.isCustodian[msg.sender] == true,
            "Only the Custodian can access this. Use a proposal or vote on it. Elect a board member"
        );
        _;
    }

    modifier onlyFounder() {
        /* check if address is founder */
        require(
            dreamcatcherToken.isFounder[msg.sender] == true,
            "Only the Founder can access this. Contact the founder"
        );
        _;
    }

    modifier onlyBoardMember() {
        //note im not sure if all account roles start with false yet
        /* check if address is custodian */
        require(
            dreamcatcherToken.isBoardMember[msg.sender] == true,
            "Only a board member can access this. vote for a board member or campaign to become one"
        );
        _;
    }

    modifier onlyDirector() {
        //note im not sure if all account roles start with false yet
        /* check if address is custodian */
        require(
            dreamcatcherToken.isDirector[msg.sender] == true,
            "Only the Custodian can access this. Use a proposal or vote on it. Elect a board member"
        );
        _;
    }

    modifier onlyMember() {
        //note im not sure if all account roles start with false yet
        /* check if address is custodian */
        require(
            dreamcatcherToken.isMember[msg.sender] == true,
            "You must wait to become a voting member of this community"
        );
        _;
    }

    function name() public view virtual returns (string memory) {
        return dreamcatcherToken.name;
    }

    function symbol() public view virtual returns (string memory) {
        return dreamcatcherToken.symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return dreamcatcherToken.decimals;
    }

    function totalSupply() public view virtual returns (uint256) {
        return dreamcatcherToken.totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        /* return how much the address has of our token */
        return dreamcatcherToken.balance[account];
    }

    function balanceVested(address account)
        public
        view
        virtual
        returns (uint256)
    {
        /* return the amount of tokens of the account which are locked */
        return dreamcatcherToken.vested[account];
    }

    function balanceStaked(address account)
        public
        view
        virtual
        returns (uint256)
    {
        /* return the amount of tokens which are staked */
        return dreamcatcherToken.staked[account];
    }

    function votes(address account) public view virtual returns (uint256) {
        /* return number of votes the person has */
        return dreamcatcherToken.votes[account];
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return dreamcatcherToken.allowance[owner][spender];
    }

    // transfer, transferfrom, approve, allowance
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(
            dreamcatcherToken.balance[msg.sender] >= amount,
            "Insufficient balance"
        );
        dreamcatcherToken.balance[msg.sender] -= amount;
        dreamcatcherToken.balance[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferfrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        require(
            dreamcatcherToken.balance[sender] >= amount,
            "Insufficient balance"
        );
        require(
            dreamcatcherToken.allowance[sender][msg.sender] >= amount,
            "Transfer amount exceeds allowance"
        );

        dreamcatcherToken.balance[sender] -= amount;
        dreamcatcherToken.balance[recipient] += amount;
        dreamcatcherToken.allowance[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);

        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        dreamcatcherToken.allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /*
        all roles can be granted except custodian and founder
    */
    function grantIsBoardMember(address account) public onlyCustodian {
        /* grant board member role */
        dreamcatcherToken.isBoardMember[account] = true;
    }

    function revokeIsBoardMember(address account) public onlyCustodian {
        /* revoke board member role */
        dreamcatcherToken.isBoardMember[account] = false;
    }

    function grantIsDirector(address account) public onlyCustodian {
        /* grant director role */
        dreamcatcherToken.isDirector[account] = true;
    }

    function revokeIsDirector(address account) public onlyCustodian {
        /* revoke director role */
        dreamcatcherToken.isDirector[account] = false;
    }

    /*
        membership is important and sets who can take part in voting
        we don't want people who just bought their tokens 2 days ago to try and vote
        we want dedicated people to be responsible no moon boiis
    */
    function grantIsMember(address account) public onlyCustodian {
        /* grant membership */
        dreamcatcherToken.isMember[account] = true;
    }

    function revokeIsMember(address account) public onlyCustodian {
        /* revoke membership */
        dreamcatcherToken.isMember[account] = false;
    }
}
