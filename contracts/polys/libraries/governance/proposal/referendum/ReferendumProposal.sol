// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/libraries/shared/errors/Errors.sol";
import "contracts/polygon/interfaces/token/dream/IDream.sol";

library ReferendumProposal {

    struct Proposal {
        string _caption;
        string _message;
        address _creator;
        mapping(address => bool) _hasVoted;
        uint256 _startTimestamp;
        uint256 _duration;
        uint256 _support;
        uint256 _against;
        uint256 _abstain;
        uint256 _requiredQuorum;
        uint256 _requiredThreshold;
        uint256 _requiredMinBalanceToVote;
        address _votingERC20;
        uint256 _snapshotId;
        address _target;
        bytes _data;
        bool _hasBeenApproved;
        bool _hasBeenExecuted;
        bool _isTimed;
        bool _requireCallSuccess;
    }

    /** Caption */

    function caption(Proposal storage self) public view returns (string memory) {
        return self._caption;
    }

    function setCaption(Proposal storage self, string memory text) public {
        self._caption = text;
    }

    /** Message */

    function message(Proposal storage self) public view returns (string memory) {
        return self._message;
    }

    function setMessage(Proposal storage self, string memory text) public {
        self._message = text;
    }

    /** Creator */

    function creator(Proposal storage self) public view returns (address) {
        return self._creator;
    }

    function setCreator(Proposal storage self, address account) public {
        self._creator = account;
    }

    /** Has Voted */

    function hasVoted(Proposal storage self, address account) public view returns (bool) {
        return self._hasVoted[account];
    }

    function setHasVoted(Proposal storage self, address account, bool boolean) public {
        self._hasVoted[account] = boolean;
    }

    /** StartTimestamp */

    function startTimestamp(Proposal storage self) public view returns (uint256) {
        return self._startTimestamp;
    }

    function setStartTimestamp(Proposal storage self, uint256 timestamp) public {
        self._startTimestamp = timestamp;
    }

    function increaseStartTimestamp(Proposal storage self, uint256 seconds_) public {
        self._startTimestamp += seconds_;
    }

    function decreaseStartTimestamp(Proposal storage self, uint256 seconds_) public {
        self._startTimestamp -= seconds_;
    }

    /** EndTimestamp */

    function endTimestamp(Proposal storage self) public view returns (uint256) {
        return startTimestamp({self: self}) + duration({self: self});
    }

    /** Duration */

    function duration(Proposal storage self) public view returns (uint256) {
        return self._duration;
    }

    function setDuration(Proposal storage self, uint256 seconds_) public {
        self._duration = seconds_;
    }

    function increaseDuration(Proposal storage self, uint256 seconds_) public {
        self._duration += seconds_;
    }

    function decreaseDuration(Proposal storage self, uint256 seconds_) public {
        self._duration -= seconds_;
    }

    /** Support */

    function support(Proposal storage self) public view returns (uint256) {
        return self._support;
    }

    function increaseSupport(Proposal storage self, uint256 amount) public {
        self._support += amount;
    }

    /** Against */

    function against(Proposal storage self) public view returns (uint256) {
        return self._against;
    }

    function increaseAgainst(Proposal storage self, uint256 amount) public {
        self._against += amount;
    }

    /** Abstain */

    function abstain(Proposal storage self) public view returns (uint256) {
        return self._abstain;
    }

    function increaseAbstain(Proposal storage self, uint256 amount) public {
        self._abstain += amount;
    }

    /** Required Quorum */

    function requiredQuorum(Proposal storage self) public view returns (uint256) {
        return self._requiredQuorum;
    }

    function setRequiredQuorum(Proposal storage self, uint256 bp) public {
        if (bp > 10_000) {
            revert Errors.OutOfBounds({min: 0, max: 10_000, value: bp});
        }
        self._requiredQuorum = bp;
    }

    /** Quorum */

    function quorum(Proposal storage self) public view returns (uint256) {
        return support({self: self}) + against({self: self}) + abstain({self: self});
    }

    function requiredNumberOfQuorum(Proposal storage self) public view returns (uint256) {
        IDream votingERC20 = IDream(votingERC20({self: self}));
        uint256 totalSupplyAt = votingERC20.totalSupplyAt(snapshotId({self: self}));
        return (totalSupplyAt * requiredQuorum({self: self})) / 10_000;
    }

    function hasSufficientQuorum(Proposal storage self) public view returns (bool) {
        return quorum({self: self}) >= requiredNumberOfQuorum({self: self});
    }

    /** Required Threshold */

    function requiredThreshold(Proposal storage self) public view returns (uint256) {
        return self._requiredThreshold;
    }

    function setRequiredThreshold(Proposal storage self, uint256 bp) public {
        if (bp > 10_000) {
            revert Errors.OutOfBounds({min: 0, max: 10_000, value: bp});
        }
        self._requiredThreshold = bp;
    }

    /** Threshold */

    function threshold(Proposal storage self) public view returns (uint256) {
        return (support({self: self}) * 10_000) / quorum({self: self});
    }

    function hasSufficientThreshold(Proposal storage self) public view returns (bool) {
        return threshold({self: self}) >= requiredThreshold({self: self});
    }

    /** Required Min Balance To Vote */

    function requiredMinBalanceToVote(Proposal storage self) public view returns (uint256) {
        return self._requiredMinBalanceToVote;
    }

    function setRequiredMinBalanceToVote(Proposal storage self, uint256 amount) public {
        IDream erc20 = IDream(votingERC20({self: self}));
        totalSupplyAt = erc20.totalSupplyAt(snapshotId({self: self}));
        if (amount > totalSupplyAt) {
            revert Errors.MinBalanceCannotBeLargerThanTotalSupply();
        }
        self._requiredMinBalanceToVote = amount;
    }

    /** Has Sufficient Balance To Vote */

    function hasSufficientBalanceToVote(Proposal storage self, address account) public view returns (bool) {
        IDream erc20 = IDream(votingERC20({self: self}));
        uint256 balance = erc20.balanceOfAt({account: account, snapshotId: snapshotId({self: self})});
        return balance >= requiredMinBalanceToVote({self: self});
    }

    /** Voting ERC20 */

    function votingERC20(Proposal storage self) public view returns (address) {
        return self._votingERC20;
    }

    function setVotingERC20(Proposal storage self, address erc20) public {
        self._votingERC20 = erc20;
    }

    /** Snapshot Id */

    function snapshotId(Proposal storage self) public view returns (uint256) {
        return self._snapshotId;
    }

    function snapshot(Proposal storage self) public {
        IDream erc20 = IDream(votingERC20({self: self}));
        self._snapshotId = erc20.snapshot();
    }

    /** Target */

    function target(Proposal storage self) public view returns (address) {
        return self._target;
    }

    function setTarget(Proposal storage self, address account) public {
        self._target = account;
    }

    /** Data */

    function data(Proposal storage self) public view returns (bytes memory) {
        return self._data;
    }

    function setData(Proposal storage self, bytes memory dat) public {
        self._data = dat;
    }

    /** Has Been Approved */

    function hasBeenApproved(Proposal storage self) public view returns (bool) {
        return self._hasBeenApproved;
    }

    /** Has Been Executed */

    function hasBeenExecuted(Proposal storage self) public view returns (bool) {
        return self._hasBeenExecuted;
    }

    /** Is Timed */

    function isTimed(Proposal storage self) public view returns (bool) {
        return self._isTimed;
    }

    function setTimed(Proposal storage self, bool boolean) public {
        self._isTimed = boolean;
    }

    /** Require Call Success */

    function requireCallSuccess(Proposal storage self) public view returns (bool) {
        return self._requireCallSuccess;
    }

    function setRequireCallSuccess(Proposal storage self, bool boolean) public {
        self._requireCallSuccess = boolean;
    }

    /** Flags */

    function onlyApproved(Proposal storage self) public view {
        if (!hasBeenApproved({self: self})) {
            revert Errors.HasNotBeenApproved();
        }
    }

    function onlynotExecuted(Proposal storage self) public view {
        if (hasBeenExecuted({self: self})) {
            revert Errors.HasAlreadyBeenExecuted();
        }
    }

    function vote(Proposal storage self, uint256 side) public {
        IDream erc20 = IDream(votingERC20({self: self}));
        uint256 balance = erc20.balanceOfAt({account: msg.sender, snapshotId: snapshotId({self: self})});
        if (!hasSufficientBalanceToVote({self: self, account: msg.sender})) {
            revert Errors.InsufficientBalanceToVote();
        }
        if (hasVoted({self: self, account: msg.sender})) {
            revert Errors.HasAlreadyVoted({account: msg.sender});
        }
        if (side == 0) {
            increaseAbstain({self: self, amount: balance});
        }
        else if (side == 1) {
            increaseAgainst({self: self, amount: balance});
        }
        else if (side == 2) {
            increaseSupport({self: self, amount: balance});
        }
        else {
            revert Errors.OutOfBounds({min: 0, max: 2, value: side});
        }
    }

    function update(Proposal storage self) public {
        if (hasSufficientQuorum({self: self}) && hasSufficientThreshold({self: self})) {
            self._hasBeenApproved = true;
        }
    }

    function execute(Proposal storage self) public {
        onlyApproved({self: self});
        onlynotExecuted({self: self});
        self._hasBeenExecuted = true;
    }

    function executeWithLowLevelCall(Proposal storage self) public returns (bytes memory) {
        onlyApproved({self: self});
        onlynotExecuted({self: self});
        (bool success, bytes memory response)
        = address(target({self: self}))
        .call(data({self: self}));
        if (requireCallSuccess({self: self})) {
            if (!success) {
                revert Errors.FailedLowLevelCall({target: target({self: self}), data: data({self: self})});
            }
        }
        self._hasBeenExecuted = true;
        return response;
    }
}