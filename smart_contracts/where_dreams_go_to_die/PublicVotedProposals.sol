// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.0;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";

import "smart_contracts/utils/Utils.sol";
import "smart_contracts/tokens/dream_token/DreamToken.sol";

interface IPublicVotedProposals {
    function pushNewPublicVotedProposal(
        uint startTimestamp,
        uint timeout,
        uint quorumRequired,
        bool delegate,
        address target,
        string memory signature,
        bytes memory args
    ) external returns (
        bool,
        uint,
        uint
    );

    function vote(uint reference_) external returns (bool);
    function withdraw(uint reference_) external returns (bool);
    function implement(uint reference_) external returns (bool);

    function count_() external view returns (uint);

    function requestOf(uint reference_) external view returns (
        bool delegate,
        address target,
        string memory signature,
        bytes memory args
    );

    function stateOf(uint reference_) external view returns (
        bool hasBeenWithdrawn,
        bool hasBeenImplemented,
        bool hasBeenCleared
    );

    function metaOf(uint reference_) external view returns (
        address creator,
        uint startTimestamp,
        uint endTimestamp,
        uint timeout,
        uint quorum,
        uint quorumRequired,
        uint votesFor,
        uint votesAgainst,
        uint votesToAbstain,
        uint threshold
    );

    function votersOf(uint reference_) external view returns (address[] memory);
}

