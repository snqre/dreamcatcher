// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

contract ProposalsCoordinator {
    address multiSigProposals;
    address publicVotedProposals;


    struct ProtocolProposals {
        uint dailyActiveVoters;
    }

    function _setMultiSigProposalsContractAddress(address new_) internal {
        multiSigProposals = new_;
    }

    function _setPublicVotedProposalsContractAddress(address new_) internal {
        publicVotedProposals = new_;
    }


    uint constant private SECONDS_PER_DAY = 86400;
    uint public dailyActiveVoters;
    uint public lastUpdatedTimestamp;
    uint public timestamp;

    function updateDailyActiveVoters() public {

        uint currentTimestamp = block.timestamp;
        uint daysPassed = (currentTimestamp - lastUpdatedTimestamp) / 86400 seconds;

        if (daysPassed >= 1) {
            
        }

        else {

        }

        // if the current time has been more than a day since last update
        if (currentTimestamp >= lastUpdatedTimestamp + SECONDS_PER_DAY) {
            // if its been more than a day calculate excess time
            uint daysPassed = (currentTimestamp - lastUpdatedTimestamp) / SECONDS_PER_DAY;

            // Calculate the new value for dailyActiveVoters
            // ...

            // Update the lastUpdatedTimestamp to the current timestamp
            lastUpdatedTimestamp = currentTimestamp;
        }
    }
}