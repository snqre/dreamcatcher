// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

/**
* The idea is to consolidate various project's base utility into once contract which means new project wont require spending on contract deployment
* Cheaper
* And expandable if required
 */

interface IState {

    event PoolFounded(

        address indexed _admin,
        address indexed _manager,
        string _name,
        string _description,
        uint256 _inception,
        uint256 _funding_start,
        uint256 _funding_end,
        uint256 _funding_required,
        bool _whitelisted

    );

    event Deposit( address _from, uint256 _value );

    event Withdraw( address _to, uint256 _value );

    event DepositERC20( address _contract, address _from, uint256 _value );

    event WithdrawERC20( address _contract, address _to, uint256 _value );


}

contract State is IState {

    struct Lock {

        bool is_unlocked;

    }

    Lock lock;

    string private name;
    string private description;
    uint256 private inception;

    struct Pool {

        string name;
        address creator;
        address[] managers;
        uint256 inception;
        uint256 class;

    }

    mapping( address => Pool ) private pools;
    
    struct Persona {

        bool is_admin;
        bool is_creator;
        bool is_manager;
        bool is_on_whitelist;

    }

    mapping( address => Persona ) private persona;

    struct FundingSchedule {

        uint256 start;
        uint256 end;
        uint256 required;
        bool whitelisted;
        bool success;

    }
    
    mapping( uint256  => FundingSchedule ) private funding;

    constructor(

        address _admin,
        address _manager,
        string memory _name,
        string memory _description,
        uint256 _funding_start,
        uint256 _funding_end,
        uint256 _funding_required,
        bool _whitelisted

    ) {

        lock.is_unlocked = true;

        uint256 _funding_duration = _funding_end - _funding_start;
        uint256 _funding_min_duration = 1 weeks;
        uint256 _funding_max_duration = 9 weeks;

        require( _funding_duration >= _funding_min_duration, "State: _funding_duration < _funding_min_duration" );
        require( _funding_duration <= _funding_max_duration, "State: _funding_duration < _funding_max_duration" );
        require( _funding_required >= 0, "State: _funding_required < 0" );

        funding[ 0 ] = Funding({

            start: _funding_start,
            end: _funding_end,
            required: _funding_required,
            whitelisted: _whitelisted,
            success: false

        });

        if ( _funding_required == 0 ) { funding[ 0 ].success = true; }

        require( _admin != address( 0 ), "_admin == address( 0 )" );
        require( _manager != address( 0 ), "_manager == address( 0 )" );

        name = _name;
        description = _description;
        inception = block.timestamp;

        emit PoolFounded(

            _admin,
            _manager,
            _name,
            _description,
            inception,
            _funding_start,
            _funding_end,
            _funding_required,
            _whitelisted

        );

    }

    receive() external payable {

        Persona memory _caller = persona_of( msg.sender );

        require( _caller.is_admin );

        address _from = msg.sender;
        uint256 _value = msg.value;

        emit Deposit( _from, _value );

    }

    function send( address _to, uint256 _value ) public  {
        // checks
        Persona memory _caller = persona_of( msg.sender );
        require( _caller.is_admin, "State: _caller.is_admin == false" );

        address payable _recipient = payable( _to );

        // getting infinite gas when i use transfer


        emit Withdraw( _recipient, _value );

    }
    
    function withdraw( address _to, uint256 _value ) public {

        Persona memory _caller = persona_of( msg.sender );

        require( _caller.is_admin, "State: _person.is_admin == false" );
        require( lock.is_unlocked, "State: lock.is_unlocked == false" );
        
        lock.is_unlocked = false;

        address payable _recipient = payable( _to );

        _recipient.transfer( _value );

        emit Withdraw( _recipient, _value );

        lock.is_unlocked = true;

    }

    function withdraw_erc20( address _contract, address _to, uint256 _value ) public {

        Persona memory _caller = persona_of( msg.sender );
        
        require( _caller.is_admin );
        require( lock.is_unlocked, "State: lock.is_unlocked == false" );

        lock.is_unlocked = false;

        address payable _recipient = payable( _to );

        IERC20 _token = IERC20( _contract );
        _token.transfer( _recipient, _value );

        lock.is_unlocked = true;

    }

    function persona_of( address _address ) public view returns ( Persona memory ) {

        return ( persona[ _address ] );

    }

    function set_persona_of( address _address, Persona memory _new ) public returns ( bool ) {

        Persona memory _caller = persona_of( msg.sender );

        require( _caller.is_admin );

        persona[ _address ] = _new;

        return true;

    }

    function view_funding( uint256 _id ) public view returns ( Funding memory ) {

        return ( funding[ _id ] );

    }

    function set_funding( uint256 _id, Funding memory _new ) public returns ( bool ) {

        Persona memory _caller = persona_of( msg.sender );

        require( _caller.is_admin );
        require( funding[ _id ].start >= block.timestamp, "State: funding[ _id ].start < block.timestamp" );

        funding[ _id ] = _new;

        return true;

    }

}