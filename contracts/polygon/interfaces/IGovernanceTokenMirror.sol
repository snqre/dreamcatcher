// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

interface IGovernanceTokenMirror {
    function stateName() external view returns (string memory);

    function stateSymbol() external view returns (string memory);

    function stateDecimals() external view returns (uint8);

    function stateTotalSupply() external view returns (uint256);

    function stateBalanceOf(address account) external view returns (uint256);

    function getCurrentSnapshotId() external view returns (uint256);

    function init() external returns (uint256);
}