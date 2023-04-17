// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
* @title Authenticator
* @todo 
*
*
*
*
*
 */

contract Token {
    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    uint256 public immutable maxSupply;
    mapping(address => uint256) private balances;
    // spender => (owner => no of tokens allowed)
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed _from, address indexed _to, uint258 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor() {
        name = "Dreamcatcher";
        symbol = "DREAM";
        decimals = 18;
        totalSupply = 0;
        maxSupply = 200000000 * 10**18;
        // mint()
    }

    function name() public view returns (string memory) {return name;}
    function symbol() public view returns (string memory) {return symbol;}
    function decimals() public view returns (uint8) {return decimals;}
    function totalSupply() public view returns (uint256) {return totalSupply;}
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "!za")
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require((balances[msg.sender] >= _value) && (balances[msg.sender] >= 0));
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}