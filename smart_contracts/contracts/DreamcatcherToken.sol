// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
/*
Purpose & Goals 
-- Purpose and goals of the DAO
---- Decentralized governance of the decentralized services we will offer
---- Decentralized finance will allow us to get better deals when trying to deal with offers
---- Giving young entrepreneurs a chance to find funding for their projects
---- Research and development and attracting talent

-- What is the DAO going to do?
---- Vote on proposals to improve the built system
---- Vote on using excess trasury capital to re invest in projects
---- Decentralized fund management
---- Decentralized application managment

-- What problems will it solve?
---- Centralized control
---- Lack of transparency
---- Cost and efficiency
---- Trust
---- Accessibility

-- What benefits will it provide to its members?
---- Transparency
---- Voting rights
---- Equity
---- Flexibility
---- Opportunities to participate
---- Cheaper fees for our products and negotiating cheaper pricing for projects we invest in
---- Member's only resources

Membership
-- Membership structure
---- Token-based membership

-- Will membership be open to anyone?
---- As long as you have more than 0 tokens you are a member
---- To become a syndicate you must have at least 1% of the total supply staked they are proposal creators, arbitrators, curators, and are the core team

-- Will there be any criteria for joining the DAO?
---- Token ownership

-- Will there be any criteria for becoming a Syndicate?
---- Token ownership
---- elected by the community

Governance
-- How will decisions be made?
---- Quadratic voting
---- Delegated voting

-- Will there be voting?
---- Yes

-- How will voting power be distributed among members?
---- Quadratic voting
---- ie. one has 10,000 the first token is worth 1:1
---- the second is worth 1:0.99
---- math still in works

Smart Contract Development
-- Voting
-- Proposal submission
-- Fund managemeng

Deployment
-- Where are you initially deploying this to?

Community Building
-- Promoting
-- Recruiting members
-- Fostering communication and engaement among members
*/

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
}

