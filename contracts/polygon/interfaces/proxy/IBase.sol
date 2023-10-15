// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* NOTE: https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies
*
* implementationKey => address
* implementationTimelineKey => addressArray
* initialImplementationHasBeenSetKey => address
 */
interface IBase {

    /**
    * @dev Emitted when the contract is upgraded to a new implementation.
    * 
    * @param implementation The address of the new implementation contract.
    */
    event Upgraded(address indexed implementation);

    /**
    * @dev Returns the key used to store the address of the current implementation contract.
    */
    function implementationKey() external pure returns (bytes32);

    /**
    * @dev Returns the key used to store the timeline of implementation contracts.
    */
    function implementationTimelineKey() external pure returns (bytes32);

    /**
    * @dev Returns the key used to check if the initial implementation has been set.
    */
    function initialImplementationHasBeenSetKey() external pure returns (bool);

    /**
    * @dev Returns the current implementation address.
    */
    function implementation() external view returns (address);

    /**
    * @dev Returns the implementation address at a specific timeline point.
    * @param implementationId The index of the implementation in the timeline.
    */
    function implementationTimeline(uint256 implementationId) external view returns (address);

    /**
    * @dev Returns the number of implementations in the timeline.
    */
    function implementationTimelineLength() external view returns (uint256);

    /**
    * @dev Checks if the initial implementation has been set.
    */
    function initialImplementationHasBeenSet() external view returns (bool);

    /**
    * @dev Sets the initial implementation if it has not been set yet.
    * @param implementation The address of the initial implementation.
    */
    function setInitialImplementation(address implementation) external;
}