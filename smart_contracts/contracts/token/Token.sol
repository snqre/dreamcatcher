// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract TokenLib {
    function sender() internal returns (address) {return msg.sender;}
}

contract TokenState is TokenLib {
    struct Meta {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 maxSupply;
    }

    Meta internal meta;

    mapping(address => uint256) internal balance;
    mapping(address => mapping(address => uint256)) internal allowed;
}

contract Token is TokenState {

    event Transfer(address indexed _from, address indexed _to, uint258 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor() {
        meta.name = "Dreamcatcher";
        meta.symbol = "DREAM";
        meta.decimals = 18;
        meta.totalSupply = 0; // once the supply it minted this will update (i want to specifically use mint for transperency)
        meta.maxSupply = 200000000 * 10**meta.decimals;
        // mint all the tokens to
        mint(sender(), meta.maxSupply);
    }

    function name() public view returns (string memory) {return meta.name;}
    function symbol() public view returns (string memory) {return meta.symbol;}
    function decimals() public view returns (uint8) {return meta.decimals;}
    function totalSupply() public view returns (uint256) {return meta.totalSupply;}
    function maxSupply() public view returns (uint256) {return meta.maxSupply;}

    function balanceOf(address _owner) public view returns (uint256 balance) {
        require(_owner != address(0), "zero address");
        return balance[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool sucess) {
        require((sender() != address(0)) && (_to != address(0)) && balance[sender()] >= _value && (balance[sender()] >= 0), "zero address || insufficient balance");
        balance[sender()] -= _value;
        balance[_to] += _value;
        emit Transfer(sender(), _to, _value);
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

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require((allowance(_from, sender()) != type(uint256).max) && (allowance(_from, sender() >= _value)) && (_from != address(0)) && (sender() != address(0)) && (_to != address(0)) && (balance[_from] >= _value) && (balance[_from] >= 0), "insufficient allowance || allowance(_owner, _spender) != type(uint256).max || zero address || insufficient balance");
        allowed[_from][sender()] = _value;
        emit Approval(_from, sender(), _value);
        balance[_from] -= _value;
        balance[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value) internal {
        require(_to != address(0), "zero address");
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