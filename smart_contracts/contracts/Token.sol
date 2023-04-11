// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "smart_contracts/contracts/Authenticator.sol";
import "smart_contracts/libraries/Math.sol";

contract Token is Authenticator {
    event VestedTokensReleased(address indexed account, uint256 amount);
    event Mint(address indexed account, uint256 amount);
    event MintWithVesting();
    event Burn(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event AllowanceIncreased(address indexed account, address indexed spender, uint256 increase);
    event AllowanceDecreased(address indexed account, address indexed spender, uint256 decrease);

    function approve(address spender, uint256 amount) public checkIsPaused {
        require(msg.sender != address(0), "zero address");
        require(spender != address(0), "zero address");
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public checkIsPaused {   
        require(msg.sender != address(0), "zero address");
        require(spender != address(0), "zero address");
        uint256 x = allowance(msg.sender, spender);
        uint256 y = addedValue;
        allowed[msg.sender][spender] = Math.add(x, y);
        emit AllowanceIncreased(msg.sender, spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public checkIsPaused {
        uint256 currentAllowance = allowance(msg.sender, spender);
        require(currentAllowance >= subtractedValue, "decrease allowance below zero");
        unchecked {
            require(msg.sender != address(0), "zero address");
            require(spender != address(0), "zero address");
            uint256 x = currentAllowance;
            uint256 y = subtractedValue;
            allowed[msg.sender][spender] = Math.sub(x, y);
        }
        emit AllowanceDecrease(msg.sender, spender, subtractedValue);
    }

    function transfer(address recipient, uint256 amount) public checkIsPaused checkIsTransferable {
        require(balances[msg.sender] >= amount, "insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public checkIsPaused checkIsTransferable {
        require(balances[sender] >= amount, "insufficient balance");
        require(allowed[sender][msg.sender] >= amount, "transfer amount exceeds allowance");
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowed[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
    }

    function burn(uint256 amount) public checkIsPaused checkIsBurnable {
        require(balances[msg.sender] >= amount, "insufficient balance");
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Burn(msg.sender, amount);
    }

    function mint(address account, uint256 amount) public checkIsPaused checkIsMintable isAdmin {
        require(amount > 0, "must be greater than zero");
        uint256 x = Math.add(totalSupply, amount);
        require(x <= maxSupply, "new amount is greater than maximum supply");
        require(account != address(0), "zero address");
        balances[account] += amount;
        totalSupply += amount;
        emit Mint(account, amount);
    }

    function mintWithVesting(address account, uint256 amount, uint256 duration) public checkIsPaused checkIsMintable isAdmin {
        require(amount > 0, "must be greater than zero");
        uint256 x = Math.add(totalSupply, amount);
        require(x <= maxSupply, "new amount is greater than maximum supply");
        require(account != address(0), "zero address");
        uint256 a = block.timestamp;
        uint256 b = Math.add(a, duration);
        VestingSchedule memory schedule = VestingSchedule(amount, a, b, 0);
        schedules[account].push(schedule);
        totalSupply += amount;
        totalVested += amount;
        vested[account] += amount;
        emit MintWithVesting();
    }

    function releaseVestedTokens() public checkIsPaused {
        VestingSchedule[] storage vestingSchedules = schedules[msg.sender];
        uint256 totalReleased;
        for (uint256 i = 0; i < vestingSchedules.length; i++) {
            VestingSchedule storage schedule = vestingSchedules[i];
            uint256 elapsed = block.timestamp - schedule.start;
            uint256 a = Math.mul(elapsed, schedule.amount);
            uint256 b = Math.sub(schedule.end, schedule.start);
            uint256 vestedAmount = Math.div(a, b);
            uint256 unreleasedAmount = vestedAmount - schedule.released;
            if (unreleasedAmount > 0) {
                schedule.released = vestedAmount;
                totalReleased += unreleasedAmount;
            }
        }
        require(totalReleased > 0, "no vested tokens to release");
        balances[msg.sender] += totalReleased;
        vested[msg.sender] -= totalReleased;
        totalVested -= totalReleased;
        emit VestedTokensReleased(msg.sender, totalReleased);
    }

    function name() public view returns (string memory) {return name;}
    function symbol() public view returns (string memory) {return symbol;}
    function decimals() public view returns (uint8) {return decimals;}
    function maxSupply() public view returns (uint256) {return maxSupply;}
    function totalSupply() public view returns (uint256) {return totalSupply;}
    function totalVested() public view returns (uint256) {return totalVested;}
    function totalStaked() public view returns (uint256) {return totalStaked;}
    function totalVotes() public view returns (uint256) {return totalVotes;}
    function balanceOf(address account) public view returns (uint256) {return balances[account];}
    function vestedOf(address account) public view returns (uint256) {return vested[account];}
    function stakedOf(address account) public view returns (uint256) {return staked[account];}
    function votesOf(address account) public view returns (uint256) {return votes[account];}
    function allowance(address owner, address spender) public view returns (uint256) {return allowed[owner][spender];}

    constructor() {}
}
