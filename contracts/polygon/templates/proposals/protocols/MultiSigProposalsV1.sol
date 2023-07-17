// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Validator.sol";

interface IMultiSigProposalsV1 {

}

contract MultiSigProposalsV1 is IMultiSigProposalsV1, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public hub;
    uint public count;
    
    struct Settings {
        uint threshold;
        uint timeout;
    }

    struct Proposal {
        uint id;
        address creator;
        string message;
        uint32 startTimestamp;
        uint32 endTimestamp;
        uint timeout;
        uint quorumRequired;
        bool isRejected;
        bool isExecuted;
        bool isApproved;
        address target;
        string signature;
        bytes args;
        EnumerableSet.AddressSet signers;
        EnumerableSet.AddressSet signatures;
    }

    mapping(uint => Proposal) public proposals;
    
    constructor(address hub_)
        Ownable(msg.sender) {
        hub = hub_;
        threshold = 10000;
        timeout = 604800 seconds;
    }
    
    function _onlyIfSigner(uint identifier, address account)
        private view {
        require(
            proposals[identifier].signers.contains(account),
            "MultiSigProposalsV1: caller is not expected to sign"
        );
    }

    function _onlyIfApproved(uint identifier)
        private view {
        require(
            proposals[identifier].isApproved,
            "MultiSigProposalsV1: proposal has not been approved"
        );
    }

    function _onlyIfNotApproved(uint identifier)
        private view {
        require(
            !proposals[identifier].isApproved,
            "MultiSigProposalsV1: proposal has been approved"
        );
    }

    function _onlyIfRejected(uint identifier)
        private view {
        require(
            proposals[identifier].isRejected,
            "MultiSigProposalsV1: proposal has not been rejected"
        );
    }

    function _onlyIfNotRejected(uint identifier)
        private view {
        require(
            !proposals[identifier].isRejected,
            "MultiSigProposalsV1: proposal has been rejected"
        );
    }

    function _onlyIfExecuted(uint identifier)
        private view {
        require(
            proposals[identifier].isExecuted,
            "MultiSigProposalsV1: proposal has not been executed"
        );
    }

    function _onlyIfNotExecuted(uint identifier)
        private view {
        require(
            proposals[identifier].isExecuted,
            "MultiSigProposalsV1: proposal has been executed"
        );
    }

    function _onlyIfNotExpired(uint identifier)
        private view {
        require(
            block.timestamp < proposals[identifier].endTimestamp,
            "MultiSigProposalsV1: proposal has expired"
        );
    }

    function _requiredQuorumHasBeenMet(uint identifier)
        private view 
        returns (bool) {
        Proposal storage proposal = proposals[identifier];
        uint currentQuorum = (proposal.signers.length() * 10000) / proposal.signatures.length();
        if (currentQuorum >= proposal.quorumRequired) {
            return true;
        }
        else {
            return false;
        }
    }

    function create(string memory message, uint32 startTimestamp, uint32 endTimestamp, address target, string memory signature)
        external returns (uint) {
        IValidator(hub).validate(msg.sender, address(this), "create()");
        
    }

    



}