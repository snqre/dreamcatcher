// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";

interface ITerminal {
    function setObjWhitelist(address contract_, bool newWhitelistState) external;


    event ConnectionEstablished(address indexed contract_, string signature, bytes args);
    event ObjWhitelistEdit(address indexed obj, bool isWhitelisted);

    event MultiSigProposalSigned(uint ref, address indexed signer_, uint timestamp);
    event MultiSigProposalHasBeenPassed(uint ref, address indexed lastSigner, uint timestamp, uint numberOfSignatures);
    event MultiSigProposalSignatureRevoked(uint ref, address indexed signer_, uint timestamp);
    event MultiSigProposalCancelled(uint ref, address indexed caller, uint timestamp);
}

using EnumerableSet for EnumerableSet.AddressSet;
contract Terminal is ITerminal, AccessControl {
    // STATE DECLARATIONS FOR ACCESS CONTROL
    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    bytes32 public constant ROLE_BOARD = keccak256("ROLE_BOARD_MEMBER");
    bytes32 public constant ROLE_SYNDICATE = keccak256("ROLE_SYNDICATE");
    bytes32 public constant ROLE_MEMBER = keccak256("ROLE_MEMBER");

    // STATE DECLARATIONS FOR MULTI SIG PROPOSALS
    struct MultiSigProposal {
        uint startTimestamp;
        uint endTimestamp;
        uint threshold;

        bool hasBeenCancelled;
        bool hasBeenExecuted;
        bool hasBeenPassed;

        address obj;
        string signature;
        bytes args;
    }

    uint numberOfMultiSigProposals;

    mapping(uint => MultiSigProposal) private multiSigProposals;
    mapping(uint => EnumerableSet.AddressSet) private signers;
    mapping(uint => EnumerableSet.AddressSet) private signatures;

    // STATE DECLARATIONS FOR TERMINAL
    mapping(address => bool) private objWhitelist;

    // MODIFIERS FOR MULTI SIG PROPOSALS
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
        require(hasBeenExecuted, "selected multi sig proposal has been executed");
        _;
    }

    modifier onlyIfNotExecuted(uint ref) {
        bool hasBeenExecuted = multiSigProposals[ref].hasBeenExecuted;
        require(!hasBeenExecuted, "selected multi sig proposal has not been executed");
        _;
    }

    modifier onlyifExpired(uint ref) {
        bool isExpired = block.timestamp >= multiSigProposals[ref].endTimestamp;
        require(isExpired, "selected multi sig proposal has not expired");
        _;
    }

    modifier onlyIfNotExpired(uint ref) {
        bool isExpired = block.timestamp >= multiSigProposals[ref].endTimestamp;
        require(!isExpired, "selected multi sig proposal has expired");
        _;
    }

    modifier onlyIfNotDuplicateSignature(uint ref) {
        bool hasDuplicateSignature = signatures[ref].contains(msg.sender);
        require(!hasDuplicateSignature, "caller has already signed for selected multi sig proposal");
        _;
    }

    modifier onlyIfDuplicateSignature(uint ref) {
        bool hasDuplicateSignature = signatures[ref].contains(msg.sender);
        require(hasDuplicateSignature, "caller has not signed for selected multi sig proposal");
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

    modifier onlyIfObjIsWhitelisted(address contract_) {
        require(objWhitelist[contract_], "contract is not whitelisted");
        _;
    }

    modifier onlyIfObjIsNotWhitelisted(address contract_) {
        require(!objWhitelist[contract_], "contract is whitelisted");
        _;
    }

    constructor() {
        _grantRole(ROLE_ADMIN, address(this));
        
    }

    function _safeConnect(address contract_, string memory signature, bytes memory args) private onlyIfObjIsWhitelisted(contract_) returns (bool) {
        (bool callWasSuccessful, ) = address(contract_).delegatecall(abi.encodeWithSignature(signature, args));
        require(callWasSuccessful, "call was not successful");
        emit ConnectionEstablished(contract_, signature, args);
        return true;
    }

    function setObjWhitelist(address contract_, bool newWhitelistState) public onlyRole(ROLE_ADMIN) {
        objWhitelist[contract_] = newWhitelistState;
        emit ObjWhitelistEdit(contract_, newWhitelistState);
    }

    function newMultiSigProposal(address[] memory signers_, uint timeout, uint threshold_, address obj_, string memory signature_, bytes memory args_) public onlyRole(ROLE_BOARD) {
        bool has2OrMoreThan2Signers = signers_.length >= 2;
        bool has9OrLessThan9Signers = signers_.length <= 9;
        require(has2OrMoreThan2Signers, "signers_.length >= 2");
        require(has9OrLessThan9Signers, "signers_.length <= 9");

        numberOfMultiSigProposals += 1;
        uint now_ = block.timestamp;
        uint ref = numberOfMultiSigProposals;
        
        multiSigProposals[ref] = MultiSigProposal({
            startTimestamp: now_,
            endTimestamp: now_ + timeout,
            threshold: threshold_,
            hasBeenCancelled: false,
            hasBeenExecuted: false,
            hasBeenPassed: false,
            obj: obj_,
            signature: signature_,
            args: args_
        });

        for (uint i = 0; i < signers_.length; i++) {
            signers[ref].add(signers_[i]);
        }
    }

    function multiSigProposalSign(uint ref) public onlyIfNotExpired(ref) onlyIfNotCancelled(ref) onlyIfNotDuplicateSignature(ref) onlySignerOf(ref) {
        signatures[ref].add(msg.sender);
        emit MultiSigProposalSigned(ref, msg.sender, block.timestamp);

        uint currentQuota = (signers[ref].length() * 100) / signatures[ref].length();

        // getting stack too deep error ffs
        if (currentQuota >= multiSigProposals[ref].threshold) {
            multiSigProposals[ref].hasBeenPassed = true;
            emit MultiSigProposalHasBeenPassed(ref, msg.sender, block.timestamp, signatures[ref].length());
        }
    }

    function multiSigProposalUnsign(uint ref) public onlyIfNotExpired(ref) onlyIfNotCancelled(ref) onlyIfDuplicateSignature(ref) onlySignerOf(ref) {
        signatures[ref].remove(msg.sender);
        emit MultiSigProposalSignatureRevoked(ref, msg.sender, block.timestamp);
    }

    function multiSigProposalCancel(uint ref) public onlyIfNotExpired(ref) onlyIfNotCancelled(ref) onlyIfNotExecuted(ref) onlyRole(ROLE_BOARD) {
        multiSigProposals[ref].hasBeenCancelled = true;
        emit MultiSigProposalCancelled(ref, msg.sender, block.timestamp);
    }
 
    // once a multi sig proposal is passed a board member can call this function
    // note to establish delegatecall with a contract not in delegatecall a proposal can be made to add a contract to whitelist first
    function multiSigProposalExecute(uint ref) public onlyIfNotExpired(ref) onlyIfNotCancelled(ref) onlyIfPassed(ref) onlyIfNotExecuted(ref) onlyRole(ROLE_BOARD) returns (bool) {
        address contract_ = multiSigProposals[ref].obj;
        string memory signature = multiSigProposals[ref].signature;
        bytes memory args = multiSigProposals[ref].args;

        _safeConnect(contract_, signature, args);
        return true;
    }

    function multiSigProposalStartTimestamp(uint ref) public view returns (uint) {
        return multiSigProposals[ref].startTimestamp;
    }

    function multiSigProposalEndTimestamp(uint ref) public view returns (uint) {
        return multiSigProposals[ref].endTimestamp;
    }

    function multiSigProposalHasBeenCancelled(uint ref) public view returns (bool) {
        return multiSigProposals[ref].hasBeenCancelled;
    }

    function multiSigProposalHasBeenExecuted(uint ref) public view returns (bool) {
        return multiSigProposals[ref].hasBeenExecuted;
    }

    function multiSigProposalHasBeenPassed(uint ref) public view returns (bool) {
        return multiSigProposals[ref].hasBeenPassed;
    }


}