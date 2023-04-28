// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
) storage of accounting will have to be by address and contract first not taking the symbol for id
) new tier system implemented
 */

contract State {
    /** map */
    mapping(string=>address) internal map;
    /** accounting */
    uint256 value;
    /** authenticator 0, 1, 2, 3*/
    mapping(address=>uint256) internal tier;
}

contract Authenticator is State {

    modifier tierI() {
        require(
            tier[msg.sender] >= 1
        );
        _;
    }

    modifier tierII() {
        require(
            tier[msg.sender] >= 2
        );
        _;
    }

    modifier tierIII() {
        require(
            tier[msg.sender] >= 3
        );
        _;
    }
    
    function permission_upgrade(address _owner) public tier_3 returns (bool) {
        require(
            tier[_owner] < 3 &&
            tier[_owner] >= 0
        );
        tier[_owner] += 1;
        return true;
    }

    function permission_downgrade(address _owner) public tier_3 returns (bool) {
        require(
            tier[_owner] < 3 &&
            tier[_owner] >= 0
        );
        tier[_owner] -= 1;
        return true;
    }

    function update_map(string _name, address _location) public tier_3 returns (bool) {
        map[_name] = _location;
        return true;
    }

    function fetch_map(string _name) public tier_1 returns (address) {
        return map[_name];
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
    function decimals() external view returns (uint8);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Vault is Authenticator {

    function deposit(
        address _contract, 
        uint256 _value
    ) payable external returns (bool) {
        address _from = msg.sender;
        address _to = address(this);
        IERC20 _token = IERC20(_contract);
        _token.transferFrom(_from, _to, _value * 10**_token.decimals());
        return true;
    }

    function withdraw(
        address _contract, 
        address _to, 
        uint256 _value
    ) payable external tierII returns (bool) {
        address _from = address(this);
        IERC20(_contract).transfer(_to, _value);
    }

}