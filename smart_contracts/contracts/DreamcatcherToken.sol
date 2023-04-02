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

        //instructions on deploy
        //send 20% to team wallet
        //send x% for private funding
        //keep x amount on contract as the contract will be the one selling directly
    }

    modifier onlyCustodian() {//note im not sure if all account roles start with false yet
        /* check if address is custodian */
        require(
            dreamcatcherToken.isCustodian[msg.sender],
            "Only the Custodian can do this. You must go through a proposal to do this."
        );
        _;
    }

    function name() public view virtual override returns (string memory) {
        return dreamcatcherToken.name;
    }

    function symbol() public view virtual override returns (string memory) {
        return dreamcatcherToken.symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return dreamcatcherToken.decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return dreamcatcherToken.totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        /* return how much the address has of our token */
        return dreamcatcherToken.balance[account];
    }

    function balanceVested(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        /* return the amount of tokens of the account which are locked */
        return dreamcatcherToken.vested[account];
    }

    function balanceStaked(address account) public view virtual override returns (uint256) {
        /* return the amount of tokens which are staked */
        return dreamcatcherToken.staked[account];
    }

    function votes(address account) public view virtual override returns (uint256) {
        /* return number of votes the person has */
        return dreamcatcherToken.votes[account];
    }

    // transfer, transferfrom, approve, allowance




















    // CUSTODIAN DATA
    struct Custodian {
        address account;
        // state machine
        bool is_polling;
    }

    Custodian custodian = Custodian("", msg.sender);

    // DIFFERENT TYPES OF ROLES
    // only the custodian can mint tokens
    bytes32 public constant CUSTODIAN = keccak256("CUSTODIAN"); // this is the contract itself responsible for maintaining and assiging roles, the custodian only can mint and control key features
    bytes32 public constant DIRECTOR = keccak256("DIRECTOR"); // ideally head to allow the project to move in a particular direction
    bytes32 public constant BOARD_MEMBER = keccak256("BOARD_MEMBER"); // the board members are elected every x amount of time, these are 6 - 16 people elected and only they can propose actions and stuff that can be voted on
    bytes32 public constant MEMBER = keccak256("MEMBER"); // token holders only they can actively vote and access certain functions

    address public addressCustodian = msg.sender;
    string public stringName = "Dreamcatcher";
    string public stringSymbol = "DREAM";
    uint256 public uint256InitialSupply = 100000;

    /*
        a project has a team behind it
        payment is split up into period of time to avoid malicious behaviour
        if the board sees that the team is getting things done they will keep paying
        else they can stop
    */
    struct Project {
        string name;
        string description;
        address funding;
        uint256 duration;
        uint256 budget;
    }

    /* THIS IS IMPORTANT STUFF THAT CAN BE CHANGED ONLY BY PROPOSAL */
    function giveCustodianRole(address _addressCustodian) private {
        /* give honorary custodian role to an impartial party set by code */
        _setupRole(DEFAULT_ADMIN_ROLE, _addressCustodian);
        _setupRole(CUSTODIAN, _addressCustodian);
    }

    constructor() ERC20(stringName, stringSymbol) {
        // give the contract custodian role
        giveCustodianRole(addressCustodian);

        // generate initial supply for the custodian
        mint(dreamcatcherToken.initialSupply);
    }

    modifier onlyCustodian() {
        require(
            hasRole(CUSTODIAN, msg.sender),
            "Only the Custodian can do this. You must go through a proposal to do this."
        );
        _;
    }

    // SNAPSHOT

    // MINTING
    function mintFor(address addressAccount, uint256 uint256Amount)
        public
        onlyCustodian
    {
        /* only the custodian can mint tokens for others */
        /* also has decimals automatically calculated */
        _mint(addressAccount, uint256Amount * 10**decimals());
    }

    function mint(uint256 uint256Amount) public onlyCustodian {
        /* only the custodian can mint tokens for itself */
        /* also has decimals automatically calculated */
        _mint(addressCustodian, uint256Amount * 10**decimals());
    }

    // BURNING
    function burn(uint256 amount) public virtual onlyCustodian {
        /* only the custodian can burn tokens for itself, people can send tokens here if they want to burn them */
        _burn(addressCustodian, amount);
    }

    // PAUSING -- the community can vote to emergency pause if neccesary

    // START PROJECT
    function beginProject() public onlyCustodian {
        Project project = Project(
            "Baking Beans",
            "I want to bake beans",
            msg.sender,
            365,
            2000
        );
        project.name;
        project.description;
        project.funding;

        // VOTING LOGIC

        // IF VOTE PASS THEN DO
        // send initial moola to team address
        // emit message saying this has happened
    }

    // RAISE FUNDING
    /*
    custodian can mint new tokens and these can be used to raise funding at a certain price per eth or crypto
    as this can devalue other people's holdings this must be voted on
    to avoid attacks and malicious behaviour people must not be able to just buy 60% of the supply and do this
    */
    function raiseCapital(uint256 amount) public onlyCustodian {
        mint(amount);
    }

    // BUDGET
    /* a budget is an amount of money or crypto that will be dedicated to an address or cause 
        this can be sent on a daily/weekly, or whatever timeframe and does not have to be used up
        in case of malicious behaviour if the entity is thought as not doing the job payments to the account will stop
        payments to the account will also stop if the budget is finished and no budget has been allocated
        unlike the treasury, the budget is set by members and receiving address must also be voted on
    */

    function budget(uint256 amount, string project) onlyCustodian {
        // this amount of tokens will
    }
}
