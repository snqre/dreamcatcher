// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// this also needs replacing
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/finance/VestingWallet.sol";

contract Wallet is VestingWallet {

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

}