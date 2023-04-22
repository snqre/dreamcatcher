// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "smart_contracts/contracts/Token/Authenticator.sol";

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

    function stake(uint256 _value) external returns (bool);
    function unstake(uint256 _value) external returns (bool);
    function release(string memory _caption) external returns (bool);
    function updateSettings(uint256 _bpFeeBurn, uint256 _bpFeeBank) external returns (bool);
    function totalVotes() external view returns (uint256);
    function totalStaked() external view returns (uint256);
    function maxSupply() external view returns (uint256);
    function stakeOf(address _owner) external view returns (uint256);
    function votesOf(address _owner) external view returns (uint256);
}

contract Token is Authenticator, IERC20, ICustomToken {

    constructor() {
        
        meta.name = "Dreamcatcher";                     // set name
        meta.symbol = "DREAM";                          // set symbol
        meta.decimals = 18;                             // set decimals
        meta.totalSupply = 0;                           // initial totalSupply
        meta.maxSupply = 200000000 * 10**meta.decimals; // 200000000.000000000000000000
        meta.mintable = meta.maxSupply;
        meta.vault = msg.sender;                        // set vault address to contract address
        settings.bpTransferBurn = 0;                    // 0 | 100 == 1%
        settings.bpTransferBank = 0;                    // 0 | 100 == 1%
        settings.bpTransferBurnMin = 0;
        settings.bpTransferBankMin = 0;
        settings.bpTransferBurnMax = 10000;
        settings.bpTransferBankMax = 10000;

        isAdmin[msg.sender] = true;

        mint_(meta.vault, 200000000 * 10**meta.decimals);
    }

    function transfer_(address _from, address _to, uint256 _value, uint256 _bpFeeBurn, uint256 _bpFeeBank) internal returns (bool, uint256) {
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
        return (true, _newValue);
    }

    function mint_(address _to, uint256 _value) internal returns (bool) {
        address _from = address(0);
        require(
            _value >= 0 &&
            _value <= meta.mintable &&
            _to != address(0)
        );
        meta.mintable -= _value;
        (balance[_to] += _value, meta.totalSupply += _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mintWithVesting_(address _to, uint256 _value, uint256 _duration, string memory _caption) internal returns (bool) {
        address _from = address(0);
        address _safe = meta.vault;
        require(
            schedules[_to][_caption].used != true &&
            _value <= meta.mintable &&
            _to != address(0) &&
            _value >= 0
        );
        (meta.mintable -=  _value, meta.totalSupply += _value, balance[_safe] += _value);
        uint256 _start = block.timestamp;
        schedules[_to][_caption] = VestingSchedule({
            caption: _caption,
            duration: _duration,
            start: _start,
            end: _start + _duration,
            value: _value,
            used: true
        });
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function burn_(address _from, uint256 _value) internal returns (bool) {
        require(
            _value >= 0 &&
            _value <= balance[_from]
        );
        (balance[_from] -= _value, meta.totalSupply -= _value);
        emit Transfer(_from, address(0), _value);
        return true;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        address _from = msg.sender;
        uint256 _bpFeeBurn = settings.bpTransferBurn;
        uint256 _bpFeeBank = settings.bpTransferBank;
        (bool _success, uint256 _newValue) = transfer_(
            _from, 
            _to, 
            _value, 
            _bpFeeBurn, 
            _bpFeeBank);
        return _success;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        uint256 _allowance = allowed[_from][msg.sender];
        require(
            _allowance != type(uint256).max &&
            _allowance >= _value
        );
        allowed[_from][msg.sender] -= _value;
        uint256 _bpFeeBurn = settings.bpTransferBurn;
        uint256 _bpFeeBank = settings.bpTransferBank;
        (bool _success, uint256 _newValue) = transfer_(
            _from,
            _to,
            _value,
            _bpFeeBurn,
            _bpFeeBank
        );
        return _success;
    }

    function stake(uint256 _value) external returns (bool) {
        address _from = msg.sender;
        address _to = meta.vault;
        uint256 _bpFeeBurn = settings.bpTransferBurn;
        uint256 _bpFeeBank = settings.bpTransferBank;
        (bool _success, uint256 _newValue) = transfer_(
            _from,
            _to,
            _value,
            _bpFeeBurn,
            _bpFeeBank
        );
        staked[_from]    += _newValue;
        votes[_from]     += _newValue;
        meta.totalStaked += _newValue;
        meta.totalVotes  += _newValue;
        return _success;
    }

    function unstake(uint256 _value) external returns (bool) {
        address _from = meta.vault;
        address _to = msg.sender;
        uint256 _bpFeeBurn = settings.bpTransferBurn;
        uint256 _bpFeeBank = settings.bpTransferBank;
        require(
            _value <= staked[_to]
        );
        (bool _success, uint256 _newValue) = transfer_(
            _from, 
            _to, 
            _value, 
            _bpFeeBurn, 
            _bpFeeBank
        );
        staked[_to]      -= _value;
        votes[_to]       -= _value;
        meta.totalStaked -= _value;
        meta.totalVotes  -= _value;
        return _success;
    }

    function release(string memory _caption) external returns (bool) {
        address _from = meta.vault;
        address _to = msg.sender;
        uint256 _end = schedules[_to][_caption].end;
        uint256 _value = schedules[_to][_caption].value;
        require(
            _end >= block.timestamp &&
            _value > 0
        );
        uint256 _bpFeeBurn = settings.bpTransferBurn;
        uint256 _bpFeeBank = settings.bpTransferBank;
        (bool _success, uint256 _newValue) = transfer_(
            _from,
            _to,
            _value,
            _bpFeeBurn,
            _bpFeeBank
        );
        schedules[_to][_caption].value = 0;
        return _success;
    }
    
    function approve(address _spender, uint256 _value) external returns (bool) {
        address _owner = msg.sender;
        require(
            _owner != address(0) &&
            _spender != address(0)
        );
        allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
        return true;
    }

    function updateSettings(uint256 _bpFeeBurn, uint256 _bpFeeBank) external onlyAdmin returns (bool) {
        uint256 _bpFeeBurnMax = settings.bpTransferBurnMax;
        uint256 _bpFeeBankMax = settings.bpTransferBankMax;
        require(
            _bpFeeBurn >= 0 &&
            _bpFeeBurn <= _bpFeeBurnMax &&
            _bpFeeBank >= 0 &&
            _bpFeeBank <= _bpFeeBankMax
        );
        settings.bpTransferBurn = _bpFeeBurn;
        settings.bpTransferBank = _bpFeeBank;
        return true;
    }

    function name() external view returns (string memory) {
        return meta.name;
    }

    function symbol() external view returns (string memory) {
        return meta.symbol;
    }

    function decimals() external view returns (uint8) {
        return meta.decimals;
    }

    function totalVotes() external view returns (uint256) {
        return meta.totalVotes;
    }

    function totalStaked() external view returns (uint256) {
        return meta.totalStaked;
    }

    function totalSupply() external view returns (uint256) {
        return meta.totalSupply;
    }

    function maxSupply() external view returns (uint256) {
        return meta.maxSupply;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return balance[_owner];
    }

    function stakeOf(address _owner) external view returns (uint256) {
        return staked[_owner];
    }

    function votesOf(address _owner) external view returns (uint256) {
        return votes[_owner];
    }

    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}