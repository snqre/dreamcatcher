// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* @title ERC-2612 Permit Extension for EIP-20 Signed Approvals.
*
* https://eips.ethereum.org/EIPS/eip-2612.
*
* ABSTRACT Arguably one of the main reasons for the success of EIP-20 tokens
*          lies in the interplay between { approve } and { transferFrom },
*          which allows for tokens to not only be transferred between
*          externally owned accounts (EOA), but to be used in other contracts
*          under application specific conditions by abstracting away
*          { msg.sender } as the defining mechanism for token access 
*          control.
*
*          However, a limiting factory in this design stems from the fact
*          that tthe EIP-20 { approve } function itself is defined in terms
*          of { msg.sender }. This means that user's initial action involving
*          EIP-20 tokens must be performed by an EOA. If the user needs to
*          interfact with a smart contract, then they need to make 2
*          transactions ({ approve } and the smart contract call which will
*          internally call { transferFrom }). Even in the simple use case of
*          paying another person, they need to hold ETH to pay for transaction
*          gas costs.
*
*          This ERC extends the EIP-20 standard with a new function { permit },
*          which allows users to modify the { allowance } mapping using a
*          signed message, instead of through { msg.sender }.
*
*          For an improved user experience, tthe signed data is structured
*          following EIP-712, which already has wide spread adoption in
*          mahor RPC providers.
*
* NOTE EIP-20 must be performed by an EOA unless the address owning the token
*      is actually a contract wallet. Although contract wallets solve many of
*      the same problems that motivate this EIP, they are currently only
*      scarcely adopted in the ecosystem. Contract wallets suffer from a UX
*      problem - since they separate the EOA { owner } of the contract wallet
*      from the contract wallet itself (which is meant to carry out actions
*      on the { owner }s behalf and holds all their funds), user interfaces
*      need to be specifically designed to support them. The { permit } pattern
*      reaps many of the same benefits while requiring little to no change in
*      user interfaces.
 */
abstract contract ERC2612 {

    /**
    * @dev A call to { permit(owner, spender, value, deadline, v, r, s) } will
    *      set { approval[owner][spender] } to { value }, increment
    *      { nonces[owner] } by 1, and emit a corresponding { Approval } event,
    *      if and only if the following conditions are met:
    *
    *           - The current blocktime is less than or equal to { deadline }.
    *           - { owner } is not the zero address.
    *           - { nonces[owner] } (before the state update) is equal to { nonce }.
    *           - { r }, { s } and { v } is a valid { secp256k1 } signature from
    *             { owner } of the message.
    *
    *      If any of these conditions are not met, the { permit } call must revert.
    *
    * keccak256(abi.encodePacked(
    *   hex"1901",
    *   DOMAIN_SEPARATOR,
    *   keccak256(abi.encode(
    *       keccak256("Permit(address owner, address spender, uint256 value, uint256 nonce, uint256 deadline)"),
    *       owner,
    *       spender,
    *       value,
    *       nonce,
    *       deadline
    *   ))
    * ));
    *
    * @dev Where { DOMAIN_SEPARATOR } is defined according to EIP-712. The 
    *      { DOMAIN_SEPARATOR } should be unique to the contract and chain to
    *      prevent replay attacks from other domains, and satisfy the
    *      requirements of EIP-712, but is otherwise unconstained.
    *      A common choice for { DOMAIN_SEPARATOR } is:
    *
    * DOMAIN_SEPARATOR = keccak256(
    *   abi.encode(
    *       keccak256("EIP712Domain(string name, string version, uint256 chainId, address verifyingContract)"),
    *       keccak256(bytes(name)),
    *       keccak256(bytes(version)),
    *       chainid,
    *       address(this) 
    * ));
    *
    * NOTE That nowhere in this definition we refer to { msg.sender }. The caller
    *      of the { permit } function can be any address.
    *
    * # Security Considerations.
    *
    * @dev Though the signer of a { permit } may have a certain party in mind to
    *      submit their transaction, another party can always front run this
    *      transaction and call { permit } before the intended party.
    *      The end result is the same for the { Permit } signer.
    *
    * @dev However, since the ecrecover precompile fails silently and just
    *      returns the zero address as { signer } when given malformed
    *      messages, it is important to ensure { owner != address(0) } to
    *      avoid { permit } from creating an approval to spend "zombie funds"
    *      belong to the zero address.
    *
    * @dev Signed { Permit } messages are censorable. The relaying party can
    *      always choose to not submit the { Permit } after having received
    *      it, withholding the option to submit it. The { deadline } parameter
    *      is one mitigation to this. If the signing party holds ETH they can
    *      also just submit the { Permit } themselves, which can render
    *      previously signed { Permit }s invalid.
    *
    * @dev The standard EIP-20 race condition for approvals (SWC-114) applies
    *      to { permit } as well.
    *
    * @dev If the { DOMAIN_SEPARATOR } contains the { chainId } and is defined
    *      at contract deployment instead of reconstructed for every signature,
    *      there is a risk of possible replay attacks between chains in the
    *      event of a future chain split.
     */
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) public virtual;

    function nonces(address owner) public view virtual returns (uint);

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32);
}