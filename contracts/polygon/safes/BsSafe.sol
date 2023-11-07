// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import 'contracts/polygon/proxy/Base.sol';

contract BsSafe is Base {
    address[] public available;
    bytes32 public constant depositor = keccak256('depositor');
    bytes32 public constant withdrawer = keccak256('withdrawer');
}