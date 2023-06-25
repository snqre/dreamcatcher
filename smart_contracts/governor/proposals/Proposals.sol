// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "smart_contracts/governor/proposals/ProposalsStateLib.sol";
import "smart_contracts/governor/proposals/referendum/ReferendumStateLib.sol";

contract Proposals {
    ProposalsStateLib.Tracker private tracker;
    ProposalsStateLib.Settings private settings;
    
    ReferendumStateLib.Settings private referendumSettings;
    ReferendumStateLib.Referendum[] private referendums;
    mapping(uint => mapping(address => ReferendumStateLib.Voter)) private referendumVoters;

    
}