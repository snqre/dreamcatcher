// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

/*
Purpose & Goals 
-- Purpose and goals of the DAO
---- Decentralized governance of the decentralized services we will offer
---- Decentralized finance will allow us to get better deals when trying to deal with offers
---- Giving young entrepreneurs a chance to find funding for their projects
---- Research and development and attracting talent

-- What is the DAO going to do?
---- Vote on proposals to improve the built system
---- Vote on using excess trasury capital to re invest in projects
---- Decentralized fund management
---- Decentralized application managment

-- What problems will it solve?
---- Centralized control
---- Lack of transparency
---- Cost and efficiency
---- Trust
---- Accessibility

-- What benefits will it provide to its members?
---- Transparency
---- Voting rights
---- Equity
---- Flexibility
---- Opportunities to participate
---- Cheaper fees for our products and negotiating cheaper pricing for projects we invest in
---- Member's only resources

Membership
-- Membership structure
---- Token-based membership

-- Will membership be open to anyone?
---- As long as you have more than 0 tokens you are a member
---- To become a syndicate you must have at least 1% of the total supply staked they are proposal creators, arbitrators, curators, and are the core team

-- Will there be any criteria for joining the DAO?
---- Token ownership

-- Will there be any criteria for becoming a Syndicate?
---- Token ownership
---- elected by the community

Governance
-- How will decisions be made?
---- Quadratic voting
---- Delegated voting

-- Will there be voting?
---- Yes

-- How will voting power be distributed among members?
---- Quadratic voting
---- ie. one has 10,000 the first token is worth 1:1
---- the second is worth 1:0.99
---- math still in works

Smart Contract Development
-- Voting
-- Proposal submission
-- Fund managemeng

Deployment
-- Where are you initially deploying this to?

Community Building
-- Promoting
-- Recruiting members
-- Fostering communication and engaement among members

Dreamcatcher itself is a DAO that will be able to hold assets and manage them
our platform for trading will be Obsidian
 */
import "smart_contracts/contracts/Governor.sol";

contract Dreamcatcher is Governor {
    function submitProposal(
        _caption,
        _description,
        _duration,
        _fundingRequested
    ) external override onlyAdmins onlySyndicates onlyCustodians {
        uint256 initialVoteSkew = 0;
        uint256 initialQuorum = 0;
        uint256 initialUniqueVotes = 0;
        uint256 initialTotalVotes = 0;
        uint256 totalGlobalVotes = properties.maxSupply;
        bool isActive = true;
        bool executed = false;
        super.submitProposal(
            _caption,
            _description,
            _duration,
            msg.sender,
            _fundingRequested,
            initialVoteSkew,
            initialQuorum,
            initialUniqueVotes,
            initialTotalVotes,
            totalGlobalVotes,
            isActive,
            executed
        );
    }

    constructor() ERC20("Dreamcatcher", "DREAM", 18, 200000000) {
        // vault
        initVault();
        newSupported("DREAM", msg.sender);
        mint(msg.sender, 160000000);
        // team member 1
        mintWithVesting(
            0xDbF85074764156004FEb245b65693e59a62262c2,
            19000000,
            4800 weeks
        );
        mint(0xDbF85074764156004FEb245b65693e59a62262c2, 1000000);
        // team member 2
        // team member 3
        // team member 4
    }
}
