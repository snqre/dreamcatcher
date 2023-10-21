// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* @title ERC-6357 Single-contract Multi-delegatecall.
*
* https://eips.ethereum.org/EIPS/eip-6357.
*
* ABSTRACT This EIP standardizes an interface containing a single function,
*          { multicall }, allowing EOAs to call multiple functions of a
*          smart contract in a single transaction, and revert all calls
*          if any call fails.
 */
abstract contract ERC6357R {

    /**
    * @notice Takes an array of abi-encoded call data, delegatecalls itself
    *         with each calldata, and returns the abi-encoded result.
    *
    * @dev Reverts if any delegatecall reverts.
    *
    * @param data The abi-encoded data.
    *
    * @return results The abi-encoded return values.
     */
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory) {
        bytes[] memory results;
        results = new bytes[](data.length);
        for (uint i = 0; i < data.length; i++) {
            (bool success, bytes memory returndata) = address(this).delegatecall(data[i]);
            require(success);
            results[i] = returndata;
        }
        return results;
    }

    /**
    * OPTIONAL Takes an array of abi-encoded call data, delegatecalls itself
    *          with each calldata, and returns the abi-encoded result.
    *
    * @dev Reverts if any delegatecall reverts.
    *
    * @param data The abi-encoded data.
    * 
    * @param values The effective msg.values. These must add up to at most msg.value.
    *
    * @return results The abi-encoded return values.
    *
    * # Security Considerations
    *
    * @dev { multicallPayable } should only be used if the contract is able to
    *      support it. A naive attempt at implementing it could allow an
    *      attacker to call a payable function multiple times with the same
    *      ether.
     */
    function multicallPayable(bytes[] calldata data, uint[] memory values) external payable virtual returns (bytes[] memory);
}