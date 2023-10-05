// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/libraries/__Shared.sol";
import "contracts/polygon/ProxyStateOwnableContract.sol";

/// 0.5.0
/// _address: "publicSig"
/// _addressSet: "signers"
contract MultiSigV1 is ProxyStateOwnableContract {
    using EnumerableSet for EnumerableSet.AddressSet;

    modifier onlySigner(address account) {
        _onlySigner(account);
        _;
    }

    modifier onlyNewCaption(string memory caption) {
        _onlyNewCaption(caption);
        _;
    }

    function signers() public view returns (address[] memory) {
        EnumerableSet.AddressSet storage signers = _addressSet[keccak256(abi.encode("signers"))];
        return signers.values();
    }

    function lenSigners() public view returns (uint256) {
        EnumerableSet.AddressSet storage signers = _addressSet[keccak256(abi.encode("signers"))];
        return signers.length();
    }

    function basisRequiredQuorum() public view returns (uint256) {
        return 5000;
    }

    function isSigner(address account) public view returns (bool) {
        EnumerableSet.AddressSet storage signers = _addressSet[keccak256(abi.encode("signers"))];
        return signers.contains(account);
    }

    function publicSig() public view returns (address) {
        return _address[keccak256(abi.encode("publicSig"))];
    }

    function durationTimeout() public view returns (uint256) {
        return _uint256[keccak256(abi.encode("duration", "timeout"))];
    }

    function setBasisRequiredQuorum(uint256 newValue) public returns (bool) {
        require(newValue <= 10000, "MultiSigV1: new value cannot be greater than 10000");
        _uint256[keccak256(abi.encode("basisRequiredQuorum"))] = newValue;
        return true;
    }

    function _onlySigner() internal view {
        EnumerableSet.AddressSet storage signers = _addressSet[keccak256(abi.encode("signers"))];
        require(isSigner(msg.sender), "MultiSig: !signer");
    }

    function _onlyNewCaption(string memory caption) internal view {
        bytes memory proposal = _bytes[keccak256(abi.encode("proposals", "mapping", caption))];
        bytes memory emptyBytes;
        require(keccak256(proposal) == emptyBytes, "MultiSigV1: !empty");
    }

    function _queue(string memory caption, MultiSigProposalClassV1 class, string memory name, address account, address implementation, string signature, bytes args) internal onlyNewCaption(caption) whenNotPaused() returns (bool) {
        MultiSigProposalV1 proposal;
        proposal.version = 1;
        proposal.class = class;
        proposal.creator = msg.sender;
        proposal.timestamps.start = block.timestamp;
        proposal.timestamps.end = proposal.timestamps.start + durationTimeout();
        proposal.settings.durationTimeout = durationTimeout();
        proposal.settings.requiredSignatures = (lenSigners() / 10000) * basisRequiredQuorum();
        proposal.phase = MultiSigProposalPhaseV1.PRIVATE;
        proposal.state = MultiSigProposalStateV1.QUEUED;
        address[] memory signers;
        signers = new address[](lenSigners());
        signers = signers();
        for (uint256 i = 0; i < lenSigners(); i++) {
            proposal.signers.add(signers[i]);
        }
        proposal.name = name;
        proposal.account = account;
        proposal.implementation = implementation;
        proposal.signature = signature;
        proposal.args = args;
        uint256 newUniqueIndex = _incrementProposalCount();
        _bytes[keccak256(abi.encode("proposals", newUniqueIndex))] = abi.encode(proposal);
        _bytes[keccak256(abi.encode("proposals", "mapping", caption))] = abi.encode(proposal);
        return true;
    }

    function _incrementProposalCount() internal returns (uint256) {
        uint256 count = _uint256[keccak256(abi.encode("proposals", "count"))];
        count += 1;
        _uint256[keccak256(abi.encode("proposals", "count"))] = count;
        return count;
    }
}