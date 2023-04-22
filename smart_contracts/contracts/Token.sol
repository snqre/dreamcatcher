// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
Note to self:
    1) refactor tf out of this
 */


import "smart_contracts/contracts/Authenticator.sol";

interface IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface ICustomToken {

    function totalVotes() external view returns (uint256);
    function totalStaked() external view returns (uint256);
    function maxSupply() external view returns (uint256);
    function stakeOf(address _owner) external view returns (uint256);
    function votesOf(address _owner) external view returns (uint256);
    function increaseAllowance(address _spender, uint256 _value) external returns (bool);
    function decreaseAllowance(address _spender, uint256 _value) external returns (bool);
    function stake(uint256 _value) external returns (bool);
    function unstake(uint256 _value) external returns (bool);
}

// inherit from authenticator contract
contract TokenState is Authenticator {

    struct VotingMechanic {
        uint256 voteWeightPerToken; // how much voting power you can get per token
    }

    struct State {

        bool paused;
    }

    struct Settings {
        uint256 bpTransferBurnMax; // Maximum fee that can be charged
        uint256 bpTransferBankMax; // Maximum fee that can be charged
        uint256 bpTransferBurn; // basis point transfer 1 / 1000 **100 == 1%
        uint256 bpTransferBank; // for vault can be used for liquidity or etc
        uint256 bpDistribution; // % of vault to distribute to stakers bp
        VotingMechanic VotingMechanic;
        State state; // conditional booleans
    }

    struct Meta {
        string name;            // name
        string symbol;          // symbol
        uint8 decimals;         // decimals
        uint256 totalSupply;    // supply
        uint256 totalStaked;    // staked in vault
        uint256 totalVested;    // vested in vault
        uint256 totalVotes;     // votes
        uint256 totalBurnt;     // all time burnt
        uint256 maxSupply;      // hard cap
        address bank;           // **deprecated
        address vault;          // address of contract vault
    }

    Settings internal settings; // also properties of token
    Meta internal meta;         // properties of token

    struct VestingSchedule {
        string caption;         // id
        uint256 duration;       // duration
        uint256 start;          // block.timestamp
        uint256 end;            // unlock
        uint256 value;          // amount
        bool used;              // already in use
    }

    mapping(address => mapping(string => VestingSchedule)) internal schedules;      // schedules
    mapping(address => uint256) internal balance;                                   // balance
    mapping(address => uint256) internal staked;                                    // staked
    mapping(address => uint256) internal votes;                                     // votes
    mapping(address => mapping(address => uint256)) internal allowed;               // allowances || allowed
}

