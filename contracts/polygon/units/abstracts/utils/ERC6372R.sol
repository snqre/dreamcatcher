// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* @title ERC-6372 Contract Clock.
*
* https://eips.ethereum.org/EIPS/eip-6372.
*
* ABSTRACT Many contracts rely on some clock for enforcing delays and storing
*          historical data. While some contracts rely on block numbers, others
*          use timestamps. There is currently no easy way to discover which
*          time-tracking function a contract internally uses. This EIP
*          proposes to standardize an interface for contracts to expore their
*          internal clock and thus improve composability and interoperability.
 */
abstract contract ERC6372R {
    
    /**
    * @dev Compliant contracts MUST implement the { clock } and { CLOCK_MODE }
    *      functions.
    *
    * @dev This function returns the current timepoint according to the mode
    *      the contract is operating on. It MUST be a non-decreasing
    *      function of the chain, such as { block.timestamp } or
    *      { block.number }.
     */
    function clock() public view virtual returns (uint48);

    /**
    * @dev This function returns a machine-readable string description of the
    *      clock the contract is operating on.
    *
    * @dev This string MUST be formatted like a URL query string ie.
    *      { application/x-www-form-urlencoded }, decodable in standard
    *      JavaScript with { new URLSearchParams(CLOCK_MODE) }.
    *
    *       If operating using block number:
    *
    *           If the block number is that of the { NUMBER } opcode { 0x43 },
    *           then this function MUST return { mode=blocknumber&from=default }.
    *
    *           If it is any other block number, then this function MUST return
    *           { mode=blocknumber&from=<CAIP-2-ID> }, where { <CAIP-2-ID> } is
    *           a CAIP-2 Blockchain ID such as { eip115:1 }.
    *
    *       If operating using timestamp, then this function MUST return
    *       { mode=timestamp }.
    *
    *       If operating using any other mode, then this function SHOULD return
    *       a unique identifier for the encoded { mode } field.
     */
    function CLOCK_MODE() public view virtual returns (string memory);
}