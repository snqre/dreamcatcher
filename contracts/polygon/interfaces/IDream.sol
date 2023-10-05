// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

interface IDream is IERC20Metadata {
    function getCurrentSnapshotId() external view returns (uint256);

    function snapshot() external returns (uint256);

    function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256);

    function totalSupplyAt(uint256 snapshotId) external view returns (uint256);
}