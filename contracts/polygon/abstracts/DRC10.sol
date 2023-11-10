// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* @title DRC-10 Standard Proposal.
*
* ABSTRACT This specification defines standard functions for a
*          proposal.
*
*          There are not set standards in terms of onchain proposals
*          so we had to build one.
 */
abstract contract DRC10 {

    /**
    * @dev This emits when a new vote is cast.
     */
    event VoteCasted(address indexed voter, uint8 indexed side, uint indexed weight);

    /**
    * @dev This is a caption or name given to the proposal which can be
    *      used to identify it. This should be descriptive and
    *      informative.
     */
    function name() public view virtual returns (string memory);

    /**
    * @dev The address of the account that created the proposal.
     */
    function creator() public view virtual returns (address);

    /**
    * @dev The governance model understands that outside sources will
    *      be used for the sake of communication but does not expect
    *      this to be present. Its important to have these open means
    *      of reading and communicating onchain to be fully censorship
    *      resistant.
     */
    function note() public view virtual returns (string memory);

    /**
    * @dev The address that the proposal is requesting to call,
    *      this can be the governor itself, for instance if
    *      the governor wants to upgrade itself it needs to
    *      call itself.
     */
    function target() public view virtual returns (address);

    /**
    * @dev This contains the function selector, and arguments for
    *      the call. It's important to add the arguments used to
    *      encode this as bytes in the note section. If the arguments
    *      are not present and transparent the proposal should be
    *      looked at with suspicion. It's important to decode
    *      and check what data is being passed.
     */
    function data() public view virtual returns (bytes memory);

    /**
    * @dev When the call has been executed it will return the response
    *      which can be checked.
     */
    function response() public view virtual returns (bytes memory);

    /**
    * @dev This indicates the timestamp of when the proposal was started
    *      by the creator. Once in session, voting will be permitted
    *      until the closing or ending of the proposal. Once the proposal
    *      has ended and if it has matched the required criteria,
    *      it can be executed, if it doesnt then it will never be
    *      able to be executed.
     */
    function startTimestamp() public view virtual returns (uint);

    /**
    * @dev The duration is how long the session will last for.
     */
    function duration() public view virtual returns (uint);

    function endTimestamp() public view virtual returns (uint);

    function opened() public view virtual returns (bool);

    function closed() public view virtual returns (bool);

    function inSession() public view virtual returns (bool);

    function secondsLeft() public view virtual returns (uint);

    /**
    * @dev The threshold is the current % of quorum which is support
    *      side vote casts. This is calculated in basis points ie.
    *      100% is 10000.
     */
    function threshold() public view virtual returns (uint);

    /**
    * @dev The total weight or amount of tokens that have been used
    *      to vote on the proposal.
     */
    function quorum() public view virtual returns (uint);

    /**
    * @dev The total weight or amount of tokens that have been casted
    *      as being in support of the proposal. If the vote was supported
    *      the account's reputation score will be rewarded if the
    *      proposal is executed.
     */
    function support() public view virtual returns (uint);

    /**
    * @dev The total weight or amount of tokens that have been casted
    *      as being against fo the proposal. If the vote was against
    *      the account's reputation score will be rewarded if the
    *      proposal is closed and has not been executed.
     */
    function against() public view virtual returns (uint);

    /**
    * @dev The total weight or amount of tokens that have been casted
    *      as being abstaining from the proposal. This is important
    *      as engagement within the proposal is also important. Abstaining
    *      also counts towards negating the execution of the proposal.
    *      It is however to grant this option as the reputation system
    *      will reward accounts with a base rate for engaging in the
    *      governance process.
     */
    function abstain() public view virtual returns (uint);

    function executed() public view virtual returns (bool);

    function requiredQuorum() public view virtual returns (uint);

    function requiredThreshold() public view virtual returns (uint);

    function token() public view virtual returns (address);

    function snapshotId() public view virtual returns (uint);

    function vote(uint8 side) public virtual;
}