using EnumerableSet for EnumerableSet.AddressSet;
contract PublicVotedProposals is Context, Ownable, ReentrancyGuard {
    uint count;
    address dreamToken;

    struct PublicVotedProposal {
        uint reference_;
        uint snapshotId;
        address creator;
        string reason;
        uint startTimestamp;
        uint endTimestamp;
        uint timeout;
        uint quorum;
        uint quorumRequired;
        uint votesFor;
        uint votesAgainst;
        uint votesToAbstain;
        uint threshold;
        bool hasBeenWithdrawn;
        bool hasBeenImplemented;
        bool hasBeenCleared;
        bool delegate;
        address target;
        string signature;
        bytes args;
        EnumerableSet.
            AddressSet voters;
    }

    mapping(uint => PublicVotedProposal) private publicVotedProposals;

    //account => reference_ : side
    mapping(address => mapping(uint => uint)) private sideOf;

    event PublicVotedProposalCreated(
        uint indexed reference_,
        address indexed creator,
        uint indexed startTimestamp,
        uint endTimestamp,
        uint timeout,
        uint quorumRequired,
        bool delegate,
        address target,
        string signature,
        bytes args,
        uint timestamp
    );

    event Voted(
        uint indexed reference_,
        address indexed voter,
        uint indexed votes,
        uint side
    );

    event Cleared(
        uint indexed reference_,
        address indexed lastVoter,
        uint indexed timestamp,
        uint numberOfVoters,
        uint quorum
    );

    event Withdrawn(
        uint indexed reference_,
        address indexed caller,
        uint indexed timestamp
    );

    event Implemented(
        uint indexed reference_,
        address indexed caller,
        uint indexed timestamp
    );

    constructor(address owner) Ownable(owner) {}

    function _hasVoted(uint reference_) internal view virtual returns (bool) {
        if (publicVotedProposals[reference_].voters.contains(_msgSender())) {
            return true;
        }

        else {
            return false;
        }
    }

    //will replace this once authenticator is complete in terminal
    function _mustNotBeMember(
        uint snapshotId
    ) internal view virtual {
        require(
            IDreamToken(dreamToken).getVotesAt(
                _msgSender(),
                snapshotId
            ) <= 0,
            "PublicVotedProposals: caller is a member of referenced member"
        );
    }
    //will replace this once authenticator is complete in terminal
    function _mustBeMember(
        uint snapshotId
    ) internal view virtual {
        require(
            IDreamToken(dreamToken).getVotesAt(
                _msgSender(),
                snapshotId
            ) >= 1,
            "PublicVotedProposals: caller is not a member"
        );
    }

    function _mustNotBeCleared(uint reference_) internal view virtual {
        require(!publicVotedProposals[reference_].hasBeenCleared, "PublicVotedProposals: referenced proposal has been cleared");
    }

    function _mustBeCleared(uint reference_) internal view virtual {
        require(publicVotedProposals[reference_].hasBeenCleared, "PublicVotedProposals: referenced proposal has not been cleared");
    }

    function _mustNotBeWithdrawn(uint reference_) internal view virtual {
        require(!publicVotedProposals[reference_].hasBeenWithdrawn, "PublicVotedProposals: referenced proposal has been withdrawn");
    }

    function _mustBeWithdrawn(uint reference_) internal view virtual {
        require(publicVotedProposals[reference_].hasBeenWithdrawn, "PublicVotedProposals: referened proposal has not been withdrawn");
    }

    function _mustNotBeImplemented(uint reference_) internal view virtual {
        require(!publicVotedProposals[reference_].hasBeenImplemented, "PublicVotedProposals: referenced proposal has been implemented");
    }

    function _mustBeImplemented(uint reference_) internal view virtual {
        require(publicVotedProposals[reference_].hasBeenImplemented, "PublicVotedProposals: referenced proposal has not been implemented");
    }

    function _mustNotBeExpired(uint reference_) internal view virtual {
        require(block.timestamp < publicVotedProposals[reference_].endTimestamp, "PublicVotedProposals: referenced proposal has expired");
    }

    function _requiredQuorumHasBeenMet(uint reference_) internal view virtual returns (bool) {
        uint quorum = publicVotedProposals[reference_].quorum;
        uint quorumRequired = publicVotedProposals[reference_].quorumRequired;
        if (quorum >= quorumRequired) {
            return true;
        }

        else {
            return false;
        }
    }

    function _requiredThresholdHasBeenMet(uint reference_) internal view virtual returns (bool) {
        uint threshold = publicVotedProposals[reference_].threshold;
        uint votesFor = publicVotedProposals[reference_].votesFor;
        uint votesAgainst = publicVotedProposals[reference_].votesAgainst;
        uint totalVotes = votesFor + votesAgainst;
        uint current = (votesFor * 100) / totalVotes;
        if (current >= threshold) {
            return true;
        }

        else {
            return false;
        }
    }

    function _mustBePresent(uint reference_) internal view virtual {
        require(
            reference_ >= 1 &&
            reference_ <= count,
            "PublicVotedProposals: reference does not point to an existing proposal"
        );
    }

    function _getAverageActiveQuorum(
        uint rangeBeginTimestamp,
        uint rangeEndTimestamp
    ) internal virtual returns (
        uint //average active quorum
    ) {
        uint activeProposals;
        uint totalQuorum;
        for (
            uint i = 1; 
            i < count; 
            i++
        ) {//too many proposals may increase gas costs too much
            PublicVotedProposal storage proposal = publicVotedProposals[i];
            if (//conditions to be an active proposal
                rangeBeginTimestamp          >= proposal.startTimestamp &&
                rangeEndTimestamp            <= proposal.endTimestamp &&
                proposal.hasBeenWithdrawn    == false &&
                proposal.hasBeenImplemented  == false &&
                proposal.hasBeenCleared      == false
            ) {
                activeProposals ++;
                totalQuorum += proposal.quorum;
            }
        }

        uint averageActiveQuorum = totalQuorum / activeProposals;
        return averageActiveQuorum;
    }

    function _pushNewPublicVotedProposal(
        string memory reason,
        uint startTimestamp,
        uint timeout,
        uint quorumRequired,
        uint threshold,
        bool delegate,
        address target,
        string memory signature,
        bytes memory args
    ) internal virtual nonReentrant returns (
        uint,
        uint
    ) {
        require(
            threshold >= 0 &&
            threshold <= 100,
            "PublicVotedProposals: threshold out of bounds"
        );

        count ++;
        PublicVotedProposal storage newProposal = publicVotedProposals[count];
        newProposal.reference_ = count;
        newProposal.snapshotId = IDreamToken(dreamToken).snapshot();
        newProposal.creator = _msgSender();
        newProposal.reason = reason;
        //check for default startTimestamp
        uint defaultStartTimestamp = block.timestamp;
        if (startTimestamp == 0) {
            newProposal.startTimestamp = defaultStartTimestamp;
        }

        else {
            newProposal.startTimestamp = startTimestamp;
        }
        //check for default timeout
        uint defaultTimeout = 4 weeks;
        if (timeout == 0) {
            newProposal.timeout = defaultTimeout;
        }

        else {
            newProposal.timeout = timeout;
        }
        //check for default quorumRequired
        uint now_ = block.timestamp;
        uint range = now_ - 4 weeks;
        uint defaultQuorumRequired = _getAverageActiveQuorum(
            range,
            now_
        );
        
        if (quorumRequired == 0) {//make sure to define this in native token
            uint totalSupply = IDreamToken(dreamToken).totalSupply();
            uint percentage = 20;
            uint portionOfTotalSupply = (totalSupply / 100) * percentage;
            if (defaultQuorumRequired < portionOfTotalSupply) {
                defaultQuorumRequired = portionOfTotalSupply;
            }

            newProposal.quorumRequired = defaultQuorumRequired;
        }

        else {
            newProposal.quorumRequired = quorumRequired;
        }
        //check for default threshold
        uint defaultThreshold = 80;
        if (threshold == 0) {
            newProposal.threshold = defaultThreshold;
        }

        else {
            newProposal.threshold = threshold;
        }
        //copy commands
        newProposal.delegate = delegate;
        newProposal.target = target;
        newProposal.signature = signature;
        newProposal.args = args;

        emit PublicVotedProposalCreated(
            count,
            _msgSender(),
            newProposal.startTimestamp,
            newProposal.endTimestamp,
            newProposal.timeout,
            newProposal.quorumRequired,
            newProposal.delegate,
            newProposal.target,
            newProposal.signature,
            newProposal.args,
            block.timestamp
        );

        return (//return reference and snapshot id
            newProposal.reference_,
            newProposal.snapshotId
        );
    }

    function _vote(uint reference_, uint side) internal virtual nonReentrant {
        PublicVotedProposal storage proposal = publicVotedProposals[reference_];
        _mustBePresent(reference_);
        _mustBeMember(proposal.snapshotId);
        _mustNotBeCleared(reference_);
        _mustNotBeWithdrawn(reference_);
        _mustNotBeExpired(reference_);

        uint votes = IDreamToken(dreamToken).getVotesAt(
            _msgSender(),
            proposal.snapshotId
        );

        if (_hasVoted(reference_)) {//caller has already voted
            //clear their votes from existing votes
            uint side_ = sideOf[_msgSender()][reference_];
            if (side_ == 0) {// abstain
                proposal.votesToAbstain -= votes;
            }

            else if (side_ == 1) {//for
                proposal.votesFor -= votes;
            }

            else if (side_ == 2) {//against
                proposal.votesAgainst -= votes;
            }
            //add edited votes for new side
            if (side == 0) {//abstain
                sideOf[_msgSender()][reference_] = 0;
                proposal.votesToAbstain += votes;
            }

            else if (side == 1) {//for
                sideOf[_msgSender()][reference_] = 1;
                proposal.votesFor += votes;
            }

            else if (side == 2) {//against
                sideOf[_msgSender()][reference_] = 2;
                proposal.votesAgainst += votes;
            }
        }

        else {//caller has not voted yet
            proposal.voters.add(_msgSender());
            proposal.quorum += votes;
            if (side == 0) {//abstain
                sideOf[_msgSender()][reference_] = 0;
                proposal.votesToAbstain += votes;
            }

            else if (side == 1) {//for
                sideOf[_msgSender()][reference_] = 1;
                proposal.votesFor += votes;
            }

            else if (side == 2) {//against
                sideOf[_msgSender()][reference_] = 2;
                proposal.votesAgainst += votes;
            }
        }

        //recount votes and check if it has been cleared
        if (
            _requiredQuorumHasBeenMet(reference_) &&
            _requiredThresholdHasBeenMet(reference_)
        ) {
            proposal.hasBeenCleared = true;

            emit Cleared(
                reference_,
                _msgSender(),
                block.timestamp,
                proposal.voters.length(),
                proposal.quorum
            );
        }

        emit Voted(
            reference_,
            _msgSender(),
            votes,
            side
        );
    }

    function _withdraw(uint reference_) internal virtual nonReentrant {
        _mustBePresent(reference_);
        _mustNotBeCleared(reference_);
        _mustNotBeWithdrawn(reference_);
        _mustNotBeImplemented(reference_);
        _mustNotBeExpired(reference_);

        PublicVotedProposal storage proposal = publicVotedProposals[reference_];
        proposal.hasBeenWithdrawn = true;

        emit Withdrawn(
            reference_,
            _msgSender(),
            block.timestamp
        );
    }

    function _implement(uint reference_) internal virtual nonReentrant {
        _mustBePresent(reference_);
        _mustNotBeExpired(reference_);
        _mustNotBeImplemented(reference_);
        _mustBeCleared(reference_);
        _mustNotBeWithdrawn(reference_);

        PublicVotedProposal storage proposal = publicVotedProposals[reference_];
        proposal.hasBeenImplemented = true;

        emit Implemented(
            reference_,
            _msgSender(),
            block.timestamp
        );
    }

    function pushNewPublicVotedProposal(
        string memory reason,
        uint startTimestamp,
        uint timeout,
        uint quorumRequired,
        uint threshold,
        bool delegate,
        address target,
        string memory signature,
        bytes memory args
    ) internal virtual nonReentrant returns (
        bool success,
        uint reference__,
        uint snapshotId_
    ) {//generate new proposal using internal function
        (
            uint reference_,
            uint snapshotId
        ) = _pushNewPublicVotedProposal(
            reason,
            startTimestamp,
            timeout,
            quorumRequired,
            threshold,
            delegate,
            target,
            signature,
            args
        );

        return (
            true,
            reference_,
            snapshotId
        );
    }

    function vote(
        uint reference_, 
        uint side
    ) public virtual nonReentrant returns (bool success) {
        _vote(
            reference_,
            side
        );

        return true;
    }

    function withdraw(uint reference_) public virtual onlyOwner nonReentrant returns (bool success) {
        _withdraw(reference_);
        return true;
    }
    //again this does nothing unless connected to other contract
    function implement(uint reference_) public virtual onlyOwner nonReentrant returns (bool success) {
        _implement(reference_);
        return true;
    }

    function count_() public view virtual returns (uint) {
        return count;
    }

    function requestOf(uint reference_) public view virtual returns (
        bool delegate,
        address target,
        string memory signature,
        bytes memory args
    ) {
        _mustBePresent(reference_);
        PublicVotedProposal storage proposal = publicVotedProposals[reference_];
        return (
            proposal.delegate,
            proposal.target,
            proposal.signature,
            proposal.args
        );
    }

    function stateOf(uint reference_) public view virtual returns (
        bool hasBeenWithdrawn,
        bool hasBeenImplemented,
        bool hasBeenCleared
    ) {
        _mustBePresent(reference_);
        PublicVotedProposal storage proposal = publicVotedProposals[reference_];
        return (
            proposal.hasBeenWithdrawn,
            proposal.hasBeenImplemented,
            proposal.hasBeenCleared
        );
    }

    function metaOf(uint reference_) public view virtual returns (
        address creator,
        string memory reason,
        uint snapshotId,
        uint startTimestamp,
        uint endTimestamp,
        uint timeout,
        uint quorum,
        uint quorumRequired,
        uint votesFor,
        uint votesAgainst,
        uint votesToAbstain,
        uint threshold
    ) {
        _mustBePresent(reference_);
        PublicVotedProposal storage proposal = publicVotedProposals[reference_];
        return (
            proposal.creator,
            proposal.reason,
            proposal.snapshotId,
            proposal.startTimestamp,
            proposal.endTimestamp,
            proposal.timeout,
            proposal.quorum,
            proposal.quorumRequired,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.votesToAbstain,
            proposal.threshold
        );
    }
    //get everyone who has voted on this proposal
    function votersOf(uint reference_) public view virtual returns (address[] memory) {
        _mustBePresent(reference_);
        return Utils.convertEnumerableSetAddressSetToArray(publicVotedProposals[reference_].voters);
    }
}