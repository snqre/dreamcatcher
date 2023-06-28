// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "deps/openzeppelin/finance/VestingWallet.sol";

contract LinearVestedWallet is VestingWallet {
    constructor(
        address beneficiaryAddress,
        uint64 startTimestamp,
        uint64 durationSeconds
    ) VestingWallet(
        beneficiaryAddress,
        startTimestamp,
        durationSeconds
    ) payable {}
}