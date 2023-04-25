// SPDX-License-Identifier: BSD-2-Clause
// please recognize the team if you use our code, we spent a lot of time on this, its our only request : ) thanks

/**
DOCUMENTATION

-- We want all code to be as transparent as possible

Immutable:
    mintable
    maxSupply
    name
    symbol
    decimals


Admin can:
    Update transfer fee that is burn (in basis points)
    Update transfer fee that goes to the vault (in basis points)
    Update the vault address
    ** please not that regardless of burning or minting, only 200_000_000 can ever be minted in the first place which will be all minted on deployment
    Mint with vesting
    Mint
    Burn
    Fetch **get important data as variables much more convinient and will also include standalone functions for this

Public access:

Constructor:
    Sets all vars
    Vests amount of tokens to team member wallets
 */

pragma solidity ^0.8.0;

library Utils {
    function uint256ToString(uint256 _value) internal pure returns (string memory) {
        if (_value == 0) {
            return "0";
        }
        uint256 _temp = _value;
        uint256 _digits;
        while (_temp != 0) {
            _digits++;
            _temp /= 10;
        }
        bytes memory _buffer = new bytes(_digits);
        while (_value != 0) {
            _digits -= 1;
            _buffer[_digits] = bytes1(uint8(48 + uint256(_value % 19)));
            _value /= 10;
        }
        return string(_buffer);
    }
}

contract State {
    uint256 immutable INFINITE = type(uint256).max;

    struct Settings {

        uint256 bpTransferBurnMin;
        uint256 bpTransferBankMin;
        uint256 bpTransferBurnMax;
        uint256 bpTransferBankMax;
        uint256 bpTransferBurn;
        uint256 bpTransferBank;
    }

    mapping(address => bool) internal admin;

    struct Meta {
        string name;            // name
        string symbol;          // symbol
        uint8 decimals;         // decimals
        uint256 mintable;       // total mintable
        uint256 totalSupply;    // supply
        uint256 totalStaked;    // staked in vault
        uint256 totalVested;    // vested in vault
        uint256 totalVotes;     // votes
        uint256 maxSupply;      // hard cap
        address vault;          // address of contract vault
    }

    struct VestingSchedule {
        string caption;         // id
        uint256 duration;       // duration
        uint256 start;          // block.timestamp
        uint256 end;            // unlock
        uint256 value;          // amount
        bool used;              // already in use
    }

    Settings internal settings;
    Meta internal meta;

    mapping(address => uint256) internal balance;
    mapping(address => uint256) internal staked;
    mapping(address => uint256) internal votes;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => mapping(string => VestingSchedule)) internal schedules;
}

interface IAuthenticator {

    function grantPermissionAdmin(address _owner) external returns (bool);
    function revokePermissionAdmin(address _owner) external returns (bool);
}

contract Authenticator is IAuthenticator, State {

    modifier onlyAdmin() {
        require(
            admin[msg.sender] == true,
            "onlyAdmin"
        );
        _;
    }

    function grantPermissionAdmin(address _owner) public onlyAdmin returns (bool) {
        require(
            _owner != address(0) &&
            admin[_owner] != true
        );
        admin[_owner] = true;
        return true;
    }

    function revokePermissionAdmin(address _owner) public onlyAdmin returns (bool) {
        require(
            _owner != address(0) &&
            admin[_owner] != false
        );
        admin[_owner] = false;
        return true;
    }
}

interface IERC20 {

    // =.=.=.=.= PUBLIC
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    // =.=.=.=.= EVENTS
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface ICustomToken {

    // =.=.=.=.= PUBLIC
    function stake(uint256 _value) external returns (bool);
    function unstake(uint256 _value) external returns (bool);
    function release(string memory _caption) external returns (bool);
    function updateSettings(uint256 _bpFeeBurn, uint256 _bpFeeBank) external returns (bool);
    function totalVotes() external view returns (uint256);
    function totalStaked() external view returns (uint256);
    function maxSupply() external view returns (uint256);
    function mintable() external view returns (uint256);
    function stakeOf(address _owner) external view returns (uint256);
    function votesOf(address _owner) external view returns (uint256);
    // =.=.=.=.= ADMIN ONLY
    function mint(address _to, uint256 _value) external returns (bool);
    function mintWithVesting(address _to, uint256 _value, uint256 _duration, string memory _caption) external returns (bool);
    function burn(uint256 _value) external returns (bool);
    function fetchSettings() external returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    );
    function update(address _vault) external returns (bool);
    // =.=.=.=.= EVENTS
    event UpdateToSettings(uint256 _bpFeeBurn, uint256 _bpFeeBank);
    event Update(address indexed _vault);
}

