// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "smart_contracts/governor/proposals/referendum/ReferendumStateLib.sol";

library ReferendumLogicLib {
    function mustNotBePassed(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            !referendum.hasBeenPassed,
            "Referendum has been passed."
        );
    }

    function mustBePassed(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            referendum.hasBeenPassed,
            "Referendum has not been passed."
        );
    }

    function mustNotBeCancelled(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            !referendum.hasBeenCancelled,
            "Referendum has been cancelled."
        );
    }

    function mustBeCancelled(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            referendum.hasBeenCancelled,
            "Referendum has not been cancelled."
        );
    }

    function mustNotBeExecuted(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            !referendum.hasBeenExecuted,
            "Referendum has been executed."
        );
    }

    function mustBeExecuted(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            referendum.hasBeenExecuted,
            "Referendum ahs not been executed."
        );
    }

    function mustNotBeExpired(ReferendumStateLib.Referendum storage referendum) public view {
        require(
            block.timestamp < referendum.endTimestamp,
            "Referendum has expired."
        );
    }

    function requiredQuorumHasBeenMet(ReferendumStateLib.Referendum storage referendum) public view returns (bool) {
        if (referendum.quorum >= referendum.quorumRequired) { return true; }
        else { return false; }
    }

    function requiredThresholdHasBeenMet(ReferendumStateLib.Referendum storage referendum) public view returns (bool) {
        if (((referendum.votesFor * 100) / (referendum.votesFor + referendum.votesAgainst)) >= referendum.threshold) { return true; }
        else { return false; }
    }
    
    function mustBePresent(
        ReferendumStateLib.Referendum storage referendum,
        ProposalsStateLib.ProposalsStateTracker storage tracker
    ) public view {
        require(
            referendum.identifier >= 1 &&
            referendum.identifier <= tracker.numberOfReferendums,
            "Identifier does not point to an existing referendum."
        );
    }
}