contract ERC20 is IERC20 {
    string public name;
    string public symbol;
    uint256 public total_supply;
    uint8 public decimals;

    mapping(address => uint256) balance;
    mapping(address => mapping(address => uint256)) allowed;

    function balanceOf(address owner) public view returns (uint256) {
        return balance;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(balance[msg.sender] >= amount);
        balance[msg.sender] -= amount;
        balance[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return allowed[owner][spender];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(balance[from] >= amount);
        require(allowed[from][msg.sender] >= amount);
        balance[from] -= amount;
        allowed[from][msg.sender] -= amount;
        balance[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}

library LibVesting {
    struct VestingSchedule {
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 released;
    }
}

/* tally balance, vested, staked, weight */
contract DreamcatcherToken {
    /* settings */
    bool isPausable;
    bool isPaused;
    bool isMintable;
    bool isBurnable;
    bool isTransferable;
    /* meta */
    string name;
    string symbol;
    uint8 decimals;
    /* state */
    uint256 totalSupply;
    uint256 totalVested;
    uint256 totalStaked;
    /* address state */
    mapping(address => uint256) balance;
    mapping(address => uint256) vested;
    mapping(address => uint256) staked;
    mapping(address => uint256) votingWeight;
    mapping(address => mapping(address => uint256)) allowed;
    /* vesting */
    mapping(address => LibVesting.VestingSchedule[]) private vestingSchedules;

    /* constructor */
    constructor() {
        /* meta */
        name = "Dreamcatcher";
        symbol = "DREAM";
        decimals = 18;
        /* settings */
        isPausable = true;
        isMintable = true;
        isBurnable = true;
        isTransferable = true;
        /* initial instructions */
        mintVested(
            0xDbF85074764156004FEb245b65693e59a62262c2,
            1_000,
            480 weeks
        );
        mintVested(
            0x172952523F64EAAF288DE4cE9e5d1295DCFd3F83,
            1_000,
            480 weeks
        );
        mintVested(
            0x1de8807f69E357FD91e47B34Dc2a66216a9DC4b4,
            1_000,
            480 weeks
        );
    }

    /* events */
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event Mint(address indexed domain, uint256 amount);
    event MintTokensVested(address indexed domain, uint256 amount);
    event Burn(address indexed domain, uint256 amount);
    event TokensReleased(address indexed domain, uint256 amount);
    event RoleGranted(address indexed domain, string role);
    event RoleRevoked(address indexed domain, string role);

    /* basic interface */
    function balanceOf(address domain) external view returns (uint256) {
        return balance[domain];
    }

    function vestedFor(address domain) external view returns (uint256) {
        return vested[domain];
    }

    function stakedFor(address domain) external view returns (uint256) {
        return staked[domain];
    }

    function votingWeightOf(address domain) external view returns (uint256) {
        return votingWeight[domain];
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return allowed[owner][spender];
    }

    /* basic funcs */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(isPaused == false);
        require(isTransferable == true);
        require(balance[msg.sender] >= amount);
        balance[msg.sender] -= amount;
        balance[recipient] += amount;
        votingWeight[msg.sender] -= amount;
        votingWeight[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
    }

    function transferfrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        require(balance[sender] >= amount, "Insufficient balance");
        require(
            allowed[sender][msg.sender] >= amount,
            "Transfer amount exceeds allowance"
        );
        balance[sender] -= amount;
        votingWeight[sender] -= amount;
        balance[recipient] += amount;
        votingWeight[recipient] += amount;
        allowed[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burn(address domain, uint256 amount) public {
        require(isPaused == false);
        require(isBurnable == true);
        balance[domain] -= amount;
        votingWeight[domain] -= amount;
        totalSupply -= amount;
        emit Burn(domain, amount);
    }

    function mint(address domain, uint256 amount) public {
        require(isMintable == true, "minting is disabled");
        require(isPaused == false, "this contract is currently paused");
        require(amount > 0, "cannot be less than zero");
        balance[domain] += amount;
        votingWeight[domain] += amount;
        totalSupply += amount;
        emit Mint(domain, amount);
    }

    function mintVested(
        address domain,
        uint256 amount,
        uint256 duration
    ) private {
        require(isPaused == false);
        require(isMintable == true);
        require(amount > 0, "");
        require(domain != address(0), "");
        uint256 start = block.timestamp;
        uint256 end = start + duration;
        LibVesting.VestingSchedule memory vestingSchedule = LibVesting
            .VestingSchedule(amount, start, end, 0);
        vestingSchedules[domain].push(vestingSchedule);
        totalSupply += amount;
        totalVested += amount;
        emit MintTokensVested(domain, amount);
    }

    function releaseVested() private {
        LibVesting.VestingSchedule[] storage schedules = vestingSchedules[
            msg.sender
        ];
        uint256 sumReleased = 0;
        for (uint256 i = 0; i < schedules.length; i++) {
            LibVesting.VestingSchedule storage schedule = schedules[i];
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
        totalVested -= sumReleased;
        votingWeight[msg.sender] += sumReleased;
        balance[msg.sender] += sumReleased;
        emit TokensReleased(msg.sender, sumReleased);
    }
}

library LibTerminalUpgrade {
    /* 
    This library is built to allow the conduint contract to connect to important smart contracts
    The reason i'm doing this is to make the contracts interchangable reducing the chance of a single point of failure
    Our members will be able to vote to allow a connection to a new smart contract
    The conduit will expect a certain interface from each key components
    This way people can read the code behind the smart contract that is trying to be connected
    There will be offchain team dedicated to "deciding" what goes where
    As such our members will be key to decentralizing, no single point of failure, no offchain trust 
    */
    struct Connection {
        //moduleTypes: <token> <governor> <treasuryDAO> <timeLock>
        string moduleType;
        bool isRootModule;//is this an important smart contract module
        address domain;
        uint256 startOn;//start of the connection or date it was implemented
        uint256 endOn;//how long until the connection must be renewed this is only for non important modules
    }
}

/*
 connect all smart contracts together
 you can assign a time between storing info about a contract and utilising that contract
 */
contract Conduit {
    event NewConnection(
        uint256 id,
        string role,
        address domain,
        uint256 duration,
        bool isRoot
    );
    event ConnectionExpired(uint256 id, uint256 expiration);
    event ConnectionVerified(uint256 id, address domain, uint256 duration);
    /* access the address of a moduleContract with the name -- allows them */
    mapping(string => address) connections;
    uint256 iConnection = 0;

    function newConnection(
        string role,
        address domain,
        uint256 duration,
        bool isRoot
    ) private {
        uint256 i = iConnection;
        LibConnection.Connection memory connection;
        connection.id = i;
        connection.role = role;
        connection.domain = domain;
        connection.duration = duration;
        connection.startOn = block.timestamp;
        connection.endOn = connection.startOn + duration;
        connection.isRoot = isRoot;
        connections[i] = connection;

        emit NewConnection(iConnection, role, domain, duration, isRoot);
        iConnection++;
    }

    function delConnection(string id) private {
        delete connections[id];
    }

    function verifyConnection(string id)
        private
        returns (LibConnection.Connection)
    {
        if (
            block.timestamp >= connections[id].endOn ||
            connections[id].isRoot != false
        ) {
            uint256 secondsLeft = connections[id].endOn - block.timestamp;
            emit ConnectionVerified(
                id = id,
                domain = domain,
                duration = secondsLeft
            );
            return connections[id];
        } else {
            emit ConnectionExpired(id = id, expiration = connections[id].endOn);
        }
    }
}

contract DreamcatcherConduit is Conduit {
    constructor(address token, address vault) {
        newConnection(
            id = 0,
            role = "native-token",
            domain = msg.sender,
            duration = 48_000 weeks,
            isRoot = true
        );
        newConnection(id = "governor-0", role, domain, duration, isRoot);
    }

    event LabelGranted(address indexed domain, string label);
    event LabelRevoked(address indexed domain, string label);

    modifier only_native_token() {
        require(
            is_native_token[msg.sender] == true,
            "domain is not of native token"
        );
        _;
    }

    modifier only_syndicate() {
        require(is_syndicate[msg.sender] == true, "domain is not a syndicate");
        _;
    }

    modifier only_conduit() {
        require(is_conduit[msg.sender] == true, "domain is not a conduit");
        _;
    }

    /* labels */
    function grant_label_native_token(address domain) private {
        require(
            is_native_token[domain] != true,
            "domain already labeled as a native token"
        );
        is_native_token[domain] = true;
        emit LabelGranted(domain, "native_token");
    }

    function grant_label_syndicate(address domain) private {
        require(
            is_syndicate[domain] != true,
            "domain is already labeled as a syndicate"
        );
        is_syndicate[domain] = true;
        emit LabelGranted(domain, "syndicate");
    }

    function revoke_label_native_token(address domain) private {
        require(
            is_native_token[domain] == true,
            "domain was not labaled as a native token"
        );
        is_native_token[domain] = false;
        emit LabelRevoked(domain, "native_token");
    }

    function revoke_label_syndicate(address domain) private {
        require(
            is_syndicate[domain] == true,
            "domain was not labeled as a syndicate"
        );
        is_syndicate[domain] = false;
        emit LabelRevoked(domain, "syndicate");
    }
}
