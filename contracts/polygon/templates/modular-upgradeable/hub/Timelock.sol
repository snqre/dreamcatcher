// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/governance/TimelockController.sol";

contract Timelock is TimelockController {
    constructor(uint minDelay, address[] memory proposers, address[] memory executors, address admin) 
        TimelockController(minDelay, proposers, executors, admin) {
        
    }
}