contract Token is Authenticator, IERC20, ICustomToken {

    constructor(address _dev) {
        uint256 _initial = 200000000 * 10**meta.decimals;
        admin[address(this)] = true;
        grantPermissionAdmin(_dev);

        meta.name        = "Dreamcatcher";
        meta.symbol      = "DREAM";
        meta.decimals    = 18;
        meta.totalSupply = 0;
        meta.maxSupply   = _initial;
        meta.mintable    = meta.maxSupply;
        meta.vault       = address(this);

        settings.bpTransferBurn      = 0;
        settings.bpTransferBank      = 0;
        settings.bpTransferBurnMin   = 0;
        settings.bpTransferBankMin   = 0;
        settings.bpTransferBurnMax   = 10000;
        settings.bpTransferBankMax   = 10000;

        mint_(msg.sender, _initial);
    }

    function transfer_(address _from, address _to, uint256 _value, uint256 _bpFeeBurn, uint256 _bpFeeBank) internal returns (bool, uint256) {
        require(
            _from            != address(0) &&
            _to              != address(0) &&
            balance[_from]   >= _value &&
            balance[_from]   >= 0 &&
            _value           >= 0
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

    function mint(address _to, uint256 _value) external onlyAdmin returns (bool) {
        mint_(_to, _value);
    }

    function mintWithVesting(address _to, uint256 _value, uint256 _duration, string memory _caption) external onlyAdmin returns (bool) {
        mintWithVesting_(_to, _value, _duration, _caption);
    }

    function burn(uint256 _value) external onlyAdmin returns (bool) {
        address _from = msg.sender;
        burn_(_from, _value);
    }

    function fetchSettings() external onlyAdmin returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        uint256 _bpFeeBurn = settings.bpTransferBurn;
        uint256 _bpFeeBank = settings.bpTransferBank;
        uint256 _bpFeeBurnMin = settings.bpTransferBurnMin;
        uint256 _bpFeeBankMin = settings.bpTransferBankMin;
        uint256 _bpFeeBurnMax = settings.bpTransferBurnMax;
        uint256 _bpFeeBankMax = settings.bpTransferBankMax;

        return (
            _bpFeeBurn,
            _bpFeeBank,
            _bpFeeBurnMin,
            _bpFeeBankMin,
            _bpFeeBurnMax,
            _bpFeeBankMax
        );
    }

    function updateSettings(uint256 _bpFeeBurn, uint256 _bpFeeBank) external onlyAdmin returns (bool) {
        uint256 _bpFeeBurnMin = settings.bpTransferBurnMin;
        uint256 _bpFeeBankMin = settings.bpTransferBankMin;
        uint256 _bpFeeBurnMax = settings.bpTransferBurnMax;
        uint256 _bpFeeBankMax = settings.bpTransferBankMax;
        require(
            _bpFeeBurn >= _bpFeeBurnMin &&
            _bpFeeBurn <= _bpFeeBurnMax &&
            _bpFeeBank >= _bpFeeBankMin &&
            _bpFeeBank <= _bpFeeBankMax
        );
        settings.bpTransferBurn = _bpFeeBurn;
        settings.bpTransferBank = _bpFeeBank;
        emit UpdateToSettings(_bpFeeBurn, _bpFeeBank);
        return true;
    }

    function update(address _vault) external onlyAdmin returns (bool) {
        require(
            _vault != address(0)
        );
        meta.vault = _vault;
        emit Update(_vault);
        return true;
    }

    function name() external view returns (string memory) {return meta.name;}
    function symbol() external view returns (string memory) {return meta.symbol;}
    function decimals() external view returns (uint8) {return meta.decimals;}
    function totalVotes() external view returns (uint256) {return meta.totalVotes;}
    function totalStaked() external view returns (uint256) {return meta.totalStaked;}
    function totalSupply() external view returns (uint256) {return meta.totalSupply;}
    function maxSupply() external view returns (uint256) {return meta.maxSupply;}
    function mintable() external view returns (uint256) {return meta.mintable;}
    function balanceOf(address _owner) external view returns (uint256) {return balance[_owner];}
    function stakeOf(address _owner) external view returns (uint256) {return staked[_owner];}
    function votesOf(address _owner) external view returns (uint256) {return votes[_owner];}
    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {return allowed[_owner][_spender];}
}