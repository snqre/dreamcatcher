// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

interface ISigValidator {
    event SetUp(address[] signers, uint sigThreshold, uint startTimestamp, uint duration);
    event Signed(address account);
    event SignerAdded(address account);
    event SignerRemoved(address account);
    event DurationChanged(uint oldDuration, uint newDuration);
    event SigThresholdChanged(uint oldThreshold, uint newThreshold);
    event Passed();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function signers(uint i) external view returns (address);
    function signers() external view returns (address[] memory);
    function signersLength() external view returns (uint);
    function isSigner(address account) external view returns (bool);

    function signatures(uint i) external view returns (address);
    function signatures() external view returns (address[] memory);
    function signaturesLength() external view returns (uint);
    function hasSigned(address account) external view returns (bool);

    function sigThreshold() external view returns (uint);
    
    function startTimestamp() external view returns (uint);
    function duration() external view returns (uint);
    function time() external view returns (uint);
    function begun() external view returns (bool);
    function ended() external view returns (bool);
    function isInSession() external view returns (bool);

    function success() external view returns (bool);

    function ready() external view returns (bool);

    function conditionsHaveBeenMet() external view returns (bool);

    function start() external;
    function addSigner(address account) external;
    function removeSigner(address account) external;
    function setDuration(uint newDuration) external;
    function setSigThreshold(uint newThreshold) external;

    function sign() external;

    function owner() external view returns (address);

    function renounceOwnership() external;
    function transferOwnership(address newOwner) external;
}

contract SigValidator is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _signers;
    EnumerableSet.AddressSet private _signatures;
    uint private _sigThreshold;
    uint private _startTimestamp;
    uint private _duration;
    bool private _success;
    bool private _ready;

    event SetUp(address[] signers, uint sigThreshold, uint startTimestamp, uint duration);
    event Signed(address account);
    event SignerAdded(address account);
    event SignerRemoved(address account);
    event DurationChanged(uint oldDuration, uint newDuration);
    event SigThresholdChanged(uint oldThreshold, uint newThreshold);
    event Passed();

    constructor() Ownable(msg.sender) {}

    ///

    function signers(uint i) public view virtual returns (address) {
        return _signers.at(i);
    }

    function signers() public view virtual returns (address[] memory) {
        return _signers.values();
    }

    function signersLength() public view virtual returns (uint) {
        return _signers.length();
    }

    function isSigner(address account) public view virtual returns (bool) {
        return _signers.contains(account);
    }

    ///

    function signatures(uint i) public view virtual returns (address) {
        return _signatures.at(i);
    }

    function signatures() public view virtual returns (address[] memory) {
        return _signatures.values();
    }

    function signaturesLength() public view virtual returns (uint) {
        return _signatures.length();
    }

    function hasSigned(address account) public view virtual returns (bool) {
        return _signatures.contains(account);
    }

    ///

    function sigThreshold() public view virtual returns (uint) {
        return _sigThreshold;
    }

    ///

    function startTimestamp() public view virtual returns (uint) {
        return _startTimestamp;
    }

    function duration() public view virtual returns (uint) {
        return _duration;
    }

    function time() public view virtual returns (uint) {
        return block.timestamp;
    }

    function begun() public view virtual returns (bool) {
        return time() >= startTimestamp() && ready();
    }

    function ended() public view virtual returns (bool) {
        return time() >= startTimestamp() + duration() && ready();
    }

    function isInSession() public view virtual returns (bool) {
        return begun() && !ended() && ready();
    }

    ///

    function success() public view virtual returns (bool) {
        return _success;
    }

    ///

    function ready() public view virtual returns (bool) {
        return _ready;
    }

    ///

    function conditionsHaveBeenMet() public view virtual returns (bool) {
        if (!success()) {
            return (signaturesLength() * 10000) / signersLength() >= sigThreshold() && ready() && isInSession();
        }
        return success();
    }

    ///

    function start() onlyOwner public virtual {
        require(!begun(), "begun");
        _ready = true;
        _startTimestamp = time();
        emit SetUp(signers(), sigThreshold(), startTimestamp(), duration());
    }

    function addSigner(address account) onlyOwner public virtual {
        require(!begun(), "begun");
        _signers.add(account);
        emit SignerAdded(account);
    }

    function removeSigner(address account) onlyOwner public virtual {
        require(!begun(), "begun");
        _signers.remove(account);
        emit SignerRemoved(account);
    }

    function setDuration(uint newDuration) onlyOwner public virtual {
        require(!begun(), "begun");
        uint oldDuration = duration();
        _duration = newDuration;
        emit DurationChanged(oldDuration, newDuration);
    }

    function setSigThreshold(uint newThreshold) onlyOwner public virtual {
        require(!begun(), "begun");
        require(_isInRange(newThreshold), "!_isInRange");
        uint oldThreshold = sigThreshold();
        _sigThreshold = newThreshold;
        emit SigThresholdChanged(oldThreshold, newThreshold);
    }

    ///

    function sign() public virtual {
        address caller = msg.sender;
        require(isSigner(caller), "!isSigner");
        require(!hasSigned(caller), "hasSigned");
        require(isInSession(), "!isInSession");
        _signatures.add(caller);
        if (conditionsHaveBeenMet() && isInSession() && !success()) {
            _success = true;
            emit Passed();
        }
        emit Signed(caller);
    }

    ///

    function _isInRange(uint value) internal view virtual returns (bool) {
        return value <= 10000;
    }
}