// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "smart_contracts/libraries/Math.sol";
import "smart_contracts/contracts/token/Authenticator.sol";

// typical erc 20 implementation plus our custom functions **incomplete
interface IToken {
    function name() external view returns (string);
    function symbol() external view returns (string);
    function decimals() external view returns (uint8);
    function maxSupply() external view returns (uint256);
    function totalSupply() public view returns (uint256);
    function balanceOf(address account) public view returns (uint256);
    function allowance(address owner, address spender) public view returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool);
    function approve(address spender, uint256 amount) public returns (bool);
    function transfer(address recipient, uint256 amount) public returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool);
}

// allows other contracts to access role management if they are admin
interface IRoleManagement {
    function grantRoleAdmin(address account) public returns (bool);      // admin can grant admin
    function revokeRoleAdmin(address account) public returns (bool);     // admin can revoke admin
    function grantRoleOwner(address account) public returns (bool);      // admin can grant owner
    function revokeRoleOwner(address account) public returns (bool);     // admin can revoke owner
    function revokeMyRoleOwner() public returns (bool);                  // owner can revoke owner
    function grantRoleValidator(address account) public returns (bool);  // admin can grant validator
    function revokeRoleValidator(address account) public returns (bool); // admin can revoke validator
    function revokeMyRoleValidator() public returns (bool);              // validator can revoke self validator
    function grantRoleExtention() public returns (bool);                 // admin can grant extension
    function revokeRoleExtension() public returns (bool);                // admin can revoke extension
    function revokeMyRoleExtension() public returns (bool);              // extension can revoke self extension
}

contract Token is Authenticator {
    string   immutable name          = "Dreamcatcher";
    string   immutable symbol        = "DREAM";
    uint8    immutable decimals      = 18;
    uint256  immutable totalSupply   = 200000000 * 10**decimals;
    uint256  immutable maxSupply     = 200000000 * 10**decimals;

    mapping(address => uint256) private balances;
    mapping(address => uint256) private vested;      // amount of tokens the vault owes them and will release linearly
    mapping(address => uint256) private staked;
    mapping(address => uint256) private votes;
    mapping(address => uint256) private allowed;
    mapping(address => uint256) private timeSinceMembership;       // time since their votes has been > 0 or they are able to vote
    
    mapping(address => VestingSchedule[]) private schedules;
    struct VestingSchedule {
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 released;
    }

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event AllowanceIncreased(address indexed account, address indexed spender, uint256 increase);
    event AllowanceDecreased(address indexed account, address indexed spender, uint256 decrease);

    function approve(address spender, uint256 amount) public returns (bool) {
        require(msg.sender != address(0), "zero address");
        require(spender != address(0), "zero address");
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {   
        require(msg.sender != address(0), "zero address");
        require(spender != address(0), "zero address");
        uint256 x = allowance(msg.sender, spender);
        uint256 y = addedValue;
        allowed[msg.sender][spender] = Math.add(x, y);
        emit AllowanceIncreased(msg.sender, spender, addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowance(msg.sender, spender);
        require(currentAllowance >= subtractedValue, "decrease allowance below zero");
        unchecked {
            require(msg.sender != address(0), "zero address");
            require(spender != address(0), "zero address");
            uint256 x = currentAllowance;
            uint256 y = subtractedValue;
            allowed[msg.sender][spender] = Math.sub(x, y);
        }
        emit AllowanceDecreased(msg.sender, spender, subtractedValue);
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(balances[sender] >= amount, "insufficient balance");
        require(allowed[sender][msg.sender] >= amount, "transfer amount exceeds allowance");
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowed[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // mint function will only ever be called once during deployment to mint the whole batch
    function mint() admin {}

    // to be able to stake you need to be a validator as staking is responsible for issuing votes
    // we will allow anyone to stake and unstake at anytime but if they unstake current votes will be cancelled
    function stake(address account, uint256 amount) public validator returns (bool) {
        require(amount <= balances[account], "insufficient balance");
        balances[account] -= amount;
        staked[account] += amount;
        votes[account] += amount;
        return true;
    }

    function unstake(address account, uint256 amount) public validator returns (bool) {
        require(amount <= staked[account], "insufficient staked balance");
        staked[account] -= amount;
        votes[account] -= amount;
        balances[account] += amount;
        return true;
    }

    // these are used to communicate with other extension contracts but in batch (can get a list of data from a map rather than use multiple transactions)
    function packageVestingScheduleToExtention() external extension {}
    function packageBalanceArrToExtension() external extension {}
    function packageVoteArrToExtension() external extension {}

    // ERC 20 STANDARD
    function name() public view returns (string) {return name;}
    function symbol() public view returns (string) {return symbol;}
    function decimals() public view returns (uint8) {return decimals;}
    function maxSupply() public view returns (uint256) {return maxSupply;}
    function totalSupply() public view returns (uint256) {return totalSupply;}
    function balanceOf(address account) public view returns (uint256) {return balances[account];}
    function allowance(address owner, address spender) public view returns (uint256) {return allowed[owner][spender];}
    // NATIVE FUNCTIONS
    function timeSinceMembership(address account) public returns (uint256) {return timeSinceMembership[account];}

    constructor() {}
}