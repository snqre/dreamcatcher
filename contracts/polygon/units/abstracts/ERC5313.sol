// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* @title ERC-5313 Light Contract Ownership.
*
* https://eips.ethereum.org/EIPS/eip-5313.
*
* ABSTRACT This specification defines the minimum interface required to
*          identify an account that controls a contract.
 */
abstract contract ERC5313 {
    
    /**
    * @notice Get the address of the owner.
    * @return The address of the owner.
    *
    * # Security Considerations
    *
    * @dev Because this specification does not extend EIP-165, calling this
    *      EIP's { owner } function cannot result in complete certainty that
    *      the result is indeed the owner. For example, another function with
    *      the same function signature may return some value that is then
    *      interpreted to be the true owner. If this EIP is used solely to
    *      identify if an account is the owner of a contract, then the impact
    *      of this risk is minimized. But if the interrogator is, for example,
    *      sending a valuable NFT to the identified owner of any contract on
    *      the network, then the risk is heightened.
     */
    function owner() public view virtual returns (address);
}