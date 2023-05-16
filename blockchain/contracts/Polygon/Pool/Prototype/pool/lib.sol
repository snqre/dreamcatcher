// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library Lib {

    /**
    * _v: value
    * _s: supply
    * _b: balance
     */
    function _how_much_to_mint( uint256 _v, uint256 _s, uint256 _b ) public pure returns ( uint256 ) {

        return (( _v * _s ) / _b );

    }

    function _how_much_to_send( uint256 _v, uint256 _s, uint256 _b ) public pure returns ( uint256 ) {

        return (( _v * _b ) / _s );

    }

    function _convert_to_wei( uint256 _value ) public pure returns ( uint256 ) {

        return ( _value * 10**18 );

    }

    function _convert_to_int( uint256 _value ) public pure returns ( uint256 ) {

        return ( _value / 10**18 );

    }

}