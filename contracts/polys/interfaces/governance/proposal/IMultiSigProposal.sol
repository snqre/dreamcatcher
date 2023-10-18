// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/utils/ITag.sol";
import "contracts/polygon/interfaces/utils/IPayload.sol";
import "contracts/polygon/interfaces/utils/ITimer.sol";
import "contracts/polygon/interfaces/utils/ILowLevelCall.sol";
import "contracts/polygon/interfaces/utils/IInitializable.sol";
import "contracts/polygon/interfaces/access-control/IOwnable.sol";

interface IMultiSigProposal is
    ITag,
    IPayload,
    ITimer,
    ILowLevelCall,
    IInitializable,
    IOwnable {

    /**
    * @dev Emitted when a new signer is added.
    * @param signer The address of the added signer. Indexed for efficient log filtering.
    */
    event SignerAdded(address indexed signer);

    /**
    * @dev Emitted when a signing action occurs.
    * @param signer The address of the signer. Indexed for efficient log filtering.
    */
    event Signed(address indexed signer);

    /**
    * @dev Emitted when a condition or step is successfully passed.
    * This event signifies the successful completion of a specific action or checkpoint.
    */
    event Passed();

    /**
    * @dev Emitted when an execution or operation is successfully completed.
    * This event signals the successful execution of a particular functionality or task.
    */
    event Executed();

    /**
    * @dev Emitted when a caption is set.
    * @param caption The string representing the new caption. Indexed for efficient log filtering.
    */
    event CaptionSet(string indexed caption);

    /**
    * @dev Emitted when a message is set.
    * @param message The string representing the new message. Indexed for efficient log filtering.
    */
    event MessageSet(string indexed message);

    /**
    * @dev Emitted when the creator address is set.
    * @param creator The address of the newly set creator. Indexed for efficient log filtering.
    */
    event CreatorSet(address indexed creator);

    /**
    * @dev Emitted when the target address is set.
    * @param target The address of the newly set target. Indexed for efficient log filtering.
    */
    event TargetSet(address indexed target);

    /**
    * @dev Emitted when a data address is set.
    * @param data The address of the newly set data. Indexed for efficient log filtering.
    */
    event DataSet(address indexed data);

    /**
    * @dev Emitted when the start timestamp is set.
    * @param timestamp The uint256 representing the newly set start timestamp. Indexed for efficient log filtering.
    */
    event StartTimestampSet(uint256 indexed timestamp);

    /**
    * @dev Emitted when the duration in seconds is set.
    * @param seconds_ The uint256 representing the newly set duration in seconds. Indexed for efficient log filtering.
    */
    event DurationSet(uint256 indexed seconds_);

    /**
    * @dev Emitted when the required quorum is set.
    * @param bp The uint256 representing the newly set quorum in basis points. Indexed for efficient log filtering.
    */
    event RequiredQuorumSet(uint256 indexed bp);

    /**
    * @dev Returns the keccak256 hash of the string "REQUIRED_QUORUM".
    * This function is used to generate a unique key for accessing the required quorum value.
    * @return bytes32 The keccak256 hash of "REQUIRED_QUORUM".
    */
    function requiredQuorumKey() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash of the string "SIGNERS".
    * This function is used to generate a unique key for managing a set of signers.
    * @return bytes32 The keccak256 hash of "SIGNERS".
    */
    function signersKey() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash of the string "SIGNATURES".
    * This function is used to generate a unique key for storing signatures related to a process or action.
    * @return bytes32 The keccak256 hash of "SIGNATURES".
    */
    function signaturesKey() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash of the string "PASSED".
    * This function is used to generate a unique key for tracking the completion status of a specific action or step.
    * @return bytes32 The keccak256 hash of "PASSED".
    */
    function passedKey() external pure returns (bytes32);

    /**
    * @dev Returns the keccak256 hash of the string "EXECUTED".
    * This function is used to generate a unique key for tracking the execution status of a specific operation or task.
    * @return bytes32 The keccak256 hash of "EXECUTED".
    */
    function executedKey() external pure returns (bytes32);

    /**
    * @dev Retrieves the required quorum value from storage.
    * @return uint256 The current required quorum value.
    */
    function requiredQuorum() external view returns (uint256);

    /**
    * @dev Calculates the required number of signatures based on the quorum and the number of signers.
    * @return uint256 The current required number of signatures for a successful action.
    */
    function requiredSignaturesLength() external view returns (uint256);

    /**
    * @dev Checks whether the number of collected signatures meets or exceeds the required threshold.
    * @return bool True if there are sufficient signatures, otherwise false.
    */
    function hasSufficientSignatures() external view returns (bool);

    /**
    * @dev Retrieves the address of a signer based on their unique identifier.
    * @param signerId The identifier of the signer.
    * @return address The address of the specified signer.
    */
    function signers(uint256 signerId) external view returns (address);

    /**
    * @dev Retrieves the total number of signers currently registered.
    * @return uint256 The current length of the signers set.
    */
    function signersLength() external view returns (uint256);

    /**
    * @dev Checks if an address is a registered signer.
    * @param account The address to check.
    * @return bool True if the address is a signer, otherwise false.
    */
    function isSigner(address account) external view returns (bool);

    /**
    * @dev Retrieves the address of a signature based on its unique identifier.
    * @param signatureId The identifier of the signature.
    * @return address The address of the specified signature.
    */
    function signatures(uint256 signatureId) external view returns (address);

    /**
    * @dev Retrieves the total number of signatures collected.
    * @return uint256 The current length of the signatures set.
    */
    function signaturesLength() external view returns (uint256);

    /**
    * @dev Checks if an address has already provided a signature.
    * @param account The address to check.
    * @return bool True if the address has signed, otherwise false.
    */
    function hasSigned(address account) external view returns (bool);

    /**
    * @dev Checks if a specific action or step has been successfully passed.
    * @return bool True if the action or step has passed, otherwise false.
    */
    function passed() external view returns (bool);

    /**
    * @dev Checks if a specific operation or task has been successfully executed.
    * @return bool True if the operation or task has been executed, otherwise false.
    */
    function executed() external view returns (bool);

    /**
    * @dev Initializes the contract, setting up any initial configurations or values.
    * This function is typically called once, often during deployment.
    */
    function initialize() external;

    /**
    * @dev Sets a new caption for the contract.
    * Only the owner has the privilege to update the caption.
    * @param caption The new caption to be set.
    */
    function setCaption(string memory caption) external;

    /**
    * @dev Sets a new message for the contract.
    * Only the owner has the privilege to update the message.
    * @param message The new message to be set.
    */
    function setMessage(string memory message) external;

    /**
    * @dev Sets a new creator for the contract.
    * Only the owner has the privilege to update the creator address.
    * @param account The new creator address to be set.
    */
    function setCreator(address account) external;

    /**
    * @dev Sets a new target address for the contract.
    * Only the owner has the privilege to update the target address.
    * @param account The new target address to be set.
    */
    function setTarget(address account) external;

    /**
    * @dev Sets new data for the contract.
    * Only the owner has the privilege to update the data.
    * @param data The new data to be set.
    */
    function setData(bytes memory data) external;

    /**
    * @dev Sets a new start timestamp for the contract.
    * Only the owner has the privilege to update the start timestamp.
    * @param timestamp The new start timestamp to be set.
    */
    function setStartTimestamp(uint256 timestamp) external;

    /**
    * @dev Sets a new duration in seconds for the contract.
    * Only the owner has the privilege to update the duration.
    * @param seconds_ The new duration in seconds to be set.
    */
    function setDuration(uint256 seconds_) external;

    /**
    * @dev Sets a new required quorum in basis points for the contract.
    * Only the owner has the privilege to update the required quorum.
    * @param bp The new required quorum in basis points to be set.
    */
    function setRequiredQuorum(uint256 bp) external;

    /**
    * @dev Adds a new signer to the contract.
    * Only the owner has the privilege to add a new signer.
    * @param account The address of the new signer to be added.
    */
    function addSigner(address account) external;

    /**
    * @dev Signs the contract, indicating the sender's agreement or authorization.
    * This function is typically called by a signer to provide their signature.
    */
    function sign() external;
}