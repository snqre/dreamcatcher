// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

library ProposalsStateLib {
    struct ProposalsStateTracker {
        uint numberOfReferendums;
        uint numberOfMultiSigReferendums;
        uint numberOfFullSetElections;
        uint numberOfSingleSetElections;
        uint numberOfEmergencyProposals;
    }

    struct ProposalsStateSettings {
        address dreamToken;
        address emberToken;
    }


}