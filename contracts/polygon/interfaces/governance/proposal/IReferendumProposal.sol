// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/utils/ILowLevelCall.sol";
import "contracts/polygon/interfaces/utils/ITag.sol";
import "contracts/polygon/interfaces/utils/ITimer.sol";
import "contracts/polygon/interfaces/utils/IPayload.sol";
import "contracts/polygon/interfaces/access-control/IOwnable.sol";
import "contracts/polygon/interfaces/utils/IInitializable.sol";

interface IReferendumProposal is 
    ITag,
    IPayload,
    ITimer,
    ILowLevelCall,
    IInitializable,
    IOwnable {

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
    event DataSet(address indexed data);

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
    function requiredQuorumKey() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash key for accessing the required threshold in storage.
    * @return bytes32 The keccak256 hash key for the required threshold.
    */
    function requiredThresholdKey() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash key for accessing the snapshot ID in storage.
    * @return bytes32 The keccak256 hash key for the snapshot ID.
    */
    function snapshotIdKey() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash key for accessing the Voting ERC20 address in storage.
    * @return bytes32 The keccak256 hash key for the Voting ERC20 address.
    */
    function votingERC20Key() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash key for accessing the support in storage.
    * @return bytes32 The keccak256 hash key for the support.
    */
    function supportKey() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash key for accessing the against votes in storage.
    * @return bytes32 The keccak256 hash key for the against votes.
    */
    function againstKey() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash key for accessing the abstain votes in storage.
    * @return bytes32 The keccak256 hash key for the abstain votes.
    */
    function abstainKey() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash key for accessing the "passed" status in storage.
    * @return bytes32 The keccak256 hash key for the "passed" status.
    */
    function passedKey() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash key for accessing the "executed" status in storage.
    * @return bytes32 The keccak256 hash key for the "executed" status.
    */
    function executedKey() external pure returns (bytes32);

    /**
    * @dev Gets the current required quorum for proposals.
    * @return uint256 The required quorum as a basis point.
    */
    function requiredQuorum() external view returns (uint256);

    /**
    * @dev Gets the current required threshold for proposals.
    * @return uint256 The required threshold as a basis point.
    */
    function requiredThreshold() external view returns (uint256);

    /**
    * @dev Gets the current snapshot ID.
    * @return uint256 The current snapshot ID.
    */
    function snapshotId() external view returns (uint256);

    /**
    * @dev Gets the current address of the Voting ERC20 contract.
    * @return address The address of the Voting ERC20 contract.
    */
    function votingERC20() external view returns (address);

    /**
    * @dev Gets the current support for a proposal.
    * @return uint256 The current support value.
    */
    function support() external view returns (uint256);

    /**
    * @dev Gets the current against votes for a proposal.
    * @return uint256 The current against votes value.
    */
    function against() external view returns (uint256);

    /**
    * @dev Gets the current abstain votes for a proposal.
    * @return uint256 The current abstain votes value.
    */
    function abstain() external view returns (uint256);

    /**
    * @dev Calculates the total quorum by summing up the support, against, and abstain votes.
    * @return uint256 The total quorum.
    */
    function quorum() external view returns (uint256);

    /**
    * @dev Calculates the required quorum number based on the total supply at a snapshot and the required quorum percentage.
    * @return uint256 The required quorum number.
    */
    function requiredQuorumNumber() external view returns (uint256);

    /**
    * @dev Checks if the current quorum is sufficient, comparing it to the required quorum number.
    * @return bool True if there is sufficient quorum, false otherwise.
    */
    function sufficientQuorum() external view returns (bool);

    /**
    * @dev Calculates the threshold by expressing the support as a percentage of the total quorum.
    * @return uint256 The threshold value.
    */
    function threshold() external view returns (uint256);

    /**
    * @dev Checks if the current threshold is sufficient, comparing it to the required threshold.
    * @return bool True if there is sufficient threshold, false otherwise.
    */
    function sufficientThreshold() external view returns (bool);

    /**
    * @dev Checks if the proposal has passed.
    * @return bool True if the proposal has passed, false otherwise.
    */
    function passed() external view returns (bool);

    /**
    * @dev Checks if the proposal has been executed.
    * @return bool True if the proposal has been executed, false otherwise.
    */
    function executed() external view returns (bool);

    /**
    * @dev Initializes the contract. Should be called only once during deployment.
    */
    function initialize() external;

    /**
    * @dev Sets the caption of the proposal.
    * @param caption The new caption to be set.
    */
    function setCaption(string memory caption) external;

    /**
    * @dev Sets the message of the proposal.
    * @param message The new message to be set.
    */
    function setMessage(string memory message) external;

    /**
    * @dev Sets the creator of the proposal.
    * @param account The address of the new creator.
    */
    function setCreator(address account) external;

    /**
    * @dev Sets the target address of the proposal.
    * @param account The new target address.
    */
    function setTarget(address account) external;

    /**
    * @dev Sets the data of the proposal.
    * @param data The new data to be set.
    */
    function setData(bytes memory data) external;

    /**
    * @dev Sets the start timestamp of the proposal.
    * @param timestamp The new start timestamp.
    */
    function setStartTimestamp(uint256 timestamp) external;

    /**
    * @dev Sets the duration of the proposal in seconds.
    * @param seconds_ The new duration in seconds.
    */
    function setDuration(uint256 seconds_) external;

    /**
    * @dev Sets the required quorum percentage for the proposal.
    * @param bp The new required quorum percentage (basis points).
    */
    function setRequiredQuorum(uint256 bp) external;

    /**
    * @dev Sets the required threshold percentage for the proposal.
    * @param bp The new required threshold percentage (basis points).
    */
    function setRequiredThreshold(uint256 bp) external;

    /**
    * @dev Takes a snapshot of the voting ERC20 balances and supply.
    * Only the owner can trigger a snapshot.
    */
    function snapshot() external;

    /**
    * @dev Sets the ERC20 token used for voting in the proposal.
    * @param erc20 The address of the ERC20 token contract.
    */
    function setVotingERC20(address erc20) external;

    /**
    * @dev Casts a vote for the specified side in the proposal.
    * @param side The side to vote for (0: Abstain, 1: Against, 2: Support).
    */
    function vote(uint256 side) external;
}