// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/finance/VestingWallet.sol";

contract BurnDrivenVestedWallet is VestingWallet {

    struct Settings {
        address beneficiary;
        uint64 startTimestamp;
    }

    constructor(
        address beneficiaryAddress,
        uint64 startTimestamp,
        uint64 durationSeconds
    ) VestingWallet(
        beneficiaryAddress,
        startTimestamp,
        durationSeconds
    ) payable {}

    function _vestingSchedule(uint totalAllocation, uint timestamp) internal view virtual override returns (uint) {
        
    }

}