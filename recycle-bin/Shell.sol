// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import 'contracts/polygon/Node.sol';

/**
* @dev The shell is meant to be inherited by the implementation. This is
*      built as an out of the box tool which will minimize the risk of
*      storage clashes as the shell's storage is directly inherited
*      by the node. It also disabled external functions from the node
*      to reduce attack surfaces as these functions should not be
*      called and cannot be called by the shell anyway.
*
* NOTE In Shell all node external functions are disabled. These will
*      be called on the node during a call therefore to reduce
*      exposure and attack vectors these are not to be used. The
*      internal functions can still be used as required.
*
* STANDARD When creating an implementation with shell prefix it as
*          sl ie. slToken. Ensure not to declare any additional
*          variables within an sl contract. These should be able to
*          be used interchangably with any node.
 */
contract Shell is Node {
    
    /**
    * @dev This error is fired when a function has been disabled.
    *      It can be used when there is an external function which
    *      is being used in an inherited contract is not longer
    *      required in the new contract.
     */
    error Disabled();

    /**
    * @dev This is disabled on the shell to minimize the risk of
    *      unexpected behaviours.
    *
    * NOTE Any calls forwarded from node will not call this function
    *      because it will be called within the node.
     */
    fallback() external payable virtual override {
        revert Disabled();
    }

    /**
    * @dev This is disabled on the shell to minimize the risk of
    *      unexpected behaviours.
    *
    * NOTE Any calls forwarded from node will not call this function
    *      because it will be called within the node.
     */
    receive() external payable virtual override {
        revert Disabled();
    }

    /**
    * @dev This is disabled on the shell to minimize the risk of
    *      unexpected behaviours.
    *
    * NOTE Any calls forwarded from node will not call this function
    *      because it will be called within the node.
     */
    function claim() external virtual override {
        revert Disabled();
    }

    /**
    * @dev This is disabled on the shell to minimize the risk of
    *      unexpected behaviours.
    *
    * NOTE Any calls forwarded from node will not call this function
    *      because it will be called within the node.
     */
    function upgradeTo(address newImplementation) external virtual override {
        revert Disabled();
    }

    /**
    * @dev This is disabled on the shell to minimize the risk of
    *      unexpected behaviours.
    *
    * NOTE Any calls forwarded from node will not call this function
    *      because it will be called within the node.
     */
    function transferOwnership(address newImplementation) external virtual override {
        revert Disabled();
    }

    /**
    * @dev Internal functions that can be used within the shell include:
    * 
    *      _upgradeTo
    *      _transferOwnership
    *      _onlyOwner
    *
    * NOTE It is possible to upgrade the node from the implementation
    *      by utilising the _upgradeTo function without permission
    *      of the owner. This can be used to add additional logic
    *      if required.
    *
    * NOTE It is possible to transfer ownership of the node from
    *      the implementation by utilising the _transferOwnership
    *      function without permission of the owner. This can be used
    *      to add additional logic if required.
     */
}