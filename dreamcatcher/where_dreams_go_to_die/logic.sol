// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/Pool/Prototype/pool/state.sol";
import "blockchain/contracts/Polygon/Pool/Prototype/pool/token.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "blockchain/contracts/Polygon/Pool/Prototype/pool/lib.sol";

contract Logic {

    State state;
    Token native_token;

    struct My {

        address state;
        address native_token;
        address creator;
        address manager;

    }

    My my;

    constructor(

        string memory _name,
        string memory _description,
        uint256 _funding_duration,
        uint256 _funding_required,
        bool _whitelisted,
        string memory _token_name,
        string memory _token_symbol,
        uint8 _token_decimals,
        uint256 _initial_supply

    ) payable {

        require( _funding_duration >= 1 weeks, "Logic: _funding_duration < 1 weeks" );
        require( _funding_required >= 0, "Logic: _funding_required < 0" );
        require( msg.value >= 1, "Logic: msg.value < 1" );
        require( _initial_supply >= 1, "Logic: _initial_supply < 1" );

        uint256 _now = block.timestamp;

        state = new State(

            address( this ),
            msg.sender,
            _name,
            _description,
            _now,
            _now + _funding_duration,
            _funding_required,
            _whitelisted

        );

        require( _token_decimals <= 18, "Logic: _token_decimals > 18" );
        require( _token_decimals >= 0, "Logic: _token_decimals < 0" );

        native_token = new Token(

            _token_name,
            _token_symbol,
            _token_decimals

        );

        mint_( _initial_supply );

        my.state = address( state );
        my.native_token = address( native_token );

    }

    function deposit_( uint256 _value ) private {

        address payable _to = payable( address( state ));

        _to.transfer( _value );

    }

    function withdraw_( address _to, uint256 _value ) private {
        // get matic from the state contract
        state.withdraw( _value );

        address payable _recipient = payable( _to );
        // send the matic to the address
        _recipient.transfer( _value );

    }

    function deposit_erc20_( address _contract, uint256 _value ) private {
        // ask for the token from the caller
        address _from = msg.sender;
        address _to = address( state );
        // send the token to the state state address
        IERC20 _token = IERC20( _contract );
        _token.transferFrom( _from,  _to, _value);

    }

    function withdraw_erc20_( address _contract, uint256 _value ) private {

        address _to = msg.sender;
        // grab the token from the state contract
        state.withdraw_erc20( _contract, _value );
        // re route the token transfer to the caller
        IERC20 _token = IERC20( _contract );
        _token.transfer( _to, _value );

    }

    function mint_( uint256 _value ) private {

        address _to = msg.sender;
        // mint and transfer to caller
        native_token.mint( _value );
        native_token.transfer( _to, _value );

    }

    function burn_( uint256 _value ) private {

        address _from = msg.sender;
        address _to = address( this );
        // transfer from caller and burn
        native_token.transferFrom( _from, _to, _value );
        native_token.burn( _value );

    }

    function contribute( uint256 _id ) public payable returns ( bool ) {
        // request funding data from state
        State.Funding memory _funding = state.view_funding( _id );
        /**
        * _v: value
        * _s: supply
        * _b: balance
        * _m: amount to mint
         */
        uint256 _v = msg.value;
        uint256 _s = native_token.totalSupply();
        uint256 _b = address( this ).balance - _v;
        uint256 _m = Lib._how_much_to_mint( _v, _s, _b );

        require( _v > 0, "Logic: _v <= 0" );
        require( _s > 0, "Logic: _s <= 0" );
        require( _b > 0, "Logic: _b <= 0" );
        // funding round is still ongoing
        require( block.timestamp <= _funding.end, "Logic: block.timestamp > _funding.end" );

        State.Persona memory _persona = state.persona_of( msg.sender );

        if ( _funding.whitelisted ) { require( _persona.is_on_whitelist, "Logic: _persona.is_on_whitelist == false" ); }
        // re route matic to state contract
        deposit_( _v );
        // mint & transger token to caller
        mint_( _m );

        return true;

    }

    function withdraw( uint256 _value ) public returns ( bool ) {
        /**
        * _a: amount to burn
        * _s: supply
        * _b: balance
        * _v: value
         */
        uint256 _a = _value;
        uint256 _s = native_token.totalSupply();
        uint256 _b = address( this ).balance;
        uint256 _v = Lib._how_much_to_send( _a, _s, _b );

        address payable _to = payable( msg.sender );
        // transfer & burn
        burn_( _a );
        // send back matic
        withdraw_( _to, _v );

        return true;

    }
    
    function reveal_state() public view returns ( address ) {
        // reveal the address of the state contract
        return my.state;

    }

    function reveal_native_token() public view returns ( address ) {
        // reveal the address of the native token contract
        return my.native_token;

    }

}