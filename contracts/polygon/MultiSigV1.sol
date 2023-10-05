// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/libraries/__Shared.sol";
import "contracts/polygon/ProxyStateOwnableContract.sol";

contract MultiSigV1 is ProxyStateOwnableContract {
    using EnumerableSet for EnumerableSet.AddressSet;

    modifier onlySigner() {
        require(isSigner(msg.sender), "msg.sender !signer");
        _;
    }

    function signers(uint256 index) public view returns (address) {
        EnumerableSet.AddressSet memory signers = _addressSet[keccak256(abi.encode("signers"))];
        return signers.at(index);
    }

    function signersLength() public view returns (uint256) {
        EnumerableSet.AddressSet memory signers = _addressSet[keccak256(abi.encode("signers"))];
        return signers.length();
    }

    function isSigner(address account) public view returns (bool) {
        EnumerableSet.AddressSet memory signers = _addressSet[keccak256(abi.encode("signers"))];
        return signers.contains(account);
    }

    function durationTimeout() public view returns (uint256) {
        return _uint256[keccak256(abi.encode("durationTimeout"))];
    }

    function proposalsClass(uint256 index) public view returns (uint256) {
        MultiSigProposalV1 memory proposal = _fetchProposal(index);
        return uint256(proposal.class);
    }

    function proposalsCreator(uint256 index) public view returns (address) {
        MultiSigProposalV1 memory proposal = _fetchProposal(index);
        return proposal.creator;
    }

    function addSigner(address account) public onlyOwner() whenNotPaused() {
        EnumerableSet.AddressSet memory signers = _addressSet[keccak256(abi.encode("signers"))];
        require(!isSigner(account), "MultiSigV1: isSigner");
        return signers.add(account);
    }

    function subSigner(address account) public onlyOwner() whenNotPaused() {
        EnumerableSet.AddressSet memory signers = _addressSet[keccak256(abi.encode("signers"))];
        require(isSigner(account), "MultiSigV1: !isSigner");
        return signers.remove(account);
    }

    function queueUpgrade(string memory proxyName, address implementation) public onlySigner() whenNotPaused() returns (uint256) {
        uint256 indexUnique = _increment();
        MultiSigProposalV1 proposal;
        proposal.version = 1;
        proposal.class = MultiSigProposalClassV1.UPGRADE;
        proposal.creator = msg.sender;
        proposal.timestamps.start = block.timestamp;
        proposal.timestamps.end = block.timestamp + durationTimeout();
        proposal.settings.durationTimeout = durationTimeout();
        proposal.settings.requiredSignatures = signersLength();
        proposal.phase = MultiSigProposalPhaseV1.PRIVATE;
        proposal.state = MultiSigProposalStageV1.QUEUED;
        address[] memory signers;
        signers
        = new address[](signersLength());
        for (uint256 i = 0; i < signersLength(); i++) {
            proposal.signers.add(signers(i));
        }
        proposal.name = proxyName;
        proposal.implementation = implementation;
        _storeProposal(proposal, indexUnique);
        return indexUnique;
    }

    function queueCall(address account, string memory signature, bytes memory args) public onlySigner() whenNotPaused() returns (uint256) {
        uint256 indexUnique = _increment();
        MultiSigProposalV1 proposal;
        proposal.version = 1;
        proposal.class = MultiSigProposalClassV1.CALL;
        proposal.creator = msg.sender;
        proposal.timestamps.start = block.timestamp;
        proposal.timestamps.end = block.timestamp + durationTimeout();
        proposal.settings.durationTimeout = durationTimeout();
        proposal.settings.requiredSignatures = signersLength();
        proposal.phase = MultiSigProposalPhaseV1.PRIVATE;
        proposal.state = MultiSigProposalStageV1.QUEUED;
        address[] memory signers;
        signers
        = new address[](signersLength());
        for (uint256 i = 0; i < signersLength(); i++) {
            proposal.signers.add(signers(i));
        }
        proposal.account = account;
        proposal.signature = signature;
        proposal.args = args;
        _storeProposal(proposal, indexUnique);
        return indexUnique;
    }

    function _fetchProposal(uint256 index) internal view returns (MultiSigProposalV1 memory proposal) {
        return abi.decode(_bytes[keccak256(abi.encode("proposals", index))], (MultiSigProposalV1));
    }

    function _increment() internal returns (uint256) {
        uint256 count = _uint256[keccak256(abi.encode("count"))];
        count += 1;
        _uint256[keccak256(abi.encode("count"))] = count;
        return count;
    }

    function _storeProposal(MultiSigProposalV1 proposal, uint256 index) internal {
        _bytes[keccak256(abi.encode("proposals", index))] = abi.encode(proposal);
    }
}



