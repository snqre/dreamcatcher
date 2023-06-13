// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";

using EnumerableSet for EnumerableSet.AddressSet;
contract SyndicateProposals is Context, Ownable, ReentrancyGuard {
    uint count;

    struct SyndicateProposal {
        uint reference_;
        address creator;
        uint startTimestamp;
        uint endTimestamp;
        uint timeout;
    }

    constructor(address owner) Ownable(owner) {}
}