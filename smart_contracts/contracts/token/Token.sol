// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// incomeplete, refactoring, and making standalone
import "smart_contracts/libraries/Math.sol";
import "smart_contracts/contracts/token/Authenticator.sol";

// typical erc 20 implementation plus our custom functions **incomplete
interface IToken {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function maxSupply() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

// allows other contracts to access role management if they are admin
interface IRoleManagement {
    function grantRoleAdmin(address _to) external returns (bool);      // admin can grant admin
    function revokeRoleAdmin(address _to) external returns (bool);     // admin can revoke admin
    function grantRoleOwner(address _to) external returns (bool);      // admin can grant owner
    function revokeRoleOwner(address _to) external returns (bool);     // admin can revoke owner
    function revokeMyRoleOwner() external returns (bool);                  // owner can revoke owner
    function grantRoleValidator(address _to) external returns (bool);  // admin can grant validator
    function revokeRoleValidator(address _to) external returns (bool); // admin can revoke validator
    function revokeMyRoleValidator() external returns (bool);              // validator can revoke self validator
    function grantRoleExtention() external returns (bool);                 // admin can grant extension
    function revokeRoleExtension() external returns (bool);                // admin can revoke extension
    function revokeMyRoleExtension() external returns (bool);              // extension can revoke self extension
}

contract Token is Authenticator {
    string   private name_ = "Dreamcatcher";
    string   private symbol_ = "DREAM";
    uint8    private decimals_ = 18;
    uint256  private totalSupply_ = 0 * 10**decimals_;
    uint256  private maxSupply_ = 200_000_000 * 10**decimals_;

    mapping(address => uint256) internal balances;
    mapping(address => uint256) internal vested;      // amount of tokens the vault owes them and will release linearly
    mapping(address => uint256) internal staked;
    mapping(address => uint256) internal votes;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => uint256) internal _timeSinceMembership;       // time since their votes has been > 0 or they are able to vote
    
    struct VestingSchedule {
        uint256 startTime;
        uint256 end;
        uint256 value;
        uint256 duration;
        uint256 releasedPerDay;
        address owner;
    }
    mapping(address => uint256) vestingId;
    // [address][vestingId] = VestingSchedule
    mapping(address => mapping(uint256 => VestingSchedule)) schedule;

    modifier countVestingId() {
        vestingId[msg.sender] ++;
        _;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event AllowanceIncreased(address indexed _owner, address indexed _spender, uint256 _value);
    event AllowanceDecreased(address indexed _owner, address indexed _spender, uint256 _value);
    event Mint(address indexed _to, uint256 _value);
    event Stake(address indexed _owner, uint256 _value);
    event Unstake(address indexed _owner, uint256 _value);
    
    constructor() {
        isAdmin[msg.sender] = true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(msg.sender != address(0), "zero address");
        require(_spender != address(0), "zero address");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _value) public returns (bool) {
        require(msg.sender != address(0), "zero address");
        require(_spender != address(0), "zero address");
        allowed[msg.sender][_spender] = Math.add(allowance(msg.sender, _spender), _value);
        emit AllowanceIncreased(msg.sender, _spender, _value);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _value) public returns (bool) {
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
    function mint(address _to, uint256 _value) public admin payable returns (bool) {
        uint256 newTotalSupply = Math.add(totalSupply_, _value);
        require(newTotalSupply <= maxSupply_, "max supply reached");
        balances[_to] += _value;
        totalSupply_ += _value;
        emit Mint(_to, _value);
        return true;
    }

    // to be able to stake you need to be a validator as staking is responsible for issuing votes
    // we will allow anyone to stake and unstake at anytime but if they unstake current votes will be cancelled
    function stake(address _owner, uint256 _value) public validator returns (bool) {
        require(_value <= balances[_owner], "insufficient balance");
        balances[_owner] -= _value;
        staked[_owner] += _value;
        votes[_owner] += _value;
        emit Stake(_owner, _value);
        return true;
    }

    function unstake(address _owner, uint256 _value) public validator returns (bool) {
        require(_value <= staked[_owner], "insufficient staked balance");
        staked[_owner] -= _value;
        votes[_owner] -= _value;
        balances[_owner] += _value;
        emit Unstake(_owner, _value);
        return true;
    }

    function vest(address _owner, uint256 _value, uint256 _duration) public admin countVestingId returns (bool) {
        uint256 vestingId = vestingId[msg.sender];
        VestingSchedule memory newSchedule = VestingSchedule({
            startTime: block.timestamp,
            duration: _duration,
            end: block.timestamp + _duration,
            value: _value,
            releasedPerDay: _value / (_duration / 1 days),
            owner: _owner
        });
        schedule[msg.sender][vestingId] = newSchedule;
    }

    function calculateVestedAmount() public view returns (uint256) {
        uint256 totalReleased = 0;
        uint256 numSchedules = vestingId[msg.sender];
        for (uint256 i = 1; i <= numSchedules; i++) {
            if (block.timestamp >= schedule[msg.sender][i].startTime && block.timestamp <= schedule[msg.sender][i].end) {
                uint256 elapsedTime = block.timestamp - schedule[msg.sender][i].startTime;
                uint256 vestedAmount = (elapsedTime / 1 days) * schedule[msg.sender][i].releasedPerDay;
                totalReleased += vestedAmount;
            }
        }
        return totalReleased;
    }
    
    

    function increaseAllowanceOwedBalance(uint256 _vestingId) external returns (bool) {
        VestingSchedule storage schedule = schedule[msg.sender][_vestingId];
        
        require(block.timestamp >= schedule.end, "Vesting not completed");
        
        uint256 vestedAmount = schedule.value;
        
        // increase allowance of the account
        require(msg.sender != address(0), "Zero address");
        address self = address(this);
        address spender = msg.sender;
        allowed[self][spender] = allowed[self][spender] + vestedAmount;
        
        emit AllowanceIncreased(address(this), msg.sender, vestedAmount);
        
        return true;
    }

    // these are used to communicate with other extension contracts but in batch (can get a list of data from a map rather than use multiple transactions)
    function packageVestingScheduleToExtention() external extension {}
    function packageBalanceArrToExtension() external extension {}
    function packageVoteArrToExtension() external extension {}

    // ERC 20 STANDARD
    function name() public view returns (string memory) {return name_;}
    function symbol() public view returns (string memory) {return symbol_;}
    function decimals() public view returns (uint8) {return decimals_;}
    function maxSupply() public view returns (uint256) {return maxSupply_;}
    function totalSupply() public view returns (uint256) {return totalSupply_;}
    function balanceOf(address account) public view returns (uint256) {return balances[account];}
    function allowance(address owner, address spender) public view returns (uint256) {return allowed[owner][spender];}
    // NATIVE FUNCTIONS
    function timeSinceMembership(address account) public returns (uint256) {return _timeSinceMembership[account];}
}