// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/libraries/Vesting.sol";
import "smart_contracts/libraries/Meta.sol";

contract BaseERC20 {
    bool internal isMintable;
    bool internal isBurnable;
    Meta.Properties internal properties;
    Meta.Database internal database;
    mapping(address => bool) internal isFoundingTeam;
    event TokensReleased(address indexed account, uint256 amount);
    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event RoleGranted(address indexed account, string role);
    event RoleRevoked(address indexed account, string role);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    modifier onlyFoundingTeam() {
        //only for the first timeframe after deployment to make sure we can fix any likely problems will revoke before funding rounds
        require(isFoundingTeam[msg.sender]);
        _;
    }

    function revokeIsFoundingTeam() external onlyFoundingTeam {
        isFoundingTeam[msg.sender] = false;
        emit RoleRevoked(msg.sender, "isFoundingTeam");
    }

    //modifier onlyProposal() {
    //require();
    //_;
    //}
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

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "Decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve from the zero address");
        database.allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) private {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function transfer(address recipient, uint256 amount)
        external
        antiReentrancyLock
        returns (bool)
    {
        require(database.balance[msg.sender] >= amount, "Insufficient balance");
        database.balance[msg.sender] -= amount;
        database.vote[msg.sender] -= amount;
        database.balance[recipient] += amount;
        database.vote[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external antiReentrancyLock returns (bool) {
        require(database.balance[sender] >= amount, "Insufficient balance");
        require(
            database.allowed[sender][msg.sender] >= amount,
            "Transfer amount exceeds allowance"
        );
        database.balance[sender] -= amount;
        database.vote[sender] -= amount;
        database.balance[recipient] += amount;
        database.vote[recipient] += amount;
        database.allowed[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal returns (bool) {
        require(isBurnable == true, "Burning disabled");
        require(balance[account] >= amount, "Insufficient balance");
        database.balance[account] -= amount;
        database.vote[account] -= amount;
        properties.totalSupply -= amount;
        emit Burn(account, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal returns (bool) {
        require(amount > 0, "Zero and negative values not supported");
        require(isMintable == true, "Minting disabled");
        require(
            (properties.totalSupply + amount) <= properties.maxSupply,
            "No more tokens can be minted"
        );
        require(account != address(0), "Address not supported");
        database.balance[account] += amount;
        database.vote[account] += amount;
        properties.totalSupply += amount;
        emit Mint(account, amount);
        return true;
    }

    mapping(address => Vesting.VestingSchedule[]) internal schedule;

    function _mintWithVesting(
        address account,
        uint256 amount,
        uint256 duration
    ) internal returns (bool) {
        require(amount > 0, "Zero and negative values not supported");
        require(isMintable == true, "Minting disabled");
        require(
            (properties.totalSupply + amount) <= properties.maxSupply,
            "No more tokens can be minted"
        );
        require(account != address(0), "Address not supported");
        uint256 start = block.timestamp;
        uint256 end = start + duration;
        Vesting.VestingSchedule memory vestingSchedule = Vesting
            .VestingSchedule(amount, start, end, 0);
        schedule[account].push(vestingSchedule);
        properties.totalSupply += amount;
        properties.totalVested += amount;
        emit Mint(account, amount);
        return true;
    }

    function release() external antiReentrancyLock returns (bool) {
        Vesting.VestingSchedule[] storage schedules = schedule[msg.sender];
        uint256 totalReleased = 0;
        for (uint256 i = 0; i < schedules.length; i++) {
            Vesting.VestingSchedule storage currentSchedule = schedules[i];
            if (block.timestamp >= currentSchedule.end) {
                uint256 amountToRelease = currentSchedule.amount -
                    currentSchedule.released;
                currentSchedule.released = currentSchedule.amount;
                totalReleased += amountToRelease;
            } else {
                uint256 timeElapsed = block.timestamp - currentSchedule.start;
                uint256 vestingDuration = currentSchedule.end -
                    currentSchedule.start;
                uint256 amountToRelease = (currentSchedule.amount *
                    timeElapsed) /
                    vestingDuration -
                    currentSchedule.released;
                currentSchedule.released += amountToRelease;
                totalReleased += amountToRelease;
            }
            require(totalReleased > 0, "No tokens to release");
            properties.totalVested -= totalReleased;
            database.balance[msg.sender] += totalReleased;
            database.vote[msg.sender] += totalReleased;
            emit TokensReleased(msg.sender, totalReleased);
            return true;
        }
    }

    function name() public view returns (string memory) {
        return properties.name;
    }

    function symbol() public view returns (string memory) {
        return properties.symbol;
    }

    function decimals() public view returns (uint256) {
        return properties.decimals;
    }

    function totalSupply() public view returns (uint256) {
        return properties.totalSupply;
    }

    function totalVested() public view returns (uint256) {
        return properties.totalVested;
    }

    function totalStaked() public view returns (uint256) {
        return properties.totalStaked;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balance[account];
    }

    function vestedFor(address account) public view returns (uint256) {
        return vested[account];
    }

    function stakedFor(address account) public view returns (uint256) {
        return staked[account];
    }

    function voteWeightOf(address account) public view returns (uint256) {
        return vote[account];
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return database.allowed[owner][spender];
    }

    constructor() {
        properties.name = "Dreamcatcher";
        properties.symbol = "DREAM";
        properties.decimals = 18;
        properties.maxSupply = 200_000_000;
        properties.totalSupply = 0;
        properties.totalVested = 0;
        properties.totalStaked = 0;
        isMintable = true;
        isBurnable = true;
        _mintWithVesting(
            0xDbF85074764156004FEb245b65693e59a62262c2,
            20_000_000,
            4_800 weeks
        );
        _mintWithVesting(
            0x172952523F64EAAF288DE4cE9e5d1295DCFd3F83,
            2_000_000,
            480 weeks
        );
        _mintWithVesting(
            0x1de8807f69E357FD91e47B34Dc2a66216a9DC4b4,
            2_000_000,
            480 weeks
        );
        _mintWithVesting(msg.sender, 160_000_000, 2 weeks);
    }
}
