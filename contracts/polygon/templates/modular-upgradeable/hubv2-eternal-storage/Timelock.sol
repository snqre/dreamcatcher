// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/__Encoder.sol";
import "contracts/polygon/templates/modular-upgradeable/hubv2-eternal-storage/__Timelock.sol";
import "contracts/polygon/templates/modular-upgradeable/hubv2-eternal-storage/Role.sol";

contract Timelock is Role {
    constructor(address storage__)
        Role(storage__) {
        
    }
}