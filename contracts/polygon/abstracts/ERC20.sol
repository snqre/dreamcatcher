// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* @title ERC-20 Token Standard.
*
* https://eips.ethereum.org/EIPS/eip-20.
*
* ABSTRACT The following standard allows for the implementation of a standard
*          API for tokens within smart contracts. This standard provides basic
*          functionality to transfer tokens, as well as allow tokens to be
*          approved so they can be spent by another on-chain third party.
 */
abstract contract ERC20 {

    /**
    * MUST Trigger when tokens are transferred, including zero value transfers.
    *
    * @dev A token contract which creates new tokens SHOULD trigger a Transfer
    *      event with the { from } address set to { 0x0 } when tokens are
    *      created.
     */
    event Transfer(address indexed from, address indexed to, uint value);

    /**
    * MUST Trigger on any successful call to { approve(address spender, uint value) }.
     */
    event Approval(address indexed owner, address indexed spender, uint value);

    /**
    * @return The name of the token ie. "MyToken".
    *
    * OPTIONAL This method can be used to improve usability, but interfaces
    *          and other contracts MUST NOT expect these values to be
    *          present.
     */
    function name() public view virtual returns (string memory);

    /**
    * @return The symbol of the token ie. "HIX".
    *
    * OPTIONAL This method can be used to improve usability, but interfaces
    *          and other contracts MUST NOT expect these values to be
    *          present.
     */
    function symbol() public view virtual returns (string memory);

    /**
    * @return The number of decimals the token uses ie. 8, means to divide
    *         the token amount by 100000000 to get its user representation.
    *
    * OPTIONAL This method can be used to improve usability, but interfaces
    *          and other contracts MUST NOT expect these values to be
    *          present.
     */
    function decimals() public view virtual returns (uint8);

    /**
    * @return The total token supply.
     */
    function totalSupply() public view virtual returns (uint);

    /**
    * @return The account balance of another account with address { owner }.
     */
    function balanceOf(address owner) public view virtual returns (uint);

    /**
    * @dev Transfers { value } amount of tokens to address { to }, and MUST
    *      fire the { Transfer } event. The function SHOULD { throw } if
    *      the message caller's account balance does not have enough
    *      tokens to spend.
    *
    * NOTE Transfers of 0 values must be treated as normal transfers and
    *      fire the { Transfer } event.
     */
    function transfer(address to, uint value) public virtual returns (bool);

    /**
    * @dev Transfers { value } amount of tokens from address { from } to address
    *      { to }, and MUST fire the { Transfer } event.
    *
    * @dev The { transferFrom } method is used for a withdraw workflow, allowing
    *      contracts to transfer tokens on your behalf. This can be used for
    *      example to allow a contract to transfer tokens on your behalf and/or
    *      to charge fees in sub-currencies. The function SHOULD { throw }
    *      unless the { from } account has deliberately authorized the sender
    *      of the message via some mechanism.
    *
    * NOTE Transfers of 0 values MUST be treated as normal transfers and
    *      fire the { Transfer } event.
     */
    function transferFrom(address from, address to, uint value) public virtual returns (bool);

    /**
    * @dev Allows { spender } to withdraw from your account multiple times,
    *      up to the { value } amount. If this function is called again it
    *      overwrites the current allowance with { value }.
    *
    * NOTE To prevent attack vectors like the ones linked below, clients
    *      SHOULD make sure to create user interfaces in such a way that they
    *      set the allowance first to 0 before setting it to another value
    *      for the same spender. THOUGH The contract itself shouldn't enforce
    *      it, to allow backwards compatibility with contracts deployed before.
    *
    * https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit?pli=1#heading=h.m9fhqynw2xvt
    *
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     */
    function approve(address spender, uint value) public virtual returns (bool);

    /**
    * @return The amount which { spender } is still allowed to withdraw from
    *         { owner }.
     */
    function allowance(address owner, address spender) public view virtual returns (uint);
}