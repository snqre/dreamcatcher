// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;
import "deps/openzeppelin/finance/VestingWallet.sol";

/// has a base rate but speeds up the more tokens are burnt.
contract BurnDrivenVestedWallet is VestingWallet {
    uint tokenInitialSupply;
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