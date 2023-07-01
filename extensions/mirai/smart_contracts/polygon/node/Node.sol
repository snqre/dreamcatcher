// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "deps/openzeppelin/access/Ownable.sol";
import "smart_contracts/module_architecture/Key.sol";

contract Node is Key, Ownable {
    constructor(address owner) Key("Node") Ownable() {
        _transferOwnership(owner);
    }
}