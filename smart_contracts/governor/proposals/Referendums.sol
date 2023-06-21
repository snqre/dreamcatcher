// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";

import "smart_contracts/utils/Utils.sol";
import "smart_contracts/tokens/dream_token/DreamToken.sol";

using EnumerableSet for EnumerableSet.AddressSet;
contract Referendums is Context, Ownable, ReentrancyGuard {
    struct Tracker {
        uint numberOfReferendums;
    }
    
    struct Settings {
        uint threshold;
        uint minTimeoutDays;
        uint maxTimeoutDays;
    }

    struct Referendum {
        uint identifier;
        uint snapshot;
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
        bool hasBeenCancelled;
        bool hasBeenExecuted;
        bool hasBeenPassed;
        bool delegatecall;
        address target;
        string signature;
        bytes args;
        EnumerableSet.
            AddressSet voters;
    }

    Tracker internal tracker;
    Settings internal settings;
    mapping(uint => Referendum) internal referendums;
    mapping(address => bool) internal whitelist;//remember check this from terminal

    constructor(address owner) Ownable(owner) {
        settings.threshold = 50;        //require 50% to pass
        settings.minTimeoutDays = 7;    //minimum of 7 days timeout
        settings.maxTimeoutDays = 365;  //maximum of 1 year timeout
    }

    function _new(
        string memory reason,
        uint startTimestamp,
        uint timeout,
        bool delegatecall,
        address target,
        string memory signature,
        bytes memory args
    ) internal virtual {
        require(_msgSender() != address(0), "Referendums: _msgSender() == address(0)");
        require(block.timestamp >= startTimestamp, "Referendums: startTimestamp is in the past");
        require(
            timeout >= settings.minTimeoutDays &&
            timeout <= settings.maxTimeoutDays,
            "Referendums: timeout value out of bounds"
        );
        require(target != address(0), "Referendum: target == address(0)");
        require(whitelist[target], "Referendum: target is not whitelisted");

        tracker.numberOfReferendums ++;
        uint identifier = tracker.numberOfReferendums;
        Referendum storage referendum = referendums[identifier];
        referendum.identifier = identifier;

        //create snapshot and return snapshot identifier
        referendum.snapshot = IDreamToken().snapshot();
        referendum.creator = _msgSender();
        referendum.reason = reason;

        //default startTimestamp
        
        
    }  


}