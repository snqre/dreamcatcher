// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/ProposalV1.sol";
import "contracts/polygon/interfaces/ITerminalV1.sol";

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
    * @dev Private variable storing the Ethereum address of the TerminalV2 contract.
    * 
    * This variable holds the Ethereum address of the TerminalV2 contract, which may be used for various functionalities
    * or interactions within this contract. It is marked as private to encapsulate internal functionality and is not directly
    * accessible externally.
    */
    address private _terminalV2;
    
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
    event ProposedImplementation(address indexed account);

    /**
    * @dev Emitted when the Ethereum address of the TerminalV2 contract associated with this proposal is set or updated.
    * 
    * @param account The Ethereum address set as the new TerminalV2 contract.
    */
    event TerminalV2(address indexed account);

    /**
    * @dev Constructor for initializing a new instance of the contract.
    * 
    * Initializes the ProposalV2 contract with the provided parameters and sets additional attributes,
    * such as the proxy address, proposed implementation, and the TerminalV2 contract address.
    * 
    * @param caption The caption for the proposal metadata.
    * @param message The message for the proposal metadata.
    * @param creator The address of the creator of the proposal.
    * @param mSigDuration The duration of the Multi-Signature (MSig) phase.
    * @param pSigDuration The duration of the Public Signature (PSig) phase.
    * @param timelockDuration The duration of the Timelock phase.
    * @param signers An array of addresses representing signers for the proposal.
    * @param mSigRequiredQuorum The required quorum percentage for the MSig phase.
    * @param pSigRequiredQuorum The required quorum percentage for the PSig phase.
    * @param threshold The threshold for passing the proposal.
    * @param proxyAddress The address of the proxy contract associated with this proposal.
    * @param proposedImplementation The address of the proposed implementation contract for upgrades.
    */
    constructor(
        string memory caption,
        string memory message,
        address creator,
        uint64 mSigDuration,
        uint64 pSigDuration,
        uint64 timelockDuration,
        address[] memory signers,
        uint256 mSigRequiredQuorum,
        uint256 pSigRequiredQuorum,
        uint256 threshold,
        address proxyAddress,
        address proposedImplementation
    ) ProposalV1(
        caption,
        message,
        creator,
        mSigDuration,
        pSigDuration,
        timelockDuration,
        signers,
        mSigRequiredQuorum,
        pSigRequiredQuorum,
        threshold
    ) Ownable(msg.sender) {
        _setProxyAddress(proxyAddress);
        _setProposedImplementation(proposedImplementation);
        _setTerminalV2(0xd59431E364531e9f627c4B8065Ed13b62326810b);
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
    * @dev Retrieves the Ethereum address of the TerminalV2 contract associated with this proposal.
    * 
    * @return The Ethereum address of the TerminalV2 contract.
    */
    function terminalV2() public view returns (address) {
        return _terminalV2;
    }

    /**
    * @dev Internal function to execute the proposal after it has passed and the timelock is over.
    * 
    * Calls the `upgradeTo` function on TerminalV2 to upgrade the proxy contract to the proposed implementation.
    * Additionally, it invokes the superclass's `_execute` function to handle any additional execution logic.
    * 
    * @override Must be implemented by subclasses to define the specific actions to be taken upon execution.
    *
    * NOTE The upgrade does not directly upgrade the Terminal. Only proxies the Terminal controls.
    */
    function _execute() internal override {
        ITerminalV2(_terminalV2).upgradeTo(proxyAddress(), proposedImplementation());
        super._execute();
    }

    /**
    * @dev Internal function to set the Ethereum address of the proxy contract associated with this proposal.
    * 
    * @param account The Ethereum address to set as the new proxy address.
    */
    function _setProxyAddress(address account) internal {
        _proxyAddress = account;
    }

    /**
    * @dev Internal function to set the Ethereum address of the proposed implementation contract for upgrades.
    * 
    * @param account The Ethereum address to set as the new proposed implementation contract.
    */
    function _setProposedImplementation(address account) internal {
        _proposedImplementation = account;
    }

    /**
    * @dev Internal function to set the Ethereum address of the TerminalV2 contract associated with this proposal.
    * 
    * @param account The Ethereum address to set as the new TerminalV2 contract.
    */
    function _setTerminalV2(address account) internal {
        _terminalV2 = account;
    }
}