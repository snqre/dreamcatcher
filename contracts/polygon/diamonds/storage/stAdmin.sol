// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract stAdmin {
    bytes32 internal constant _ADMIN = keccak256('node.admin');

    struct StAdmin {
        address admin;
    }

    function admin() internal pure virtual returns (StAdmin storage s) {
        bytes32 location = _ADMIN;
        assembly {
            s.slot := location
        }
    }
}