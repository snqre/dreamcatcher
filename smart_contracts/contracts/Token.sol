// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9; // note that in  pragma greater than 0.8.0 overflow and underflow is automatically checked

import "smart_contracts/contracts/Authenticator.sol";

interface IERC20 {
    function name() public view returns (string memory);
    function symbol() public view returns (string memory);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface ICustomToken {
    function maxSupply() public view returns (uint256);
    function stakeOf(address _owner) public view returns (uint256);
    function votesOf(address _owner) public view returns (uint256);
    // ripped straight from @openzeppelin
    function increaseAllowance(address _spender, uint256 _value) public returns (bool);
    function decreaseAllowance(address _spender, uint256 _value) public returns (bool);
    // staking and unstaking functions and features here
    /**
    Staking goes to our bank or vault, it cannot be used by anyone, it just stays there
    When we make earnings or give out rewards, stakers will be able to withdraw directly from the vault
     */
    function stake(uint256 _value) public returns (bool);
    function unstake(uint256 _value) public returns (bool);

    // distribution mechanin
    function distribute() public returns (bool);
}

// inherit from authenticator contract
contract TokenState is Authenticator {

    struct VotingMechanic {
        uint256 voteWeightPerToken; // how much voting power you can get per token
    }

    struct State {
        // conditions are difficult to change but can be chanegd in case of emergency or strong requirmeent require large quorum to do so
        bool isPaused;
        bool isTransferable;
        bool isMintable;
        bool isBurnable;
        bool isTempHalt; // temp halt with limited duration, does not pause the eco fully but only when required
        uint256 durationTempHalt;
        bool isMonetized; // temp halt or fully disable monetizeation within the contract
        uint256 durationTempMonetizationHalt;
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
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 totalStaked;
        uint256 totalVotes;
        uint256 maxSupply;
        address bank;
        address vault;
    }

    Settings internal settings;
    Meta internal meta;

    struct VestingSchedule {
        string id;
        string releaseType;
        uint256 duration;
        uint256 start;
        uint256 end;
        uint256 value;
    }

    mapping(address => mapping(string => VestingSchedule)) internal schedules;

    mapping(address => uint256) internal balance;
    mapping(address => uint256) internal staked; // amount of their tokens staked cannot be both in balance and staked must be only one
    mapping(address => uint256) internal votes; // amount of voting weight this account has typically only given when staked
    mapping(address => mapping(address => uint256)) internal allowed;
}


contract Token is TokenState {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    

    constructor() {
        meta.name = "Dreamcatcher";
        meta.symbol = "DREAM";
        meta.decimals = 18;
        meta.totalSupply = 0; // once the supply it minted this will update (i want to specifically use mint for transperency)
        meta.maxSupply = 200000000 * 10**meta.decimals; // 200_000_000.000000000000000000 *much divisible ... much wow
        meta.bank = sender();
        meta.vault = sender();
        settings.bpTransferBurn = 0;  // start 0 but after exposure period 0.15% | 15
        settings.bpTransferBank = 0;  // start 0 but after exposure period 0.10% transferred to vault
        settings.VotingMechanic.voteWeightPerToken = 1; // x vote per token


    }

    function mint_(address _to, uint256 _value) private {
        require(_to != address(0) && meta.totalSupply + _value <= meta.maxSupply);
        (meta.totalSupply, balance[_to]) += _value;
        emit Transfer(address(0), _to, _value);
    }

    function mintWithVesting_(address _for, uint256 _value, uint256 _duration, string _id, string _releaseType) private {

        require(
            schedules[_for][_id] == 0 &&
            meta.totalSupply + _value <= meta.maxSupply
        );

        if (_releaseType == "-cliff") {
            mint_(meta.vault, _value);

            schedules[_to][_id] = new VestingSchedule({
            id: _id,
            releaseType: _releaseType,
            duration: _duration,
            start: _start,
            end: _start + _duration,
            value: _value,
            released: 0
            });
        }
    }

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

    function transfer(address _to, uint256 _value) public returns (bool) {
        (bool _success, uint256 _newValue) = transfer_(sender(), _to, _value, settings.bpTransferBurn, settings.bpTransferBank);
        return _success;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(
            allowance(_from, sender()) != type(uint256).max &&
            allowance(_from, sender()) >= _value
        );

        allowed[_from][sender()] = _value;
        emit Approval(_from, sender(), _value);

        (bool _success, uint256 _newValue) = transfer_(_from, _to, _value, settings.bpTransferBurn, settings.bpTransferBank);
        return _success;
    }

    function stake(uint256 _value) public returns (bool) {
        (bool _success, uint256 _newValue) = transfer_(sender(), meta.vault, _value, settings.bpTransferBurn, settings.bpTransferBank);
        (staked[sender()], votes[sender()], meta.totalStaked, meta.totalVotes) += _newValue;
        return _success;
    }

    function unstake(uint256 _value) public returns (bool) {
        require(staked[sender()] >= _value);
        (bool _success, uint256 _newValue) = transfer_(meta.vault, sender(), _value, settings.bpTransferBurn, settings.bpTransferBank);
        (staked[sender()], votes[sender()], meta.totalStaked, meta.totalVotes) -= _value;
        return _success;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {return allowed[_owner][_spender];}
    function increaseAllowance(address _spender, uint256 _value) public returns (bool) {
        require((sender() != address(0)) && (_spender != address(0)), "zero address");
        allowed[sender()][_spender] = allowance(sender(), _spender) + _value;
        emit Approval(sender(), _spender, allowance(sender(), _spender) + _value);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _value) public returns (bool) {
        require((allowance(sender(), _spender) >= _value) && (sender() != address(0)) && (_spender != address(0)), "zero address || decreased allowance below zero");
        allowed[sender()][_spender] = allowance(sender(), _spender) - _value;
        emit Approval(sender(), _spender, allowance(sender(), _spender) - _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require((sender() != address(0)) && (_spender != address(0)), "zero address");
        allowed[sender()][_spender] = _value;
        emit Approval(sender(), _spender, _value);
        return true;
    }

    // mint then lock in vault or validator
    

    function release(string _id) public returns (bool) {
        string memory _releaseType = schedules[_to][_id].releaseType;

        if (_releaseType == "-cliff") {
            require(schedules[sender()][_id].end >= block.timestamp && schedules[_to][_id].value > 0);
            transferFromVault(sender(), _value);
            schedules[sender()][_id].value = 0;
        } else if (_releaseType == "-linear") {
            // release amount that has been assigned
        } else if (_releaseType == "-log") {
            //
        }

    }

    function burn(address _from, uint256 _value) internal {
        require(_from != address(0) && balance[_from] >= _value);
        balance[_from] -= _value;
        meta.totalSupply -= _value;
        emit Transfer(_from, address(0), _value);
    }


    // convert or swap amount of tokens to DREAM and distribute the amount we have in the vault or bank to the people staking
    // hence staking means you get votes but you also get earnings
    // we will do a check to see how long they've been staking for
    // this will also be important for the voting mechanisms
    function distribute() internal {
        
    }


    // ======  A MASSIVE LIST OF FUNCTIONS THAT ALTER THE STATE OF THE CONTRACT
    // please note that these need to be locked behind the proposal and governance mechanisms

    // please note that bp is in basis points 1 / 1000
    function setBpTransferBurn(uint256 _newValue) private returns (bool) {
        settings.bpTransferBurn = _newValue;
    }

    // again please note that in bp
    function setBpTransferBank(uint256 _newValue) private returns (bool) {
        settings.bpTransferBank = _newValue;
    }

    function setStateIsPaused(bool _is) public onlyAdmin onlyDev onlyOperator returns (bool) {
        // check boolean value
        settings.state.isPaused = _is;
        return true;
    }

    function setStateIsTransferable(bool _is) public onlyAdmin onlyDev returns (bool) {
        settings.state.isTransferable = _is;
        return true;
    }

    function setStateIsMintable(bool _is) public onlyAdmin onlyDev onlyOperator returns (bool) {
        settings.state.isMintable = _is;
        return true;
    }

    function name() public view returns (string memory) {return meta.name;}
    function symbol() public view returns (string memory) {return meta.symbol;}
    function decimals() public view returns (uint8) {return meta.decimals;}
    function totalSupply() public view returns (uint256) {return meta.totalSupply;}
    function maxSupply() public view returns (uint256) {return meta.maxSupply;}

    function balanceOf(address _owner) public view returns (uint256) {return balance[_owner];}
    function stakeOf(address _owner) public view returns (uint256) {return staked[_owner];}
    function votesOf(address _owner) public view returns (uint256) {return votes[_owner];}
}