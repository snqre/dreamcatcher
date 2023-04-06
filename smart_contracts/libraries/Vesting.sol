// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Vesting {
    struct VestingSchedule {
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 released;
    }
}
