// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/FoundationImplementation.sol";
import "contracts/polygon/abstract/utils/LowLevelCall.sol";

contract MultiSig is FoundationImplementation {

    /**
    * @dev Emitted when a new signer is added.
    * @param signer The address of the added signer. Indexed for efficient log filtering.
    */
    event SignerAdded(address indexed signer);

    /**
    * @dev Emitted when a signing action occurs.
    * @param signer The address of the signer. Indexed for efficient log filtering.
    */
    event Signed(address indexed signer);

    /**
    * @dev Emitted when a condition or step is successfully passed.
    * This event signifies the successful completion of a specific action or checkpoint.
    */
    event Passed();

    /**
    * @dev Emitted when an execution or operation is successfully completed.
    * This event signals the successful execution of a particular functionality or task.
    */
    event Executed();

    function ____requiredQuorum() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("REQUIRED_QUORUM"));
    }
    
}