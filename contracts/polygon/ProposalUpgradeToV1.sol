// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/ProposalV1.sol";
import "contracts/polygon/interfaces/ITerminalV2.sol";
import "contracts/polygon/libraries/__Shared.sol";

contract ProposalUpgradeToV1 is ProposalV1 {
    
    /**
    * @dev Private variable storing the address of the proxy contract associated with this contract.
    * 
    * This variable holds the Ethereum address of the proxy contract used for proxy-based upgrades or interactions.
    * It is marked as private to encapsulate the proxy-related functionality and is not directly accessible externally.
    */
    address private _proxyAddress;

    /**
    * @dev Private variable storing the address of the proposed implementation contract for upgrades.
    * 
    * This variable holds the Ethereum address of the proposed implementation contract,
    * which may be used for upgrading the functionality of the contract through a proxy-based upgrade mechanism.
    * It is marked as private to encapsulate the upgrade-related functionality and is not directly accessible externally.
    */
    address private _proposedImplementation;
    
    /**
    * @dev Emitted when the Ethereum address of the proxy contract associated with this proposal is set or updated.
    * 
    * @param account The Ethereum address set as the new proxy address.
    */
    event ProxyAddressSetTo(address indexed account);

    /**
    * @dev Emitted when the Ethereum address of the proposed implementation contract for upgrades is set or updated.
    * 
    * @param account The Ethereum address set as the new proposed implementation contract.
    */
    event ProposedImplementationSetTo(address indexed account);

    /**
    * @dev Initializes a new ProposalV1 contract with the specified parameters.
    * @param args The ProposalUpgradeToV1Args struct containing the necessary parameters:
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
    * @dev Inherits from ProposalV1 and Ownable contracts.
    * @dev Sets the initial proxy address and proposed implementation for the proposal.
    */
    constructor(ProposalUpgradeToV1Args memory args) 
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
        _setProxyAddress(args.proxyAddress);
        _setProposedImplementation(args.proposedImplementation);
    }

    /**
    * @dev Retrieves the Ethereum address of the proxy contract associated with this proposal.
    * 
    * @return The Ethereum address of the proxy contract.
    */
    function proxyAddress() public view returns (address) {
        return _proxyAddress;
    }

    /**
    * @dev Retrieves the Ethereum address of the proposed implementation contract for upgrades.
    * 
    * @return The Ethereum address of the proposed implementation contract.
    */
    function proposedImplementation() public view returns (address) {
        return _proposedImplementation;
    }

    /**
    * @dev Internal function to execute the proposal, upgrading the TerminalV2 to the proposed implementation.
    * @dev It calls the `upgradeTo` function on the TerminalV2 contract with the specified proxy address and proposed implementation.
    * @dev Overrides the base implementation in the ProposalV1 contract.
    * @dev Calls the parent _execute function to handle additional execution steps.
    */
    function _execute() internal override {
        ITerminalV2(terminalV2()).upgradeTo(proxyAddress(), proposedImplementation());
        super._execute();
    }

    /**
    * @dev Internal function to set the Ethereum address of the proxy contract associated with this proposal.
    * 
    * @param account The Ethereum address to set as the new proxy address.
    */
    function _setProxyAddress(address account) internal {
        _proxyAddress = account;
        emit ProxyAddressSetTo(account);
    }

    /**
    * @dev Internal function to set the Ethereum address of the proposed implementation contract for upgrades.
    * 
    * @param account The Ethereum address to set as the new proposed implementation contract.
    */
    function _setProposedImplementation(address account) internal {
        _proposedImplementation = account;
        emit ProposedImplementationSetTo(account);
    }
}