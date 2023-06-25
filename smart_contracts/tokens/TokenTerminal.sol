// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/access/Ownable.sol";
import "smart_contracts/tokens/dream_token/DreamToken.sol";
import "smart_contracts/tokens/ember_token/EmberToken.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";

interface ITokenTerminal {
    function snapshot() external returns (uint);
}

contract TokenTerminal is ReentrancyGuard {
    DreamToken immutable private dreamToken;
    EmberToken immutable private emberToken;

    constructor() Ownable() {
        dreamToken = new DreamToken();
        emberToken = new EmberToken();
    }

    /// snapshot will call snapshot on both contracts such that the snapshot identifier is the same.
    function _snapshot() private returns (uint) {
        uint snapshot = dreamToken.snapshot_();
        emberToken.snapshot_();
        return snapshot;
    }

    function snapshot() external nonReentrant returns (uint) { return _snapshot(); }

    function mintEmber(
        address to,
        uint amount
    ) external onlyOwner nonReentrant returns (bool) {
        emberToken.mint(
            to,
            amount
        );

        return true;
    }

    function mintEmberUsingBasisPoints(
        address to,
        uint points
    ) external onlyOwner nonReentrant returns (bool) {
        emberToken.mintUsingBasisPoints(
            to, 
            points
        );

        return true;
    }

    /// votes accounting for $ember token.
    function getVotesWithModifier(address account) external view returns (uint) {
        uint votes = dreamToken.getVotes(account);
        uint weight = emberToken.getWeight(account);

        uint additionalVotes = (votes / 10000) * weight;

        return votes + additionalVotes;
    }

    /// past votes accounting for $ember token.
    function getPastVotesWithModifier(
        address account,
        uint snapshot
    ) external view returns (uint) {
        uint votes = dreamToken.getVotesAt(
            account, 
            snapshot
        );

        uint weight = emberToken.getPastWeight(
            account, 
            snapshot
        );

        uint additionalVotes = (votes / 10000) * weight;

        return votes + additionalVotes;
    }

    function getDreamTokenContract() external view returns (address) { return address(dreamToken); }
    function getEmberTokenContract() external view returns (address) { return address(emberToken); }
}