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

    function _mustBeSigner(uint identifier, address account) private view {
        require(
            referendums[identifier].signers.contains(account),
            "MultiSigReferendums: Caller is not an expected signer."
        );
    }

    function _mustHaveSigned(uint identifier, address account) private view {
        require(
            referendums[identifier].signers.contains(account),
            "MultiSigReferendums: Caller has not signed."
        );
    }

    function _mustNotBePassed(uint identifier) private view {
        require(
            !referendums[identifier].hasBeenPassed,
            "multiSigReferendums: Referendum has been passed."
        );
    }

    function _mustBePassed(uint identifier) private view {
        require(
            referendums[identifier].hasBeenPassed,
            "multiSigReferendums: Referendum has not been passed."
        );
    }

    function _mustNotBeCancelled(uint identifier) private view {
        require(
            !referendums[identifier].hasBeenCancelled,
            "multiSigReferendums: Referendum has been cancelled."
        );
    }

    function _mustBeCancelled(uint identifier) private view {
        require(
            referendums[identifier].hasBeenCancelled,
            "multiSigReferendums: Referendum has not been cancelled."
        );
    }

    function _mustNotBeExecuted(uint identifier) private view {
        require(
            !referendums[identifier].hasBeenExecuted,
            "multiSigReferendums: Referendum has been executed."
        );
    }

    function _mustBeExecuted(uint identifier) private view {
        require(
            referendums[identifier].hasBeenExecuted,
            "multiSigReferendums: Referendum has not been executed."
        );
    }

    function _mustNotBeExpired(uint identifier) private view {
        require(
            block.timestamp < referendums[identifier].endTimestamp,
            "multiSigReferendums: Referendum has expired."
        );
    }

    function _requiredQuorumHasBeenMet(uint identifier) private view returns (bool) {
        Referendum storage referendum = referendums[identifier];
        uint currentQuorum = (referendum.signers.length() * 100) / referendum.signatures.length();
        if (currentQuorum >= referendum.quorumRequired) {
            return true;
        }

        else {
            return false;
        }
    }

    function _mustBePresent(uint identifier) private view {
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
        uint threshold,
        uint quorumRequired,
        bool delegatecall,
        address target,
        string memory signature,
        bytes memory args,
        address[] memory signers
    ) private returns (uint) {
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
            "MultiSigReferendums: Timeout value is out of bounds."
        );

        require(
            quorumRequired <= signers.length,
            "MultiSigReferendums: quorumRequired cannot be higher than signers."
        );

        require(
            target != address(0),
            "MultiSigReferendums: target is zero address."
        );

        require(
            whitelist[target],
            "MultiSigReferendums: target is not whitelisted."
        );

        require(
            threshold >= settings.minThreshold &&
            threshold <= settings.maxThreshold,
            "MultiSigReferendums: threshold is out of bounds."
        );

        tracker.numberOfReferendums ++;
        Referendum storage referendum = referendums[tracker.numberOfReferendums];
        referendum.identifier = tracker.numberOfReferendums;
        referendum.creator = _msgSender();
        referendum.reason = reason;

        if (startTimestamp == 0) { referendum.startTimestamp = now_; }
        else { referendum.startTimestamp = startTimestamp; }

        if (timeout == 0) { referendum.timeout = settings.minTimeoutDays; }
        else { referendum.timeout = timeout; }

        referendum.endTimestamp = referendum.startTimestamp + referendum.timeout;

        if (quorumRequired == 0) { referendum.quorumRequired = (signers.length / 100) * referendum.threshold; }
        else { referendum.quorumRequired = quorumRequired; }

        if (threshold == 0) { referendum.threshold = settings.threshold; }
        else { referendum.threshold = threshold; }

        referendum.delegatecall = delegatecall;
        referendum.signature = signature;
        referendum.args = args;

        emit ReferendumCreated(
            referendum.identifier,
            referendum.creator,
            referendum.startTimestamp,
            referendum.endTimestamp,
            referendum.timeout,
            referendum.quorumRequired,
            referendum.delegatecall,
            referendum.target,
            referendum.signature,
            referendum.args,
            signers
        );

        return referendum.identifer;
    }

    function _sign(uint identifier) private {
        _mustBePresent(identifier);
        _mustBeSigner(identifer, _msgSender());
        _mustNotBePassed(identifier);
        _mustNotBeCancelled(identifier);
        _mustNotBeExecuted(identifier);
        _mustNotBeExpired(identifier);

        Referendum storage referendum = referendums[identifier];
        referendum.signatures.add(_msgSender());

        uint now_ = block.timestamp;
        emit Signed(
            identifier,
            _msgSender(),
            now_
        );

        // we check if the threshold has been met
        if (_requiredQuorumHasBeenMet(identifier)) {
            referendum.hasBeenPassed = true;
            emit Passed(
                identifier,
                _msgSender(),
                referendum.signatures.length()
            );
        }
    }

    function _unsign(uint identifier) private {
        _mustBePresent(identifier);
        _mustBeSigner(identifier, _msgSender());
        _mustHaveSigned(identifier, _msgSender());
        _mustNotBePassed(identifier);
        _mustNotBeCancelled(identifier);
        _mustNotBeExecuted(identifier);
        _mustNotBeExpired(identifier);

        Referendum storage referendum = referendums[identifier];
        referendum.signatures.remove(_msgSender());

        emit SignatureRevoked(
            identifier,
            _msgSender()
        );
    }

    function _cancel(uint identifier) private {
        _mustBePresent(identifier);
        _mustNotBePassed(identifer);
        _mustNotBeCancelled(identifer);
        _mustNotBeExecuted(identifier);
        _mustNotBeExpired(identifier);

        Referendum storage referendum = referendums[identifier];
        referendum.hasBeenCancelled = true;

        emit Cancelled(
            identifier,
            _msgSender()
        );
    }

    function _execute(uint identifier) private {
        _mustBePresent(identifier);
        _mustNotBeExpired(identifier);
        _mustNotBeExecuted(identifier);
        _mustBePassed(identifier);
        _mustNotBeWithdrawn(identifier);

        Referendum storage referendum = referendums[identifier];
        referendum.hasBeenExecuted = true;

        emit Executed(
            identifier,
            _msgSender()
        );
    }

    function new_(
        string memory reason,
        uint startTimestamp,
        uint timeout,
        uint threshold,
        uint quorumRequired,
        bool delegatecall,
        address target,
        string memory signature,
        bytes memory args,
        address[] memory signers
    ) external onlyOwner nonReentrant returns (
        bool,
        uint
    ) {
        uint identifier = _new(
            reason,
            startTimestamp,
            timeout,
            threshold,
            quorumRequired,
            delegatecall,
            target,
            signature,
            args,
            signers
        );

        return (
            true,
            identifier
        );
    }

    function sign(uint identifier) external onlyOwner nonReentrant returns (bool) {
        _sign(identifier);
        return true;
    }

    function unsign(uint identifier) external onlyOwner nonReentrant returns (bool) {
        _unsign(identifier);
        return true;
    }

    function cancel(uint identifier) external onlyOwner nonReentrant returns (bool) {
        _cancel(identifier);
        return true;
    }

    function execute(uint identifier) external onlyOwner nonReentrant returns (bool) {
        _execute(identifier);
        return true;
    }

    function getNumberOfReferendums() external view returns (uint) {
        return tracker.numberOfReferendums;
    }

    function getPayload(uint identifier) external view returns (
        bool,
        address,
        string memory,
        bytes memory
    ) {
        _mustBePresent(identifier);
        Referendum storage referendum = referendums[identifier];
        return (
            referendum.delegatecall,
            referendum.target,
            referendum.signature,
            referendum.args
        );
    }

    function getState(uint identifier) external view returns (
        bool,
        bool,
        bool
    ) {
        _mustBePresent(identifier);
        Referendum storage referendum = referendums[identifier];
        return (
            referendum.hasBeenCancelled,
            referendum.hasBeenExecuted,
            referendum.hasBeenPassed
        );
    }

    function getMetaData(uint identifier) external view returns (
        address,
        uint,
        uint,
        uint,
        uint
    ) {
        _mustBePresent(identifier);
        Referendum storage referendum = referendums[identifier];
        return (
            referendum.creator,
            referendum.startTimestamp,
            referendum.endTimestamp,
            referendum.timeout,
            referendum.quorumRequired
        );
    }

    function getSigners(uint identifier) external view returns (address[] memory) {
        _mustBePresent(identifier);
        Referendum storage referendum = referendums[identifier];
        return Utils.convertEnumerableSetAddressSetToArray(referendum.signers);
    }

    function getSignatures(uint identifier) external view returns (address[] memory) {
        _mustBePresent(identifier);
        Referendum storage referendum = referendums[identifier];
        return Utils.convertEnumerableSetAddressSetToArray(referendum.signatures);
    }
}