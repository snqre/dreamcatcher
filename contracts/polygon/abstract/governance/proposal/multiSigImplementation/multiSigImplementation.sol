// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

abstract contract MultiSigImplementation is StateV1 {

    using EnumerableSet for EnumerableSet.AddressSet;

    function caption() public view returns (string memory) {
        return _string[_keyCaption()];
    }

    function message() public view returns (string memory) {
        return _string[_keyMessage()];
    }

    function creator() public view returns (address) {
        return _address[_keyCreator()];
    }

    function target() public view returns (address) {
        return _address[_keyTarget()];
    }

    function data() public view returns (bytes memory) {
        return _bytes[_keyData()];
    }

    function signers(uint signerId) public view returns (address) {
        return _addressSet[_keySigners()].at(signerId);
    }
    
    function signersLength() public view returns (uint) {
        return _addressSet[_keySigners()].length();
    }

    function isSigner(address account) public view returns (bool) {
        return _addressSet[_keySigners()].contains(account);
    }

    function signatures(uint signatureId) public view returns (address) {
        return _addressSet[_keySignatures()].at(signatureId);
    }

    function signaturesLength() public view returns (uint) {
        return _addressSet[_keySignatures()].length();
    }

    function hasSigned(address account) public view returns (bool) {
        return _addressSet[_keySignatures()].contains(account);
    }

    function requiredQuorum() public view returns (uint) {
        return _uint256[_keyRequiredQuorum()];
    }

    function requiredSignaturesLength() public view returns (uint) {
        return (signersLength() * requiredQuorum()) / 10_000;
    }

    function hasSufficientSignatures() public view returns (bool) {
        return signersLength() >= requiredSignaturesLength();
    }

    function passed() public view returns (bool) {
        return _bool[_keyPassed()];
    }

    function executed() public view returns (bool) {
        return _bool[_keyExecuted()];
    }

    function timed() public view returns (bool) {
        return _bool[_keyTimed()];
    }

    function startTimestamp() public view returns (uint) {
        _uint256[_keyStartTimestamp()];
    }

    function endTimestamp() public view returns (uint) {
        return startTimestamp() + duration();
    }

    function duration() public view returns (uint) {
        _uint256[_keyDuration()];
    }

    function hasStarted() public view returns (bool) {
        if (timed()) {
            return block.timestamp >= startTimestamp();
        }
        else {
            return false;
        }
    }

    function hasEnded() public view returns (bool) {
        if (timed()) {
            return block.timestamp >= endTimestamp();
        }
        else {
            return false;
        }
    }

    function isCounting() public view returns (bool) {
        if (timed()) {
            return hasStarted() && !hasEnded();
        }
        else {
            return false;
        }
    }

    function secondsLeft() public view returns (uint) {
        if (timed()) {
            if (isCounting()) {
                return (startTimestamp() + duration()) - block.timestamp;
            }
            else if (!hasStarted()) {
                return duration();
            }
            else {
                return 0;
            }
        }
        else {
            return 0;
        }
    }
    
    function setStartTimestamp(uint timestamp) public {
        _uint256[_keyStartTimestamp()] = timestamp;
    }

    

    function _keyCaption() internal pure returns (bytes32) {
        return keccak256(abi.encode("caption"));
    }

    function _keyMessage() internal pure returns (bytes32) {
        return keccak256(abi.encode("message"));
    }

    function _keyCreator() internal pure returns (bytes32) {
        return keccak256(abi.encode("creator"));
    }

    function _keyTarget() internal pure returns (bytes32) {
        return keccak256(abi.encode("target"));
    }

    function _keyData() internal pure returns (bytes32) {
        return keccak256(abi.encode("data"));
    }

    function _keySigners() internal pure returns (bytes32) {
        return keccak256(abi.encode("signers"));
    }

    function _keySignatures() internal pure returns (bytes32) {
        return keccak256(abi.encode("signatures"));
    }

    function _keyRequiredQuorum() internal pure returns (bytes32) {
        return keccak256(abi.encode("requiredQuorum"));
    }

    function _keyPassed() internal pure returns (bytes32) {
        return keccak256(abi.encode("passed"));
    }

    function _keyExecuted() internal pure returns (bytes32) {
        return keccak256(abi.encode("executed"));
    }

    function _keyTimed() internal pure returns (bytes32) {
        return keccak256(abi.encode("timed"));
    }

    function _keyStartTimestamp() internal pure returns (bytes32) {
        return keccak256(abi.encode("startTimestamp"));
    }

    function _keyDuration() internal pure returns (bytes32) {
        return keccak256(abi.encode("duration"));
    }
}