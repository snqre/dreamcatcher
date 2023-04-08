// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* base ERC20 no vote */

import "../libraries/Vesting.sol";
import "smart_contracts/libraries/Meta.sol";
import "smart_contracts/contracts/Authenticator.sol";

contract BaseERC20 is Authenticator {
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

    function approve(address spender, uint256 amount)
        public
        virtual
        reentrancyLock
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        reentrancyLock
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        reentrancyLock
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
    ) internal virtual reentrancyLock {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve from the zero address");
        database.allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual reentrancyLock {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function transfer(address _recipient, uint256 _amount)
        public
        virtual
        reentrancyLock
        antiReentrancyLock
        returns (bool)
    {
        require(
            database.balance[msg.sender] >= _amount,
            "Insufficient balance"
        );
        database.balance[msg.sender] -= _amount;
        database.balance[_recipient] += _amount;
        emit Transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public virtual reentrancyLock returns (bool) {
        require(database.balance[_sender] >= _amount, "Insufficient balance");
        require(
            database.allowed[_sender][msg.sender] >= _amount,
            "Transfer amount exceeds allowance"
        );
        database.balance[_sender] -= _amount;
        database.balance[_recipient] += _amount;
        database.allowed[_sender][msg.sender] -= _amount;
        emit Transfer(_sender, _recipient, _amount);
        return true;
    }

    function burn(address account, uint256 amount)
        internal
        virtual
        reentrancyLock
        returns (bool)
    {
        require(isBurnable == true, "Burning disabled");
        require(database.balance[account] >= amount, "Insufficient balance");
        database.balance[account] -= amount;
        properties.totalSupply -= amount;
        emit Burn(account, amount);
        return true;
    }

    function mint(address account, uint256 amount)
        internal
        virtual
        reentrancyLock
        returns (bool)
    {
        require(amount > 0, "Zero and negative values not supported");
        require(isMintable == true, "Minting disabled");
        require(
            (properties.totalSupply + amount) <= properties.maxSupply,
            "No more tokens can be minted"
        );
        require(account != address(0), "Address not supported");
        database.balance[account] += amount;
        properties.totalSupply += amount;
        emit Mint(account, amount);
        return true;
    }

    mapping(address => Vesting.VestingSchedule[]) internal schedule;

    function mintWithVesting(
        address account,
        uint256 amount,
        uint256 duration
    ) internal virtual reentrancyLock returns (bool) {
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

    function release() public virtual reentrancyLock returns (bool) {
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
        return database.balance[account];
    }

    function vestedFor(address account) public view returns (uint256) {
        return database.vested[account];
    }

    function stakedFor(address account) public view returns (uint256) {
        return database.staked[account];
    }

    function voteWeightOf(address account) public view returns (uint256) {
        return database.vote[account];
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return database.allowed[owner][spender];
    }

    constructor(string _name, string _symbol, uint256 _decimals, uint256 _maxSupply) {
        properties.totalSupply = 0;
        properties.totalVested = 0;
        properties.totalStaked = 0;
        isMintable = true;
        isBurnable = true;
    }
}
