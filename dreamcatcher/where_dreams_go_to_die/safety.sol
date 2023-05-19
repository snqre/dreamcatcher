// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Safety {

    bool is_locked;

    modifier one_at_a_time() {

        require( is_locked == false );

        is_locked = true;

        _;

       is_locked = false;

    }

}