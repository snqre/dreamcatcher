// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";

interface IDreamToken is IERC20 {
    function getCurrentSnapshotId() external view returns (uint);
    function init() external;
    function snapshot() external returns (uint index);
}