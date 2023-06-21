// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";

import "smart_contracts/utils/Utils.sol";

contract EmergencyProposals is Context, Ownable, ReentrancyGuard {
    uint count;

    struct EmergencyProposal {
        uint reference_;
        address creator;
        uint startTimestamp;
        uint endTimestamp;
        uint timeout;
        uint quorum; //amount of people who aknoledge this
        string concern;
    }

    mapping(uint => EmergencyProposal) private emergencyProposals;

    constructor(address owner) Ownable(owner) {}
}