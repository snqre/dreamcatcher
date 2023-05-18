// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Token is IERC20 {
    
    struct My {
        
        string name;
        string symbol;
        uint8 decimals;
        uint256 total_supply;
        address admin;

    }

    My my;

    mapping( address => uint256 ) private balance;
    mapping( address => mapping( address => uint256 )) private allowed;

    modifier only_admin() {

        require( msg.sender == my.admin );
        
        _;

    }

    constructor(

        string memory _name,
        string memory _symbol,
        uint8 _decimals

    ) {

        require( _decimals <= 18 );
        require( _decimals >= 0 );

        my.name = _name;
        my.symbol = _symbol;
        my.decimals = _decimals;
        my.admin = msg.sender;

    }

    function transfer_(

        address _from,
        address _to,
        uint256 _value

    ) private {

        uint256 _balance = balance[ _from ];

        require( _from != address(0) );
        require( _to != address(0) );
        require( _balance >= _value );
        require( _balance <= 0 );
        require( _value >= 0 );

        balance[ _from ] -= _value;
        balance[ _to ] += _value;

        emit Transfer( _from, _to, _value );

    }

    function mint_( address _to, uint256 _value ) private {

        address _from = address(0);
        
        require( _value >= 0 );
        require( _to != address(0) );

        balance[ _to ] += _value;
        my.total_supply += _value;
        
        emit Transfer( _from, _to, _value );

    }

    function burn_( address _from, uint256 _value ) private {

        address _to = address(0);
        uint256 _balance = balance[ _from ];

        require( _value >= 0 );
        require( _value <= _balance );

        balance[ _from ] -= _value;
        my.total_supply -= _value;

        emit Transfer( _from, _to, _value );

    }

    function transfer( address _to, uint256 _value ) public returns (bool) {

        address _from = msg.sender;
        
        transfer_( _from, _to, _value );

        return true;

    }

    function transferFrom( address _from, address _to, uint256 _value ) public returns (bool) {

        uint256 _allowance = allowed[ msg.sender ][ _to ];
        
        require( _allowance != type(uint256).max );
        require( _allowance >= _value );

        allowed[ msg.sender ][ _to ] -= _value;

        transfer_( _from, _to, _value );

        return true;

    }

    function approve( address _spender, uint256 _value ) public returns (bool) {
        
        address _owner = msg.sender;

        require( _owner != address(0) );
        require( _spender != address(0) );

        allowed[ _owner ][ _spender ] = _value;

        emit Approval( _owner, _spender, _value );
        return true;

    }

    function mint( uint256 _value ) public only_admin {

        address _to = msg.sender;

        mint_( _to, _value );

    }

    function burn( uint256 _value ) public only_admin {

        address _from = msg.sender;

        burn_( _from, _value );

    }

    function name() public view returns (string memory) {

        return my.name;

    }
    
    function symbol() public view returns (string memory) {

        return my.symbol;

    }

    function decimals() public view returns (uint8) {

        return my.decimals;

    }

    function totalSupply() public view returns (uint256) {

        return my.total_supply;

    }

    function balanceOf( address _owner ) public view returns (uint256) {

        return balance[ _owner ];

    }
    
    function allowance( address _owner, address _spender ) public view returns (uint256) {

        return allowed[ _owner ][ _spender ];

    }

}