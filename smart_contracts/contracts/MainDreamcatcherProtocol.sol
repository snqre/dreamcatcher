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
import "smart_contracts/contracts/Conduit.sol";
import "smart_contracts/contracts/BaseERC20.sol";

contract DreamcatcherProtocol is BaseERC20, Conduit {
    /* this is where everything comes together 
    building a decentralized system such that the governoment cant do anything about it
    we dont exist in a country
    we dont pay taxes on our treasury
    they cant shut us down
    a true dao
    */
}