/// 0.5.0
/// _address: "publicSig"
/// _addressSet: "signers"
contract MultiSigV1B is ProxyStateOwnableContract {
    using EnumerableSet for EnumerableSet.AddressSet;

    modifier onlySigner() {
        _onlySigner();
        _;
    }

    modifier onlyNewCaption(string memory caption) {
        _onlyNewCaption(caption);
        _;
    }

    modifier onlyExistingCaption(string memory caption) {
        _onlyExistingCaption(caption);
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

    function isSigner(uint256 index) public view returns (bool) {
        EnumerableSet.AddressSet storage signers = _addressSet[keccak256(abi.encode("signers"))];
        return signers.contains(account);
    }

    function publicSig() public view returns (address) {
        return _address[keccak256(abi.encode("publicSig"))];
    }

    function durationTimeout() public view returns (uint256) {
        return _uint256[keccak256(abi.encode("duration", "timeout"))];
    }

    function addSigner(address account) public onlyOwner() whenNotPaused() returns (bool) {
        EnumerableSet.AddressSet storage signers = _addressSet[keccak256(abi.encode("signers"))];
        require(!signers.contains(account), "MultiSigV1: address is already a signer");
        signers.add(account);
    }

    function removeSigner(address account) public onlyOwner() whenNotPaused() returns (bool) {
        EnumerableSet.AddressSet storage signers = _addressSet[keccak256(abi.encode("signers"))];
        require(signers.contains(account), "MultiSigV1: address is not a signer");
        signers.remove(account);
    }

    function setDurationTimeout(uint256 value) public onlyOwner() whenNotPaused() returns (bool) {
        _uint256[keccak256(abi.encode("duration", "timeout"))] = value;
    }

    function queue(string memory caption, MultiSigProposalClassV1 class, string memory name, address account, address implementation, string signature, bytes args) public onlyOwner() whenNotPaused() onlyNewCaption(caption) returns (uint256) {
        return _queue(caption, class, name, account, implementation, signature, args);
    }

    function _onlySigner(uint256 index) internal view {
        bytes memory proposalEncoded = _bytes[keccak256(abi.encode("proposals", index))];
        bytes memory emptyBytes;
        require(keccak256(abi.encode(proposalEncoded)) == keccak256(emptyBytes), "MultiSigV1: empty");
        MultiSigProposalV1 proposal;
        proposal
        = abi.decode(proposalEncoded, (MultiSigProposalV1));
        require(proposal.signers.contains(msg.sender), "MultiSigV1: !signer");
    }

    function _onlyNewCaption(string memory caption) internal view {
        bytes memory proposal = _bytes[keccak256(abi.encode("proposals", "mapping", caption))];
        bytes memory emptyBytes;
        require(keccak256(proposal) == keccak256(emptyBytes), "MultiSigV1: !empty");
    }

    function _onlyExistingCaption(string memory caption) internal view {
        bytes memory proposal = _bytes[keccak256(abi.encode("proposals", "mapping", caption))];
        bytes memory emptyBytes;
        require(keccak256(proposal) == keccak256(emptyBytes), "MultiSigV1: empty");
    }

    function _queue(string memory caption, MultiSigProposalClassV1 class, string memory name, address account, address implementation, string signature, bytes args) internal onlyNewCaption(caption) whenNotPaused() returns (uint256) {
        MultiSigProposalV1 proposal;
        proposal.version = 1;
        proposal.class = class;
        proposal.creator = msg.sender;
        proposal.timestamps.start = block.timestamp;
        proposal.timestamps.end = proposal.timestamps.start + durationTimeout();
        proposal.settings.durationTimeout = durationTimeout();
        proposal.settings.requiredSignatures = lenSigners();
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
        return newUniqueIndex;
    }

    function _incrementProposalCount() internal returns (uint256) {
        uint256 count = _uint256[keccak256(abi.encode("proposals", "count"))];
        count += 1;
        _uint256[keccak256(abi.encode("proposals", "count"))] = count;
        return count;
    }
}