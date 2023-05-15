// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library Lib {
    /**
    * where _v is value
    * where _s is supply
    * where _b is balance
     */

    function _how_much_to_mint(
        uint256 _v,
        uint256 _s,
        uint256 _b

    ) public pure {
        return ((_v *_s) /_b);
    }

    function _how_much_to_send(
        uint256 _v,
        uint256 _s,
        uint256 _b
    ) public pure {
        return ((_v *_b) /_s);
    }

    function _convert_to_wei(uint256 _v) public pure {
        return (_v *10 **18);
    }

    function _convert_to_int(uint256 _v) public pure {
        uint256 _d =10 **18;
        return (_v /_d);
    }
}