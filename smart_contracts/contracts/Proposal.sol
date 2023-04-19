// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "smart_contracts/contracts/vault/Vault.sol";

/**
Expanding the possibility to set an automated timer which only checks once a month or per week
depending on the cost of doing so, this means we wont have to rely on someone executing a proposal
This might cost $10 - $20 to check if a proposal can be exectued, it wont check already passed proposals so we save computation power
 */
interface IProposal {
    function newProposal() public onlySyndicate onlyDev onlyAdmin returns (bool);
    function cancel() public onlySyndicate onlyDev onlyAdmin returns (bool);
    function reset() public onlySyndicate onlyDev onlyAdmin returns (bool);
    function execute() public onlySyndicate onlyDev onlyAdmin returns (bool);

}

library LibProposal {

}

// id is in string because ther are many more ways to combine string to give id and we can have the proposals in a map
// maps dont have any endings therefore when we reach uint256 we wont overflow, and we can keep going forever, built to survive
// also strings can be gievn names that we understand and can read
// althrough the downsize is that we might consume more gas using this method
// again still very exeperimental
contract ProposalState {
    struct ProposalMeta {
        string id;
        string name;
        string description;
        uint256 duration;
        uint256 start;
        uint256 end;
        target ;// target function to execute if any
        uint256 requiredFunding; // if any
        address creator;
        address funding; // may support multiple later
        
    }

    // voted is amount of votes an address has put up for this proposal
    mapping(string => mapping(address => uint256)) internal voted;
    mapping(string => mapping(address => bool)) internal isFor; // if they are not for then they voted against if they voted at all
    mapping(string => mapping(address => mapping(uint256 => string))) // comments
}

// linearly inherit
contract Proposal is Vault {
    // Only syndicate are allowed to make proposals at the moment
    function newProposal() public onlySyndicate onlyAdmin onlyDev onlyProposer returns (bool) {
        // can be called by custom contracts external to the actual contract
        ProposalMeta prop = new ProposalMeta({
            id: _id,
            name: _name,
            description: _description,
            duration: _duration,
            start: block.timestamp,
            end: block.timestamp + _duration,
            target: /* target function */,
            requiredFunding: _requiredFunding,
            creator: sender(),
            funding: _funding
        });
    }

    // function to cancel ongoing proposals
    function cancel() internal {}

    function reset() internal {}

    function execute() internal {}

    // you can dispute a proposal
    function dispute() internal returns (bool) { // return true if won, return false if lost

    }

}