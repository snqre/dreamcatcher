// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/libraries/Vesting.sol";
contract BaseERC20 {
    bool private isMintable;
    bool private isBurnable;
    string private name;
    string private symbol;
    uint256 private decimals;
    uint256 private maxSupply;
    uint256 private totalSupply;
    uint256 private totalVested;
    uint256 private totalStaked;
    mapping(address => uint256) private balance;
    mapping(address => uint256) private vested;
    mapping(address => uint256) private staked;
    mapping(address => uint256) private vote;
    mapping(address => mapping(address => uint256)) private allowed;
    mapping(address => Vesting.VestingSchedule[]) private schedule;
    mapping(address => bool) private isFoundingTeam;
    event TokensReleased(address indexed account, uint256 amount);
    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event RoleGranted(address indexed account, string role);
    event RoleRevoked(address indexed account, string role);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    modifier onlyFoundingTeam() {//only for the first timeframe after deployment to make sure we can fix any likely problems will revoke before funding rounds
        require(isFoundingTeam[msg.sender]);
        _;
    }
    function revokeIsFoundingTeam() external onlyFoundingTeam {
        isFoundingTeam[msg.sender] = false;
        emit RoleRevoked(msg.sender, "isFoundingTeam");
    }
    modifier onlyProposal() {
        require();
        _;
    }
    bool private locked;
    modifier antiReentrancyLock() {
        require(!locked, "Anti-reentrancy in place");
        locked = true;
        _;
        locked = false;
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve from the zero address");
        allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }
    function _spendAllowance(address owner, address spender, uint256 amount) private {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _spendAllowance(address owner, address spender, uint256 amount) private {
        uint256 currentAllowance = allowed;
    }
    function transfer(address recipient, uint256 amount) external antiReentrancyLock() returns (bool) {
        require(balance[msg.sender] >= amount, "Insufficient balance");
        balance[msg.sender] -= amount;
        vote[msg.sender] -= amount;
        balance[recipient] += amount;
        vote[msg.sender] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) external antiReentrancyLock() returns (bool) {
        require(balance[sender] >= amount, "Insufficient balance");
        require(allowed[sender][msg.sender] >= amount, "Transfer amount exceeds allowance");
        balance[sender] -= amount;
        vote[sender] -= amount;
        balance[recipient] += amount;
        vote[recipient] += amount;
        allowed[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function _burn(address account, uint256 amount) private returns (bool) {
        require(isBurnable == true, "Burning disabled");
        require(balance[account] >= amount, "Insufficient balance");
        balance[account] -= amount;
        vote[account] -= amount;
        totalSupply -= amount;
        emit Burn(account, amount);
        return true;
    }
    function _mint(address account, uint256 amount) private returns (bool) {
        require(amount > 0, "Zero and negative values not supported");
        require(isMintable == true, "Minting disabled");
        require((totalSupply + amount) <= maxSupply, "No more tokens can be minted");
        require(account != address(0), "Address not supported");
        balance[account] += amount;
        vote[account] += amount;
        totalSupply += amount;
        emit Mint(account, amount);
        return true;
    }
    function _mintWithVesting(address account, uint256 amount, uint256 duration) private returns (bool) {
        require(amount > 0, "Zero and negative values not supported");
        require(isMintable == true, "Minting disabled");
        require((totalSupply + amount) <= maxSupply, "No more tokens can be minted");
        require(account != address(0), "Address not supported");
        uint256 memory start = block.timestamp;
        uint256 memory end = start + duration;
        Vesting.VestingSchedule memory vestingSchedule = Vesting.VestingSchedule(amount, start, end, 0);
        schedule[account].push(vestingSchedule);
        totalSupply += amount;
        totalVested += amount;
        emit Mint(account, amount);
        return true;
    }
    function release() external antiReentrancyLock returns (bool) {
        Vesting.VestingSchedule[] storage schedules = schedule[msg.sender];
        uint256 memory totalReleased = 0;
        for (uint256 i = 0; i < schedules.length; i++) {
            Vesting.VestingSchedule storage schedules = schedule[i];
            if (block.timestamp >= schedules.end) {
                uint256 memory amountToRelease = schedules.amount - schedules.released;
                schedules.released = schedules.amount;
                totalReleased += amountToRelease;
            }
            else {
                uint256 memory timeElapsed = block.timestamp - schedules.start;
                uint256 memory vestingDuration = schedules.end - schedules.start;
                uint256 memory amountToRelease = (schedules.amount * timeElapsed) / vestingDuration - schedules.released;
                schedules.released += amountToRelease;
                totalReleased += amountToRelease;
            }
            require(sumReleased > 0, "No tokens to release");
            totalVested -= totalReleased;
            balance[msg.sender] += totalReleased;
            vote[msg.sender] += totalReleased;
            emit TokensReleased(msg.sender, totalReleased);
            return true;       
        }
    }
    function name() public view returns (string memory) {
        return name;
    }
    function symbol() public view returns (string memory) {
        return symbol;
    }
    function decimals() public view returns (uint256 memory) {
        return decimals;
    }
    function totalSupply() public view returns (uint256 memory) {
        return totalSupply;
    }
    function totalVested() public view returns (uint256 memory) {
        return totalVested;
    }
    function totalStaked() public view returns (uint256 memory) {
        return totalStaked;
    }
    function balanceOf(address account) public view returns (uint256 memory) {
        return balance[account];
    }
    function vestedFor(address account) public view returns (uint256 memory) {
        return vested[account];
    }
    function stakedFor(address account) public view returns (uint256 memory) {
        return staked[account];
    }
    function voteWeightOf(address account) public view returns (uint256 memory) {
        return vote[account];
    }
    function allowance(address owner, address spender) public view returns (uint256 memory) {
        return allowed[owner][spender];
    }
    constructor() {
        name = "Dreamcatcher";
        symbol = "DREAM";
        decimals = 18;
        maxSupply = 100_000;
        isMintable = true;
        isBurnable = true;
        _mintWithVesting(0xDbF85074764156004FEb245b65693e59a62262c2, 10_000, 4_800 weeks);
        _mintWithVesting(0x172952523F64EAAF288DE4cE9e5d1295DCFd3F83, 1_000, 480 weeks);
        _mintWithVesting(0x1de8807f69E357FD91e47B34Dc2a66216a9DC4b4, 1_000, 480 weeks);
    }
}
