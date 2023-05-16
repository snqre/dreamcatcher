// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/Pool/Prototype/pool/safety.sol";
import "blockchain/contracts/Polygon/Pool/Prototype/pool/authenticator.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

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

contract State is IState, Safety, Authenticator {

    string private name;
    string private description;
    uint256 private inception;
    
    struct Persona {

        bool is_on_whitelist;

    }

    mapping( address => Persona ) private persona;

    struct Funding {

        uint256 start;
        uint256 end;
        uint256 required;
        bool whitelisted;
        bool success;

    }
    
    mapping( uint256 => Funding ) private funding;

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

        uint256 _funding_duration = _funding_end - _funding_start;
        uint256 _funding_min_duration = 1 weeks;
        uint256 _funding_max_duration = 9 weeks;

        require( _funding_required >= _funding_min_duration );
        require( _funding_duration >= _funding_max_duration );

        funding[ 0 ] = Funding({

            start: _funding_start,
            end: _funding_end,
            required: _funding_required,
            whitelisted: _whitelisted,
            success: false

        });

        if ( _funding_required == 0 ) { funding[ 0 ].success = true; }

        require( _admin != address( 0 ));
        require( _manager != address( 0 ));

        admin = _admin;
        manager = _manager;
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

    receive() external payable only_admin {

        address _from = msg.sender;
        uint256 _value = msg.value;

        emit Deposit( _from, _value );

    }

    function withdraw( uint256 _value ) public only_admin {

        address payable _to = payable( admin );

        _to.transfer( _value );

        emit Withdraw( _to, _value );

    }

    function withdraw_erc20( address _contract, uint256 _value ) public only_admin {

        address payable _to = payable( admin );

        IERC20 _token = IERC20( _contract );
        _token.transfer( _to, _value );

    }

    function persona_of( address _address ) public view returns ( Persona memory ) {

        return ( persona[ _address ] );

    }

    function set_persona_of( address _address, Persona memory _new ) public only_admin returns ( bool ) {

        persona[ _address ] = _new;

        return true;

    }

    function view_funding( uint256 _id ) public view returns ( Funding memory ) {

        return ( funding[ _id ] );

    }

    function set_funding( uint256 _id, Funding memory _new ) public only_admin returns ( bool ) {

        require( funding[ _id ].start >= block.timestamp );

        funding[ _id ] = _new;

        return true;

    }

}