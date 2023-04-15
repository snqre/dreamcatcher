// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// incomeplete, refactoring, and making standalone
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

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event AllowanceIncreased(address indexed _owner, address indexed _spender, uint256 _value);
    event AllowanceDecreased(address indexed _owner, address indexed _spender, uint256 _value);
    event Mint(address indexed _to, uint256 _value);

    function approve(address _spender, uint256 _value) external returns (bool) {
        require(msg.sender != address(0), "zero address");
        require(_spender != address(0), "zero address");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _value) external returns (bool) {
        require(msg.sender != address(0), "zero address");
        require(_spender != address(0), "zero address");
        allowed[msg.sender][_spender] = Math.add(allowance(msg.sender, _spender), _value);
        emit AllowanceIncreased(msg.sender, _spender, _value);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _value) external returns (bool) {
        uint256 currentAllowance = allowance(msg.sender, _spender);
        require(currentAllowance >= _value, "decrease allowance below zero");
        unchecked {
            require(msg.sender != address(0), "zero address");
            require(_spender != address(0), "zero address");
            allowed[msg.sender][_spender] = Math.sub(currentAllowance, _value);
        }
        emit AllowanceDecreased(msg.sender, _spender, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] >= _value, "insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balances[_from] >= _value, "insufficient balance");
        require(allowed[_from][msg.sender] >= _value, "transfer amount exceeds allowance");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
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