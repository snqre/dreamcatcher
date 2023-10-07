// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

using EnumerableSet for EnumerableSet.AddressSet;

struct ProposalUpgradeToV1Args {
    string caption;
    string message;
    address creator;
    uint64 mSigDuration;
    uint64 pSigDuration;
    uint64 timelockDuration;
    address[] signers;
    uint256 mSigRequiredQuorum;
    uint256 pSigRequiredQuorum;
    uint256 threshold;
    address proxyAddress;
    address proposedImplementation;
}

struct ProposalCallV1Args {
    string caption;
    string message;
    address creator;
    uint64 mSigDuration;
    uint64 pSigDuration;
    uint64 timelockDuration;
    address[] signers;
    uint256 mSigRequiredQuorum;
    uint256 pSigRequiredQuorum;
    uint256 threshold;
    address target;
    string signature;
    bytes args;
}