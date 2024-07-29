// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title Partial ERC173 interface needed by internal functions
 */
interface IERC173Internal {
    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );
}
