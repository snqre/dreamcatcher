// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";
import "contracts/polygon/abstract/utils/LowLevelCall.sol";
import "contracts/polygon/abstract/utils/Tag.sol";
import "contracts/polygon/abstract/utils/Timer.sol";
import "contracts/polygon/abstract/utils/Payload.sol";
import "contracts/polygon/abstract/access-control/Ownable.sol";
import "contracts/polygon/abstract/utils/Initializable.sol";
import "contracts/polygon/interfaces/token/dream/IDream.sol";

abstract contract ReferendumProposal is 
    Storage,
    Tag,
    Payload,
    Timer,
    LowLevelCall,
    Initializable,
    Ownable {

    /**
    * @param account The address that has voted.
    * @param amount The amount of votes they have dedicated to this side.
    */
    event SupportIncreased(address indexed account, uint256 indexed amount);

    /**
    * @param account The address that has voted.
    * @param amount The amount of votes they have dedicated to this side.
    */
    event AgainstIncreased(address indexed account, uint256 indexed amount);

    /**
    * @param account The address that has voted.
    * @param amount The amount of votes they have dedicated to this side.
    */
    event AbstainIncreased(address indexed account, uint256 indexed amount);

    /**
    * @dev Emitted when a proposal is marked as passed.
    */
    event Passed();

    /**
    * @dev Emitted when a proposal is marked as executed.
    */
    event Executed();

    /**
    * @dev Emitted when the caption of a proposal is set.
    * @param caption The new caption for the proposal.
    */
    event CaptionSet(string indexed caption);

    /**
    * @dev Emitted when the message of a proposal is set.
    * @param message The new message for the proposal.
    */
    event MessageSet(string indexed message);

    /**
    * @dev Emitted when the creator of a proposal is set.
    * @param creator The address of the new creator for the proposal.
    */
    event CreatorSet(address indexed creator);

    /**
    * @dev Emitted when the target address of a proposal is set.
    * @param target The address of the new target for the proposal.
    */
    event TargetSet(address indexed target);

    /**
    * @dev Emitted when the data of a proposal is set.
    * @param data The new data for the proposal.
    */
    event DataSet(bytes indexed data);

    /**
    * @dev Emitted when the start timestamp of a proposal is set.
    * @param timestamp The new start timestamp for the proposal.
    */
    event StartTimestampSet(uint256 indexed timestamp);

    /**
    * @dev Emitted when the duration of a proposal is set.
    * @param seconds_ The new duration in seconds for the proposal.
    */
    event DurationSet(uint256 indexed seconds_);

    /**
    * @dev Emitted when the required quorum of a proposal is set.
    * @param bp The new required quorum as a basis point for the proposal.
    */
    event RequiredQuorumSet(uint256 indexed bp);

    /**
    * @dev Emitted when the required threshold of a proposal is set.
    * @param bp The new required threshold as a basis point for the proposal.
    */
    event RequiredThresholdSet(uint256 indexed bp);

    /**
    * @dev Emitted when a snapshot is taken for a specific ID.
    * @param id The index or identifier of the snapshot.
    */
    event SnapshotTaken(uint256 indexed id);

    /**
    * @dev Emitted when the Voting ERC20 address is set.
    * @param erc20 The address of the new Voting ERC20 contract.
    */
    event VotingERC20Set(address indexed erc20);

    /**
    * @dev Returns the keccak256 hash key for accessing the required quorum in storage.
    * @return bytes32 The keccak256 hash key for the required quorum.
    */
    function requiredQuorumKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REQUIRED_QUORUM"));
    }

    /**
    * @dev Returns the keccak256 hash key for accessing the required threshold in storage.
    * @return bytes32 The keccak256 hash key for the required threshold.
    */
    function requiredThresholdKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REQUIRED_THRESHOLD"));
    }

    /**
    * @dev Returns the keccak256 hash key for accessing the snapshot ID in storage.
    * @return bytes32 The keccak256 hash key for the snapshot ID.
    */
    function snapshotIdKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("SNAPSHOT_ID"));
    }

    /**
    * @dev Returns the keccak256 hash key for accessing the Voting ERC20 address in storage.
    * @return bytes32 The keccak256 hash key for the Voting ERC20 address.
    */
    function votingERC20Key() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("VOTING_ERC20"));
    }

    /**
    * @dev Returns the keccak256 hash key for accessing the support in storage.
    * @return bytes32 The keccak256 hash key for the support.
    */
    function supportKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("SUPPORT"));
    }

    /**
    * @dev Returns the keccak256 hash key for accessing the against votes in storage.
    * @return bytes32 The keccak256 hash key for the against votes.
    */
    function againstKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("AGAINST"));
    }

    /**
    * @dev Returns the keccak256 hash key for accessing the abstain votes in storage.
    * @return bytes32 The keccak256 hash key for the abstain votes.
    */
    function abstainKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("ABSTAIN"));
    }

    /**
    * @dev Returns the keccak256 hash key for accessing the "passed" status in storage.
    * @return bytes32 The keccak256 hash key for the "passed" status.
    */
    function passedKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("PASSED"));
    }

    /**
    * @dev Returns the keccak256 hash key for accessing the "executed" status in storage.
    * @return bytes32 The keccak256 hash key for the "executed" status.
    */
    function executedKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("EXECUTED"));
    }

    /**
    * @dev Gets the current required quorum for proposals.
    * @return uint256 The required quorum as a basis point.
    */
    function requiredQuorum() public view virtual returns (uint256) {
        return _uint256[requiredQuorumKey()];
    }

    /**
    * @dev Gets the current required threshold for proposals.
    * @return uint256 The required threshold as a basis point.
    */
    function requiredThreshold() public view virtual returns (uint256) {
        return _uint256[requiredThresholdKey()];
    }

    /**
    * @dev Gets the current snapshot ID.
    * @return uint256 The current snapshot ID.
    */
    function snapshotId() public view virtual returns (uint256) {
        return _uint256[snapshotIdKey()];
    }

    /**
    * @dev Gets the current address of the Voting ERC20 contract.
    * @return address The address of the Voting ERC20 contract.
    */
    function votingERC20() public view virtual returns (address) {
        return _address[votingERC20Key()];
    }

    /**
    * @dev Gets the current support for a proposal.
    * @return uint256 The current support value.
    */
    function support() public view virtual returns (uint256) {
        return _uint256[supportKey()];
    }

    /**
    * @dev Gets the current against votes for a proposal.
    * @return uint256 The current against votes value.
    */
    function against() public view virtual returns (uint256) {
        return _uint256[againstKey()];
    }

    /**
    * @dev Gets the current abstain votes for a proposal.
    * @return uint256 The current abstain votes value.
    */
    function abstain() public view virtual returns (uint256) {
        return _uint256[abstainKey()];
    }

    /**
    * @dev Calculates the total quorum by summing up the support, against, and abstain votes.
    * @return uint256 The total quorum.
    */
    function quorum() public view virtual returns (uint256) {
        return support() + against() + abstain();
    }

    /**
    * @dev Calculates the required quorum number based on the total supply at a snapshot and the required quorum percentage.
    * @return uint256 The required quorum number.
    */
    function requiredQuorumNumber() public view virtual returns (uint256) {
        IDream erc20 = IDream(votingERC20());
        uint256 totalSupplyAt = erc20.totalSupplyAt(snapshotId());
        return (totalSupplyAt * requiredQuorum()) / 10000;
    }

    /**
    * @dev Checks if the current quorum is sufficient, comparing it to the required quorum number.
    * @return bool True if there is sufficient quorum, false otherwise.
    */
    function sufficientQuorum() public view virtual returns (bool) {
        return quorum() >= requiredQuorumNumber();
    }

    /**
    * @dev Calculates the threshold by expressing the support as a percentage of the total quorum.
    * @return uint256 The threshold value.
    */
    function threshold() public view virtual returns (uint256) {
        return (support() * 10000) / quorum();
    }

    /**
    * @dev Checks if the current threshold is sufficient, comparing it to the required threshold.
    * @return bool True if there is sufficient threshold, false otherwise.
    */
    function sufficientThreshold() public view virtual returns (bool) {
        return threshold() >= requiredThreshold();
    }

    /**
    * @dev Checks if the proposal has passed.
    * @return bool True if the proposal has passed, false otherwise.
    */
    function passed() public view virtual returns (bool) {
        return _bool[passedKey()];
    }

    /**
    * @dev Checks if the proposal has been executed.
    * @return bool True if the proposal has been executed, false otherwise.
    */
    function executed() public view virtual returns (bool) {
        return _bool[executedKey()];
    }

    /**
    * @dev Initializes the contract. Should be called only once during deployment.
    */
    function initialize() public virtual {
        _initialize();
    }

    /**
    * @dev Sets the caption of the proposal.
    * @param caption The new caption to be set.
    */
    function setCaption(string memory caption) public virtual {
        _onlyOwner();
        _setCaption(caption);
    }

    /**
    * @dev Sets the message of the proposal.
    * @param message The new message to be set.
    */
    function setMessage(string memory message) public virtual {
        _onlyOwner();
        _setMessage(message);
    }

    /**
    * @dev Sets the creator of the proposal.
    * @param account The address of the new creator.
    */
    function setCreator(address account) public virtual {
        _onlyOwner();
        _setCreator(account);
    }

    /**
    * @dev Sets the target address of the proposal.
    * @param account The new target address.
    */
    function setTarget(address account) public virtual {
        _onlyOwner();
        _setTarget(account);
    }

    /**
    * @dev Sets the data of the proposal.
    * @param data The new data to be set.
    */
    function setData(bytes memory data) public virtual {
        _onlyOwner();
        _setData(data);
    }

    /**
    * @dev Sets the start timestamp of the proposal.
    * @param timestamp The new start timestamp.
    */
    function setStartTimestamp(uint256 timestamp) public virtual {
        _onlyOwner();
        _setStartTimestamp(timestamp);
    }

    /**
    * @dev Sets the duration of the proposal in seconds.
    * @param seconds_ The new duration in seconds.
    */
    function setDuration(uint256 seconds_) public virtual {
        _onlyOwner();
        _setDuration(seconds_);
    }

    /**
    * @dev Sets the required quorum percentage for the proposal.
    * @param bp The new required quorum percentage (basis points).
    */
    function setRequiredQuorum(uint256 bp) public virtual {
        _onlyOwner();
        _setRequiredQuorum(bp);
    }

    /**
    * @dev Sets the required threshold percentage for the proposal.
    * @param bp The new required threshold percentage (basis points).
    */
    function setRequiredThreshold(uint256 bp) public virtual {
        _onlyOwner();
        _setRequiredThreshold(bp);
    }

    /**
    * @dev Takes a snapshot of the voting ERC20 balances and supply.
    * Only the owner can trigger a snapshot.
    */
    function snapshot() public virtual {
        _onlyOwner();
        _snapshot();
    }

    /**
    * @dev Sets the ERC20 token used for voting in the proposal.
    * @param erc20 The address of the ERC20 token contract.
    */
    function setVotingERC20(address erc20) public virtual {
        _onlyOwner();
        _setVotingERC20(erc20);
    }

    /**
    * @dev Casts a vote for the specified side in the proposal.
    * @param side The side to vote for (0: Abstain, 1: Against, 2: Support).
    */
    function vote(uint256 side) public virtual {
        _vote(side);
    }

    /**
    * @dev Modifier to ensure that the condition is met only when the proposal has passed.
    * Reverts if the proposal has not passed.
    */
    function _onlyWhenPassed() internal view virtual {
        require(passed(), "ReferendumProposal: !passed()");
    }

    /**
    * @dev Modifier to ensure that the condition is met only when the proposal has not passed.
    * Reverts if the proposal has passed.
    */
    function _onlyWhenNotPassed() internal view virtual {
        require(!passed(), "ReferendumProposal: passed()");
    }

    /**
    * @dev Modifier to ensure that the condition is met only when the proposal has been executed.
    * Reverts if the proposal has not been executed.
    */
    function _onlyWhenExecuted() internal view virtual {
        require(executed(), "ReferendumProposal: !executed()");
    }

    /**
    * @dev Modifier to ensure that the condition is met only when the proposal has not been executed.
    * Reverts if the proposal has been executed.
    */
    function _onlyWhenNotExecuted() internal view virtual {
        require(!executed(), "ReferendumProposal: executed()");
    }

    /**
    * @dev Modifier to ensure that the condition is met only before the proposal starts.
    * Reverts if the proposal has already started.
    */
    function _onlyBeforeStart() internal view virtual {
        require(!started(), "ReferendumProposal: started()");
    }

    /**
    * @dev Modifier to ensure that the condition is met only when the proposal is not timed out.
    * Reverts if the proposal is timed out.
    */
    function _onlyWhenNotTimedout() internal view virtual {
        require(counting(), "ReferendumProposal: !counting()");
    }

    /**
    * @dev Internal function to initialize the contract.
    * It transfers ownership to the deployer and calls the base class's initialization.
    */
    function _initialize() internal virtual override(Initializable, Ownable) {
        _transferOwnership(msg.sender);
        Ownable._initialize();
        Initializable._initialize();
    }

    /**
    * @dev Internal function for users to cast their votes on the referendum proposal.
    * It ensures that the proposal is not timed out, not passed, and not executed before accepting votes.
    * Increases the vote count for the specified side based on the user's balance at the snapshot.
    * Updates the proposal status after the vote.
    * @param side The side of the vote (0 for Abstain, 1 for Against, 2 for Support).
    * revert If the input side is unsupported.
    */
    function _vote(uint256 side) internal virtual {
        _onlyWhenNotTimedout();
        _onlyWhenNotPassed();
        _onlyWhenNotExecuted();
        uint256 amount = IDream(votingERC20()).balanceOfAt(msg.sender, snapshotId());
        if (side == 0) {
            _increaseAbstain(amount);
        }
        else if (side == 1) {
            _increaseAgainst(amount);
        }
        else if (side == 2) {
            _increaseSupport(amount);
        }
        else {
            revert("ReferendumProposal: unsupported input");
        }
        _update();
    }

    /**
    * @dev Internal function to execute the referendum proposal.
    * It ensures that the proposal is not timed out, has passed, and has not been executed before proceeding.
    * Sets the executed state to true and emits the Executed event.
    */
    function _execute() internal virtual {
        _onlyWhenNotTimedout();
        _onlyWhenPassed();
        _onlyWhenNotExecuted();
        _bool[executedKey()] = true;
        emit Executed();
    }

    /**
    * @dev Internal function to execute the referendum proposal with a low-level call.
    * It first executes the proposal using the standard `_execute` function.
    * Then, it performs a low-level call to the target contract with the provided data.
    * This function is used for more complex execution scenarios.
    * @return The result of the low-level call (if any).
    */
    function _executeWithLowLevelCall() internal virtual returns (bytes memory) {
        _execute();
        return _lowLevelCall(target(), data());
    }

    /**
    * @dev Internal function to update the status of the referendum proposal.
    * Checks if the current votes meet both the required quorum and threshold.
    * If satisfied, sets the passed state to true and emits the Passed event.
    */
    function _update() internal virtual {
        if (sufficientQuorum() && sufficientThreshold()) {
            _bool[passedKey()] = true;
            emit Passed();
        }
    }

    /**
    * @dev Internal function to set the caption of the referendum proposal.
    * Calls the parent implementation to update the caption and emits the CaptionSet event with the new caption.
    * @param caption The new caption for the proposal.
    */
    function _setCaption(string memory caption) internal virtual override {
        super._setCaption(caption);
        emit CaptionSet(caption);
    }

    /**
    * @dev Internal function to set the message of the referendum proposal.
    * Calls the parent implementation to update the message and emits the MessageSet event with the new message.
    * @param message The new message for the proposal.
    */
    function _setMessage(string memory message) internal virtual override {
        super._setMessage(message);
        emit MessageSet(message);
    }

    /**
    * @dev Internal function to set the creator of the referendum proposal.
    * Calls the parent implementation to update the creator and emits the CreatorSet event with the new creator address.
    * @param account The address of the new creator for the proposal.
    */
    function _setCreator(address account) internal virtual override {
        super._setCreator(account);
        emit CreatorSet(account);
    }

    /**
    * @dev Internal function to set the target address of the referendum proposal.
    * Calls the parent implementation to update the target and emits the TargetSet event with the new target address.
    * @param account The new target address for the proposal.
    */
    function _setTarget(address account) internal virtual override {
        super._setTarget(account);
        emit TargetSet(account);
    }

    /**
    * @dev Internal function to set additional data for the referendum proposal.
    * Calls the parent implementation to update the data and emits the DataSet event with the new data.
    * @param data The new data to be associated with the proposal.
    */
    function _setData(bytes memory data) internal virtual override {
        super._setData(data);
        emit DataSet(data);
    }

    /**
    * @dev Internal function to set the start timestamp of the referendum proposal.
    * Calls the parent implementation to update the start timestamp and emits the StartTimestampSet event with the new timestamp.
    * @param timestamp The new start timestamp for the proposal.
    */
    function _setStartTimestamp(uint256 timestamp) internal virtual override {
        super._setStartTimestamp(timestamp);
        emit StartTimestampSet(timestamp);
    }

    /**
    * @dev Internal function to set the duration of the referendum proposal.
    * Calls the parent implementation to update the duration and emits the DurationSet event with the new duration.
    * @param seconds_ The new duration, in seconds, for the proposal.
    */
    function _setDuration(uint256 seconds_) internal virtual override {
        super._setDuration(seconds_);
        emit DurationSet(seconds_);
    }

    /**
    * @dev Internal function to set the required quorum for the referendum proposal.
    * Requires the input quorum percentage to be within the bounds [0, 10000].
    * Sets the required quorum in the storage and emits the RequiredQuorumSet event with the new quorum value.
    * @param bp The new quorum percentage, represented in basis points (0 to 10000).
    */
    function _setRequiredQuorum(uint256 bp) internal virtual {
        require(bp <= 10000, "ReferendumProposal: out of bounds");
        _uint256[requiredQuorumKey()] = bp;
        emit RequiredQuorumSet(bp);
    }

    /**
    * @dev Internal function to set the required threshold for the referendum proposal.
    * Requires the input threshold percentage to be within the bounds [0, 10000].
    * Sets the required threshold in the storage and emits the RequiredThresholdSet event with the new threshold value.
    * @param bp The new threshold percentage, represented in basis points (0 to 10000).
    */
    function _setRequiredThreshold(uint256 bp) internal virtual {
        require(bp <= 10000, "ReferendumProposal: out of bounds");
        _uint256[requiredThresholdKey()] = bp;
        emit RequiredThresholdSet(bp);
    }

    /**
    * @dev Internal function to take a snapshot of the voting ERC20 token's state.
    * Calls the `snapshot` function of the voting ERC20 token and stores the resulting snapshot ID.
    * Emits the SnapshotTaken event with the new snapshot ID.
    */
    function _snapshot() internal virtual {
        _uint256[snapshotIdKey()] = IDream(votingERC20()).snapshot();
        emit SnapshotTaken(_uint256[snapshotIdKey()]);
    }

    /**
    * @dev Internal function to set the address of the ERC20 token used for voting.
    * Updates the stored ERC20 token address and emits the VotingERC20Set event.
    * @param erc20 The address of the ERC20 token to be set for voting.
    */
    function _setVotingERC20(address erc20) internal virtual {
        _address[votingERC20Key()] = erc20;
        emit VotingERC20Set(erc20);
    }

    /**
    * @dev Internal function to increase the support for the proposal.
    * Increases the support by the specified `amount` and emits the SupportIncreased event.
    * @param amount The amount by which to increase the support for the proposal.
    */
    function _increaseSupport(uint256 amount) internal virtual {
        _uint256[supportKey()] += amount;
        emit SupportIncreased(msg.sender, amount);
    }

    /**
    * @dev Internal function to increase the opposition against the proposal.
    * Increases the opposition by the specified `amount` and emits the AgainstIncreased event.
    * @param amount The amount by which to increase the opposition against the proposal.
    */
    function _increaseAgainst(uint256 amount) internal virtual {
        _uint256[againstKey()] += amount;
        emit AgainstIncreased(msg.sender, amount);
    }

    /**
    * @dev Internal function to increase the abstention count for the proposal.
    * Increases the abstention count by the specified `amount` and emits the AbstainIncreased event.
    * @param amount The amount by which to increase the abstention count.
    */
    function _increaseAbstain(uint256 amount) internal virtual {
        _uint256[abstainKey()] += amount;
        emit AbstainIncreased(msg.sender, amount);
    }
}