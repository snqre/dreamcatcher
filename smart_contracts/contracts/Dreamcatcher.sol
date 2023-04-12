// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "smart_contracts/contracts/Governor.sol";

inteface IDreamcatcher {
    function submitProposalOnchainNative(string caption, string description, uint256 duration, )
}

contract ProxyDreamcatcher is Dream

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
