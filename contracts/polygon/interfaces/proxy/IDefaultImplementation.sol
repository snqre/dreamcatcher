// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/proxy/IBase.sol";
import "contracts/polygon/interfaces/access-control/IOwnable.sol";
import "contracts/polygon/interfaces/security/IPausable.sol";

/**
* initializedKey => bool
 */
interface IDefaultImplementation is IBase, IOwnable, IPausable {
    
    /**
    * @dev Returns the key used to store the initialization status.
    */
    function initializedKey() external pure returns (bytes32);

    /**
    * @dev Returns whether the contract has been initialized.
    */
    function initialized() external view returns (bool);

    /**
    * @dev Upgrades the contract to a new implementation.
    * Can only be called by the owner.
    * @param implementation The address of the new implementation.
    */
    function upgrade(address implementation) external;

    /**
    * @dev Initializes the contract. 
    * Can only be called if the contract has not been initialized yet.
    */
    function initialize() external;
}