// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/finance/VestingWallet.sol";

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

    function _vestingSchedule(
        uint totalAllocation, 
        uint timestamp
    ) internal view virtual override returns (uint256) {
        if (timestamp < start()) { return 0; }
        else if (timestamp > end()) { return totalAllocation; }
        else {}
    }

}