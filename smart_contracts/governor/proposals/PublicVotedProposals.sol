// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";
import "smart_contracts/utils/Utils.sol";

using EnumerableSet for EnumerableSet.AddressSet;
contract PublicVotedProposals is Context, Ownable, ReentrancyGuard {
    uint count;

    struct PublicVotedProposal {
        uint reference_;
        address creator;
        string reason;
        uint startTimestamp;
        uint endTimestamp;
        uint timeout;
        uint quorum;
        uint quorumRequired;
        uint votesFor;
        uint votesAgainst;
        uint votesToAbstain;
        uint threshold;
        bool hasBeenWithdrawn;
        bool hasBeenImplemented;
        bool hasBeenCleared;
        bool delegate;
        address target;
        string signature;
        bytes args;
    }

    constructor(address owner) Ownable(owner) {}
}