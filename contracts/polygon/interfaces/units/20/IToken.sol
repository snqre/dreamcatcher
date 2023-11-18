// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Permit.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol';

interface IToken is IERC20, IERC20Metadata, IERC20Permit {
    function mint(address account, uint amount) external;

    ///

    function getCurrentSnapshotId() external view returns (uint);
    function balanceOfAt(address account, uint snapshotId) external returns (uint);
    function totalSupplyAt(uint snapshotId) external returns (uint);
    function burn(uint amount) external;
    function burnFrom(address account, uint amount) external;
    function snapshot() external returns (uint);
}