// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";
import "contracts/polygon/abstract/utils/LowLevelCall.sol";
import "contracts/polygon/abstract/utils/Tag.sol";
import "contracts/polygon/abstract/utils/Timer.sol";
import "contracts/polygon/abstract/utils/Payload.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/abstract/access-control/Ownable.sol";
import "contracts/polygon/abstract/utils/Initializable.sol";

abstract contract MultiSigProposal is 
    Storage, 
    Tag, 
    Payload, 
    Timer, 
    LowLevelCall,
    Initializable,
    Ownable {

    /**
    * @dev Importing and using EnumerableSet library for managing a set of addresses.
    * The `AddressSet` type is now equipped with useful set operations.
    */
    using EnumerableSet for EnumerableSet.AddressSet;

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
    event DataSet(bytes indexed data);

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
    function requiredQuorumKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REQUIRED_QUORUM"));
    }

    /**
    * @dev Returns the keccak256 hash of the string "SIGNERS".
    * This function is used to generate a unique key for managing a set of signers.
    * @return bytes32 The keccak256 hash of "SIGNERS".
    */
    function signersKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("SIGNERS"));
    }

    /**
    * @dev Returns the keccak256 hash of the string "SIGNATURES".
    * This function is used to generate a unique key for storing signatures related to a process or action.
    * @return bytes32 The keccak256 hash of "SIGNATURES".
    */
    function signaturesKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("SIGNATURES"));
    }

    /**
    * @dev Returns the keccak256 hash of the string "PASSED".
    * This function is used to generate a unique key for tracking the completion status of a specific action or step.
    * @return bytes32 The keccak256 hash of "PASSED".
    */
    function passedKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("PASSED"));
    }

    /**
    * @dev Returns the keccak256 hash of the string "EXECUTED".
    * This function is used to generate a unique key for tracking the execution status of a specific operation or task.
    * @return bytes32 The keccak256 hash of "EXECUTED".
    */
    function executedKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("EXECUTED"));
    }

    /**
    * @dev Retrieves the required quorum value from storage.
    * @return uint256 The current required quorum value.
    */
    function requiredQuorum() public view virtual returns (uint256) {
        return _uint256[requiredQuorumKey()];
    }

    /**
    * @dev Calculates the required number of signatures based on the quorum and the number of signers.
    * @return uint256 The current required number of signatures for a successful action.
    */
    function requiredSignaturesLength() public view virtual returns (uint256) {
        return (signersLength() * requiredQuorum()) / 10000;
    }

    /**
    * @dev Checks whether the number of collected signatures meets or exceeds the required threshold.
    * @return bool True if there are sufficient signatures, otherwise false.
    */
    function hasSufficientSignatures() public view virtual returns (bool) {
        return signaturesLength() >= requiredSignaturesLength();
    }

    /**
    * @dev Retrieves the address of a signer based on their unique identifier.
    * @param signerId The identifier of the signer.
    * @return address The address of the specified signer.
    */
    function signers(uint256 signerId) public view virtual returns (address) {
        return _addressSet[signersKey()].at(signerId);
    }

    /**
    * @dev Retrieves the total number of signers currently registered.
    * @return uint256 The current length of the signers set.
    */
    function signersLength() public view virtual returns (uint256) {
        return _addressSet[signersKey()].length();
    }

    /**
    * @dev Checks if an address is a registered signer.
    * @param account The address to check.
    * @return bool True if the address is a signer, otherwise false.
    */
    function isSigner(address account) public view virtual returns (bool) {
        return _addressSet[signersKey()].contains(account);
    }

    /**
    * @dev Retrieves the address of a signature based on its unique identifier.
    * @param signatureId The identifier of the signature.
    * @return address The address of the specified signature.
    */
    function signatures(uint256 signatureId) public view virtual returns (address) {
        return _addressSet[signaturesKey()].at(signatureId);
    }

    /**
    * @dev Retrieves the total number of signatures collected.
    * @return uint256 The current length of the signatures set.
    */
    function signaturesLength() public view virtual returns (uint256) {
        return _addressSet[signaturesKey()].length();
    }

    /**
    * @dev Checks if an address has already provided a signature.
    * @param account The address to check.
    * @return bool True if the address has signed, otherwise false.
    */
    function hasSigned(address account) public view virtual returns (bool) {
        return _addressSet[signaturesKey()].contains(account);
    }

    /**
    * @dev Checks if a specific action or step has been successfully passed.
    * @return bool True if the action or step has passed, otherwise false.
    */
    function passed() public view virtual returns (bool) {
        return _bool[passedKey()];
    }

    /**
    * @dev Checks if a specific operation or task has been successfully executed.
    * @return bool True if the operation or task has been executed, otherwise false.
    */
    function executed() public view virtual returns (bool) {
        return _bool[executedKey()];
    }

    /**
    * @dev Initializes the contract, setting up any initial configurations or values.
    * This function is typically called once, often during deployment.
    */
    function initialize() public virtual {
        _initialize();
    }

    /**
    * @dev Sets a new caption for the contract.
    * Only the owner has the privilege to update the caption.
    * @param caption The new caption to be set.
    */
    function setCaption(string memory caption) public virtual {
        _onlyOwner();
        _setCaption(caption);
    }

    /**
    * @dev Sets a new message for the contract.
    * Only the owner has the privilege to update the message.
    * @param message The new message to be set.
    */
    function setMessage(string memory message) public virtual {
        _onlyOwner();
        _setMessage(message);
    }

    /**
    * @dev Sets a new creator for the contract.
    * Only the owner has the privilege to update the creator address.
    * @param account The new creator address to be set.
    */
    function setCreator(address account) public virtual {
        _onlyOwner();
        _setCreator(account);
    }

    /**
    * @dev Sets a new target address for the contract.
    * Only the owner has the privilege to update the target address.
    * @param account The new target address to be set.
    */
    function setTarget(address account) public virtual {
        _onlyOwner();
        _setTarget(account);
    }

    /**
    * @dev Sets new data for the contract.
    * Only the owner has the privilege to update the data.
    * @param data The new data to be set.
    */
    function setData(bytes memory data) public virtual {
        _onlyOwner();
        _setData(data);
    }

    /**
    * @dev Sets a new start timestamp for the contract.
    * Only the owner has the privilege to update the start timestamp.
    * @param timestamp The new start timestamp to be set.
    */
    function setStartTimestamp(uint256 timestamp) public virtual {
        _onlyOwner();
        _setStartTimestamp(timestamp);
    }

    /**
    * @dev Sets a new duration in seconds for the contract.
    * Only the owner has the privilege to update the duration.
    * @param seconds_ The new duration in seconds to be set.
    */
    function setDuration(uint256 seconds_) public virtual {
        _onlyOwner();
        _setDuration(seconds_);
    }

    /**
    * @dev Sets a new required quorum in basis points for the contract.
    * Only the owner has the privilege to update the required quorum.
    * @param bp The new required quorum in basis points to be set.
    */
    function setRequiredQuorum(uint256 bp) public virtual {
        _onlyOwner();
        _setRequiredQuorum(bp);
    }

    /**
    * @dev Adds a new signer to the contract.
    * Only the owner has the privilege to add a new signer.
    * @param account The address of the new signer to be added.
    */
    function addSigner(address account) public virtual {
        _onlyOwner();
        _addSigner(account);
    }

    /**
    * @dev Signs the contract, indicating the sender's agreement or authorization.
    * This function is typically called by a signer to provide their signature.
    */
    function sign() public virtual {
        _sign();
    }

    /**
    * @dev Sets a new required quorum in basis points internally.
    * @param bp The new required quorum in basis points to be set.
    * @dev Reverts if the provided value is out of bounds (greater than 10000).
    */
    function _setRequiredQuorum(uint256 bp) internal virtual {
        require(bp <= 10000, "MultiSigProposal: out of bounds");
        _uint256[requiredQuorumKey()] = bp;
        emit RequiredQuorumSet(bp);
    }

    /**
    * @dev Ensures that the associated action can only be performed when it has passed.
    * @dev Reverts if the action has not passed.
    */
    function _onlyWhenPassed() internal view virtual {
        require(passed(), "MultiSigProposal: !passed()");
    }

    /**
    * @dev Ensures that the associated action can only be performed when it has not passed.
    * @dev Reverts if the action has already passed.
    */
    function _onlyWhenNotPassed() internal view virtual {
        require(!passed(), "MultiSigProposal: passed()");
    }

    /**
    * @dev Ensures that the associated action can only be performed when it has been executed.
    * @dev Reverts if the action has not been executed.
    */
    function _onlyWhenExecuted() internal view virtual {
        require(executed(), "MultiSigProposal: !executed()");
    }

    /**
    * @dev Ensures that the associated action can only be performed when it has not been executed.
    * @dev Reverts if the action has already been executed.
    */
    function _onlyWhenNotExecuted() internal view virtual {
        require(!executed(), "MultiSigProposal: executed()");
    }

    /**
    * @dev Ensures that the associated action can only be performed before the start timestamp.
    * @dev Reverts if the current timestamp indicates that the action has already started.
    */
    function _onlyBeforeStart() internal view virtual {
        require(!started(), "MultiSigProposal: started()");
    }

    /**
    * @dev Ensures that the associated action can only be performed when it is not timed out.
    * @dev Reverts if the action has reached the timeout condition.
    */
    function _onlyWhenNotTimedout() internal view virtual {
        require(counting(), "MultiSigProposal: !counting()");
    }

    /**
    * @dev Initializes the contract, transferring ownership to the deployer.
    * Calls the initializer of the parent contract.
    */
    function _initialize() internal virtual override(Initializable, Ownable) {
        _transferOwnership(msg.sender);
        Ownable._initialize();
        Initializable._initialize();
    }

    /**
    * @dev Adds a new signer internally.
    * @param account The address of the new signer to be added.
    * @dev Reverts if the provided address is already a signer.
    */
    function _addSigner(address account) internal virtual {
        require(!isSigner(account), "MultiSigProposal: isSigner()");
        _addressSet[signersKey()].add(account);
        emit SignerAdded(account);
    }

    /**
    * @dev Handles the signing process internally.
    * Ensures that the action is not timed out, not passed, and not executed.
    * Requires the sender to be a signer and not to have signed already.
    * Adds the sender's address to the signatures set and triggers an update.
    * Emits a Signed event upon successful signing.
    */
    function _sign() internal virtual {
        _onlyWhenNotTimedout();
        _onlyWhenNotPassed();
        _onlyWhenNotExecuted();
        require(isSigner(msg.sender), "MultiSigProposal: !isSigner()");
        require(!hasSigned(msg.sender), "MultiSigProposal: hasSigned()");
        _addressSet[signaturesKey()].add(msg.sender);
        _update();
        emit Signed(msg.sender);
    }

    /**
    * @dev Handles the execution process internally.
    * Ensures that the action is not timed out, has passed, and not executed.
    * Marks the action as executed and emits an Executed event.
    */
    function _execute() internal virtual {
        _onlyWhenNotTimedout();
        _onlyWhenPassed();
        _onlyWhenNotExecuted();
        _bool[executedKey()] = true;
        emit Executed();
    }

    /**
    * @dev Handles the execution process internally with a low-level call.
    * Ensures that the action is not timed out, has passed, and not executed.
    * Marks the action as executed, emits an Executed event, and performs a low-level call.
    * @return bytes The result of the low-level call.
    */
    function _executeWithLowLevelCall() internal virtual returns (bytes memory) {
        _execute();
        return _lowLevelCall(target(), data());
    }

    /**
    * @dev Updates the contract state internally based on collected signatures.
    * If there are sufficient signatures, marks the action as passed and emits a Passed event.
    */
    function _update() internal virtual {
        if (hasSufficientSignatures()) {
            _bool[passedKey()] = true;
            emit Passed();
        }
    }

    /**
    * @dev Sets a new caption for the contract internally.
    * Calls the parent implementation to update the caption and emits a CaptionSet event.
    * @param caption The new caption to be set.
    */
    function _setCaption(string memory caption) internal virtual override {
        super._setCaption(caption);
        emit CaptionSet(caption);
    }

    /**
    * @dev Sets a new message for the contract internally.
    * Calls the parent implementation to update the message and emits a MessageSet event.
    * @param message The new message to be set.
    */
    function _setMessage(string memory message) internal virtual override {
        super._setMessage(message);
        emit MessageSet(message);
    }

    /**
    * @dev Sets a new creator for the contract internally.
    * Calls the parent implementation to update the creator address and emits a CreatorSet event.
    * @param account The new creator address to be set.
    */
    function _setCreator(address account) internal virtual override {
        super._setCreator(account);
        emit CreatorSet(account);
    }

    /**
    * @dev Sets a new target address for the contract internally.
    * Calls the parent implementation to update the target address and emits a TargetSet event.
    * @param account The new target address to be set.
    */
    function _setTarget(address account) internal virtual override {
        super._setTarget(account);
        emit TargetSet(account);
    }

    /**
    * @dev Sets new data for the contract internally.
    * Calls the parent implementation to update the data and emits a DataSet event.
    * @param data The new data to be set.
    */
    function _setData(bytes memory data) internal virtual override {
        super._setData(data);
        emit DataSet(data);
    }

    /**
    * @dev Sets a new start timestamp for the contract internally.
    * Calls the parent implementation to update the start timestamp and emits a StartTimestampSet event.
    * @param timestamp The new start timestamp to be set.
    */
    function _setStartTimestamp(uint256 timestamp) internal virtual override {
        super._setStartTimestamp(timestamp);
        emit StartTimestampSet(timestamp);
    }

    /**
    * @dev Sets a new duration in seconds for the contract internally.
    * Calls the parent implementation to update the duration and emits a DurationSet event.
    * @param seconds_ The new duration in seconds to be set.
    */
    function _setDuration(uint256 seconds_) internal virtual override {
        super._setDuration(seconds_);
        emit DurationSet(seconds_);
    }
}