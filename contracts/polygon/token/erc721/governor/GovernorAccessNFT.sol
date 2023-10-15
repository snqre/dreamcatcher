// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/nft/NFT.sol";

contract GovernorAccessNFT is NFT {
    constructor() NFT("Governor", "GOV", address(this)) {
        safeMint(msg.sender, "");
        _transferOwnership(msg.sender);
    }
}