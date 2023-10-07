// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/interfaces/IProposalV1.sol";

interface IProposalUpgradeToV1 is IProposalV1 {

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
    * @dev Retrieves the Ethereum address of the proxy contract associated with this proposal.
    * 
    * @return The Ethereum address of the proxy contract.
    */
    function proxyAddress() external view returns (address);

    /**
    * @dev Retrieves the Ethereum address of the proposed implementation contract for upgrades.
    * 
    * @return The Ethereum address of the proposed implementation contract.
    */
    function proposedImplementation() external view returns (address);
}