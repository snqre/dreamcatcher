// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";

import "smart_contracts/utils/Utils.sol";
import "smart_contracts/tokens/dream_token/DreamToken.sol";

using EnumerableSet for EnumerableSet.AddressSet;
contract MultiSigReferendums is Context, Ownable, ReentrancyGuard {
    struct Tracker {
        uint numberOfReferendums;
    }

    struct Settings {
        uint threshold;
        uint minTimeoutDays;
        uint maxTimeoutDays;
        uint minThreshold;
        uint maxThreshold;
        address nativeToken;
    }

    struct Referendum {
        uint identifier;
        address creator;
        string reason;
        uint startTimestamp;
        uint endTimestamp;
        uint timeout;
        uint quorumRequired;
        bool hasBeenCancelled;
        bool hasBeenExecuted;
        bool hasBeenPassed;
        bool delegatecall;
        address target;
        string signature;
        bytes args;
        EnumerableSet
            .AddressSet signers;
        EnumerableSet
            .AddressSet signatures;
    }

    Tracker internal tracker;
    Settings internal settings;
    mapping(uint => Referendum) internal referendums;
    mapping(address => bool) internal whitelist;//remember check this from terminal

    event ReferendumCreated(
        uint indexed identifier,
        address indexed creator,
        uint startTimestamp,
        uint endTimestamp,
        uint timeout,
        uint quorumRequired,
        bool delegatecall,
        address target,
        string signature,
        bytes args,
        address[] signers
    );

    event Signed(
        uint indexed identifier,
        address indexed signer
    );

    event SignatureRevoked(
        uint indexed identifier,
        address indexed signer
    );

    event Passed(
        uint indexed identifier,
        address indexed lastSigner,
        uint numberOfSignatures
    );

    event Cancelled(
        uint indexed identifier,
        address indexed caller
    );

    event Executed(
        uint indexed identifier,
        address indexed caller
    );

    constructor(address owner) Ownable(owner) {
        settings.threshold = 50;
        settings.minTimeoutDays = 7 days;
        settings.maxTimeoutDays = 356 days;
        settings.minThreshold = 50;
        settings.maxThreshold = 100;
    }

    function _mustNotBePassed(uint identifier) internal view virtual {
        require(
            !referendums[identifier].hasBeenPassed,
            "multiSigReferendums: Referendum has been passed."
        );
    }

    function _mustBePassed(uint identifier) internal view virtual {
        require(
            referendums[identifier].hasBeenPassed,
            "multiSigReferendums: Referendum has not been passed."
        );
    }

    function _mustNotBeCancelled(uint identifier) internal view virtual {
        require(
            !referendums[identifier].hasBeenCancelled,
            "multiSigReferendums: Referendum has been cancelled."
        );
    }

    function _mustBeCancelled(uint identifier) internal view virtual {
        require(
            referendums[identifier].hasBeenCancelled,
            "multiSigReferendums: Referendum has not been cancelled."
        );
    }

    function _mustNotBeExecuted(uint identifier) internal view virtual {
        require(
            !referendums[identifier].hasBeenExecuted,
            "multiSigReferendums: Referendum has been executed."
        );
    }

    function _mustBeExecuted(uint identifier) internal view virtual {
        require(
            referendums[identifier].hasBeenExecuted,
            "multiSigReferendums: Referendum has not been executed."
        );
    }

    function _mustNotBeExpired(uint identifier) internal view virtual {
        require(
            block.timestamp < referendums[identifier].endTimestamp,
            "multiSigReferendums: Referendum has expired."
        );
    }

    function _requiredQuorumHasBeenMet(uint identifier) internal view virtual returns (bool) {
        Referendum storage referendum = referendums[identifier];
        uint currentQuorum = (referendum.signers.length() * 100) / referendum.signatures.length();
        if (currentQuorum >= referendum.quorumRequired) {
            return true;
        }

        else {
            return false;
        }
    }

    function _mustBePresent(uint identifier) internal view virtual {
        require(
            identifier >= 1 &&
            identifier <= tracker.numberOfReferendums,
            "MultiSigReferendums: Identifier does not point to an existing referendum."
        );
    }

    function _new(
        string memory reason,
        uint startTimestamp,
        uint timeout,
        uint quorumRequired,
        bool delegatecall,
        address target,
        string memory signature,
        bytes memory args,
        address[] memory signers
    ) internal virtual returns (uint identifier_) {
        uint now_ = block.timestamp;
        require(
            _msgSender() != address(0),
            "MultiSigReferendums: Caller is zero address."
        );
        require(
            now_ >= startTimestamp,
            "MultiSigReferendums: startTimestamp is in the past."
        );
        require(
            timeout >= settings.minTimeoutDays &&
            timeout <= settings.maxTimeoutDays,
            "MultiSigReferendums: Timeout value out of bounds."
        );
        require(
            target != address(0),
            "MultiSigReferendums: Target is zero address."
        );
        require(
            whitelist[target],
            "MultiSigReferendums: Target is not whitelisted."
        );

        tracker.numberOfReferendums ++;
        uint identifier = tracker.numberOfReferendums;
        Referendum storage referendum = referendums[identifier];
        referendum.identifier = identifier;
        referendum.creator = _msgSender();
        referendum.reason = reason;
    }





}