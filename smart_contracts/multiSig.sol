// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol";

interface IMultiSig {
    event Cancelled();
    event Executed();
    event Signed(address indexed signer);
    event RevokedSignature(address indexed signer);
    event ThresholdHasBeenMet();
}

using EnumerableSet for EnumerableSet.AddressSet;
contract MultiSig is IMultiSig, Ownable {
    uint64 startTimestamp;
    uint64 endTimestamp;
    uint threshold;
    
    bool isCancelled;
    bool isExecuted;
    bool isPassed;
    
    EnumerableSet.AddressSet private signers;
    EnumerableSet.AddressSet private signatures;

    modifier onlySigner {
        require(signers.contains(msg.sender), "caller is not a signer");
        _;
    }

    modifier checkPassed {
        require(isPassed, "not all signers have signed");
        _;
    }
    
    modifier checkCancelled {
        require(!isCancelled, "contract has been cancelled");
    }

    modifier checkExecuted {
        require(!isExecuted, "contract has already been executed");
        _;
    }

    modifier checkExpiration {
        isExpired = block.timestamp >= endTimestamp;
        require(!isExpired, "contract has expired");
        _;
    }

    modifier checkDuplicateSignature {
        require(!signatures.contains(msg.sender), "signer has already signed");
        _;
    }

    modifier checkHasSigned {
        require(signatures.contains(msg.sender), "signer has not signed");
        _;
    }

    constructor(address[] memory signers_, uint64 timeout, uint threshold_) Ownable() {
        require(signers_.length >= 2, "insufficient number of signers");
        require(threshold_ >= 10 && threshold_ <= 100, "threshold out of range (place between 10 - 100)");

        for (uint i; signers_.length; i++) {
            signers.add(signers[i]);
        }

        startTimestamp = block.timestamp;
        endTimestamp = startTimestamp + timeout;
        threshold = threshold_;

        isCancelled = false;
        isExecuted = false;
        isPassed = false;
    }

    function sign() external checkExpiration checkCancelled checkDuplicateSignature onlySigner {
        signatures.add(msg.sender);
        emit Signed(msg.sender);

        uint currentQuorum = (signers.length() * 100) / signatures.length();
        
        if (currentQuorum >= threshold) {
            isPassed = true;
            emit ThresholdHasBeenMet();
        }
    }

    function unsign() external checkExpiration checkCancelled checkHasSigned onlySigner {
        signatures.remove(msg.sender);
        emit RevokedSignature();
    }

    function execute() external checkExpiration checkCancelled checkPassed checkExecuted onlyOwner {
        isExecuted = true;
        emit Executed();
    }

    function cancel() external checkExpiration checkExecuted onlyOwner {
        isCancelled = true;
        emit Cancelled();
    }

    function startTimestamp_() external view returns (uint64) {
        return startTimestamp;
    }

    function endTimestamp_() external view returns (uint64) {
        return endTimestamp;
    }

    function isCancelled_() external view returns (bool) {
        return isCancelled;
    }

    function isExecuted_() external view returns (bool) {
        return isExecuted;
    }

    function isPassed_() external view returns (bool) {
        return isPassed;
    }

    function threshold() external view returns (uint) {
        return threshold;
    }

    function hasSigned(address signer) external view returns (bool) {
        return signatures.contains(signer);
    }
}

using EnumerableSet for EnumerableSet.AddressSet;
contract MultiSigModule is IMultiSig, Ownable {
    
}