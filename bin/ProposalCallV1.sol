// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/ProposalV1.sol";
import "contracts/polygon/interfaces/ITerminalV2.sol";
import "contracts/polygon/libraries/__Shared.sol";

contract ProposalCallV1 is ProposalV1 {

    /**
    * @dev Private variable to store the target address.
    * @dev It represents the address that the contract interacts with or tracks internally.
    */
    address private _target;

    /**
    * @dev Private variable to store a string representing a signature.
    * @dev It is used to hold a signature related to the contract's functionality or state.
    */
    string private _signature;

    /**
    * @dev Private variable to store binary data (bytes) representing additional arguments.
    * @dev It is used to hold additional parameters or information in binary format.
    */
    bytes private _args;

    /**
    * @dev Emitted when the target address is set to a new value.
    * @param account The address that the contract's target is set to.
    * @dev The `indexed` keyword is used for efficient event filtering based on the specified address.
    */
    event TargetSetTo(address indexed account);

    /**
    * @dev Emitted when the signature is set to a new value.
    * @param signature The string representing the new signature set in the contract.
    * @dev The `indexed` keyword is used for efficient event filtering based on the specified signature.
    */
    event SignatureSetTo(string indexed signature);

    /**
    * @dev Emitted when the arguments are set to a new value.
    * @param args The binary data (bytes) representing the new arguments set in the contract.
    * @dev The `indexed` keyword is used for efficient event filtering based on the specified arguments.
    */
    event ArgsSetTo(bytes indexed args);

    /**
    * @dev Initializes a new ProposalCallV1 contract with the specified parameters.
    * @param args The ProposalCallV1Args struct containing the necessary parameters:
    *   - caption: A brief description or title for the proposal.
    *   - message: The detailed content or purpose of the proposal.
    *   - creator: The address of the creator/initiator of the proposal.
    *   - mSigDuration: Duration (in seconds) for the Meta Signature (mSig) phase of the proposal.
    *   - pSigDuration: Duration (in seconds) for the Proxy Signature (pSig) phase of the proposal.
    *   - timelockDuration: Duration (in seconds) for the overall timelock period of the proposal.
    *   - signers: An array of addresses representing the signers involved in the proposal.
    *   - mSigRequiredQuorum: The minimum Meta Signature quorum required for approval.
    *   - pSigRequiredQuorum: The minimum Proxy Signature quorum required for approval.
    *   - threshold: The overall approval threshold for the proposal.
    *   - target: The target address for the proposal execution.
    *   - signature: The signature associated with the proposal.
    *   - args: Binary data (bytes) representing additional arguments for the proposal.
    * @dev Inherits from ProposalV1 and Ownable contracts.
    * @dev Sets the initial target address, signature, and arguments for the proposal.
    */
    constructor(ProposalCallV1Args memory args) 
    ProposalV1(
        args.caption,
        args.message,
        args.creator,
        args.mSigDuration,
        args.pSigDuration,
        args.timelockDuration,
        args.signers,
        args.mSigRequiredQuorum,
        args.pSigRequiredQuorum,
        args.threshold
    ) Ownable(terminalV2()) {
        _setTarget(args.target);
        _setSignature(args.signature);
        _setArgs(args.args);
    }

    /**
    * @dev Public function to retrieve the current target address.
    * @return The current target address stored in the contract.
    */
    function target() public view returns (address) {
        return _target;
    }

    /**
    * @dev Public function to retrieve the current signature.
    * @return The current signature stored in the contract as a string.
    */
    function signature() public view returns (string memory) {
        return _signature;
    }

    /**
    * @dev Public function to retrieve the current arguments.
    * @return The current arguments stored in the contract as binary data (bytes).
    */
    function args() public view returns (bytes memory) {
        return _args;
    }

    /**
    * @dev Internal function to execute the proposal by making a call to the TerminalV2 contract.
    * @dev Calls the `call` function on the TerminalV2 contract with the specified target address, signature, and arguments.
    * @dev Overrides the base implementation in the ProposalV1 contract.
    * @dev Calls the parent _execute function to handle additional execution steps.
    */
    function _execute() internal override {
        ITerminalV2(terminalV2()).call(target(), signature(), args());
        super._execute();
    }

    /**
    * @dev Internal function to set the target address.
    * @param account The new target address to be set.
    * @dev Updates the internal state with the new target address and emits the TargetSetTo event.
    */
    function _setTarget(address account) internal {
        _target = account;
        TargetSetTo(account);
    }

    /**
    * @dev Internal function to set the signature.
    * @param signature The new signature to be set.
    * @dev Updates the internal state with the new signature and emits the SignatureSetTo event.
    */
    function _setSignature(string memory signature) internal {
        _signature = signature;
        SignatureSetTo(signature);
    }

    /**
    * @dev Internal function to set the arguments.
    * @param args The new arguments to be set.
    * @dev Updates the internal state with the new arguments and emits the ArgsSetTo event.
    */
    function _setArgs(bytes memory args) internal {
        _args = args;
        ArgsSetTo(args);
    }
}