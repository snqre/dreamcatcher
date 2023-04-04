// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*
The token max supply is uncapped to allow the governor to raise funds
However, it will require proposals and heavy voting to be able to do such a thing
As holders would not be incetizied to do so, unless the proposal was good
If the DAO is making money then they can also burn tokens too
*/

// snapshot governance voting compatibility
// install 0.0.135 vscode solidity extension because latest one doesnt work for imports

/* 
    transfers
    mint

*/

contract DreamcatcherToken {
    /* =.=.=.=.=.=.=.= TRUTHS =.=.=.=.=.=.=.= */
    uint256 dy = 86400;
    uint256 wk = 604800;
    uint256 mn = 2419200;
    uint256 yr = 29030400;

    /* =.=.=.=.=.=.=.= TOKEN =.=.=.=.=.=.=.= */
    struct TokenIERC20 {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 initialSupply;
        uint256 totalVested;
        uint256 totalStaked;
    }

    struct TokenToggles {
        bool isPausable;
        bool isPaused;
        bool isMintable;
        bool isBurnable;
        bool isTransferable;
    }

    struct TokenAddressStateToggles {
        mapping(address => bool) isCustodian; //incharge of critical things
        mapping(address => bool) isSyndicate;
    }

    struct Token {
        /* ERC20 compliant data */
        TokenIERC20 IERC20;
        // address data
        mapping(address => uint256) balance; //how much each address has of our token
        mapping(address => uint256) vested; // how many of the tokens are locked
        mapping(address => uint256) staked; // how much they are staking
        mapping(address => uint256) votes; //how many votes do they have typically 1:1 with tokens but might change
        mapping(address => mapping(address => uint256)) allowance;
        // state machine
        TokenToggles toggles;
        TokenAddressStateToggles addressStateToggles;
        uint256 snapshotCount;
    }

    /* =.=.=.=.=.=.=.= CUSTODIAN SYNDICATE =.=.=.=.=.=.=.= */
    struct Settings {
        uint256 n;
        uint256 nMin;
        uint256 nMax;
        uint256 minBalance;
        uint256 minStaked;
        uint256 minVotes;
    }

    struct Syndicate {
        Settings settings;
    }

    /* =.=.=.=.=.=.=.= CUSTODIAN TREASURY MANAGEMENT =.=.=.=.=.=.=.= */
    struct MultiSig {
        /* number of required signatures to access signatures */
        uint256 requiredSignatures;
        /* once signed how long it takes before the funds can be accessed */
        uint256 delay;
    }

    struct Vault {
        /* can people get Eth from the address */
        bool isBuying;
        bool isSelling;
        /* unlike others you can redeem ETH for yours share*/
        uint256 askEth;
        uint256 bidEth;
        /* amount being sold or bought */
        uint256 amount;
    }

    struct Custodian {
        address account;
        /* a group of people allowed to propose and incharge of the project */
        Syndicate syndicate;
        Vault vault;
    }

    /* =.=.=.=.=.=.=.= VESTING =.=.=.=.=.=.=.= */
    struct VestingSchedule {
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 released;
    }

    mapping(address => VestingSchedule[]) private vestingSchedules;

    /* =.=.=.=.=.=.=.= INIT =.=.=.=.=.=.=.= */
    Token private dreamcatcherToken;
    Custodian private custodian;

    constructor() {
        /* =.=.=.=.=.=.=.= TOKEN IERC20 =.=.=.=.=.=.=.= */
        dreamcatcherToken.IERC20.name = "Dreamcatcher";
        dreamcatcherToken.IERC20.symbol = "DREAM";
        dreamcatcherToken.IERC20.decimals = 18;
        dreamcatcherToken.IERC20.totalSupply = 0;

        /* =.=.=.=.=.=.=.= CUSTODIAN =.=.=.=.=.=.=.= */
        /* set custodian */
        custodian.account = msg.sender;
        /* make the contract custodian */
        dreamcatcherToken.addressStateToggles.isCustodian[
            custodian.account
        ] = true;
        /* default settings for the syndicate */
        custodian.syndicate.settings.n = 0;
        custodian.syndicate.settings.nMin = 0;
        custodian.syndicate.settings.nMax = 0;
        custodian.syndicate.settings.minBalance =
            10000 *
            10**dreamcatcherToken.IERC20.decimals;
        custodian.syndicate.settings.minStaked =
            10000 *
            10**dreamcatcherToken.IERC20.decimals;
        custodian.syndicate.settings.minVotes =
            10000 *
            10**dreamcatcherToken.IERC20.decimals;

        /* =.=.=.=.=.=.=.= LAUNCH INSTRUCTIONS =.=.=.=.=.=.=.= */
        mint(custodian.account, 60000);
        mintVested(0x172952523F64EAAF288DE4cE9e5d1295DCFd3F83, 1000, yr * 10);
        //mint(0x172952523F64EAAF288DE4cE9e5d1295DCFd3F83, 1000); // -- team member I
        //mint(0xDbF85074764156004FEb245b65693e59a62262c2, 1000); // -- team member II
        //mint(0x1de8807f69E357FD91e47B34Dc2a66216a9DC4b4, 1000); // -- team member III
        // -- team address
        //send 20% to team wallet
        //send x% for private funding
        //keep x amount on contract as the contract will be the one selling directly
    }

    /* =.=.=.=.=.=.=.= EVENTS =.=.=.=.=.=.=.= */
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);
    event TokensReleased(address indexed account, uint256 amount);
    event MintTokensVested(address indexed account, uint256 amount);

    /* =.=.=.=.=.=.=.= VERIFY CUSTODIAN & SYNDICATE =.=.=.=.=.=.=.= */
    modifier onlyCustodian() {
        require(
            dreamcatcherToken.addressStateToggles.isCustodian[msg.sender] ==
                true,
            "Must be accessed through a proposal"
        );
        _;
    }

    modifier onlySyndicate() {
        require(
            dreamcatcherToken.addressStateToggles.isSyndicate[msg.sender] ==
                true,
            "Only Syndicates can access this function"
        );
        _;
    }

    /* =.=.=.=.=.=.=.= IERC20 =.=.=.=.=.=.=.= */
    function name() public view virtual returns (string memory) {
        return dreamcatcherToken.IERC20.name;
    }

    function symbol() public view virtual returns (string memory) {
        return dreamcatcherToken.IERC20.symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return dreamcatcherToken.IERC20.decimals;
    }

    function totalSupply() public view virtual returns (uint256) {
        return dreamcatcherToken.IERC20.totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        /* return how much the address has of our token */
        return dreamcatcherToken.balance[account];
    }

    function votingWeightOf(address account)
        public
        view
        virtual
        returns (uint256)
    {
        /* how much voting power the address holds */
        return dreamcatcherToken.votes[account];
    }

    function mint(address account, uint256 amount) public onlyCustodian {
        dreamcatcherToken.balance[account] += amount;
        dreamcatcherToken.votes[account] += amount;
        dreamcatcherToken.IERC20.totalSupply += amount;
        emit Mint(account, amount);
    }

    /* mint new tokens as vested for the address (linearly released) */
    function mintVested(
        address account,
        uint256 amount,
        uint256 duration
    ) public onlyCustodian {
        require(amount > 0, "must be non-zero");
        require(account != address(0), "invalid address");
        uint256 start = block.timestamp;
        uint256 end = start + duration;

        VestingSchedule memory vestingSchedule = VestingSchedule(
            amount,
            start,
            end,
            0
        );
        vestingSchedules[account].push(vestingSchedule);
        dreamcatcherToken.IERC20.totalSupply += amount;
        dreamcatcherToken.IERC20.totalVested += amount;
        emit MintTokensVested(account, amount);
    }

    function releaseVested() public {
        VestingSchedule[] storage schedules = vestingSchedules[msg.sender];
        uint256 sumReleased = 0;
        for (uint256 i = 0; i < schedules.length; i++) {
            VestingSchedule storage schedule = schedules[i];
            if (block.timestamp >= schedule.end) {
                uint256 amountToRelease = schedule.amount - schedule.released;
                schedule.released = schedule.amount;
                sumReleased += amountToRelease;
            } else {
                uint256 timeElapsed = block.timestamp - schedule.start;
                uint256 vestingDuration = schedule.end - schedule.start;
                uint256 amountToRelease = (schedule.amount * timeElapsed) /
                    vestingDuration -
                    schedule.released;
                schedule.released += amountToRelease;
                sumReleased += amountToRelease;
            }
        }
        require(sumReleased > 0, "no tokens to release");
        dreamcatcherToken.IERC20.totalVested -= sumReleased;
        dreamcatcherToken.votes[msg.sender] += sumReleased;
        dreamcatcherToken.balance[msg.sender] += sumReleased;
        emit TokensReleased(msg.sender, sumReleased);
    }

    function burn(address account, uint256 amount) public onlyCustodian {
        dreamcatcherToken.balance[account] -= amount;
        dreamcatcherToken.votes[account] -= amount;
        dreamcatcherToken.IERC20.totalSupply -= amount;
        emit Burn(account, amount);
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return dreamcatcherToken.allowance[owner][spender];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(
            dreamcatcherToken.balance[msg.sender] >= amount,
            "Insufficient balance"
        );
        dreamcatcherToken.balance[msg.sender] -= amount;
        dreamcatcherToken.votes[msg.sender] -= amount;
        dreamcatcherToken.balance[recipient] += amount;
        dreamcatcherToken.votes[recipient] += amount;
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
        dreamcatcherToken.votes[sender] -= amount;
        dreamcatcherToken.balance[recipient] += amount;
        dreamcatcherToken.votes[recipient] += amount;
        dreamcatcherToken.allowance[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);

        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        dreamcatcherToken.allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /* =.=.=.=.=.=.=.= GRANT & REVOKE SYNDICATE =.=.=.=.=.=.=.= */
    /* --add check for max and min */
    function toggleIsSyndicate(address account) public onlyCustodian {
        if (
            dreamcatcherToken.addressStateToggles.isSyndicate[account] == true
        ) {
            dreamcatcherToken.addressStateToggles.isSyndicate[account] = false;
        } else if (
            dreamcatcherToken.addressStateToggles.isSyndicate[account] == false
        ) {
            dreamcatcherToken.addressStateToggles.isSyndicate[account] = true;
        }
    }

    /* check account state toggles */
    function isCustodian(address account) public view returns (bool) {
        return dreamcatcherToken.addressStateToggles.isCustodian[account];
    }

    function isSyndicate(address account) public view returns (bool) {
        return dreamcatcherToken.addressStateToggles.isSyndicate[account];
    }
}
