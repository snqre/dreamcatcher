// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IBase {
    event Upgraded(address indexed implementation);

    function implementationKey() external pure returns (bytes32);

    function implementationTimelineKey() external pure returns (bytes32);

    function initialImplementationKey() external pure returns (bytes32);

    function implementation() external view returns (address);

    function implementationTimeline(uint256 implementationId) external view returns (address);

    function implementationTimelineLength() external view returns (uint256);

    function initialImplementation() external view returns (address);

    function setInitialImplementation(address implementation) external;
}