contract Token is TokenState {
    
    modifier paused() {require(settings.state.paused != true);_;}

    event Transfer(
        address indexed _from,
        address indexed _to, 
        uint256 _value
    );

    event Approval(
        address indexed _owner, 
        address indexed _spender, 
        uint256 _value
    );

    constructor() {
        
        meta.name = "Dreamcatcher";                     // set name
        meta.symbol = "DREAM";                          // set symbol
        meta.decimals = 18;                             // set decimals
        meta.totalSupply = 0;                           // initial totalSupply
        meta.maxSupply = 200000000 * 10**meta.decimals; // 200000000.000000000000000000
        meta.vault = msg.sender;                        // set vault address to contract address
        settings.bpTransferBurn = 0;                    // 0 | 100 == 1%
        settings.bpTransferBank = 0;                    // 0 | 100 == 1%
        settings.VotingMechanic.voteWeightPerToken = 1; // 1 token == 1 vote

        mint_(meta.vault, 200000000 * 10**meta.decimals);
    }

    function name() public view returns (string memory) {return meta.name;}
    function symbol() public view returns (string memory) {return meta.symbol;}
    function decimals() public view returns (uint8) {return meta.decimals;}
    function totalVotes() public view returns (uint256) {return meta.totalVotes;}
    function totalStaked() public view returns (uint256) {return meta.totalStaked;}
    function totalSupply() public view returns (uint256) {return meta.totalSupply;}
    function maxSupply() public view returns (uint256) {return meta.maxSupply;}
    function balanceOf(address _owner) public view returns (uint256) {return balance[_owner];}
    function stakeOf(address _owner) public view returns (uint256) {return staked[_owner];}
    function votesOf(address _owner) public view returns (uint256) {return votes[_owner];}

    // working!
    function transfer_(address _from, address _to, uint256 _value, uint256 _bpFeeBurn, uint256 _bpFeeBank) private returns (bool, uint256) {
        require(
            _from != address(0) &&
            _to   != address(0) &&
            balance[_from] >= _value &&
            balance[_from] >= 0 &&
            _value >= 0
        );

        balance[_from] -= _value;
        uint256 _feeBurn = (_value / 1000) * _bpFeeBurn;
        uint256 _feeBank = (_value / 1000) * _bpFeeBank;
        uint256 _newValue = _value - (_feeBurn + _feeBank);
        balance[_to] += _newValue;
        balance[meta.vault] += _feeBank;
        meta.totalSupply -= _feeBurn;
        emit Transfer(_from, _to, _newValue);
        if (_feeBurn != 0) {emit Transfer(_from, address(0), _feeBurn);}
        if (_feeBank != 0) {emit Transfer(_from, meta.vault, _feeBank);}

        return (
            true,       // success
            _newValue   // value after fee
        );
    }

    // working!
    function transfer(address _to, uint256 _value) public paused returns (bool) {
        (bool _success, uint256 _newValue) = transfer_(sndr, _to, _value, settings.bpTransferBurn, settings.bpTransferBank);
        return _success;
    }

    // need testing
    function transferFrom(address _from, address _to, uint256 _value) public paused returns (bool) {
        require(
            allowance(_from, sndr) != type(uint256).max &&
            allowance(_from, sndr) >= _value
        );

        allowed[_from][sndr] = _value;
        emit Approval(_from, sndr, _value);

        (bool _success, uint256 _newValue) = transfer_(_from, _to, _value, settings.bpTransferBurn, settings.bpTransferBank);
        return _success;
    }

    // working!
    function stake(uint256 _value) public paused returns (bool) {
        (bool _success, uint256 _newValue) = transfer_(msg.sender, meta.vault, _value, settings.bpTransferBurn, settings.bpTransferBank);
        staked[msg.sender]   += _newValue;
        votes[msg.sender]    += _newValue;
        meta.totalStaked     += _newValue;
        meta.totalVotes      += _newValue;
        return _success;
    }

    // working!
    function unstake(uint256 _value) public paused returns (bool) {
        require(staked[msg.sender] >= _value);
        (bool _success, uint256 _newValue) = transfer_(meta.vault, msg.sender, _value, settings.bpTransferBurn, settings.bpTransferBank);
        staked[msg.sender]   -= _value;
        votes[msg.sender]    -= _value;
        meta.totalStaked     -= _value;
        meta.totalVotes      -= _value;
        return _success;
    }

    // delegate vote to ** must ensure that if unstaked all delagates stop having those votes
    function delegateVote(address _to, uint256 _value) public paused returns (bool) {
        require(
            votesOf(msg.sender) >= _value &&
            stakeOf(msg.sender) >= _value
        );

        votes[msg.sender]    -= _value;
        votes[_to]           += _value;

        return true;
    }

    // revoke delegated votes
    function undertakeVote(address _from, uint256 _value) public paused returns (bool) {
        votes[_from] -= _value;
        votes[msg.sender] += _value;

        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {return allowed[_owner][_spender];}
    
    // need testing
    function increaseAllowance(address _spender, uint256 _value) public paused returns (bool success) {
        require(msg.sender != address(0) && _spender != address(0));
        allowed[msg.sender][_spender] = allowance(msg.sender, _spender) + _value;
        emit Approval(msg.sender, _spender, allowance(msg.sender, _spender) + _value);
        return true;
    }

    // need testing
    function decreaseAllowance(address _spender, uint256 _value) public paused returns (bool success) {
        require(
            allowance(msg.sender, _spender) >= _value &&
            msg.sender != address(0) &&
            _spender != address(0)
        );
        allowed[msg.sender][_spender] = allowance(msg.sender, _spender) - _value;
        emit Approval(msg.sender, _spender, allowance(msg.sender, _spender) - _value);
        return true;
    }
    
    // need testing
    function approve(address _spender, uint256 _value) public paused returns (bool success) {
        require((sndr != address(0)) && (_spender != address(0)), "zero address");
        allowed[sndr][_spender] = _value;
        emit Approval(sndr, _spender, _value);
        return true;
    }

    function release(string memory _caption) public paused returns (bool success) {
        require(
            schedules[msg.sender][_caption].end >= block.timestamp && // cannot release before end
            schedules[msg.sender][_caption].value > 0                 // cannot release if there is nothing to release
        );

        transfer_(
            meta.vault,                             // from
            msg.sender,                             // to
            schedules[msg.sender][_caption].value,  // value
            settings.bpTransferBurn,                // fee
            settings.bpTransferBank                 // fee
        );

        schedules[msg.sender][_caption].value = 0;  // update schedule value
        return true;                                // bool success
    }

    function mintWithVesting(     // a simple cliff vesting schedule
        address _owner,            // vested for
        uint256 _value,            // value
        uint256 _duration,         // duration seconds till release from call of this function
        string memory _caption     // readable caption to identify the staking schedule per address
        ) public paused onlyAdmin onlyOperator onlyDev returns (bool success) {
        
        require(
            schedules[_owner][_caption].used == false,   // check if schedule slot is empty
            "_caption already in use"                    // schedule already in use or used
        );

        schedules[_owner][_caption] = VestingSchedule({
            caption:     _caption,                       // readable caption to identify the staking schedule per address
            duration:    _duration,                      // duration seconds till release from call of this function
            start:       block.timestamp,                // start now
            end:         block.timestamp + _duration,    // end at
            value:       _value,                         // value
            used:        true                            // update used
        });

        meta.totalVested += _value;                      // update totalVested
        mint(_value);                                    // mint to vault **only once released will it be transfered to _owner

    }

    function mint(uint256 _value) public paused onlyAdmin onlyOperator onlyDev returns (bool success) {
        uint256 _newValue = meta.totalSupply + meta.totalBurnt + _value;
        require(
            settings.state.mintable != false &&         // check mintable
            _newValue <= meta.maxSupply,                // check maxSupply && totalBurnt
            "_newValue !<= maxSupply"                   // revert message if maxSupply reached
        );

        balance[meta.vault] += _value;                  // mint in vault
        meta.totalSupply += _value;                     // update totalSupply

        emit Transfer(address(0), meta.vault, _value);  // emit event
        return true;                                    // bool success
    }

    function burn(uint256 _value) public burnable onlyAdmin onlyOperator onlyDev returns (bool success) {
        uint256 _availableBalance = balance[meta.vault] - (meta.totalStaked + meta.totalVested);
        require(
            settings.state.burnable != false &&          // check burnable
            _availableBalance >= _value,                 // check balance
            "insufficient balance"                       // revert message if vault balance is insufficient
        );
        
        balance[meta.vault] -= _value;                   // burn
        meta.totalSupply -= _value;                      // update totalSupply
        meta.totalBurnt += _value;                       // update totalBurnt **can never mint more even if you burn totalSupply

        emit Transfer(meta.vault, address(0), _value);   // emit event
        return true;                                     // bool success
    }
    
    function updateSettings(uint256 _bpFeeBurn, uint256 _bpFeeBank) public onlyAdmin onlyOperator onlyDev returns (bool success) {
        require(
            _bpFeeBurn >= 0 &&                  // cannot be less than zero
            _bpFeeBurn <= 10000 &&              // cannot be more than 10_000 (100%)
            _bpFeeBank >= 0 &&                  // cannot be less than zero
            _bpFeeBank <= 10000,                // cannot be more than 10_000 (100%)
            "_bpFeeBurn || _bpFeeBank !range"   // revert message if one of these values are out of range
        );

        settings.bpTransferBurn = _bpFeeBurn;   // update transfer fee
        settings.bpTransferBank = _bpFeeBank;   // update transfer fee
        return true;                            // bool success
    }

    function updateSettingsState(bool _paused) public onlyAdmin onlyOperator onlyDev returns (bool success) {
        settings.state.paused = _paused;
        return true;
    }
}