// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library FinMath {
    function bp(uint256 _value, uint256 _outOf) internal returns (uint256) {
        uint256 _bp = (_value / _outOf) * 10000;
        return _bp;
    }

    // % (bp) of
    function bpOfValue(uint256 _bp, uint256 _value) internal returns (uint256) {
        return (_value / 10000) * _bp;
    }
}

contract State {
    // <symbol> : <basis point>
    mapping(string => uint256) internal allocation;

    mapping (address => bool) internal admin;

    uint256 remainingPreSeed;
}

interface IAuthenticator {
    
    function grantPermissionAdmin(address _owner) external returns (bool);
    function revokePermissionAdmin(address _owner) external returns (bool);
}

contract Authenticator is IAuthenticator, State {

        modifier onlyAdmin() {
        address _sender = msg.sender;
        require(
            admin[_sender] != false,
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

contract Conduit is Authenticator {
    // this in theory should access any tokens from any address
    function deposit(address _contract, uint256 _value) public returns (bool) {
        IERC20 _token = IERC20(_contract);
        address _from = msg.sender;
        address _to = address(this);
        require(
            _value <= _token.balanceOf(_from) &&
            _to != address(0) &&
            _from != address(0)
        );
        _token.transferFrom(_from, _to, _value * 10**_token.decimals());
        return true;
    }

    // this should allow withdrawal
    function withdraw(address _contract, uint256 _value) external onlyAdmin returns (bool) {
        IERC20 _token = IERC20(_contract);
        address _from = address(this);
        address _to = msg.sender;
        require(
            _value <= _token.balanceOf(_from) &&
            _to != address(0) &&
            _from != address(0)
        );
        IERC20(_contract).transfer(_to, _value * 10**_token.decimals());
        return true;
    }

    function send(address _to, uint256 _value) public onlyAdmin {
        _to.transfer(_value);
    }

    // full-back function
    function() payable external returns (bool) {

    }
}

contract Vault is Conduit {
    /**
    Pre Seed Funding    $0.035
    Seed Funding        $0.050
    Series A            $0.250
    Series B            $0.500
    ICO                 $1.000
     */
    constructor(address _dev) {
        admin[msg.sender] = true;
        admin[_dev] = true;
    }
    

    function preSeedFundingSwap(uint256 _value) payable external returns (bool) {
        // 10,000,000 remaining
        // POLYGON IN > DREAM OUT price above
        address _from = msg.sender;
        address _to = address(this);
        // recieve MATIC

        // swap math
        
        // send tokens
        remainingPreSeed -= _value;

        return true;
    }

    function seedFundingSwap(uint256 _value) payable external returns (bool) {
        
    }
    
    function fetch() external onlyAdmin returns (bool, bool) {
        return (
            true,
            true
        );
    }
}