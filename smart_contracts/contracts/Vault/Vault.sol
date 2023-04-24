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

    struct Meta {
        address vault;
    }

    Meta internal meta;
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
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
}

contract Vault is Authenticator {
    /**
    Pre Seed Funding    $0.035
    Seed Funding        $0.05
    Series A            $0.25
    Series B            $0.50
    ICO                 $1.00
     */
    constructor(address _dev) {
        admin[msg.sender] = true;
        meta.vault = _dev;
        grantPermissionAdmin(_dev);
    }

    function IBalanceOf(address _tokenContract) external returns (uint256) {
        IERC20 _token = IERC20(_tokenContract);
        address _owner = meta.vault;
        uint256 _value = _token.balanceOf(_owner);
        return _value;
    }

    function ITransferFromVault(address _tokenContract, address _to, uint256 _value) payable external onlyAdmin returns (bool) {
        IERC20 _token = IERC20(_tokenContract);
        address _from = meta.vault;
        require(
            _to != address(0) &&
            _token.balanceOf(_from) >= _value
        );
        bool _success = _token.transfer(_to, _value);
        return _success;
    }
}