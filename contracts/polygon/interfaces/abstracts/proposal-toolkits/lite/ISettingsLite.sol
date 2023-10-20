// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ISettingsLite {
    event RequiredQuorumUpdated(uint indexed previousRequiredQuorum, uint indexed newRequiredQuorum);

    event RequiredThresholdUpdated(uint indexed previousRequiredThreshold, uint indexed newRequiredThreshold);

    event GovernanceTokenUpdated(address indexed previousToken, address indexed newToken);

    event Snapped(uint indexed newSnapshotId);

    function requiredQuorum() external view returns (uint);

    function requiredThreshold() external view returns (uint);

    function governanceToken() external view returns (address);

    function snapshotId() external view returns (uint);
}