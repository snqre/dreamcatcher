// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "smart_contracts/governor/proposals/ProposalsStateLib.sol";
import "smart_contracts/governor/proposals/referendum/ReferendumLogicLib.sol";
import "smart_contracts/governor/proposals/referendum/ReferendumStateLib.sol";

contract ProposalsTerminal { /// swappable
    ProposalsStateLib.Tracker private tracker;
    ProposalsStateLib.Settings private settings;
    
    ReferendumStateLib.Settings private settingsReferendum;
    ReferendumStateLib.Referendum[] private referendums;

    bool isActive;
    mapping(address => bool) private isModule;
    mapping(address => bool) private isSubModule;

    constructor() {
        isActive = true;
    }

    function _mustBeActive() private view {
        require(
            isActive,
            "This module is not in function."
        );
    }

    function createReferendum(
        string memory reason,
        uint startTimestamp,
        uint timeout,
        uint requiredQuorum,
        uint threshold,
        bool delegatecall,
        address target,
        string memory signature,
        bytes memory args
    ) external returns (
        uint,
        uint
    ) {
        _mustBeActive();
        (
            uint identifier,
            uint snapshot
        ) = ReferendumLogicLib.create(
            referendums,
            settingsReferendum,
            settings,
            tracker,
            reason,
            startTimestamp,
            timeout,
            requiredQuorum,
            threshold,
            delegatecall,
            target,
            signature,
            args
        );

        return (
            identifier,
            snapshot
        );
    }

    function voteForReferendum(
        uint identifier,
        uint choice
    ) external returns (bool) {
        _mustBeActive();
        ReferendumLogicLib.vote(
            referendums,
            tracker,
            identifier,
            choice
        );

        return true;
    }

    function cancelReferendum(
        uint identifier
    ) external returns (bool) {
        ReferendumLogicLib.cancel(
            referendums, 
            tracker, 
            identifier
        );

        return true;
    }

    function execute(
        uint identifier
    ) external returns (bool) {
        _mustBeActive();
        ReferendumLogicLib.execute(
            referendums, 
            tracker, 
            identifier
        );

        return true;
    }
}