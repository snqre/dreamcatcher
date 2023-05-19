// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Authenticator {

    address internal admin;
    address internal manager;
    address internal governor;

    modifier only_admin() {

        require( msg.sender == admin );

        _;

    }

    modifier only_manager() {

        require( msg.sender == manager );

        _;

    }

    modifier only_governor() {

        require( msg.sender == governor );

        _;

    }

}