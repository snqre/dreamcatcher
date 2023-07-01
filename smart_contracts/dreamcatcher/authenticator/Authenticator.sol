// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/access/Ownable.sol";

contract Authenticator is Ownable {
    mapping(string => bool) private _isRole;

    constructor() Ownable() {
        _transferOwnership(msg.sender);
    }
}