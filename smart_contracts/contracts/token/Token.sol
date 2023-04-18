// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Authenticator {
    mapping(address => bool) internal isAdmin;
    mapping(address => bool) internal isDev;    // we will maintain some control of the contract for period after deployment to improve and fine tuine it
}

contract TokenLib {
    function sender() internal view returns (address) {return msg.sender;}
}

contract TokenState is TokenLib {
    struct VotingMechanic {
        uint256 voteWeightPerToken; // how much voting power you can get per token
    }

    struct Settings {
        uint256 bpTransferBurn; // basis point transfer 1 / 1000 **100 == 1%
        uint256 bpTransferBank; // for vault can be used for liquidity or etc
        VotingMechanic VotingMechanic;
    }

    struct Meta {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 maxSupply;
        address bank;
    }

    Settings internal settings;
    Meta internal meta;

    mapping(address => uint256) internal balance;
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
        meta.maxSupply = 200000000 * 10**meta.decimals;
        meta.bank = sender();
        // mint all the tokens to
        mint(sender(), meta.maxSupply);
        settings.bpTransferBurn = 0;  // start 0 but after exposure period 0.15%
        settings.bpTransferBank = 0;  // start 0 but after exposure period 0.10% transferred to vault
        settings.VotingMechanic.voteWeightPerToken = 1; // x vote per token
    }

    function name() public view returns (string memory) {return meta.name;}
    function symbol() public view returns (string memory) {return meta.symbol;}
    function decimals() public view returns (uint8) {return meta.decimals;}
    function totalSupply() public view returns (uint256) {return meta.totalSupply;}
    function maxSupply() public view returns (uint256) {return meta.maxSupply;}

    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "zero address");
        return balance[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool sucess) {
        require((sender() != address(0)) && (_to != address(0)) && balance[sender()] >= _value && (balance[sender()] >= 0), "zero address || insufficient balance");
        balance[sender()] -= _value;
        if (settings.bpTransferBurn != 0 && settings.bpTransferBank != 0) {
            uint256 feeBurn = (_value / 1000) * settings.bpTransferBurn;
            uint256 feeBank = (_value / 1000) * settings.bpTransferBank;
            balance[_to] += _value - (feeBurn + feeBank);
            balance[meta.bank] += feeBank;
            meta.totalSupply -= feeBurn;
            emit Transfer(sender(), _to, _value - (feeBurn + feeBank));
            // send to burn address
            emit Transfer(sender(), address(0), feeBurn);
            // transfer to contract bank message
            emit Transfer(sender(), meta.bank, feeBank);
        // transfer burn is not zero but transfer to bank is
        } else if (settings.bpTransferBurn != 0 && settings.bpTransferBank == 0) {
            uint256 feeBurn = (_value / 1000) * settings.bpTransferBurn;
            balance[_to] += _value - feeBurn;
            meta.totalSupply -= feeBurn;
            emit Transfer(sender(), _to, _value - feeBurn);
            // send to burn address
            emit Transfer(sender(), address(0), feeBurn);
        } else if (settings.bpTransferBurn == 0 && settings.bpTransferBank != 0) {
            uint256 feeBank = (_value / 1000) * settings.bpTransferBank;
            balance[_to] += _value - feeBank;
            balance[meta.bank] += feeBank;
            emit Transfer(sender(), _to, _value - feeBank);
            // transfer to contract bank message
            emit Transfer(sender(), meta.bank, feeBank);
        } else { // normal transaction if both are zero -- saves on gas fee if we arent using them
            balance[_to] += _value;
            emit Transfer(sender(), _to, _value);
        }
        return true;
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

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(allowance(_from, sender()) != type(uint256).max);
        require(allowance(_from, sender()) >= _value);
        require(_from != address(0), "zero address");
        require(sender() != address(0), "zero address");
        require(_to != address(0), "zero address");
        require(balance[_from] >= _value, "insufficient balance");
        require((balance[_from] >= 0));
        allowed[_from][sender()] = _value;
        emit Approval(_from, sender(), _value);
        balance[_from] -= _value;
        if (settings.bpTransferBurn != 0 && settings.bpTransferBank != 0) {
            uint256 feeBurn = (_value / 1000) * settings.bpTransferBurn;
            uint256 feeBank = (_value / 1000) * settings.bpTransferBank;
            balance[_to] += _value - (feeBurn + feeBank);
            balance[meta.bank] += feeBank;
            meta.totalSupply -= feeBurn;
            emit Transfer(sender(), _to, _value - (feeBurn + feeBank));
            // send to burn address
            emit Transfer(sender(), address(0), feeBurn);
            // transfer to contract bank message
            emit Transfer(sender(), meta.bank, feeBank);
        // transfer burn is not zero but transfer to bank is
        } else if (settings.bpTransferBurn != 0 && settings.bpTransferBank == 0) {
            uint256 feeBurn = (_value / 1000) * settings.bpTransferBurn;
            balance[_to] += _value - feeBurn;
            meta.totalSupply -= feeBurn;
            emit Transfer(sender(), _to, _value - feeBurn);
            // send to burn address
            emit Transfer(sender(), address(0), feeBurn);
        } else if (settings.bpTransferBurn == 0 && settings.bpTransferBank != 0) {
            uint256 feeBank = (_value / 1000) * settings.bpTransferBank;
            balance[_to] += _value - feeBank;
            balance[meta.bank] += feeBank;
            emit Transfer(sender(), _to, _value - feeBank);
            // transfer to contract bank message
            emit Transfer(sender(), meta.bank, feeBank);
        } else { // normal transaction if both are zero -- saves on gas fee if we arent using them
            balance[_to] += _value;
            emit Transfer(sender(), _to, _value);
        }
        return true;
    }

    function mint(address _to, uint256 _value) internal {
        require(_to != address(0), "zero address");
        require(meta.totalSupply + _value <= meta.maxSupply);
        meta.totalSupply += _value;
        balance[_to] += _value;
        emit Transfer(address(0), _to, _value);
    }

    function burn(address _from, uint256 _value) internal {
        require((_from != address(0)) && (balance[_from] >= _value), "zero address");
        balance[_from] -= _value;
        meta.totalSupply -= _value;
        emit Transfer(_from, address(0), _value);
    }
}