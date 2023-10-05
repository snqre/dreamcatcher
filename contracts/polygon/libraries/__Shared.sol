// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

using EnumerableSet for EnumerableSet.AddressSet;

enum MultiSigProposalPhaseV1 {
    PRIVATE,
    PUBLIC,
    TIMELOCKED,
    EXECUTED
}

enum MultiSigProposalStateV1 {
    QUEUED,
    REJECTED,
    APPROVED,
    EXECUTED
}

enum MultiSigProposalClassV1 {
    UPGRADE,
    CALL
}

struct MultiSigProposalTimestampsV1 {
    uint256 start;
    uint256 end;
}

struct MultiSigProposalSettingsV1 {
    uint256 durationTimeout;
    uint256 requiredSignatures;
}

/**
* version Is the type of struct as there may be upgrades to the datatype
*         it is important to allow the protocol to identify what kind
*         of struct it is. These are all stored as bytes in an array
*         so when trying to check a type it may be of a different
*         struct.
*
* name Is the name of the proxy to be upgraded if proposal is an UPGRADE.
* account Is the address to call if the proposal is a CALL.
* implementation Is the address to upgrade the proxy to if proposal is an UPGRADE.
* signature Is the signature of the function to call if proposal is a CALL.
* args Is the args of the function to call if proposal is a CALL.
 */
struct MultiSigProposalV1 {
    uint256 version;
    MultiSigProposalClassV1 class;
    address creator;
    MultiSigProposalTimestampsV1 timestamps;
    MultiSigProposalSettingsV1 settings;
    MultiSigProposalPhaseV1 phase;
    MultiSigProposalStateV1 state;
    EnumerableSet.AddressSet signers;
    EnumerableSet.AddressSet signatures;
    string name;
    address account;
    address implementation;
    string signature;
    bytes args;
}