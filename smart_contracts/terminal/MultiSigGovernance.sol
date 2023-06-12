// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

import "smart_contracts/terminal/Authenticator.sol";
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "smart_contracts/utils/Utils.sol";

contract MultiSigGovernance is Authenticator {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint public numberOfMultiSigProposals;

    struct MultiSigProposal {
        uint ref;
        address creator;
        string reason;

        uint startTimestamp;
        uint endTimestamp;
        uint threshold;

        bool hasBeenCancelled;
        bool hasBeenExecuted;
        bool hasBeenPassed;

        bool delegateToTarget;
        address target;
        string signature;
        bytes args;
        uint value;
        uint gasLimit;
    }

    mapping(uint => MultiSigProposal) private multiSigProposals;
    mapping(uint => EnumerableSet.AddressSet) private signers;
    mapping(uint => EnumerableSet.AddressSet) private signatures;

    modifier onlySignerOf(uint ref) {
        bool isSignerOf = signers[ref].contains(msg.sender);
        require(isSignerOf, "caller is not a signer for the selected multi sig proposal");
        _;
    }

    modifier onlyIfPassed(uint ref) {
        bool hasBeenPassed = multiSigProposals[ref].hasBeenPassed;
        require(hasBeenPassed, "selected multi sig proposal has not been passed");
        _;
    }

    modifier onlyIfNotPassed(uint ref) {
        bool hasBeenPassed = multiSigProposals[ref].hasBeenPassed;
        require(!hasBeenPassed, "selected multi sig proposal has been passed");
        _;
    }

    modifier onlyIfCancelled(uint ref) {
        bool hasBeenCancelled = multiSigProposals[ref].hasBeenCancelled;
        require(hasBeenCancelled, "selected multi sig proposal has not been cancelled");
        _;
    }

    modifier onlyIfNotCancelled(uint ref) {
        bool hasBeenCancelled = multiSigProposals[ref].hasBeenCancelled;
        require(!hasBeenCancelled, "selected multi sig proposal has been cancelled");
        _;
    }

    modifier onlyIfExecuted(uint ref) {
        bool hasBeenExecuted = multiSigProposals[ref].hasBeenExecuted;
        require(hasBeenExecuted, "selected multi sig has not been executed");
        _;
    }

    modifier onlyIfNotExecuted(uint ref) {
        bool hasBeenExecuted = multiSigProposals[ref].hasBeenExecuted;
        require(!hasBeenExecuted, "selected multi sig has been executed");
        _;
    }

    modifier onlyIfExpired(uint ref) {
        bool isExpired = block.timestamp >= multiSigProposals[ref].endTimestamp;
        require(isExpired, "selected multi sig proposal has not expired");
        _;
    }

    modifier onlyIfNotExpired(uint ref) {
        bool isExpired = block.timestamp >= multiSigProposals[ref].endTimestamp;
        require(isExpired, "selected multi sig proposals has expired");
        _;
    }

    modifier onlyIfDuplicateSignature(uint ref) {
        bool hasDuplicateSignature = signatures[ref].contains(msg.sender);
        require(hasDuplicateSignature, "caller has not signed for selected multi sig proposal");
        _;
    }

    modifier onlyIfNotDuplicateSignature(uint ref) {
        bool hasDuplicateSignature = signatures[ref].contains(msg.sender);
        require(!hasDuplicateSignature, "caller has already signed for selected multi sig proposal");
        _;
    }

    modifier onlyIfThresholdHasBeenMet(uint ref) {
        uint currentThreshold = (signers[ref].length() * 100) / signatures[ref].length();
        require(currentThreshold >= multiSigProposals[ref].threshold);
        _;
    }

    modifier onlyIfThresholdHasNotBeenMet(uint ref) {
        uint currentThreshold = (signers[ref].length() * 100) / signatures[ref].length();
        require(currentThreshold < multiSigProposals[ref].threshold);
        _;
    }

    function _incrementNumberOfMultiSigProposals(uint increase) private {
        numberOfMultiSigProposals += increase;
    }

    function _pushNewMultiSigProposal(
        address creator,
        string memory reason,
        uint startTimestamp,
        uint timeout,
        uint threshold,
        bool delegateToTarget,
        address target,
        string memory signature,
        bytes memory args,
        uint value,
        uint gasLimit
    ) internal virtual {
        _incrementNumberOfMultiSigProposals(1);

        multiSigProposals[numberOfMultiSigProposals] = MultiSigProposal({
            ref: numberOfMultiSigProposals,
            creator: creator,
            reason: reason,
            startTimestamp: startTimestamp,
            endTimestamp: startTimestamp + timeout,
            threshold: threshold,
            hasBeenCancelled: false,
            hasBeenExecuted: false,
            hasBeenPassed: false,
            delegateToTarget: delegateToTarget,
            target: target,
            signature: signature,
            args: args,
            value: value,
            gasLimit: gasLimit
        });
    }

    function pushNewMultiSigProposal(
        string memory reason,
        uint startTimestamp,
        bool delegateToTarget,
        address target,
        string memory signature,
        bytes memory args,
        uint value,
        uint gasLimit
    ) public {

    }
}