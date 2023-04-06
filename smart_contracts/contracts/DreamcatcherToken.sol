// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

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

library LibSeconds
{
    struct to {
        uint256 day;
        uint256 week;
        uint256 month;
        uint256 
    }
}
library LibVesting
{
    struct VestingSchedule 
    {
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 released;
    }
}
/* tally balance, vested, staked, weight */
contract DreamcatcherToken 
{
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
    mapping(address => VestingSchedule[]) private vestingSchedules;
    /* constructor */
    constructor()
    {
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
        mintVested(0xDbF85074764156004FEb245b65693e59a62262c2, 1_000, 480 weeks);
        mintVested(0x172952523F64EAAF288DE4cE9e5d1295DCFd3F83, 1_000, 480 weeks);
        mintVested(0x1de8807f69E357FD91e47B34Dc2a66216a9DC4b4, 1_000, 480 weeks);
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
    function balanceOf(address domain) external view returns (uint256) 
    {
        return balance [domain];
    }
    function vestedFor(address domain) external view returns (uint256)
    {
        return vested [domain];
    }
    function stakedFor(address domain) external view returns (uint256)
    {
        return staked [domain];
    }
    function votingWeightOf(address domain) external view returns (uint256)
    {
        return votingWeight [domain];
    }
    function allowance(address owner, address spender) external view returns (uint256)
    {
        return allowed[owner][spender];
    }
    /* basic funcs */
    function transfer(address recipient, uint256 amount) public returns (bool)
    {
        require(isPaused == false);
        require(isTransferable == true);
        require(balance[msg.sender] >= amount);
        balance[msg.sender] -= amount;
        balance[recipient] += amount;
        votingWeight[msg.sender] -= amount;
        votingWeight[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
    }
    function transferfrom(address sender, address recipient, uint256 amount) public returns (bool)
    {
        require
        (
            balance[sender] >= amount,
            "Insufficient balance"
        );
        require
        (
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
    function burn(address domain, uint256 amount) public 
    {
        require(isPaused == false);
        require(isBurnable == true);
        balance[domain] -= amount;
        votingWeight[domain] -= amount;
        totalSupply -= amount;
        emit Burn(domain, amount);
    }
    function mint(address domain, uint256 amount) public 
    {
        require(isMintable == true, "minting is disabled");
        require(isPaused == false, "this contract is currently paused");
        require(amount > 0, "cannot be less than zero");
        balance[domain] += amount;
        votingWeight[domain] += amount;
        totalSupply += amount;
        emit Mint(domain, amount);
    }
    function mintVested(address domain, uint256 amount, uint256 duration) private 
    {
        require(isPaused == false);
        require(isMintable == true);
        require(amount > 0, "");
        require(domain != address(0), "");
        uint256 start = block.timestamp;
        uint256 end = start + duration;
        LibVesting.VestingSchedule memory vestingSchedule = LibVesting.VestingSchedule(
            amount,
            start,
            end,
            0
        );
        vestingSchedules[domain].push(vestingSchedule);
        totalSupply += amount;
        totalVested += amount;
        emit MintTokensVested(domain, amount);
    }
    function releaseVested() private
    {
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
        totalVested -= sumReleased;
        votingWeight[msg.sender] += sumReleased;
        balance[msg.sender] += sumReleased;
        emit TokensReleased(msg.sender, sumReleased);
    }
}
library LibConnection 
{
    struct Connection 
    {
        string role;
        address domain;
        uint256 startOn;
        uint256 endOn;
        /* is the smartContract a core module of Dreamcatcher */
        bool isRoot;
    }
}
/* connect all smart contracts together */
contract Conduit 
{
    event NewConnection(string id, address domain, uint256 duration, bool isRoot);
    event ConnectionExpired(string id, uint256 expiration);
    event ConnectionVerified(string id, address domain, uint256 duration)
    /* access the address of a moduleContract with the name -- allows them */
    mapping (string=>address) connections;
    function newConnection(string id, string role="default", address domain, uint256 duration=-1, bool isRoot=false) private
    {
        connections [id] = LibConnection.Connection
        (
            if (role != "default")
            {
                role = role;
            }
            domain = domain;
            startOn = block.timestamp;
            if (timeout >= 0) && (isRoot == false)
            {
                endOn = startOn + duration;
            }
            isRoot = isRoot;
        );
        NewConnection(id=id, domain=domain, duration=duration, isRoot=isRoot);
    }
    function delConnection(string id) private
    {
        delete connections[id];
    }
    /* recommend utilising this with timeout contracts */
    function verifyConnection(string id) private returns (LibConnection.Connection)
    {
        if (block.timestamp >= connections[id].endOn) || (connections[id].isRoot!=false)
        {
            uint256 secondsLeft = connections[id].endOn - block.timestamp;
            emit ConnectionVerified(id=id, domain=domain, duration=secondsLeft);
            return connections[id];
        }
        else
        {      
            emit ConnectionExpired(id=id, expiration=connections[id].endOn);
        }
    }

}
contract DreamcatcherConduit is Conduit
{
    

    address mapping(address=>bool) addressIsNativeToken;
    address mapping(address=>bool) addressIsSyndicate;
    address mapping(address=>bool) addressIsGovernor;
    constructor (address token, address vault) {
        
    }

    event LabelGranted(address indexed domain, string label);
    event LabelRevoked(address indexed domain, string label);


    modifier only_native_token() {
        require(is_native_token[msg.sender] == true, "domain is not of native token"); 
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
        require(is_native_token[domain] != true, "domain already labeled as a native token");
        is_native_token[domain] = true;
        emit LabelGranted(domain, "native_token");
    } 
    function grant_label_syndicate(address domain) private {
        require(is_syndicate[domain] != true, "domain is already labeled as a syndicate");
        is_syndicate[domain] = true;
        emit LabelGranted(domain, "syndicate");
    } 
    function revoke_label_native_token(address domain) private {
        require(is_native_token[domain] == true, "domain was not labaled as a native token");
        is_native_token[domain] = false;
        emit LabelRevoked(domain, "native_token");
    } 
    function revoke_label_syndicate(address domain) private {
        require(is_syndicate[domain] == true, "domain was not labeled as a syndicate");
        is_syndicate[domain] = false;
        emit LabelRevoked(domain, "syndicate");
    }    
}