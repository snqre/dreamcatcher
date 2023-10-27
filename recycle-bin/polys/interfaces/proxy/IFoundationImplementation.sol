// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/proxy/IFoundation.sol";
import "contracts/polygon/interfaces/utils/IInitializableLite.sol";
import "contracts/polygon/interfaces/access-control/IOwnableLite.sol";

interface IFoundationImplementation is IFoundation, IOwnableLite, IInitializableLite {

    /**
    * @dev Public function to initialize the contract.
    */
    function initialize() external;

    /**
    * @dev Public function to upgrade the contract's implementation.
    * @param implementation The address of the new implementation contract.
    */
    function upgrade(address implementation) external;
}